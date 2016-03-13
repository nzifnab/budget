class IncomesController < ApplicationController
  decorates_assigned :income, :incomes

  def index
    @income = budget.new_income
    @incomes = budget.incomes
  end

  def create
    @income = budget.new_income(income_params)
    if @income.save
      @incomes = budget.incomes
      render action: 'show'
    else
      render action: 'new', status: :unprocessable_entity
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
