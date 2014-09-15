RSpec.describe Account do
  context "validations" do
    describe "#deny_negative_amount_with_no_overflow" do
      let(:account){Account.new(name: "Acct", priority: 5, amount: -50, id: 29, negative_overflow_id: nil)}
      it "is valid when overflows are allowed" do
        account.negative_overflow_id = 29
        expect(account).to be_valid
      end

      it "is valid when the amount is >= 0" do
        account.amount = 0
        expect(account).to be_valid
      end

      it "is invalid when overflows are disallowed" do
        expect(account).not_to be_valid
        expect(account.errors[:amount]).to eq ["Insufficient Funds"]
        expect(account.errors[:negative_overflow_id]).to eq ["Insufficient Funds"]
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
        expect(account).to be_valid
      end

      it "is invalid if the negative_overflow_account is disabled" do
        overflow_account.enabled = false
        expect(account).not_to be_valid
      end

      it "is valid if the negative_overflow account is itself" do
        account.enabled = false
        account.negative_overflow_account = account
        expect(account).to be_valid
      end

      it "is valid if there is no negative overflow account" do
        account.negative_overflow_account = nil
        expect(account).to be_valid
      end
    end

    describe "#cannot_receive_overflow_when_disabled" do
      let(:account){Account.new(name: 'Acct', priority: 5)}
      before(:each) do
        allow(account).to receive_messages(negative_overflowed_from_accounts: [Account.new(name: 'Bob')])
      end
      it "is valid when enabled" do
        account.enabled = true
        expect(account).to be_valid
      end

      it "is invalid when disabled" do
        account.enabled = false
        expect(account).not_to be_valid
      end

      it "is valid when disabled but not being overflowed" do
        allow(account).to receive_messages(negative_overflowed_from_accounts: [])
        expect(account).to be_valid
      end
    end

    describe "#cannot_overflow_as_disabled_account" do
      let(:account){Account.new(name: 'Acct', priority: 3, id: 29)}
      it "is valid when disabled and allowing negatives in itself" do
        account.enabled = false
        account.negative_overflow_id = 29
        expect(account).to be_valid
      end

      it "is valid when disabled and not allowing negatives" do
        account.enabled = false
        account.negative_overflow_id = nil
        expect(account).to be_valid
      end

      it "is not valid when disabled and negatively overflowing" do
        account.enabled = false
        account.negative_overflow_id = 32
        expect(account).not_to be_valid
      end

      it "is valid when enabled and overflowing" do
        account.enabled = true
        account.negative_overflow_id = 32
        expect(account).to be_valid
      end
    end
  end

  describe "#requires_negative_overflow?" do
    let(:account){Account.new(amount: -100, id: 29, negative_overflow_id: 34)}

    it "negatively overflows if it references a different account" do
      expect(account).to be_requires_negative_overflow
    end

    it "can't overflow if negative_overflow_id is nil" do
      account.negative_overflow_id = nil
      expect(account).not_to be_requires_negative_overflow
    end

    it "can't overflow if amount is >= 0" do
      account.amount = 0
      expect(account).not_to be_requires_negative_overflow
    end

    it "can't overflow if negative_overflow_id references itself" do
      account.negative_overflow_id = 29
      expect(account).not_to be_requires_negative_overflow
    end
  end
end
