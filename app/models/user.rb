class User < ActiveRecord::Base
  has_many :accounts, inverse_of: :user
  has_many :quick_funds, through: :accounts
  has_many :incomes, inverse_of: :user
  has_many :category_sums, inverse_of: :user

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: {case_sensitive: false}, email: true

  has_secure_password

  def self.authenticate(params)
    find_by_email(params[:email]).try(:authenticate, params[:password])
  end

  def update_last_login!
    self.last_login_at = Time.zone.now
    self.save!
  end
end
