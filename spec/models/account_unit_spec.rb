require 'spec_helper'

describe Account do
  context "validations" do
    describe "#deny_negative_amount_with_no_overflow" do
      let(:account){Account.new(name: "Acct", priority: 5, amount: -50, id: 29, negative_overflow_id: nil)}
      it "is valid when overflows are allowed" do
        account.negative_overflow_id = 29
        account.should be_valid
      end

      it "is valid when the amount is >= 0" do
        account.amount = 0
        account.should be_valid
      end

      it "is invalid when overflows are disallowed" do
        account.should_not be_valid
        account.errors[:amount].should == ["Insufficient Funds"]
        account.errors[:negative_overflow_id].should == ["Insufficient Funds"]
      end
    end
  end

  describe "#requires_negative_overflow?" do
    let(:account){Account.new(amount: -100, id: 29, negative_overflow_id: 34)}

    it "negatively overflows if it references a different account" do
      account.should be_requires_negative_overflow
    end

    it "can't overflow if negative_overflow_id is nil" do
      account.negative_overflow_id = nil
      account.should_not be_requires_negative_overflow
    end

    it "can't overflow if amount is >= 0" do
      account.amount = 0
      account.should_not be_requires_negative_overflow
    end

    it "can't overflow if negative_overflow_id references itself" do
      account.negative_overflow_id = 29
      account.should_not be_requires_negative_overflow
    end
  end
end
