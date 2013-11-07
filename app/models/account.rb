class Account < ActiveRecord::Base
  include Draper::Decoratable

  attr_accessor :budget

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

  before_save :default_amount_to_zero

  def submit
    return false unless valid?
    self.created_at = Time.now
    !!budget.add_account(self)
  end

  private

  def default_amount_to_zero
    unless amount.present?
      self.amount = 0
    end
  end
end
