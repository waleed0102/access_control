class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :check_parental_consent
  before_action :set_current_user_organization

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :date_of_birth, :phone, :organization_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :date_of_birth, :phone, :organization_id])
  end

  def check_parental_consent
    return unless current_user&.requires_parental_consent?
    
    unless request.path.start_with?('/parental_consents', '/users/sign_out')
      redirect_to parental_consent_path, alert: 'Parental consent is required to continue.'
    end
  end

  def set_current_user_organization
    return unless current_user&.organization
    
    @current_organization = current_user.organization
  end

  def require_organization_membership
    unless current_user&.organization_member?
      redirect_to root_path, alert: 'You must be a member of an organization to access this feature.'
    end
  end

  def require_organization_admin
    unless current_user&.organization_admin?
      redirect_to root_path, alert: 'You must be an organization administrator to access this feature.'
    end
  end

  def require_organization_moderator
    unless current_user&.organization_admin? || current_user&.organization_moderator?
      redirect_to root_path, alert: 'You must be an organization moderator or administrator to access this feature.'
    end
  end

  def can_access_space?(participation_space)
    current_user&.can_access_space?(participation_space)
  end

  def require_space_access(participation_space)
    unless can_access_space?(participation_space)
      redirect_to root_path, alert: 'You do not have access to this participation space.'
    end
  end
end
