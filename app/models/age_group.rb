class AgeGroup < ApplicationRecord
  # Associations
  has_many :participation_spaces, dependent: :destroy
  has_many :users

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :min_age, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 150 }
  validates :max_age, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 150 }
  validates :min_age, numericality: { less_than: :max_age }
  validates :max_age, numericality: { greater_than: :min_age }

  # Scopes
  scope :ordered, -> { order(:min_age) }
  scope :for_age, ->(age) { where('min_age <= ? AND max_age >= ?', age, age) }

  # Instance methods
  def age_range
    "#{min_age}-#{max_age}"
  end

  def includes_age?(age)
    age >= min_age && age <= max_age
  end

  def rules_hash
    return {} if participation_rules.blank?
    JSON.parse(participation_rules)
  rescue JSON::ParserError
    {}
  end

  def requires_parental_consent?
    rules_hash['requires_parental_consent'] || false
  end

  def content_filter_level
    rules_hash['content_filter_level'] || 'standard'
  end

  def allowed_activities
    rules_hash['allowed_activities'] || []
  end

  def restricted_activities
    rules_hash['restricted_activities'] || []
  end

  def time_restrictions
    rules_hash['time_restrictions'] || {}
  end

  def can_perform_activity?(activity)
    return false if restricted_activities.include?(activity)
    allowed_activities.empty? || allowed_activities.include?(activity)
  end

  def within_time_restrictions?
    return true if time_restrictions.empty?
    
    current_time = Time.current
    current_hour = current_time.hour
    
    # Check if current time is within allowed hours
    start_hour = time_restrictions['start_hour'] || 0
    end_hour = time_restrictions['end_hour'] || 23
    
    if start_hour <= end_hour
      current_hour >= start_hour && current_hour <= end_hour
    else
      # Handles overnight restrictions (e.g., 22:00 to 06:00)
      current_hour >= start_hour || current_hour <= end_hour
    end
  end

  def user_count
    users.count
  end

  def active_user_count
    users.active.count
  end

  # Class methods
  def self.default_groups
    [
      { name: 'Children (0-12)', min_age: 0, max_age: 12, 
        participation_rules: { requires_parental_consent: true, content_filter_level: 'strict', 
                              allowed_activities: ['educational', 'creative'], restricted_activities: ['social_media'],
                              time_restrictions: { start_hour: 6, end_hour: 20 } }.to_json },
      { name: 'Teens (13-17)', min_age: 13, max_age: 17,
        participation_rules: { requires_parental_consent: true, content_filter_level: 'moderate',
                              allowed_activities: ['educational', 'creative', 'social'], restricted_activities: ['adult_content'],
                              time_restrictions: { start_hour: 6, end_hour: 22 } }.to_json },
      { name: 'Young Adults (18-25)', min_age: 18, max_age: 25,
        participation_rules: { requires_parental_consent: false, content_filter_level: 'standard',
                              allowed_activities: ['all'], restricted_activities: [],
                              time_restrictions: {} }.to_json },
      { name: 'Adults (26-35)', min_age: 26, max_age: 35,
        participation_rules: { requires_parental_consent: false, content_filter_level: 'standard',
                              allowed_activities: ['all'], restricted_activities: [],
                              time_restrictions: {} }.to_json },
      { name: 'Middle-aged (36-50)', min_age: 36, max_age: 50,
        participation_rules: { requires_parental_consent: false, content_filter_level: 'standard',
                              allowed_activities: ['all'], restricted_activities: [],
                              time_restrictions: {} }.to_json },
      { name: 'Seniors (50+)', min_age: 50, max_age: 120,
        participation_rules: { requires_parental_consent: false, content_filter_level: 'standard',
                              allowed_activities: ['all'], restricted_activities: [],
                              time_restrictions: {} }.to_json }
    ]
  end
end
