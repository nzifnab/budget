class AccountHistoriesController < ApplicationController
  decorates_assigned :account_histories, :account

  def index
    if params[:account_id].present?
      @account = budget.account(params[:account_id])
      @account_histories = @account.account_histories.
        preload(:quick_fund).page(params[:page]).per_page(15)
    else
      @account_histories = budget.account_histories.
        preload(:quick_fund).page(params[:page]).per_page(15)
    end
    render layout: !request.xhr?
  end
end
