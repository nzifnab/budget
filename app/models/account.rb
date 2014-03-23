class Account < ActiveRecord::Base
  belongs_to(
    :negative_overflow_account,
    class_name: "Account",
    foreign_key: "negative_overflow_id"
  )
  has_many :account_histories, -> {order{created_at.desc}}, inverse_of: :account
  has_many :quick_funds, inverse_of: :account, validate: false
  belongs_to :user, inverse_of: :accounts

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

  before_save :default_amount_to_zero
  before_save :record_fund_change_amount
  after_create :update_self_negative_overflow

  validate :deny_negative_amount_with_no_overflow
  validate :cannot_overflow_to_disabled_account
  validate :cannot_receive_overflow_when_disabled
  validate :cannot_overflow_as_disabled_account
  validate :cannot_exceed_max_overflow_recursion

  MAX_OVERFLOW_RECURSION_COUNT = 3

  attr_accessor :fund_change

  def disabled?
    !enabled?
  end

  def reset_amount
    self.amount = amount_was
  end

  def fund_change
    (@fund_change ||= 0).to_f
  end

  def requires_negative_overflow?
    amount.to_d < 0 && negative_overflow_id && negative_overflow_id != self.id
  end

  def negative_overflowed_from_accounts
    Account.
      where{negative_overflow_id == my{id}}.
      where{negative_overflow_id != nil}.
      where{id != my{id}}
  end

  def negative_overflow_recursion_error?
    tester = nil
    if negative_overflow_id.present?
      tester = Account.where{id == my{self.negative_overflow_id}}

      last_account_alias = "accounts"
      # well this spiraled out of control...
      MAX_OVERFLOW_RECURSION_COUNT.times do |num|
        # Each 'join check' also has to consider the fact
        # that this is an unsaved record, so it checks for
        # joined records based on the unsaved value for this account,
        # or a regular join condition for other accounts.
        tester = tester.joins(
          """
          INNER JOIN accounts a#{num}
            ON (
              (
                #{last_account_alias}.id = #{self.id || 0}
                AND a#{num}.id = #{negative_overflow_id || 0}
              )
              OR (
                #{last_account_alias}.id != #{self.id || 0}
                AND #{last_account_alias}.negative_overflow_id = a#{num}.id
              )
            )
            AND (
              (
                #{last_account_alias}.id = #{self.id || 0}
                AND #{negative_overflow_id || 0} != #{last_account_alias}.id
              )
              OR (
                #{last_account_alias}.id != #{self.id || 0}
                AND #{last_account_alias}.negative_overflow_id != #{last_account_alias}.id
              )
            )
          """
        )
        last_account_alias = "a#{num}"
      end
    end
    tester && tester.exists?
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
      errors.add(:amount_extended, "Funds unavailable in account '#{name}'")
      errors.add(:negative_overflow_id, "Insufficient Funds")
      errors.add(:negative_overflow_id_extended, "Account '#{name_was}' has a negative balance already.")
    end
  end

  # validate
  def cannot_overflow_to_disabled_account
    if negative_overflow_account.present? && negative_overflow_account != self && negative_overflow_account.disabled?
      errors.add(:negative_overflow_id, "Invalid")
      errors.add(:negative_overflow_id_extended, "The account '#{negative_overflow_account.name}' has been disabled, and may not be selected.")
    end
  end

  # validate
  def cannot_receive_overflow_when_disabled
    if disabled? && negative_overflowed_from_accounts.size > 0
      errors.add(:enabled, "Invalid")
      errors.add(:enabled_extended, "The account '#{negative_overflowed_from_accounts.first.name}' is using this account as a negative overflow, so this account cannot be disabled.")
    end
  end

  # validate
  def cannot_overflow_as_disabled_account
    if disabled? && negative_overflow_id && negative_overflow_id != self.id && negative_overflow_id != 0
      errors.add(:negative_overflow_id, "Disabled")
      errors.add(:negative_overflow_id_extended, "Cannot set a negative overflow for a disabled account.")
    end
  end

  # validate
  def cannot_exceed_max_overflow_recursion
    if negative_overflow_recursion_error?
      basic_error = "Recursion Error"
      advanced_error = "Cannot overflow into more than #{MAX_OVERFLOW_RECURSION_COUNT} additional nested accounts"
      errors.add(:negative_overflow_id, basic_error)
      errors.add(:negative_overflow_id_extended, advanced_error)
      errors.add(:amount, basic_error)
      errors.add(:amount_extended, advanced_error)
    end
  end
end
