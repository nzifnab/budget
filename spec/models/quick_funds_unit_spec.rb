RSpec.describe QuickFund do
  describe "#before_validation" do
    let(:account){Account.new(amount: 100, id: 200)}

    describe "the new account history object" do
      let(:quick_fund) do
        fund = account.quick_funds.build(
          account: account,
          fund_type: "Deposit",
          description: "My Funds"
        )
        fund.amount = 28
        fund
      end
      let(:history){quick_fund.account_histories.first}

      it "builds a new account history object for the withdrawn funds" do
        expect(quick_fund).to be_valid
        expect(quick_fund.account_histories.size).to eq 1
      end

      it "set's the amount on history to positive for deposit" do
        expect(quick_fund).to be_valid
        expect(quick_fund.amount).to eq 28
        expect(history.amount).to eq 28
      end

      it "set's the amount to negative for withdrawal" do
        quick_fund.fund_type = "Withdraw"
        expect(quick_fund).to be_valid
        expect(quick_fund.amount).to eq 28
        expect(history.amount).to eq -28
      end

      it "set's the account to the one having funds withdrawn" do
        expect(quick_fund).to be_valid
        expect(history.account).to eq account
      end

      it "bubbles validation errors into quick_fund" do
        quick_fund.fund_type = "Withdraw"
        quick_fund.amount = 110
        expect(quick_fund).not_to be_valid
        expect(quick_fund.errors[:amount][0]).to eq "Insufficient Funds"
      end

      it "set's description on the history" do
        expect(quick_fund).to be_valid
        expect(history.description).to eq "My Funds"
      end
    end

  end
end
