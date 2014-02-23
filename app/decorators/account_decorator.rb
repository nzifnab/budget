class AccountDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  delegate_all

  def prioritized_name
    "(#{object.priority}) #{object.name}"
  end

  def amount_class
    if object.amount > 0
      'good'
    elsif object.amount < 0
      'bad'
    else
      'neutral'
    end
  end

  def display_amount
    number_to_currency(object.amount, negative_format: "(%u%n)")
  end

  def formatted_created_at
    nice_date(object.created_at)
  end
end
