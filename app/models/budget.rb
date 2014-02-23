class Budget
  def new_account(params={})
    Account.new(params)
  end

  def accounts
    Account.all.order("accounts.enabled DESC, accounts.priority DESC")
  end
end
