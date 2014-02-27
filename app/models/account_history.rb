class AccountHistory < ActiveRecord::Base
  belongs_to :account, inverse_of: :account_histories
  belongs_to :quick_fund, inverse_of: :account_histories
  # belongs_to :income, inverse_of: :account_histories
  belongs_to :overflow_from_account,
    class_name: "Account",
    foreign_key: "overflow_from_id"

  validate :steal_amount_validation_from_account
  before_create :save_account

  def amount=(val)
    self[:amount] = val
    if new_record?
      account.amount = account.amount.to_d + amount.to_d
      if account.requires_negative_overflow?
        remaining_funds = account.amount
        self[:amount] = self[:amount] - remaining_funds
        account.amount = 0

        quick_fund.distribute_funds(remaining_funds, account.negative_overflow_account)
      end
    end
    val
  end

  protected


    # validate
    def steal_amount_validation_from_account
      if !account.valid? && (errors_found = account.errors.messages[:amount]).present?
        errors.add(:amount, errors_found.first)
      end
    end

    # before_create
    def save_account
      account.save
    end
end
