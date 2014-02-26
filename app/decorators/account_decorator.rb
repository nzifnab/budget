class AccountDecorator < Draper::Decorator
  delegate_all

  def prioritized_name
    "(#{model.priority}) #{model.name}"
  end

  def amount_class
    h.amount_class(model.amount)
  end

  def display_amount
    h.nice_currency(model.amount)
  end

  def display_fund_change
    h.nice_currency(model.fund_change)
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
