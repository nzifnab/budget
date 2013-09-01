class AccountsController < ApplicationController
  def index
    @new_account = Account.new
  end
end
