class ParentalConsent < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :parent_email, presence: true, email_format: true
  validates :parent_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :terms_accepted, acceptance: { accept: true, message: 'must be accepted' }
  validates :consent_given, inclusion: { in: [true, false] }
  validate :user_must_be_minor

  # Callbacks
  before_save :set_consent_date
  after_update :notify_user_of_consent_status

  # Scopes
  scope :pending, -> { where(consent_given: false) }
  scope :approved, -> { where(consent_given: true) }
  scope :recent, -> { where('consent_date >= ?', 30.days.ago) }

  # Instance methods
  def status
    if consent_given?
      'approved'
    elsif consent_date.present?
      'pending'
    else
      'not_submitted'
    end
  end

  def can_be_approved?
    terms_accepted? && parent_email.present? && parent_name.present?
  end

  def approve!
    return false unless can_be_approved?
    update!(consent_given: true, consent_date: Time.current)
  end

  def revoke!
    update!(consent_given: false, consent_date: Time.current)
  end

  def send_consent_request_email
    # This would integrate with your email service
    # For now, we'll just log it
    Rails.logger.info "Sending consent request email to #{parent_email} for user #{user.full_name}"
  end

  def send_consent_approval_email
    Rails.logger.info "Sending consent approval email to #{parent_email} for user #{user.full_name}"
  end

  def send_consent_revocation_email
    Rails.logger.info "Sending consent revocation email to #{parent_email} for user #{user.full_name}"
  end

  def consent_expired?
    return false unless consent_date
    consent_date < 1.year.ago
  end

  def needs_renewal?
    consent_expired? || consent_date.nil?
  end

  private

  def set_consent_date
    self.consent_date = Time.current if consent_given_changed? && consent_given?
  end

  def notify_user_of_consent_status
    if consent_given_changed?
      if consent_given?
        send_consent_approval_email
      else
        send_consent_revocation_email
      end
    end
  end

  def user_must_be_minor
    return unless user
    unless user.minor?
      errors.add(:base, 'Parental consent can only be given for users under 18')
    end
  end
end
