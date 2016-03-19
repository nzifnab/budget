class IncomesController < ApplicationController
  decorates_assigned :income, :incomes

  def index
    @income = budget.new_income
    @incomes = budget.incomes.page(params[:page]).per_page(15)
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

  private

  def income_params
    params.require(:income).permit(
      :amount,
      :description
    )
  end
end
