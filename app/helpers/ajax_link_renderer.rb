class AjaxLinkRenderer < WillPaginate::ActionView::LinkRenderer

  def link(text, target, attributes={})
    attributes["data-remote"] = true
    attributes["data-disable-with"] = ""
    super(text, target, attributes)
  end
end
