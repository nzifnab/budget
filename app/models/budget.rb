class Budget
  def new_account(params={})
    Account.new(params)
  end

  def accounts
    Account.all.order("accounts.enabled DESC, accounts.priority DESC")
  end

  def account(account_id)
    Account.find(account_id)
  end
end
