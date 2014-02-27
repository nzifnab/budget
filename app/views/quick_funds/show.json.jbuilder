json.accounts quick_fund.account_histories.map(&:account) do |account|
  json.partial! "accounts/account", account: account
  json.html render(partial: 'accounts/account', locals: {account: account.decorate}, formats: [:html])
end
json.auto_open @account.id
