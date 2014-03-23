class Budget
  def initialize(user)
    @user = user
  end

  def new_account(params={})
    Account.new(params)
  end

  def accounts
    Account.order{[
      accounts.enabled.desc,
      accounts.priority.desc,
      accounts.amount.desc
    ]}.includes(
      :negative_overflow_account
    )
  end

  def negative_overflowable_accounts(self_id)
    Account.order{accounts.name.asc}.
      where{(id != self_id) & (enabled == true)}
  end

  def account(account_id)
    Account.find(account_id)
  end

  # TODO: Make sure this is properly scoped through user and/or account
  def quick_fund(quick_fund_id)
    QuickFund.includes(account_histories: :account).find(quick_fund_id)
  end
end
