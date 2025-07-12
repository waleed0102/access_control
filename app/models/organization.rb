class Organization < ApplicationRecord
  # Associations
  has_many :users, dependent: :nullify
  has_many :participation_spaces, dependent: :destroy
  has_many :organization_analytics, dependent: :destroy
  has_many :roles, as: :resource, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :domain, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}\z/ }
  validates :description, length: { maximum: 1000 }

  # Callbacks
  before_save :set_default_settings
  after_create :create_default_analytics

  # Scopes
  # Removed :active scope (was using confirmed_at)
  scope :by_domain, ->(domain) { where(domain: domain) }

  # Instance methods
  def member_count
    users.count
  end

  def active_member_count
    users.count # No confirmed_at, so just count all users
  end

  def admin_users
    users.joins(:roles).where(roles: { name: 'admin', resource_type: 'Organization', resource_id: id })
  end

  def moderator_users
    users.joins(:roles).where(roles: { name: 'moderator', resource_type: 'Organization', resource_id: id })
  end

  def member_users
    users.joins(:roles).where(roles: { name: 'member', resource_type: 'Organization', resource_id: id })
  end

  def age_distribution
    distribution = {}
    users.each do |user|
      age = user.age
      next unless age
      age_group = case age
                  when 0..12 then 'Children (0-12)'
                  when 13..17 then 'Teens (13-17)'
                  when 18..25 then 'Young Adults (18-25)'
                  when 26..35 then 'Adults (26-35)'
                  when 36..50 then 'Middle-aged (36-50)'
                  else 'Seniors (50+)'
                  end
      distribution[age_group] ||= 0
      distribution[age_group] += 1
    end
    distribution
  end

  def role_distribution
    {
      'admin' => admin_users.count,
      'moderator' => moderator_users.count,
      'member' => member_users.count
    }
  end

  def update_analytics!
    analytics = organization_analytics.first_or_initialize
    analytics.update!(
      total_members: member_count,
      active_members: active_member_count,
      age_distribution: age_distribution.to_json,
      role_distribution: role_distribution.to_json,
      last_updated: Time.current
    )
  end

  def settings_hash
    return {} if settings.blank?
    JSON.parse(settings)
  rescue JSON::ParserError
    {}
  end

  def minimum_age
    settings_hash['minimum_age'] || 0
  end

  def maximum_age
    settings_hash['maximum_age'] || 120
  end

  def requires_parental_consent?
    settings_hash['requires_parental_consent'] || false
  end

  def allowed_age_groups
    age_group_ids = settings_hash['allowed_age_group_ids'] || []
    AgeGroup.where(id: age_group_ids)
  end

  def can_join?(user)
    return false unless user.date_of_birth
    
    user_age = user.age
    return false unless user_age
    
    # Check age restrictions
    return false if user_age < minimum_age || user_age > maximum_age
    
    # Check age group restrictions
    if allowed_age_groups.any?
      user_age_group = user.age_group
      return false unless user_age_group && allowed_age_groups.include?(user_age_group)
    end
    
    # Check parental consent requirement
    if requires_parental_consent? && user.minor?
      return false unless user.parental_consent&.consent_given?
    end
    
    true
  end

  private

  def set_default_settings
    if settings.blank?
      self.settings = {
        minimum_age: 0,
        maximum_age: 120,
        requires_parental_consent: true,
        allowed_age_group_ids: []
      }.to_json
    end
  end

  def create_default_analytics
    organization_analytics.create!(
      total_members: 0,
      active_members: 0,
      age_distribution: '{}',
      role_distribution: '{}',
      last_updated: Time.current
    )
  end
end
