class Budget
  def new_account(params={})
    Account.new(params)
  end

  def accounts
    Account.order{[
      accounts.enabled.desc,
      accounts.priority.desc,
      accounts.amount.desc
    ]}
  end

  def account(account_id)
    Account.find(account_id)
  end

  # TODO: Make sure this is properly scoped through user and/or account
  def quick_fund(quick_fund_id)
    QuickFund.find(quick_fund_id)
  end
end
