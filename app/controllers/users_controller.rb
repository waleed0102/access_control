class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:profile, :edit, :update]

  def profile
    # Profile action - user is already set by before_action
  end

  def edit
    # Edit profile action
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :date_of_birth, :organization_id)
  end
end
