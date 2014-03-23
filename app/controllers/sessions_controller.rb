class SessionsController < ApplicationController
  skip_before_filter :authorize_current_user

  def new
    @email = params[:email] || cookies.signed[:email]
  end

  def create
    @email = session_params(params)[:email]

    if user = User.authenticate(session_params(params))
      redirect_to login(user)
    else
      flash.now[:alert] = "Invalid email or password"
      render action: :new
    end
  end

  # Only used in testing env
  def backdoor
    reset_session
    unless Rails.env.production?
      session[:user_id] = params[:id]
      render nothing: true, status: 201
    end
  end

  protected

  def session_params(params)
    @session_params ||= params.require(:session).permit(
      :email,
      :password
    )
  end
end
