require 'ostruct'
class AccountsController < ApplicationController
  decorates_assigned :account, :accounts, :account_with_errors
  helper_method :negative_overflow_options, :select_account_options

  def index
    @account = budget.new_account(enabled: true)

    @accounts = budget.accounts
  end

  def create
    @account = budget.new_account(account_params(params))
    if @account.save
      render action: 'show'
    else
      render action: 'new', status: :unprocessable_entity
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
      @account_with_errors = @account
      @account = budget.account(params[:id])
      render action: 'edit', status: :unprocessable_entity
    end
  end

  protected

  def account_params(params)
    params.require(:account).permit(
      :name,
      :description,
      :priority,
      :enabled,
      :negative_overflow_id,
      :add_per_month,
      :add_per_month_type,
      #:monthly_cap,
      :cap,
      :prerequisite_account_id,
      :overflow_into_id
    )
  end

  def negative_overflow_options(self_id)
    @negative_overflow_options ||= select_account_options(self_id).
      unshift(OpenStruct.new(id: self_id || 0, truncated_name: "&mdash; Allow Negatives &mdash;".html_safe))
  end

  def select_account_options(self_id)
    @select_account_options ||= budget.accounts_except(self_id).decorate
  end
end
