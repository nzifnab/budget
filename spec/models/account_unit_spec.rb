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

  it "supports setting attributes in the initializer" do
    account = Account.new(name: "Checking", description: "Fun Times")
    account.name.should == "Checking"
    account.description.should == "Fun Times"
  end

  describe "#submit" do
    let(:budget){mock(:budget, add_account: account)}

    before(:each) do
      account.budget = budget
      account.name = "Checking"
      account.priority = 4
    end

    it "adds the account to the budget" do
      budget.should_receive(:add_account).with(account)
      account.submit
    end

    context "Given an invalid account" do
      before(:each) do
        account.name = nil
      end

      it "won't add the account to the budget" do
        budget.should_not_receive(:add_account)
        account.submit
      end

      it "returns false" do
        account.submit.should be_false
      end
    end
  end
end
