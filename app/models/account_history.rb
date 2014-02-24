class AccountHistory < ActiveRecord::Base
  belongs_to :account, inverse_of: :account_histories
  belongs_to :quick_fund, inverse_of: :account_histories
  # belongs_to :income, inverse_of: :account_histories
  belongs_to :overflow_from_account,
    class_name: "Account",
    foreign_key: "overflow_from_id"

  validate :steal_amount_validation_from_account
  before_validation :update_account_amount, on: :create
  before_create :save_account

  #before_validation :update_amount_based_on_type
#
  #attr_accessor :history_type
  attr_accessor :did_distribute_funds
#
  #protected
  #  # before_validation
  #  def update_amount_based_on_type
  #    if amount_changed? && history_type.to_s.downcase == "withdraw"
  #      self.amount *= -1
  #    end
  #  end

  protected

    # before_validation on: :create
    def update_account_amount
      unless did_distribute_funds
        self.did_distribute_funds = true
        account.amount = account.amount.to_d + amount.to_d
      end
    end

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
