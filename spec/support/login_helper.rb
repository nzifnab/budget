module Budgeteer
  module LoginHelper
    def login(user=nil)
      self.current_user = user
      visit backdoor_login_path(current_user)
    end

    def current_user
      @current_user ||= User.create!(
        first_name: "Mittens",
        last_name: "The Cat",
        email: "mcat@example.net",
        password: "thepass",
        password_confirmation: "thepass"
      )
    end

    def current_user=(user)
      @current_user = user
    end
  end
end
