if @account.present?
  json.html render(template: 'account_histories/index', formats: [:html])
  json.accountNameShort account.truncated_name
  json.accountName account.name
end
