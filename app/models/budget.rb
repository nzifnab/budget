class Budget
  attr_writer :account_source

  

  def new_account(*args)
    account_source.call(*args).tap do |a|
      a.budget = self
    end
  end

  def add_account(account)
    account.save
  end

  def accounts
    Account.all.order("accounts.enabled DESC, accounts.priority DESC")
  end

  private
  def account_source
    @account_source ||= Account.public_method(:new)
  end
end
