class AccountsController < ApplicationController
  decorates_assigned :account, :accounts

  def index
    @account = budget.new_account

    unless budget.accounts.size > 0
      # here be dummy data
      account1 = budget.new_account
      account1.name = "Savings Account"
      account1.description = "Wells Fargo savings"
      account1.priority = 10
      account1.enabled = true
      account1.amount = 12
      account1.submit
  ##
      account2 = budget.new_account(name: "Insurance Payment")
      account2.description = "Allstate Insurance"
      account2.priority = 6
      account2.enabled = true
      account2.amount = -34.82
      account2.submit
  ##
      account3 = budget.new_account(
        name: "Checking Account",
        description: "Wells Fargo",
        priority: 7,
        enabled: false,
        amount: 0
      )
      account3.submit
    end

    @accounts = budget.accounts
  end

  def create
    @account = budget.new_account(params[:account])
    if @account.submit
      if request.xhr?
        render partial: 'accounts/account', locals: {account: account}
      else
        redirect_to accounts_path
      end
    else
      @accounts = budget.accounts
      render action: 'index'
    end
  end
end
