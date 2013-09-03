class Budget
  attr_writer :account_source

  def initialize
    @accounts = []
  end

  def new_account(*args)
    account_source.call(*args).tap do |a|
      a.budget = self
    end
  end

  def add_account(account)
    @accounts << account
  end

  def accounts
    @accounts.sort{|a,b|
      if a.enabled? == b.enabled?
        b.priority <=> a.priority
      else
        b.enabled? ? 1 : -1
      end
    }
  end

  private
  def account_source
    @account_source ||= Account.public_method(:new)
  end
end
