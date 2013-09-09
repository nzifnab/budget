module ApplicationHelper
  def nice_date(date)
    date.strftime("%b %d, %Y")
  end
end
