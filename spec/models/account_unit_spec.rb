RSpec.describe Account do
  context "validations" do
    describe "Basic validations" do
      let(:account){Account.new(name: "Acct", priority: 1)}

      it 'is valid with just name and priority' do
        account.enabled = nil
        expect(account).to be_valid
      end

      it 'is invalid without name' do
        account.name = ""
        expect(account).not_to be_valid
      end

      it '+is invalid with a priority > 10' do
        account.priority = 11
        expect(account).not_to be_valid
      end

      it 'is invalid with a blank priority' do
        account.priority = nil
        expect(account).not_to be_valid
      end

      it 'is valid with valid add_per_month values' do
        valid_values = [
          ["$", nil],
          ["%", nil],
          [nil, nil],
          ["$", 0],
          ["$", 1],
          ["$", 100],
          ["$", 101],
          ["$", "1047.82".to_d],
          ["%", 0],
          ["%", 1],
          ["%", 100],
          ["%", "45.28".to_d]
        ]

        expect(
          valid_values.map{|value_type, value|
            account.add_per_month_type = value_type
            account.add_per_month = value
            message = account.valid? ? nil : account.errors.full_messages.join(' | ')
            [value_type, value, account.valid?] + [message].compact
          }
        ).to match_array(
          valid_values.map{|value_type, value|
            [value_type, value, true]
          }
        )
      end

      it 'is invalid with bad add_per_month_values' do
        invalid_values = [
          [nil, 45],
          [nil, 0],
          ["$", -1],
          ["%", "-0.01".to_d],
          ["%", "100.01".to_d],
          ["%", 101],
          ["*", 55],
          ["USD", 48]
        ]

        expect(
          invalid_values.map{|value_type, value|
            account.add_per_month_type = value_type
            account.add_per_month = value
            [value_type, value, account.valid?]
          }
        ).to match_array(
          invalid_values.map{|value_type, value|
            [value_type, value, false]
          }
        )
      end
    end

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
          priority: 8
        )
      end

      context "negative overflow" do
        before(:each) do
          account.negative_overflow_account = overflow_account
        end

        it "is valid if the negative_overflow_account is enabled" do
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

      context "income overflow" do
        before(:each) do
          account.overflow_into_account = overflow_account
        end

        it 'is valid if the overflow_account is enabled' do
          expect(account).to be_valid
        end

        it "is invalid if the overflow_account is disabled" do
          overflow_account.enabled = false
          expect(account).not_to be_valid
        end

        it "is valid if there is no overflow account" do
          account.overflow_into_account = nil
          expect(account).to be_valid
        end
      end
    end

    describe "#cannot_receive_overflow_when_disabled" do
      let(:account){Account.new(name: 'Acct', priority: 5)}

      context "negative_overflow" do
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

      context "income_overflow" do
        before(:each) do
          allow(account).to receive_messages(overflowed_from_accounts: [Account.new(name: 'Savings')])
        end

        it 'is valid when enabled' do
          account.enabled = true
          expect(account).to be_valid
        end

        it 'is invalid when disabled' do
          account.enabled = false
          expect(account).not_to be_valid
        end

        it 'is valid when disabled but not being overflowed' do
          allow(account).to receive_messages(overflowed_from_accounts: [])
          expect(account).to be_valid
        end
      end
    end

    #describe "#cannot_overflow_as_disabled_account" do
    #  let(:account){Account.new(name: 'Acct', priority: 3, id: 29)}
    #  it "is valid when disabled and allowing negatives in itself" do
    #    account.enabled = false
    #    account.negative_overflow_id = 29
    #    expect(account).to be_valid
    #  end

    #  it "is valid when disabled and not allowing negatives" do
    #    account.enabled = false
    #    account.negative_overflow_id = nil
    #    expect(account).to be_valid
    #  end

    #  it "is not valid when disabled and negatively overflowing" do
    #    account.enabled = false
    #    account.negative_overflow_id = 32
    #    expect(account).not_to be_valid
    #  end

    #  it "is valid when enabled and overflowing" do
    #    account.enabled = true
    #    account.negative_overflow_id = 32
    #    expect(account).to be_valid
    #  end
    #end

    describe "#cannot_exceed_max_overflow_recursion" do
      let(:account){Account.new(name: 'Acct', priority: 1)}
      it 'is valid if there is no recursion error' do
        allow(account).to receive(:negative_overflow_recursion_error?).and_return(false)
        expect(account).to be_valid
      end

      it 'is invalid if there is a recursion error' do
        allow(account).to receive(:negative_overflow_recursion_error?).and_return(true)
        expect(account).not_to be_valid
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
