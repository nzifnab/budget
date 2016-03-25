class UsersController < ApplicationController
  decorates_assigned :user

  def edit
    @user = User.find(budget.user.id)
  end

  def update
    @user = User.find(budget.user.id)

    old_pass = params[:user].delete(:old_password)
    new_pass = params[:user].delete(:password)

    @user.attributes = user_params

    if @user.update_password(old_pass, new_pass) && @user.save
      redirect_to accounts_path, notice: "User updated"
    else
      render action: 'edit'
    end
  end

  protected

  def user_params
    params.require(:user).permit(
      :email
    )
  end
end
