require 'spec_helper'

describe Account do
  describe "#negative_overflow_recursion_error?" do
    let(:account1){Account.new(name: "acct1", priority: 1, enabled: true)}
    let(:account2){Account.new(name: "acct2", priority: 2, enabled: true, negative_overflow_id: account1.id)}
    let(:account3){Account.new(name: "acct3", priority: 3, enabled: true, negative_overflow_id: account2.id)}
    let(:account4){Account.new(name: "acct4", priority: 4, enabled: true, negative_overflow_id: account3.id)}
    it "has no error for a brand new account" do
      Account.new.negative_overflow_recursion_error?.should be_false
    end

    context "unsaved negative_overflow_id" do
      it "has no error if there are 3 nested negative accounts" do
        account1.save!; account2.save!; account3.save!;
        account = Account.new(negative_overflow_id: account3.id)
        account.negative_overflow_recursion_error?.should be_false
      end

      it "has an error if there are 4 nested negative accounts" do
        account1.save!; account2.save!; account3.save!; account4.save!
        account = Account.new(negative_overflow_id: account4.id)
        account.negative_overflow_recursion_error?.should be_true
      end

      it "does not have an error if the negative overflow is '0'" do
        account = Account.new(negative_overflow_id: 0)
        account.negative_overflow_recursion_error?.should be_false
      end

      it "does not have an error if the negative_overflow_id is referencing itself" do
        account1.save!
        account1.negative_overflow_id = account1.id
        account1.negative_overflow_recursion_error?.should be_false
      end

      it "has an error if it tries to create a circular reference" do
        account1.save!; account2.save!
        account1.negative_overflow_id = account2.id
        account1.negative_overflow_recursion_error?.should be_true
      end

      it "has an error if it tries to make a triangle" do
        account1.save!; account2.save!; account3.save!
        account1.negative_overflow_id = account3.id
        account1.negative_overflow_recursion_error?.should be_true
      end

      it "has no error even if the account used to have an error but is being set to nil" do
        account1.save!; account2.save!; account3.save!
        account1.update_attribute(:negative_overflow_id, account3.id).should be_true
        account1.negative_overflow_id = nil
        account1.negative_overflow_recursion_error?.should be_false
      end

      it "has no error even if the account used to have an error but is being set to itself" do
        account1.save!; account2.save!; account3.save!
        account1.update_attribute(:negative_overflow_id, account3.id).should be_true
        account1.negative_overflow_id = account1.id
        account1.negative_overflow_recursion_error?.should be_false
      end
    end

    context "saved negative_overflow_id" do
      it "has no error if there are 3 nested negative accounts" do
        account1.save!; account2.save!; account3.save!;
        account = Account.new(name: "Frank", priority: 3, enabled: true)
        account.save!
        # update_attribute skips callbacks
        account.update_attribute(:negative_overflow_id, account3.id).should be_true
        account.negative_overflow_recursion_error?.should be_false
      end

      it "has an error if there are 4 nested negative accounts" do
        account1.save!; account2.save!; account3.save!; account4.save!
        account = Account.new(name: "Frank", priority: 3, enabled: true)
        account.save!
        account.update_attribute(:negative_overflow_id, account4.id).should be_true
        account.negative_overflow_recursion_error?.should be_true
      end

      it "does not have an error if the negative_overflow_id is referencing itself" do
        account1.save!
        account1.update_attribute(:negative_overflow_id, account1.id).should be_true
        account1.negative_overflow_recursion_error?.should be_false
      end

      it "has an error if it tries to create a circular reference" do
        account1.save!; account2.save!
        account1.update_attribute(:negative_overflow_id, account2.id).should be_true
        account1.negative_overflow_recursion_error?.should be_true
      end

      it "has an error if it tries to make a triangle" do
        account1.save!; account2.save!; account3.save!
        account1.update_attribute(:negative_overflow_id, account3.id).should be_true
        account1.negative_overflow_recursion_error?.should be_true
      end
    end
  end
end
