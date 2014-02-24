class QuickFund < ActiveRecord::Base
  # The base account that the quick fund was made from,
  # even if overall funds were taken from several sources.
  belongs_to :account, inverse_of: :quick_funds
  has_many :account_histories, inverse_of: :quick_fund

  validates :amount, presence: {message: "Required"}
  validates :amount, numericality: {greater_than: 0, message: "Positive number only"}

  before_validation :build_account_history, on: :create
  validate :steal_amount_validation_from_history

  protected

    # before_validation on: :create
    def build_account_history
      account_histories.build(
        account: account,
        amount: fund_type.to_s.downcase == "withdraw" ? -amount.to_d : amount.to_d,
        description: description
      )
    end

    # validate
    def steal_amount_validation_from_history
      err_history = account_histories.detect{|hist|
        hist.errors.messages[:amount].present?
      }
      if err_history.present?
        errors.add(:amount, err_history.errors.messages[:amount].first)
      end
    end
end