class BudgetFormBuilder < ActionView::Helpers::FormBuilder
  def error_for(attribute)
    if object.present?
      errors = object.errors.messages[attribute]
      if errors.present?
        extended_error = object.errors.messages[:"#{attribute}_extended"]
        extended_error = extended_error.present? ? extended_error.first : "This field was invalid"
        @template.content_tag(:div, class: 'form-error', title: extended_error) do
          errors.first
        end
      end
    end
  end

  alias_method :budget_old_text_field, :text_field
  alias_method :budget_old_text_area, :text_area
  %w[text_field text_area].each do |method_name|
    define_method(method_name) do |method, *args|
      send("budget_old_#{method_name}", method, *args).concat error_for(method)
    end
  end

  alias_method :budget_old_collection_select, :collection_select
  def collection_select(method, *args)
    budget_old_collection_select(method, *args).concat error_for(method)
  end

  alias_method :budget_old_check_box, :check_box
  def check_box(method, *args)
    budget_old_check_box(method, *args).concat error_for(method)
  end
end
