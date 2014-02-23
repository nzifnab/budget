class Account < ActiveRecord::Base
  include Draper::Decoratable

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

  before_save :default_amount_to_zero

  private

  # before_save
  def default_amount_to_zero
    unless amount.present?
      self.amount = 0
    end
  end
end
