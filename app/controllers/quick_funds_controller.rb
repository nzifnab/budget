class QuickFundsController < ApplicationController
  decorates_assigned :account, :quick_fund

  def create
    @account = budget.account(params[:account_id])
    @quick_fund = @account.quick_funds.build(fund_params(params))

    if @quick_fund.save
      render action: 'show'
    else
      @account.reset_amount
      render action: 'new', status: :unprocessable_entity
    end
  end

  protected

    def fund_params(params)
      params.require(:quick_fund).permit(
        :amount,
        :description
      ).merge(fund_type: params[:fund_type])
    end
end
