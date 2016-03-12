class Budget
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def new_account(params={})
    user.accounts.build(params)
  end

  def new_income(params={})
    user.incomes.build(params)
  end

  def accounts
    user.accounts.order(
      enabled: :desc,
      priority: :desc,
      amount: :desc
    ).preload(
      :negative_overflow_account,
      :prerequisite_account,
      :overflow_into_account
    )
  end

  def accounts_except(self_id)
    user.accounts.order(name: :asc).
      where(
        "id != :self_id AND enabled = :true",
        self_id: self_id,
        true: true
      )
  end

  def account(account_id)
    user.accounts.find(account_id)
  end

  def quick_fund(quick_fund_id)
    user.quick_funds.preload(account_histories: :account).find(quick_fund_id)
  end
end
