class CategorySum < ActiveRecord::Base
  validates :name, presence: {
    message: "Required"
  }
end
