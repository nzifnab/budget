class ApplicationDecorator < Draper::Decorator
  def haml_object_ref
    model.respond_to?(:haml_object_ref) ? model.haml_object_ref : model.class.to_s.underscore
  end
end
