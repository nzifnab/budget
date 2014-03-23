class User < ActiveRecord::Base
  has_many :accounts, inverse_of: :user

  has_secure_password
end
