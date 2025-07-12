# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Organization.destroy_all
AgeGroup.destroy_all
Role.destroy_all

# Create Age Groups
puts "Creating age groups..."
age_groups = AgeGroup.default_groups.map do |group_data|
  AgeGroup.create!(group_data)
end

puts "Created #{age_groups.count} age groups:"
age_groups.each { |group| puts "  - #{group.name} (#{group.age_range})" }

# Create Sample Organizations
puts "\nCreating sample organizations..."

# Educational Organization
educational_org = Organization.create!(
  name: "Learning Academy",
  description: "A comprehensive educational platform for students of all ages",
  domain: "learningacademy.edu",
  settings: {
    minimum_age: 5,
    maximum_age: 25,
    requires_parental_consent: true,
    allowed_age_group_ids: age_groups.select { |g| g.min_age >= 5 && g.max_age <= 25 }.map(&:id)
  }.to_json
)

# Youth Club
youth_club = Organization.create!(
  name: "Youth Innovation Club",
  description: "A creative space for young innovators and entrepreneurs",
  domain: "youthinnovation.org",
  settings: {
    minimum_age: 13,
    maximum_age: 25,
    requires_parental_consent: true,
    allowed_age_group_ids: age_groups.select { |g| g.min_age >= 13 && g.max_age <= 25 }.map(&:id)
  }.to_json
)

# Professional Network
professional_org = Organization.create!(
  name: "Professional Network Hub",
  description: "A networking platform for professionals and career development",
  domain: "prohub.com",
  settings: {
    minimum_age: 18,
    maximum_age: 65,
    requires_parental_consent: false,
    allowed_age_group_ids: age_groups.select { |g| g.min_age >= 18 }.map(&:id)
  }.to_json
)

puts "Created #{Organization.count} organizations:"
Organization.all.each { |org| puts "  - #{org.name} (#{org.domain})" }

# Create Participation Spaces for each organization
puts "\nCreating participation spaces..."
[educational_org, youth_club, professional_org].each do |org|
  ParticipationSpace.create_default_spaces(org)
  puts "  Created #{org.participation_spaces.count} spaces for #{org.name}"
end

# Create Sample Users
puts "\nCreating sample users..."

# Admin user
admin_user = User.create!(
  email: "admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "User",
  date_of_birth: 25.years.ago,
  phone: "+15551234567",
  organization: educational_org
)
admin_user.add_role(:admin, educational_org)
puts "  Created admin user: #{admin_user.email}"

# Teen user (requires parental consent)
teen_user = User.new(
  email: "teen@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Alex",
  last_name: "Johnson",
  date_of_birth: 15.years.ago,
  phone: "+15551234568",
  organization: youth_club
)
teen_user.skip_parental_consent_validation = true
teen_user.save!
teen_user.add_role(:member, youth_club)
teen_user.parental_consent.update!(
  parent_name: "Sarah Johnson",
  parent_email: "sarah@example.com",
  consent_given: true,
  terms_accepted: true
)
puts "  Created teen user: #{teen_user.email} (with parental consent)"

# Child user (requires parental consent)
child_user = User.new(
  email: "child@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Emma",
  last_name: "Smith",
  date_of_birth: 10.years.ago,
  phone: "+15551234569",
  organization: educational_org
)
child_user.skip_parental_consent_validation = true
child_user.save!
child_user.add_role(:member, educational_org)
child_user.parental_consent.update!(
  parent_name: "Michael Smith",
  parent_email: "michael@example.com",
  consent_given: false,
  terms_accepted: true
)
puts "  Created child user: #{child_user.email} (pending parental consent)"

# Adult user
adult_user = User.create!(
  email: "adult@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "David",
  last_name: "Wilson",
  date_of_birth: 28.years.ago,
  phone: "+15551234570",
  organization: professional_org
)
adult_user.add_role(:member, professional_org)
puts "  Created adult user: #{adult_user.email}"

# Senior user
senior_user = User.create!(
  email: "senior@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Margaret",
  last_name: "Brown",
  date_of_birth: 55.years.ago,
  phone: "+15551234571",
  organization: professional_org
)
senior_user.add_role(:moderator, professional_org)
puts "  Created senior user: #{senior_user.email} (moderator)"

# Generate analytics for organizations
puts "\nGenerating analytics..."
Organization.all.each do |org|
  org.update_analytics!
  puts "  Generated analytics for #{org.name}"
end

puts "\nSeed data created successfully!"
puts "\nSample login credentials:"
puts "  Admin: admin@example.com / password123"
puts "  Teen: teen@example.com / password123"
puts "  Child: child@example.com / password123"
puts "  Adult: adult@example.com / password123"
puts "  Senior: senior@example.com / password123"
