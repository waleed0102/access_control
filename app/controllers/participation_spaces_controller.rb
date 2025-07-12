class ParticipationSpacesController < ApplicationController
  before_action :set_participation_space, only: [:show, :edit, :update, :destroy]
  before_action :require_organization_membership
  before_action :check_space_access, only: [:show]
  before_action :require_organization_moderator, only: [:new, :create, :edit, :update, :destroy]

  def index
    @participation_spaces = current_user.organization.participation_spaces.includes(:age_group)
  end

  def show
    @participants = @participation_space.participant_list
    @analytics_data = @participation_space.analytics_data
    @can_perform_activities = @participation_space.allowed_activities
    @restricted_activities = @participation_space.restricted_activities
  end

  def new
    @participation_space = ParticipationSpace.new
    @age_groups = AgeGroup.ordered
  end

  def create
    @participation_space = ParticipationSpace.new(participation_space_params)
    @participation_space.organization = current_user.organization
    
    if @participation_space.save
      redirect_to @participation_space, notice: 'Participation space was successfully created.'
    else
      @age_groups = AgeGroup.ordered
      render :new
    end
  end

  def edit
    @age_groups = AgeGroup.ordered
  end

  def update
    if @participation_space.update(participation_space_params)
      redirect_to @participation_space, notice: 'Participation space was successfully updated.'
    else
      @age_groups = AgeGroup.ordered
      render :edit
    end
  end

  def destroy
    @participation_space.destroy
    redirect_to participation_spaces_url, notice: 'Participation space was successfully deleted.'
  end

  private

  def set_participation_space
    @participation_space = ParticipationSpace.find(params[:id])
  end

  def participation_space_params
    params.require(:participation_space).permit(:name, :description, :age_group_id, :is_active, :access_rules)
  end

  def check_space_access
    require_space_access(@participation_space)
  end
end
