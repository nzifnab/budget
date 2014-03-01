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
      "Negative overflow"
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

  def js_sort_parts
    num = []
    # This is intended to be sorted as a string,
    # alphabetically.  NOT NUMERICALLY.
    # sort by enabled first...
    if enabled?
      num << "1"
    else
      num << "0"
    end

    # Next sort by priority - left-padded with 0's
    num << ("%02d" % priority.to_i)

    a = amount.to_d
    # Now... '1' for positive, '0' for negative
    num << (a < 0 ? "0" : "1")

    if a < 0
      # We have to invert negative numbers
      # because they count backwards...
      a = -a * 100
      a_size = ("%.0f" % a).size
      max_for_size = "9"*a_size
      a = max_for_size.to_i - a
    else
      a = a * 100
    end

    # Next grab the *length* of amount with exactly 2 decimals
    # so that larger amounts are sorted first
    num << "%02d" % ("%.0f" % a).size

    # Finally sort by amount itself - different sized numbers
    # won't matter because they would have already been sub-filtered
    # by the length check
    num << ("%.0f" % a)
  end

  def js_sort_weight
    js_sort_parts.join("")
  end
end
