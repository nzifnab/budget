class User < ActiveRecord::Base
  has_many :accounts, inverse_of: :user

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: {case_sensitive: false}, email: true

  has_secure_password
end
