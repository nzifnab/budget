class BudgetFormBuilder < ActionView::Helpers::FormBuilder
  def error_for(attribute)
    if object.present?
      errors = object.errors.messages[attribute]
      if errors.present?
        extended_error = object.errors.messages[:"#{attribute}_extended"]
        extended_error = extended_error.present? ? extended_error.first : "This field was invalid"

        @template.content_tag(:div, class: 'form-error-container') do
          @template.content_tag(:div, class: 'form-error', title: extended_error) do
            errors.first
          end
        end
      end
    end
  end

  %w[
    text_field
    text_area
    email_field
    password_field
    collection_select
    check_box
    select
  ].each do |method_name|
    alias_method :"budget_old_#{method_name}", :"#{method_name}"

    define_method(method_name) do |method, *args|
      send("budget_old_#{method_name}", method, *args).concat error_for(method)
    end
  end
end
