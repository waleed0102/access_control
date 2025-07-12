class OrganizationAnalytic < ApplicationRecord
  # Associations
  belongs_to :organization

  # Validations
  validates :total_members, numericality: { greater_than_or_equal_to: 0 }
  validates :active_members, numericality: { greater_than_or_equal_to: 0 }
  validates :last_updated, presence: true

  # Scopes
  scope :recent, -> { where('last_updated >= ?', 7.days.ago) }
  scope :by_organization, ->(org_id) { where(organization_id: org_id) }

  # Instance methods
  def age_distribution_hash
    return {} if age_distribution.blank?
    JSON.parse(age_distribution)
  rescue JSON::ParserError
    {}
  end

  def role_distribution_hash
    return {} if role_distribution.blank?
    JSON.parse(role_distribution)
  rescue JSON::ParserError
    {}
  end

  def member_activity_rate
    return 0 if total_members.zero?
    (active_members.to_f / total_members * 100).round(2)
  end

  def growth_rate(previous_analytics)
    return 0 unless previous_analytics
    previous_total = previous_analytics.total_members
    return 0 if previous_total.zero?
    
    ((total_members - previous_total).to_f / previous_total * 100).round(2)
  end

  def top_age_group
    age_distribution_hash.max_by { |_, count| count }&.first
  end

  def dominant_role
    role_distribution_hash.max_by { |_, count| count }&.first
  end

  def analytics_summary
    {
      total_members: total_members,
      active_members: active_members,
      activity_rate: "#{member_activity_rate}%",
      top_age_group: top_age_group,
      dominant_role: dominant_role,
      last_updated: last_updated.strftime('%B %d, %Y at %I:%M %p')
    }
  end

  def generate_report
    {
      overview: {
        total_members: total_members,
        active_members: active_members,
        activity_rate: member_activity_rate,
        last_updated: last_updated
      },
      demographics: {
        age_distribution: age_distribution_hash,
        top_age_group: top_age_group
      },
      roles: {
        role_distribution: role_distribution_hash,
        dominant_role: dominant_role
      },
      participation_spaces: organization.participation_spaces.map(&:analytics_data)
    }
  end

  # Class methods
  def self.generate_analytics_for_organization(organization)
    analytics = organization.organization_analytics.first_or_initialize
    
    analytics.update!(
      total_members: organization.member_count,
      active_members: organization.active_member_count,
      age_distribution: organization.age_distribution.to_json,
      role_distribution: organization.role_distribution.to_json,
      last_updated: Time.current
    )
    
    analytics
  end

  def self.generate_all_analytics
    Organization.all.each do |organization|
      generate_analytics_for_organization(organization)
    end
  end
end
