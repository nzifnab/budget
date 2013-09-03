require 'spec_helper_lite'
stub_module('Draper::Decoratable')
require_relative '../../app/models/account'

describe Account do
  let(:account){Account.new}

  it "starts with blank attributes" do
    account.name.should be_nil
    account.description.should be_nil
    account.enabled.should be_false
    account.priority.should be_nil
  end

  it "supports reading and writing a name" do
    account.name = "Foo"
    account.name.should == "Foo"
  end

  it "supports reading and writing a budget reference" do
    budget = Object.new
    account.budget = budget
    account.budget.should == budget
  end

  it "supports reading and writing the 'enabled' flag" do
    account.enabled = true
    account.should be_enabled
  end

  it "supports reading and writing the priority" do
    account.priority = 5
    account.priority.should == 5
  end

  describe "#submit" do
    let(:budget){mock(:budget)}

    before(:each) do
      account.budget = budget
    end

    it "adds the account to the budget" do
      budget.should_receive(:add_account).with(account)
      account.submit
    end
  end
end
