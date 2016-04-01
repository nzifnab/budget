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
      :overflow_into_account,
      :category_sum
    )
  end

  def accounts_except(self_id)
    accounts = user.accounts.order(name: :asc)
      .where(enabled: true)

    if self_id
      accounts = accounts.
        where(
          "id != :self_id",
          self_id: self_id
        )
    end
    accounts
  end

  def account_histories
    income_history = AccountHistory.joins(:income).
      where("incomes.user_id = :user_id", user_id: user.id)
    quick_fund_history = AccountHistory.joins(:quick_fund => :account).
      where("accounts.user_id = :user_id", user_id: user.id)

    # Hmm, yay union.
    # http://stackoverflow.com/questions/21996653/postgres-left-outer-join-appears-to-not-be-using-table-indices/21996913?noredirect=1#comment33338427_21996913
    AccountHistory.from((income_history).union(:all,
      quick_fund_history).to_sql + " AS account_histories"
    ).order(created_at: :desc, id: :desc)
  end

  def incomes
    user.incomes.order(
      applied_at: :desc
    ).preload(
      account_histories: :account
    )
  end

  def income(income_id)
    user.incomes.preload(account_histories: :account).find(income_id)
  end

  def account(account_id)
    user.accounts.find(account_id)
  end

  def quick_fund(quick_fund_id)
    user.quick_funds.preload(account_histories: :account).find(quick_fund_id)
  end

  def category_sums
    user.category_sums
  end

  def category_sum(category_id)
    user.category_sums.find(category_id)
  end
end
