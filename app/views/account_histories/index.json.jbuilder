json.html render(template: 'account_histories/index', formats: [:html])
json.accountNameShort account.try(:truncated_name) || "Transaction History"
json.accountName account.try(:truncated_name) || "Transaction History"
