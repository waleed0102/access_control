class ParentalConsentsController < ApplicationController
  before_action :set_parental_consent
  before_action :ensure_minor_user

  def show
    # Show current consent status
  end

  def edit
    # Allow editing consent information
  end

  def update
    if @parental_consent.update(parental_consent_params)
      if @parental_consent.consent_given?
        redirect_to root_path, notice: 'Parental consent has been approved. You can now access all features.'
      else
        redirect_to @parental_consent, notice: 'Parental consent information has been updated.'
      end
    else
      render :edit
    end
  end

  private

  def set_parental_consent
    @parental_consent = current_user.parental_consent
    redirect_to root_path, alert: 'Parental consent not found.' unless @parental_consent
  end

  def ensure_minor_user
    unless current_user.minor?
      redirect_to root_path, alert: 'Parental consent is only required for users under 18.'
    end
  end

  def parental_consent_params
    params.require(:parental_consent).permit(:parent_email, :parent_name, :consent_given, :terms_accepted)
  end
end
