require 'rails_helper'

RSpec.describe AccountHistory do
  describe "#amount_for_quick_fund=" do
    let(:account) do
      a = Account.new(amount: 30)
      allow(a).to receive_messages(requires_negative_overflow?: false)
      a
    end
    let(:history) do
      AccountHistory.new(account: account)
    end

    it "sets the amount attribute" do
      expect(history.amount).to  be_nil
      history.amount_for_quick_fund = 29
      expect(history.amount).to eq 29
    end

    it 'sets the amount attribute even as a new record' do
      allow(history).to receive_messages(new_record?: false)
      expect(history.amount).to  be_nil
      history.amount_for_quick_fund = 29
      expect(history.amount).to eq 29
    end

    it "modifies the account's amount by this amount" do
      expect(account.amount).to eq 30
      history.amount_for_quick_fund = 25
      expect(account.amount).to eq 55
    end

    context "account requires negative overflow" do
      let(:quick_fund){QuickFund.new}
      before(:each) do
        allow(account).to receive_messages(requires_negative_overflow?: true, negative_overflow_account: nil)
        history.quick_fund = quick_fund
        allow(quick_fund).to receive_messages(distribute_funds: nil)
      end

      it "Changes the history's amount to the amount that account's changed" do
        history.amount_for_quick_fund = -50
        expect(history.amount).to eq -30
      end

      it "set's account's amount to 0" do
        history.amount_for_quick_fund = -90
        expect(account.amount).to eq 0
      end

      it "distributes the remaining funds through the original quick_fund model" do
        allow(account).to receive_messages(negative_overflow_account: "Neg Account")
        expect(quick_fund).to receive(:distribute_funds).with(-75, "Neg Account")
        history.amount_for_quick_fund = -105
      end
    end
  end
end
