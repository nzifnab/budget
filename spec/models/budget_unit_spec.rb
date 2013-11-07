require 'spec_helper'

describe Budget do
  let(:budget){Budget.new}

  it "has no accounts" do
    budget.accounts.should be_empty
  end

  describe "#new_account" do
    let(:new_account){OpenStruct.new}
    before(:each) do
      budget.account_source = ->{ new_account }
    end

    it "returns a new account" do
      budget.new_account.should == new_account
    end

    it "sets the account's budget reference to itself" do
      budget.new_account.budget.should == budget
    end

    it "accepts an attribute hash to create the account" do
      account_source = mock(:account)
      account_source.should_receive(:call).with(x: 42, y: 'z').and_return(new_account)
      budget.account_source = account_source
      budget.new_account(x: 42, y: 'z')
    end
  end

  describe "#add_account" do
    it "adds the account to your budget" do
      account = stub(:account).as_null_object
      account.should_receive(:save).and_return(true)
      budget.add_account(account).should be_true
    end
  end
end
