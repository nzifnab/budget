require 'ostruct'
class AccountsController < ApplicationController
  decorates_assigned :account, :accounts
  helper_method :negative_overflow_options

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

  def update
    @account = budget.account(params[:id])

    if @account.update_attributes(account_params(params))
      render action: 'show'
    else
      render partial: 'edit'
    end
  end

  protected

  def account_params(params)
    params.require(:account).permit(
      :name,
      :description,
      :priority,
      :enabled,
      :negative_overflow_id
    )
  end

  def negative_overflow_options(self_id)
    [
      OpenStruct.new(id: self_id || 0, name: ">> Allow Negatives"),
      *budget.accounts.where{id != self_id}
    ]
  end
end
