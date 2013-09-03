require 'spec_helper_lite'
require_relative '../../app/models/budget'

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
      budget.add_account(account)
      budget.accounts.should include(account)
    end
  end

  describe "#accounts" do
    def stub_account_with_priority(val, params={})
      OpenStruct.new(params.merge(priority: val))
    end
    it "sorts with highest priority first" do
      lowest = stub_account_with_priority(4)
      middle = stub_account_with_priority(7)
      highest = stub_account_with_priority(9)
      budget.add_account(lowest)
      budget.add_account(highest)
      budget.add_account(middle)
      budget.accounts.should == [highest, middle, lowest]
    end

    it "always puts disabled accounts at the bottom" do
      enabled = stub_account_with_priority(4, enabled?: true)
      disabled_lowest = stub_account_with_priority(3, enabled?: false)
      disabled_highest = stub_account_with_priority(6, enabled?: false)
      budget.add_account(disabled_lowest)
      budget.add_account(enabled)
      budget.add_account(disabled_highest)
      budget.accounts.should == [enabled, disabled_highest, disabled_lowest]
    end
  end
end
