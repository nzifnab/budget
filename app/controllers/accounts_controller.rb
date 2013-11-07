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
    @account = budget.new_account(account_params(params))
    if @account.submit
      respond_to do |format|
        format.json do
          render 'show'
        end
      end
    else
      respond_to do |format|
        format.json do
          render partial: 'accounts/form', status: :unprocessable_entity
        end
      end
    end
  end

  protected

  def account_params(params)
    params.require(:account).permit(
      :name,
      :description,
      :priority,
      :enabled,
      :negative_overflows_into_id
    )
  end
end
