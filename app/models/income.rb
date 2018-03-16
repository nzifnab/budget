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
  before_destroy :destroy_account_histories

  attr_accessor :skip_distribution

  def distribute_funds(funds)
    last_priority = 11
    priority_funds = funds

    # Since distributing into one account can potentially change the
    # amounts/values in the next account, we should just do a single query
    # for each account that is going to be looped over...
    account_ids = user.accounts.by_distribution_priority.map(&:id)


    account_ids.each do |account_id|
      account = Account.find(account_id)
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
    account_ids = user.accounts.by_distribution_priority(self, from_account).map(&:id)
    account_ids.each do |account_id|
      account = Account.find(account_id)
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
      distribute_funds(amount) unless skip_distribution
    end

    # before_destroy
    def destroy_account_histories
      success = true
      account_histories.each do |hist|
        if !hist.destroy
          errors.add(:amount, hist.errors.messages[:amount].first)
          errors.add(:amount_extended, hist.errors.messages[:amount_extended].first)
          success = false
        end
      end
      success
    end
end
