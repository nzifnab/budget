updatable = [[".js-category-sums", "category_sums/for_layout"]]
if income.errors[:amount].any?
  updatable << ["#income_#{income.id}", "incomes/income", {type: "replace", locals: {auto_open: income.id}}]
else
  updatable << ["#income_#{income.id}", nil, {type: "replace"}]
end

json.dynamicUpdate updatable do |attrs|
  options = attrs.last.is_a?(Hash) ? attrs.last : {}

  json.selector attrs.first
  json.html attrs[1] ? render(partial: attrs[1], formats: [:html], locals: options[:locals]) : ""
  json.updateType options[:type]
end
