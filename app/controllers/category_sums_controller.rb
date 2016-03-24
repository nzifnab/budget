class CategorySumsController < ApplicationController
  decorates_assigned :category

  def destroy
    @category = budget.category_sum(params[:id])

    if @category.destroy
      render action: 'destroy'
    else
      render json: {error: "Category could not be destroyed: #{category.errors.full_messages.inspect}"}.to_json, status: :unprocessable_entity
    end
  end
end
