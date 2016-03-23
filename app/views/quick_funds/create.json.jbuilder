json.accounts quick_fund.account_histories.map(&:account) do |account|
  json.partial! "accounts/account", account: account
  json.html render(partial: 'accounts/account', locals: {account: account.decorate}, formats: [:html])
end
json.auto_open @account.id

json.dynamicUpdate [
  [".js-category-sums", "category_sums/for_layout"]
] do |attrs|
  json.selector attrs.first
  json.html render(partial: attrs.last, formats: [:html])
end
