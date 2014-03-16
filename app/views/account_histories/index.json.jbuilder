json.html render(template: 'account_histories/index', formats: [:html])
if @account.present?
  json.accountNameShort account.truncated_name
  json.accountName account.name
end
