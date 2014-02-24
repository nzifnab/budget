class BudgetFormBuilder < ActionView::Helpers::FormBuilder
  def error_for(attribute)
    if object.present?
      errors = object.errors.messages[attribute]
      if errors.present?
        @template.content_tag(:div, class: 'form-error', title: "This field was invalid") do
          errors.first
        end
      end
    end
  end

  alias_method :old_text_field, :text_field
  alias_method :old_text_area, :text_area
  %w[text_field text_area].each do |method_name|
    define_method(method_name) do |method, *args|
      send("old_#{method_name}", method, *args).concat error_for(method)
    end
  end
end
