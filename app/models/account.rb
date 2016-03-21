class Account < ActiveRecord::Base
  belongs_to(
    :negative_overflow_account,
    class_name: "Account",
    foreign_key: "negative_overflow_id"
  )
  belongs_to(
    :prerequisite_account,
    class_name: "Account"
  )
  belongs_to(
    :overflow_into_account,
    class_name: "Account",
    foreign_key: "overflow_into_id"
  )
  belongs_to :user, inverse_of: :accounts
  has_many :account_histories, -> {order(created_at: :desc)}, inverse_of: :account
  has_many :quick_funds, inverse_of: :account, validate: false
  has_many(
    :overflowed_from_accounts,
    class_name: "Account",
    foreign_key: "overflow_into_id"
  )

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}
  validates :add_per_month_type, presence: {
    message: "Required",
    if: ->{ add_per_month.present?}
  }, inclusion: {
    in: ['%', '$'],
    allow_blank: true,
    message: "'%' or '$' only"
  }
  validates :add_per_month, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true,
    message: "Positive number only",
    if: ->{add_per_month_type == '$'}
  }
  validates :add_per_month, numericality: {
    less_than_or_equal_to: 100,
    greater_than_or_equal_to: 0,
    allow_blank: true,
    message: "0% to 100%",
    if: ->{add_per_month_type == '%'}
  }

  before_save :default_amount_to_zero
  before_save :record_fund_change_amount
  after_create :update_self_negative_overflow

  validate :deny_negative_amount_with_no_overflow
  validate :cannot_overflow_to_disabled_account
  validate :cannot_receive_overflow_when_disabled
  #validate :cannot_overflow_as_disabled_account
  validate :cannot_exceed_max_overflow_recursion

  MAX_OVERFLOW_RECURSION_COUNT = 3

  attr_accessor :fund_change

  def self.enabled
    where(enabled: true)
  end

  # More reasons this belongs in a background job...
  def self.by_distribution_priority(prerequisite_account=nil)
    accounts = enabled.order(priority: :desc)
      .order("accounts.cap ASC NULLS LAST")
      .order(id: :asc)

    if prerequisite_account
      accounts = accounts.where(prerequisite_account_id: prerequisite_account.id).
        where("""
          (priority >= :priority) OR
          (priority = :priority AND cap < :cap) OR
          (priority = :priority AND cap >= :cap AND accounts.id < :id) OR
          (priority = :priority AND cap IS NULL AND :cap IS NULL AND accounts.id < :id)
        """,
          priority: prerequisite_account.priority,
          cap: prerequisite_account.cap,
          id: prerequisite_account.id
        )
    end
    accounts
  end

  def disabled?
    !enabled?
  end

  def allow_negative?
    if negative_overflow_id.present?
      negative_overflow_id == 0 || negative_overflow_id == self.id
    else
      negative_overflow_account == self
    end
  end

  def reset_amount
    self.amount = amount_was
  end

  def fund_change
    (@fund_change ||= 0).to_f
  end

  def requires_negative_overflow?
    amount.to_d < 0 && negative_overflow_id && !allow_negative?
  end

  def prereq_fulfilled?
    return true unless prerequisite_account
    return false if !prerequisite_account.cap
    prerequisite_account.amount >= prerequisite_account.cap
  end

  # TODO: PERFORMANCE: Cache amount_received_this_month/year
  # on account, with a cached_date for the earliest recorded
  # value so it knows if it needs to bust the cache.
  # Otherwise this is gonna be some wonky 2(n+1) queries.
  # ALTERNATIVELY: Collect this data all in one go
  # before distribution iteration begins. But that might
  # have to happen when i refactor distribution into it's own class:
  # IncomeDistribution.
  # ALTERNATIVELY: Do distribution in the background... of course,
  # that'll require a running worker :(
  def amount_received_this_month
    date = @income_applied_at || Time.zone.now
    account_histories.where(
      "created_at BETWEEN :start_of_month AND :end_of_month",
      start_of_month: date.beginning_of_month,
      end_of_month: date.end_of_month
    ).
      where("income_id IS NOT NULL").
      sum(:amount)
  end

  def amount_received_this_year
    date = @income_applied_at || Time.zone.now
    account_histories.where(
      "created_at BETWEEN :start_of_year AND :end_of_year",
      start_of_year: date.beginning_of_year,
      end_of_year: date.end_of_year
    ).
      where("income_id IS NOT NULL").
      sum(:amount)
  end

  def month_amount_remaining
    # Returns Infinity if there is no monthly_cap for a %
    val = percentage? ? monthly_cap.presence : add_per_month.to_d
    val ? [0, val - amount_received_this_month].max : "Infinity".to_d
  end

  def year_amount_remaining
    annual_cap ? [0, annual_cap.to_d - amount_received_this_year].max : "Infinity".to_d
  end

  def monthly_amount(amount_at_start_of_priority)
    if percentage?
      amount_at_start_of_priority * (add_per_month.to_d / 100.to_d)
    else
      add_per_month.to_d
    end
  end

  def cash?
    !percentage?
  end

  def percentage?
    add_per_month_type == '%'
  end

  # TODO: HACK: Make this distribution code it's own class,
  # which can, in the class, handle this explanation messaging.
  # Really doesn't belong here.
  def amount_to_use(funds, priority_funds)
    @excess_funds = nil
    # Cannot exceed per_month amount
    funds_to_add = monthly_amount(priority_funds)
    monthly_remaining = month_amount_remaining
    yearly_remaining = year_amount_remaining
    compare_vals = []
    compare_vals << {val: funds}
    compare_vals << {val: funds_to_add}
    compare_vals << {
      val: monthly_remaining,
      expl: if percentage? && monthly_remaining < funds_to_add
        "#{decorate.h.nice_currency(monthly_cap)} monthly cap"
      elsif cash? && monthly_remaining < funds_to_add
        "#{decorate.h.nice_currency(add_per_month - monthly_remaining)} previously added this month"
      end
    }
    # Cannot exceed annual cap
    compare_vals << {
      val: yearly_remaining,
      expl: "#{decorate.h.nice_currency(annual_cap)} annual cap"
    }
    # Cannot exceed the cap
    if cap
      compare_vals << {
        expl: "#{decorate.display_cap} cap",
        val: [0, (cap - amount)].max
      }
    end

    explanation_and_val = compare_vals.min_by{|a| a[:val]}
    expl = explanation_and_val[:expl]
    @expl << " (#{expl})" if @expl && expl
    val = explanation_and_val[:val]

    @excess_funds = [monthly_remaining, funds_to_add, funds].compact.min - val
    @excess_funds = nil if @excess_funds <= 0

    val
  end

  def negative_overflowed_from_accounts
    Account.
      where(negative_overflow_id: self.id).
      where.not(negative_overflow_id: nil).
      where.not(id: self.id)
  end

  def apply_history_amount(quick_fund_or_income, val)
    history_amount = val.to_d
    self.amount = self.amount.to_d + history_amount

    if requires_negative_overflow?
      remaining_funds = self.amount
      history_amount -= remaining_funds
      self.amount = 0

      quick_fund_or_income.distribute_funds(remaining_funds, negative_overflow_account)
    end
    history_amount
  end

  # Returns the unused funds
  def apply_income_amount(income:, funds:, priority_funds:, desc_prefix: "")
    deco = self.decorate
    @expl = "#{desc_prefix}Distributed at priority level #{priority}: #{deco.display_add_per_month} per month of #{deco.h.nice_currency(priority_funds)} funds"
    @income_applied_at = income.applied_at
    if prereq_fulfilled?
      funds_to_distribute = amount_to_use(funds, priority_funds)
      # Don't re-distribute to accounts where this was a prerequisite,
      # if this account was already capped.
      check_fulfilled_prerequisites = (cap || "Infinity".to_d) > amount
      self.amount += funds_to_distribute
      save!
      income.build_history(
        self, funds_to_distribute,
        @expl
      )
      funds -= funds_to_distribute

      if @excess_funds && overflow_into_account.try(:enabled?)
        funds -= @excess_funds
        @excess_funds = overflow_into_account.apply_overflow_amount(
          income: income,
          from_account: self,
          funds: @excess_funds,
          from_priority: priority
        )
        funds += @excess_funds
      end

      # If this account has excess funds to distribute, hit the cap,
      # and has now fulfilled the prerequisites of other accounts...
      if @excess_funds && cap && amount >= cap && check_fulfilled_prerequisites
        funds -= @excess_funds
        @excess_funds = income.distribute_via_prerequisite(
          from_account: self,
          funds: @excess_funds,
          from_priority: priority
        )
        funds += @excess_funds
      end
    end
    funds
  end

  # Returns the unused funds
  def apply_overflow_amount(income:, from_account:, funds:, from_priority:)
    desc = "Distributed at priority level #{from_priority}: #{decorate.h.nice_currency(funds)} (Overflowed from '#{from_account.name}'"
    funds_to_distribute = if cap && (funds + amount) > cap
      desc << ", #{decorate.h.nice_currency(cap)} cap"
      cap - amount
    else
      funds
    end

    self.amount += funds_to_distribute
    save!
    desc << ")"
    income.build_history(
      self, funds_to_distribute,
      desc
    )
    funds -= funds_to_distribute

    if funds > 0 && overflow_into_account
      funds = overflow_into_account.apply_overflow_amount(
        income: income,
        from_account: self,
        funds: funds,
        from_priority: from_priority
      )
    end
    funds
  end

  def negative_overflow_recursion_error?
    tester = false
    if negative_overflow_id.present?
      tester = Account.where(id: self.negative_overflow_id)

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
    if amount.to_d < 0 && !allow_negative?
      errors.add(:amount, "Insufficient Funds")
      errors.add(:amount_extended, "Funds unavailable in account '#{name}'")
      errors.add(:negative_overflow_id, "Insufficient Funds")
      errors.add(:negative_overflow_id_extended, "Account '#{name_was}' has a negative balance already.")
    end
  end

  # validate
  def cannot_overflow_to_disabled_account
    if !allow_negative? && negative_overflow_account.present? && negative_overflow_account.disabled?
      errors.add(:negative_overflow_id, "Invalid")
      errors.add(:negative_overflow_id_extended, "The account '#{negative_overflow_account.name}' has been disabled, and may not be selected.")
    end

    if overflow_into_account.present? && overflow_into_account.disabled?
      errors.add(:overflow_into_id, "Invalid")
      errors.add(:overflow_into_id_extended, "The account '#{overflow_into_account.name}' has been disabled, and may not be selected.")
    end

    # Can't income_overflow into self either.
    if overflow_into_account == self
      errors.add(:overflow_into_id, "Invalid")
      errors.add(:overflow_into_id_extended, "An account cannot have income overflow into itself.")
    end
  end

  # validate
  def cannot_receive_overflow_when_disabled
    if disabled? && negative_overflowed_from_accounts.size > 0
      errors.add(:enabled, "Invalid")
      errors.add(:enabled_extended, "The account '#{negative_overflowed_from_accounts.first.name}' is using this account as a negative overflow, so this account cannot be disabled.")
    end

    if disabled? && overflowed_from_accounts.size > 0
      errors.add(:enabled, "Invalid")
      errors.add(:enabled_extended, "The account '#{overflowed_from_accounts.first.name}' is using this account as an overflow, so this account cannot be disabled.")
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
