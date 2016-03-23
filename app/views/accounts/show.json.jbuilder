json.partial! "accounts/account", account: account
json.html render(partial: 'accounts/account', locals: {account: account}, formats: [:html])

if new_form_account.present?
  json.newFormHtml render(partial: 'accounts/new_account', locals: {account: new_form_account}, formats: [:html])
end

json.dynamicUpdate [
  [".js-category-sums", "category_sums/for_layout"]
] do |attrs|
  json.selector attrs.first
  json.html render(partial: attrs.last, formats: [:html])
end
