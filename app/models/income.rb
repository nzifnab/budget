class Income < ActiveRecord::Base
  belongs_to :user, inverse_of: :incomes
  has_many :account_histories, ->{order(id: :asc)}, inverse_of: :income

  validates :amount, presence: {
    message: "Required"
  }, numericality: {
    greater_than_or_equal_to: 0,
    message: "Positive number only"
  }

  before_create :set_applied_at
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
    user.accounts.by_distribution_priority(self, from_account).each do |account|
      if account.priority < last_priority
        last_priority = account.priority
        priority_funds = funds
      end
      funds = account.apply_income_amount(
        income: self,
        funds: funds,
        priority_funds: priority_funds,
        desc_prefix: "Re-distributed from fulfilled prerequisite '#{from_account.name}' at priority level #{from_priority} with #{decorate.h.nice_currency(funds)} - ",
        redistribution: true
      )
    end
    funds
  end

  def build_history(account, funds, expl=nil)
    return unless funds > 0
    options = {
      account: account,
      explanation: expl,
      amount: funds,
      description: description
    }
    options[:created_at] = self.applied_at
    history = account_histories.create!(options)
    history
  end

  protected

    # before_create
    def set_applied_at
      self.applied_at ||= Time.zone.now
    end

    # after_create
    def build_account_histories
      distribute_funds(amount)
    end
end
