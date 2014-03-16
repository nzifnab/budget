module ApplicationHelper
  def nice_date(date)
    date.strftime("%b %d, %Y")
  end

  def nice_datetime(datetime)
    return if datetime.blank?
    datetime.strftime("%b %d, %Y %r")
  end

  def nice_currency(currency)
    number_to_currency(currency, negative_format: "(%u%n)")
  end

  def amount_class(amount)
    if amount > 0
      'good'
    elsif amount < 0
      'bad'
    else
      'neutral'
    end
  end

  def pagination(collection)
    options = {
      previous_label: "&laquo;",
      next_label: "&raquo;",
      inner_window: 1,
      outer_window: 1,
      "data-remote" => true,
      renderer: AjaxLinkRenderer,
      "data-remote-content-fill" => ".sidebar-content"
    }
    will_paginate collection, options
  end
end
