class Account < ActiveRecord::Base
  include Draper::Decoratable
  belongs_to(
    :negative_overflow_account,
    class_name: "Account",
    foreign_key: "negative_overflow_id"
  )

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

  before_save :default_amount_to_zero
  after_create :update_self_negative_overflow

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
end
