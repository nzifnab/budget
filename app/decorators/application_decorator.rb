class ApplicationDecorator < Draper::Decorator
  def haml_object_ref
    model.class.to_s.underscore
  end
end
