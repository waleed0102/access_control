class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy, :analytics]
  before_action :require_organization_admin, only: [:edit, :update, :destroy, :analytics]

  def index
    @organizations = Organization.all
  end

  def show
    @members = @organization.users.includes(:roles)
    @participation_spaces = @organization.participation_spaces.includes(:age_group)
    @analytics = @organization.organization_analytics.first
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    
    if @organization.save
      # Create default participation spaces
      ParticipationSpace.create_default_spaces(@organization)
      
      # Add current user as admin
      current_user.add_role(:admin, @organization)
      current_user.update(organization: @organization)
      
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully deleted.'
  end

  def analytics
    @analytics = @organization.organization_analytics.first_or_initialize
    @analytics = OrganizationAnalytic.generate_analytics_for_organization(@organization)
    
    @age_distribution = @analytics.age_distribution_hash
    @role_distribution = @analytics.role_distribution_hash
    @participation_spaces_data = @organization.participation_spaces.map(&:analytics_data)
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :domain, :settings)
  end
end
