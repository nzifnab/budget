json.html render(template: 'account_histories/index', formats: [:html])
if @account.present?
  json.accountNameShort truncate(account.name, length: 16)
  json.accountName account.name
end
