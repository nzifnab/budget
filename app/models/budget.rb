class Budget
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def new_account(params={})
    user.accounts.build(params)
  end

  def accounts
    user.accounts.order{[
      accounts.enabled.desc,
      accounts.priority.desc,
      accounts.amount.desc
    ]}.includes(
      :negative_overflow_account,
      :prerequisite_account,
      :overflow_into_account
    )
  end

  def accounts_except(self_id)
    user.accounts.order{accounts.name.asc}.
      where{(id != self_id) & (enabled == true)}
  end

  def account(account_id)
    user.accounts.find(account_id)
  end

  # TODO: Make sure this is properly scoped through user and/or account
  def quick_fund(quick_fund_id)
    user.quick_funds.includes(account_histories: :account).find(quick_fund_id)
  end
end
