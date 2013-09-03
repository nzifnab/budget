module Budgeteer
  module RequestHelper
    def open_accordion(accordion_text)
      accordion = find_accordion(accordion_text)
      accordion[:header].click

      accordion
    end

    def find_accordion(accordion_text)
      header = find(".accordion-header", text: accordion_text)
      ui_id = header[:id].match(/ui\-accordion\-(\d)\-header\-([\d])/)
      content = find("#ui-accordion-#{ui_id[1]}-panel-#{ui_id[2]}", visible: false)
      {header: header, content: content}
    end
  end
end
