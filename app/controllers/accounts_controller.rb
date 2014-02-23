class AccountsController < ApplicationController
  decorates_assigned :account, :accounts

  def index
    @account = budget.new_account

    @accounts = budget.accounts
  end

  def create
    @account = budget.new_account(account_params(params))
    if @account.save
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
