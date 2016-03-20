json.partial! "accounts/account", account: account
json.html render(partial: 'accounts/account', locals: {account: account}, formats: [:html])

if new_form_account.present?
  json.newFormHtml render(partial: 'accounts/new_account', locals: {account: new_form_account}, formats: [:html])
end
