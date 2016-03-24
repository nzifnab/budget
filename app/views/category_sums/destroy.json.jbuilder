json.dynamicUpdate [
  [".js-category-sums", "category_sums/for_layout"],
  ["[data-category-id=#{category.id}]", ""]
] do |attrs|
  json.selector attrs.first
  json.html attrs.last.present? ? render(partial: attrs.last, formats: [:html]) : ""
end
