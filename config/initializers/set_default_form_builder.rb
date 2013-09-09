#module Budgeteer
#  class Application
    #config.action_view.default_form_builder = BudgetFormBuilder
#    ActionView::Base.default_form_builder = BudgetFormBuilder
#  end
#end

module ActionView
  module Helpers
    module FormHelper
      def form_for_with_bootstrap(record, options = {}, &proc)
        options[:builder] = BudgetFormBuilder
        form_for_without_bootstrap(record, options, &proc)
      end
 
      def fields_for_with_bootstrap(record_name, record_object = nil, options = {}, &block)
        options[:builder] = BudgetFormBuilder
        fields_for_without_bootstrap(record_name, record_object, options, &block)
      end
 
      alias_method_chain :form_for, :bootstrap
      alias_method_chain :fields_for, :bootstrap
    end
  end
end
