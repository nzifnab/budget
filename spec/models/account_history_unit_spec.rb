require 'spec_helper'

describe AccountHistory do
  describe "#amount=" do
    let(:account) do
      a = Account.new(amount: 30)
      a.stub(requires_negative_overflow?: false)
      a
    end
    let(:history) do
      AccountHistory.new(account: account)
    end

    it "sets the amount attribute" do
      history.stub(new_record?: false)
      history.amount.should be_nil
      history.amount = 29
      history.amount.should == 29
    end

    it "modifies the account's amount by this amount" do
      account.amount.should == 30
      history.amount = 25
      account.amount.should == 55
    end

    context "account requires negative overflow" do
      let(:quick_fund){QuickFund.new}
      before(:each) do
        account.stub(requires_negative_overflow?: true, negative_overflow_account: nil)
        history.quick_fund = quick_fund
        quick_fund.stub(distribute_funds: nil)
      end

      it "Changes the history's amount to the amount that account's changed" do
        # account.amount == 30
        history.amount = -50
        history.amount.should == -30
      end

      it "set's account's amount to 0" do
        history.amount = -90
        account.amount.should == 0
      end

      it "distributes the remaining funds through the original quick_fund model" do
        account.stub(negative_overflow_account: "Neg Account")
        quick_fund.should_receive(:distribute_funds).with(-75, "Neg Account")
        history.amount = -105
      end
    end
  end
end
