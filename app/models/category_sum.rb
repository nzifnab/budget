class CategorySum < ActiveRecord::Base
  belongs_to :user, inverse_of: :category_sums
  has_many :accounts, inverse_of: :category_sums

  validates :name, presence: {
    message: "Required"
  }
end
