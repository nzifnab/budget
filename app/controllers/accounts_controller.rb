class AccountsController < ApplicationController
  decorates_assigned :account, :accounts

  def index
    @account = budget.new_account

    @accounts = budget.accounts
  end

  def create
    @account = budget.new_account(account_params(params))
    if @account.save
      render action: 'show'
    else
      render partial: 'accounts/new_account', status: :unprocessable_entity
    end
  end

  def edit
    @account = budget.account(params[:id])

    render layout: !request.xhr?
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
