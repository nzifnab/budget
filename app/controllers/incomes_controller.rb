class IncomesController < ApplicationController
  decorates_assigned :income

  def index
    @income = budget.new_income
  end

  def create
  end
end
