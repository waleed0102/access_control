class DashboardController < ApplicationController
  def index
    if current_user.organization_member?
      @organization = current_user.organization
      @participation_spaces = @organization.participation_spaces.active.includes(:age_group)
      @accessible_spaces = @participation_spaces.select { |space| current_user.can_access_space?(space) }
      @analytics = @organization.organization_analytics.first
      
      # User-specific data
      @user_age_group = current_user.age_group
      @user_roles = current_user.roles.where(resource: @organization)
      @requires_consent = current_user.requires_parental_consent?
      
      # Organization statistics
      @total_members = @organization.member_count
      @active_members = @organization.active_member_count
      @age_distribution = @organization.age_distribution
      @role_distribution = @organization.role_distribution
    else
      @organizations = Organization.all
    end
  end
end
