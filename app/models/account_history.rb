class AccountHistory < ActiveRecord::Base
  belongs_to :account, inverse_of: :account_histories
  belongs_to :quick_fund, inverse_of: :account_histories
  belongs_to :income, inverse_of: :account_histories
  belongs_to :overflow_from_account,
    class_name: "Account",
    foreign_key: "overflow_from_id"

  validate :steal_amount_validation_from_account
  before_create :save_account

  def amount=(val)
    super
    if new_record?
      self[:amount] = account.apply_history_amount(originator, val)
    end
    val
  end

  def originator
    if new_record?
      quick_fund || income
    else
      quick_fund_id ? quick_fund : income
    end
  end

  protected


    # validate
    def steal_amount_validation_from_account
      if !account.valid? && (errors_found = account.errors.messages[:amount]).present?
        errors.add(:amount, errors_found.first)
        errors.add(:amount_extended, account.errors.messages[:amount_extended].first)
      end
    end

    # validate
    def check_valid_account
      if !account.valid?
        errors.add(:account, "Error")
      end
    end

    # before_create
    def save_account
      account.save
    end
end
