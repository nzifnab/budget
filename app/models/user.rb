class User < ActiveRecord::Base
  has_many :accounts, inverse_of: :user
  has_many :quick_funds, through: :accounts
  has_many :incomes, inverse_of: :user
  has_many :category_sums, inverse_of: :user

  validates :first_name, :last_name, :email, presence: {message: "Required"}
  validates :email, uniqueness: {case_sensitive: false, message: "Already taken"}, email: {message: "Invalid format"}

  has_secure_password

  def self.authenticate(params)
    find_by_email(params[:email]).try(:authenticate, params[:password])
  end

  def update_last_login!
    self.last_login_at = Time.zone.now
    self.save!
  end

  def old_password
    nil
  end

  def update_password(old_pass, new_pass)
    return true if old_pass.blank? || new_pass.blank?

    if authenticate(old_pass) == self
      if old_pass == new_pass
        errors.add(:password, "Cannot use the same password")
        false
      else
        self.password = new_pass
        true
      end
    else
      errors.add(:old_password, "Incorrect Password")
      false
    end
  end
end
