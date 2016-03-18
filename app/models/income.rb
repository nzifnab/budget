class Income < ActiveRecord::Base
  belongs_to :user, inverse_of: :incomes
  has_many :account_histories, inverse_of: :income

  before_create :build_account_histories

  def distribute_funds(funds)
    last_priority = 11
    priority_funds = funds
    user.accounts.by_distribution_priority.each do |account|
      if account.priority < last_priority
        last_priority = account.priority
        priority_funds = funds
      end
      funds = account.apply_income_amount(
        income: self,
        funds: funds,
        priority_funds: priority_funds
      )
    end
    build_history(nil, funds)
  end

  def build_history(account, funds)
    return unless funds > 0
    history = account_histories.build(
      account: account,
      description: description
    )
    history.amount = funds
    history
  end

  protected

    # before_create
    def build_account_histories
      distribute_funds(amount)
    end
end
