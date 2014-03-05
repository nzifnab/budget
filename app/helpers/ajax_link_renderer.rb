class AjaxLinkRenderer < WillPaginate::ActionView::LinkRenderer

  def link(text, target, attributes={})
    attributes["data-remote"] = true
    attributes["data-disable-with"] = text
    super(text, target, attributes)
  end

  def previous_or_next_page(page, text, classname)
    if page
      link(text, page, class: "#{classname} btn btn-green btn-pad-less pagination")
    else
      tag(:span, text, class: "#{classname} btn btn-pad-less btn-disabled pagination")
    end
  end

  def page_number(page)
    if page == current_page
      tag(:em, page, class: 'btn btn-pad-less btn-disabled pagination')
    else
      link(page, page, rel: rel_value(page), class: "btn btn-green btn-pad-less pagination")
    end
  end
end
