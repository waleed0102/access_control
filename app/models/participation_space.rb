class ParticipationSpace < ApplicationRecord
  # Associations
  belongs_to :age_group
  belongs_to :organization

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :is_active, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_organization, ->(org_id) { where(organization_id: org_id) }
  scope :by_age_group, ->(age_group_id) { where(age_group_id: age_group_id) }

  # Instance methods
  def access_rules_hash
    return {} if access_rules.blank?
    JSON.parse(access_rules)
  rescue JSON::ParserError
    {}
  end

  def required_roles
    access_rules_hash['required_roles'] || ['member']
  end

  def max_participants
    access_rules_hash['max_participants']
  end

  def current_participant_count
    # This would count actual participants in the space
    # For now, we'll return a placeholder
    0
  end

  def has_available_space?
    return true unless max_participants
    current_participant_count < max_participants
  end

  def allowed_activities
    access_rules_hash['allowed_activities'] || []
  end

  def restricted_activities
    access_rules_hash['restricted_activities'] || []
  end

  def content_filter_level
    access_rules_hash['content_filter_level'] || age_group.content_filter_level
  end

  def time_restrictions
    access_rules_hash['time_restrictions'] || age_group.time_restrictions
  end

  def can_user_access?(user)
    return false unless is_active?
    return false unless user.organization_id == organization_id
    return false unless has_available_space?
    
    # Check age group access
    user_age_group = user.age_group
    return false unless user_age_group && user_age_group.id == age_group_id
    
    # Check role-based access
    has_required_role = required_roles.any? do |role|
      user.has_role?(role, organization)
    end
    return false unless has_required_role
    
    # Check time restrictions
    return false unless within_time_restrictions?
    
    # Check parental consent for minors
    if user.minor? && age_group.requires_parental_consent?
      return false unless user.parental_consent&.consent_given?
    end
    
    true
  end

  def can_perform_activity?(user, activity)
    return false unless can_user_access?(user)
    return false if restricted_activities.include?(activity)
    allowed_activities.empty? || allowed_activities.include?(activity)
  end

  def within_time_restrictions?
    return true if time_restrictions.empty?
    
    current_time = Time.current
    current_hour = current_time.hour
    
    start_hour = time_restrictions['start_hour'] || 0
    end_hour = time_restrictions['end_hour'] || 23
    
    if start_hour <= end_hour
      current_hour >= start_hour && current_hour <= end_hour
    else
      current_hour >= start_hour || current_hour <= end_hour
    end
  end

  def participant_list
    # This would return actual participants
    # For now, return users who can access this space
    organization.users.select { |user| can_user_access?(user) }
  end

  def analytics_data
    {
      total_accessible_users: organization.users.count,
      accessible_users: participant_list.count,
      age_group: age_group.name,
      content_filter_level: content_filter_level,
      time_restrictions: time_restrictions,
      allowed_activities: allowed_activities,
      restricted_activities: restricted_activities
    }
  end

  # Class methods
  def self.create_default_spaces(organization)
    AgeGroup.all.each do |age_group|
      create!(
        name: "#{age_group.name} Space",
        description: "Participation space for #{age_group.name}",
        age_group: age_group,
        organization: organization,
        is_active: true,
        access_rules: {
          required_roles: ['member'],
          max_participants: 100,
          allowed_activities: age_group.allowed_activities,
          restricted_activities: age_group.restricted_activities,
          content_filter_level: age_group.content_filter_level,
          time_restrictions: age_group.time_restrictions
        }.to_json
      )
    end
  end
end
