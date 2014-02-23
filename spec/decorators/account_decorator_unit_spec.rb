require 'spec_helper'

describe AccountDecorator do
  let(:account){Account.new}
  let(:decorator){AccountDecorator.decorate(account)}

  describe "#prioritized_name" do
    it "prepends the priority to the name for display" do
      account.priority = 3
      account.name = "Bob's Tool Shed"
      decorator.prioritized_name.should == "(3) Bob's Tool Shed"
    end
  end

  # good, bad, or neutral
  describe "#amount_class" do
    it "is 'good' for positive amounts" do
      account.amount = 43.71
      decorator.amount_class.should == 'good'
    end

    it "is 'bad' for negative amounts" do
      account.amount = -1.43
      decorator.amount_class.should == 'bad'
    end

    it "is 'neutral' for zero amounts" do
      account.amount = 0
      decorator.amount_class.should == 'neutral'
    end
  end

  describe "#display_amount" do
    it "shows a dollar amount for positive funds" do
      account.amount = 12
      decorator.display_amount.should == "$12.00"
    end

    it "shows $0.00 for no amount" do
      account.amount = 0
      decorator.display_amount.should == "$0.00"
    end

    it "shows a parenthesized amount for negative values" do
      account.amount = -12.43
      decorator.display_amount.should == "($12.43)"
    end
  end

  describe "#formatted_created_at" do
    let(:time_now){"January 3rd, 2013".to_datetime}

    it "returns a properly formatted time" do
      account.created_at = time_now
      decorator.formatted_created_at.should == "Jan 03, 2013"
    end
  end

  describe "#negative_overflow_label" do
    it "labels it with 'Negatives allowed?' when the id is nil" do
      account.negative_overflow_id = nil
      decorator.negative_overflow_label.should == "Negatives allowed?"
    end

    it "labels it with 'Negatives allowed?' when the id is the account's own id" do
      account.stub(id: 24)
      account.negative_overflow_id = 24
      decorator.negative_overflow_label.should == "Negatives allowed?"
    end

    it "labels it with 'Negatives overflow into' when the id is something else" do
      account.stub(id: 25)
      account.negative_overflow_id = 24
      decorator.negative_overflow_label.should == "Negatives overflow into"
    end
  end

  describe "#negative_overflow_name" do
    let(:overflow_account){Account.new(name: "Credit Card")}

    it "returns 'No' if the id is nil" do
      account.negative_overflow_id = nil
      decorator.negative_overflow_name.should == "No"
    end

    it "returns 'Yes' if the id is self" do
      account.stub(id: 29)
      account.negative_overflow_id = 29
      decorator.negative_overflow_name.should == "Yes"
    end

    it "returns the name of an account if the id is something else" do
      account.stub(id: 20)
      account.negative_overflow_id = 25
      account.stub(:negative_overflow_account).and_return(overflow_account)
      decorator.negative_overflow_name.should == "Credit Card"
    end
  end
end
