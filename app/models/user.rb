class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Allow bypassing parental consent validation (for seeds/tests)
  attr_accessor :skip_parental_consent_validation

  # Associations
  belongs_to :organization, optional: true
  has_one :parental_consent, dependent: :destroy
  has_many :participation_spaces, through: :organization

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :date_of_birth, presence: true
  validates :email, presence: true, email_format: true
  validates :phone, phony_plausible: true, allow_blank: true
  validate :age_appropriate_for_organization
  validate :parental_consent_required_for_minors, unless: :skip_parental_consent_validation

  # Callbacks
  before_save :normalize_phone
  after_create :assign_default_role
  after_create :create_parental_consent_if_minor

  # Scopes
  scope :by_age_group, ->(min_age, max_age) { 
    where(date_of_birth: max_age.years.ago..min_age.years.ago) 
  }
  scope :with_organization, -> { where.not(organization_id: nil) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return nil unless date_of_birth
    now = Time.current.to_date
    now.year - date_of_birth.year - (date_of_birth.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def minor?
    age && age < 18
  end

  def adult?
    age && age >= 18
  end

  def age_group
    return nil unless age
    AgeGroup.where('min_age <= ? AND max_age >= ?', age, age).first
  end

  def can_access_space?(participation_space)
    return false unless participation_space.is_active?
    return false unless organization_id == participation_space.organization_id
    
    # Check age group access
    user_age_group = age_group
    return false unless user_age_group && user_age_group.id == participation_space.age_group_id
    
    # Check role-based access
    has_role?(:admin, participation_space.organization) || 
    has_role?(:moderator, participation_space.organization) ||
    has_role?(:member, participation_space.organization)
  end

  def requires_parental_consent?
    minor? && !parental_consent&.consent_given?
  end

  def organization_member?
    organization_id.present?
  end

  def organization_admin?
    has_role?(:admin, organization)
  end

  def organization_moderator?
    has_role?(:moderator, organization)
  end

  private

  def normalize_phone
    self.phone = PhonyRails.normalize_number(phone, country_code: 'US') if phone.present?
  end

  def assign_default_role
    add_role(:member, organization) if organization
  end

  def create_parental_consent_if_minor
    if minor? && !parental_consent
      create_parental_consent(
        parent_email: '',
        parent_name: '',
        consent_given: false,
        terms_accepted: false
      )
    end
  end

  def age_appropriate_for_organization
    return unless organization && date_of_birth
    
    org_settings = organization.settings.present? ? JSON.parse(organization.settings) : {}
    min_age = org_settings['minimum_age'] || 0
    max_age = org_settings['maximum_age'] || 120
    
    user_age = age
    if user_age && (user_age < min_age || user_age > max_age)
      errors.add(:date_of_birth, "Age #{user_age} is not within the organization's allowed range (#{min_age}-#{max_age})")
    end
  end

  def parental_consent_required_for_minors
    return unless minor?
    
    unless parental_consent&.consent_given?
      errors.add(:base, "Parental consent is required for users under 18")
    end
  end
end
