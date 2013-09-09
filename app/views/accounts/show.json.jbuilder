json.accountId account.id
json.html render(partial: 'accounts/account', locals: {account: account}, formats: [:html])
json.priority account.priority
json.enabled account.enabled?
