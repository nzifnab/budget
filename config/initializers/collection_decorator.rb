module Draper
  class CollectionDecorator
    delegate :current_page, :per_page, :offset, :total_entries, :total_pages
  end
end
