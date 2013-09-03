class AccountDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
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
end
