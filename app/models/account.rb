class Account < ActiveRecord::Base
  belongs_to(
    :negative_overflow_account,
    class_name: "Account",
    foreign_key: "negative_overflow_id"
  )
  has_many :account_histories, inverse_of: :account
  has_many :quick_funds, inverse_of: :account, validate: false

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

  before_save :default_amount_to_zero
  before_save :record_fund_change_amount
  after_create :update_self_negative_overflow

  validate :deny_negative_amount_with_no_overflow

  attr_accessor :fund_change

  def reset_amount
    self.amount = amount_was
  end

  def fund_change
    (@fund_change ||= 0).to_f
  end

  def requires_negative_overflow?
    amount.to_d < 0 && negative_overflow_id && negative_overflow_id != self.id
  end

  private

  # before_save
  def default_amount_to_zero
    unless amount.present?
      self.amount = 0
    end
  end

  # before_save
  def record_fund_change_amount
    @fund_change = self.amount.to_d - self.amount_was.to_d
  end

  # after_create
  def update_self_negative_overflow
    update_attributes(negative_overflow_id: self.id) if negative_overflow_id == 0
  end

  # validate
  def deny_negative_amount_with_no_overflow
    if amount.to_d < 0 && negative_overflow_id != self.id
      errors.add(:amount, "Insufficient Funds")
      errors.add(:negative_overflow_id, "Insufficient Funds")
    end
  end
end
