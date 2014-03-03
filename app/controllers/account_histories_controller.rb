class AccountHistoriesController < ApplicationController
  decorates_assigned :account_histories, :account

  def index
    if params[:account_id].present?
      @account = budget.account(params[:account_id])
      @account_histories = @account.account_histories
    end
  end
end
