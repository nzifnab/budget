class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize_current_user
  before_filter :initialize_category_sums
  helper_method :current_user

  decorates_assigned :category_sums

  protected
    def budget
      @budget ||= Budget.new(current_user)
    end

    def current_user
      if session[:user_id]
        @current_user ||= User.find(session[:user_id])
      end
    end

    def login(user, default_path=accounts_path)
      original_destination_or_default = session[:return_to_path] || default_path

      # Prevents session hijacking and fixation.
      # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
      reset_session

      update_last_login(user)
      session[:user_id] = user.id
      cookies.permanent.signed[:email] = user.email

      original_destination_or_default
    end

    def update_last_login(user)
      user.update_last_login!
    end

    def authorize_current_user
      unless current_user
        reset_session
        save_return_to_path
        redirect_to session_path, notice: "Please log in"
      end
    end

    def initialize_category_sums
      if current_user
        @category_sums = budget.category_sums
      end
    end

    def save_return_to_path
      session[:return_to_path] = request.fullpath if request.get?
    end
end
