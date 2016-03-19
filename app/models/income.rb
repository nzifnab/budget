class Income < ActiveRecord::Base
  belongs_to :user, inverse_of: :incomes
  has_many :account_histories, inverse_of: :income

  after_create :build_account_histories

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
    build_history(nil, funds, "Undistributed Funds")
    funds
  end

  def distribute_via_prerequisite(from_account:, funds:, from_priority:)
    last_priority = 11
    priority_funds = funds
    user.accounts.by_distribution_priority(from_account).each do |account|
      if account.priority < last_priority
        last_priority = account.priority
        priority_funds = funds
      end
      funds = account.apply_income_amount(
        income: self,
        funds: funds,
        priority_funds: priority_funds,
        desc_prefix: "Re-distributed from fulfilled prerequisite '#{from_account.name}' at priority level #{from_priority} with #{decorate.h.nice_currency(funds)} - "
      )
    end
    funds
  end

  def build_history(account, funds, expl=nil)
    return unless funds > 0
    history = account_histories.create!(
      account: account,
      explanation: expl,
      amount: funds
    )
    history
  end

  protected

    # after_create
    def build_account_histories
      distribute_funds(amount)
    end
end
