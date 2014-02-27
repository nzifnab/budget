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

    describe "#cannot_overflow_to_disabled_account" do
      let(:overflow_account){Account.new(enabled: true)}
      let(:account) do
        Account.new(
          name: "Acct",
          priority: 8,
          negative_overflow_account: overflow_account
        )
      end
      it "is valid if the negative_overflow account is enabled" do
        account.should be_valid
      end

      it "is invalid if the negative_overflow_account is disabled" do
        overflow_account.enabled = false
        account.should_not be_valid
      end

      it "is valid if the negative_overflow account is itself" do
        account.enabled = false
        account.negative_overflow_account = account
        account.should be_valid
      end

      it "is valid if there is no negative overflow account" do
        account.negative_overflow_account = nil
        account.should be_valid
      end
    end

    describe "#cannot_receive_overflow_when_disabled" do
      let(:account){Account.new(name: 'Acct', priority: 5)}
      before(:each) do
        account.stub(negative_overflowed_from_accounts: [Account.new(name: 'Bob')])
      end
      it "is valid when enabled" do
        account.enabled = true
        account.should be_valid
      end

      it "is invalid when disabled" do
        account.enabled = false
        account.should_not be_valid
      end

      it "is valid when disabled but not being overflowed" do
        account.stub(negative_overflowed_from_accounts: [])
        account.should be_valid
      end
    end

    describe "#cannot_overflow_as_disabled_account" do
      let(:account){Account.new(name: 'Acct', priority: 3, id: 29)}
      it "is valid when disabled and allowing negatives in itself" do
        account.enabled = false
        account.negative_overflow_id = 29
        account.should be_valid
      end

      it "is valid when disabled and not allowing negatives" do
        account.enabled = false
        account.negative_overflow_id = nil
        account.should be_valid
      end

      it "is not valid when disabled and negatively overflowing" do
        account.enabled = false
        account.negative_overflow_id = 32
        account.should_not be_valid
      end

      it "is valid when enabled and overflowing" do
        account.enabled = true
        account.negative_overflow_id = 32
        account.should be_valid
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
