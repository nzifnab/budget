class AccountHistoriesController < ApplicationController
  decorates_assigned :account_histories, :account

  def index
    if params[:account_id].present?
      @account = budget.account(params[:account_id])
      @account_histories = @account.account_histories.page(params[:page]).per_page(10)
    end
  end
end
