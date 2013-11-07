require 'spec_helper'
#require 'spec_helper_lite'
#stub_module('Draper::Decoratable')
#require_relative '../../app/models/account'

describe Account do
  let(:account){Account.new}

  it "supports reading and writing a budget reference" do
    budget = Object.new 
    account.budget = budget
    account.budget.should == budget
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
