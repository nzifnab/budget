RSpec.describe Account do
  describe "#negative_overflow_recursion_error?" do
    let(:account1){Account.new(name: "acct1", priority: 1, enabled: true)}
    let(:account2){Account.new(name: "acct2", priority: 2, enabled: true, negative_overflow_id: account1.id)}
    let(:account3){Account.new(name: "acct3", priority: 3, enabled: true, negative_overflow_id: account2.id)}
    let(:account4){Account.new(name: "acct4", priority: 4, enabled: true, negative_overflow_id: account3.id)}
    it "has no error for a brand new account" do
      expect(Account.new.negative_overflow_recursion_error?).to eq false
    end

    context "unsaved negative_overflow_id" do
      it "has no error if there are 3 nested negative accounts" do
        account1.save!; account2.save!; account3.save!;
        account = Account.new(negative_overflow_id: account3.id)
        expect(account.negative_overflow_recursion_error?).to be false
      end

      it "has an error if there are 4 nested negative accounts" do
        account1.save!; account2.save!; account3.save!; account4.save!
        account = Account.new(negative_overflow_id: account4.id)
        expect(account.negative_overflow_recursion_error?).to be true
      end

      it "does not have an error if the negative overflow is '0'" do
        account = Account.new(negative_overflow_id: 0)
        expect(account.negative_overflow_recursion_error?).to be false
      end

      it "does not have an error if the negative_overflow_id is referencing itself" do
        account1.save!
        account1.negative_overflow_id = account1.id
        expect(account1.negative_overflow_recursion_error?).to be false
      end

      it "has an error if it tries to create a circular reference" do
        account1.save!; account2.save!
        account1.negative_overflow_id = account2.id
        expect(account1.negative_overflow_recursion_error?).to be true
      end

      it "has an error if it tries to make a triangle" do
        account1.save!; account2.save!; account3.save!
        account1.negative_overflow_id = account3.id
        expect(account1.negative_overflow_recursion_error?).to be true
      end

      it "has no error even if the account used to have an error but is being set to nil" do
        account1.save!; account2.save!; account3.save!
        expect(account1.update_attribute(:negative_overflow_id, account3.id)).to be true
        account1.negative_overflow_id = nil
        expect(account1.negative_overflow_recursion_error?).to eq false
      end

      it "has no error even if the account used to have an error but is being set to itself" do
        account1.save!; account2.save!; account3.save!
        expect(account1.update_attribute(:negative_overflow_id, account3.id)).to be true
        account1.negative_overflow_id = account1.id
        expect(account1.negative_overflow_recursion_error?).to be false
      end
    end

    context "saved negative_overflow_id" do
      it "has no error if there are 3 nested negative accounts" do
        account1.save!; account2.save!; account3.save!;
        account = Account.new(name: "Frank", priority: 3, enabled: true)
        account.save!
        # update_attribute skips callbacks
        expect(account.update_attribute(:negative_overflow_id, account3.id)).to be true
        expect(account.negative_overflow_recursion_error?).to be false
      end

      it "has an error if there are 4 nested negative accounts" do
        account1.save!; account2.save!; account3.save!; account4.save!
        account = Account.new(name: "Frank", priority: 3, enabled: true)
        account.save!
        expect(account.update_attribute(:negative_overflow_id, account4.id)).to be true
        expect(account.negative_overflow_recursion_error?).to be true
      end

      it "does not have an error if the negative_overflow_id is referencing itself" do
        account1.save!
        expect(account1.update_attribute(:negative_overflow_id, account1.id)).to be true
        expect(account1.negative_overflow_recursion_error?).to be false
      end

      it "has an error if it tries to create a circular reference" do
        account1.save!; account2.save!
        expect(account1.update_attribute(:negative_overflow_id, account2.id)).to be true
        expect(account1.negative_overflow_recursion_error?).to be true
      end

      it "has an error if it tries to make a triangle" do
        account1.save!; account2.save!; account3.save!
        expect(account1.update_attribute(:negative_overflow_id, account3.id)).to be true
        expect(account1.negative_overflow_recursion_error?).to be true
      end
    end
  end
end
