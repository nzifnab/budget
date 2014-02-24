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
  after_create :update_self_negative_overflow

  validate :deny_negative_amount_with_no_overflow

  # TODO:  fund withdraw/deposit needs to be a method on account
  # that will add/remove the funds and go through any required
  # overflow accounts and modify them as well - then save them,
  # record proper errors, and return all modified accounts in a nice
  # array for the controller to give to the jbuilder.  Maybe this should
  # be an intermediary class FundChange or AccountFund that handles this
  # stuff.
  #def new_history(params={})
  #  history = account_histories.build(params)
  #end
  #def modify_amount(params={})
  #  if params[:history_type].to_s.downcase == "withdraw"
  #    params[:amount] = params[:amount].to_d * -1
  #  end
#
  #  funds = []
#
  #end

  def reset_amount
    self.amount = amount_was
  end

  private

  # before_save
  def default_amount_to_zero
    unless amount.present?
      self.amount = 0
    end
  end

  # after_create
  def update_self_negative_overflow
    update_attributes(negative_overflow_id: self.id) if negative_overflow_id == 0
  end

  # validate
  def deny_negative_amount_with_no_overflow
    if amount.to_d < "0".to_d && !negative_overflow_id
      errors.add(:amount, "Insufficient Funds")
    end
  end
end
