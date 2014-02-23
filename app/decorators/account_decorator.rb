class AccountDecorator < Draper::Decorator
  delegate_all

  def prioritized_name
    "(#{model.priority}) #{model.name}"
  end

  def amount_class
    if model.amount > 0
      'good'
    elsif model.amount < 0
      'bad'
    else
      'neutral'
    end
  end

  def display_amount
    h.number_to_currency(model.amount, negative_format: "(%u%n)")
  end

  def formatted_created_at
    h.nice_date(model.created_at)
  end

  def negative_overflow_label
    if !negative_overflow_id || negative_overflow_id == model.id
      "Negatives allowed?"
    else
      "Negatives overflow into"
    end
  end

  def negative_overflow_name
    if !negative_overflow_id
      "No"
    elsif negative_overflow_id == model.id
      "Yes"
    else
      negative_overflow_account.name
    end
  end
end
