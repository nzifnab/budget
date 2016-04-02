class IncomesController < ApplicationController
  decorates_assigned :income, :incomes, :account

  def index
    @income = budget.new_income
    @incomes = budget.incomes.page(params[:page]).per_page(15)

    if request.xhr?
      render partial: 'incomes/sidebar', locals: {incomes: incomes}, layout: false
    end
  end

  def create
    @income = budget.new_income(income_params)
    if @income.save
      @incomes = budget.incomes.page(params[:page]).per_page(15)
      redirect_to incomes_path(income_id: @income.id)
    else
      @incomes = budget.incomes.page(params[:page]).per_page(15)
      render action: 'index', status: :unprocessable_entity
    end
  end

  # From accounts#index when looking at history
  # of a specific account, you can view the entire income
  # from a single income history event
  def show
    @income = budget.income(params[:id])
    @account = budget.account(params[:account_id])
    render layout: !request.xhr?
  end

  def destroy
    @income = budget.income(params[:id])
    @income.destroy
  end

  private

  def income_params
    params.require(:income).permit(
      :amount,
      :description,
      :applied_at
    )
  end
end
