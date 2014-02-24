require 'spec_helper'

describe QuickFund do
  describe "#before_validation" do
    let(:account){Account.new(amount: 100)}

    describe "the new account history object" do
      let(:quick_fund) do
        account.quick_funds.build(
          account: account,
          fund_type: "Deposit",
          amount: 28,
          description: "My Funds"
        )
      end
      let(:history){quick_fund.account_histories.first}

      it "builds a new account history object for the withdrawn funds" do
        quick_fund.should be_valid
        quick_fund.account_histories.size.should == 1
      end

      it "set's the amount on history to positive for deposit" do
        quick_fund.should be_valid
        quick_fund.amount.should == 28
        history.amount.should == 28
      end

      it "set's the amount to negative for withdrawal" do
        quick_fund.fund_type = "Withdraw"
        quick_fund.should be_valid
        quick_fund.amount.should == 28
        history.amount.should == -28
      end

      it "set's the account to the one having funds withdrawn" do
        quick_fund.should be_valid
        history.account.should == account
      end

      it "bubbles validation errors into quick_fund" do
        quick_fund.fund_type = "Withdraw"
        quick_fund.amount = 110
        quick_fund.should_not be_valid
        quick_fund.errors_on(:amount)[0].should == "Insufficient Funds"
      end

      it "set's description on the history" do
        quick_fund.should be_valid
        history.description.should == "My Funds"
      end
    end

  end
end
