module ApplicationHelper

  def flash_messages
    messages = []
    flash.each do |key, value|
      messages << content_tag(:div, class: "flash flash-#{key}") do
        value
      end
    end
    messages.join("\n").html_safe
  end

  def nice_date(date)
    date.strftime("%b %d, %Y")
  end

  def nice_datetime(datetime)
    return if datetime.blank?
    datetime.strftime("%b %d, %Y %r")
  end

  def datepicker_date(date)
    return if date.blank?
    date.strftime("%B %d, %Y")
  end

  def nice_currency(currency)
    currency ||= 0
    number_to_currency(currency, negative_format: "(%u%n)")
  end

  def nice_percent(value)
    number_to_percentage(value, precision: 2)
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
      "data-remote-content-fill" => ".js-sidebar-content"
    }
    will_paginate collection, options
  end

  def current_action?(*action_strings)
    cur_action = "#{controller.controller_name}##{controller.action_name}"

    action_strings.include?(cur_action)
  end
end
