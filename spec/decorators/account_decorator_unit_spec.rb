require 'spec_helper'

describe AccountDecorator do
  let(:account){mock(:account)}
  let(:decorator){AccountDecorator.decorate(account)}

  describe "#prioritized_name" do
    it "prepends the priority to the name for display" do
      account.stub(priority: 3, name: "Bob's Tool Shed")
      decorator.prioritized_name.should == "(3) Bob's Tool Shed"
    end
  end

  # good, bad, or neutral
  describe "#amount_class" do
    it "is 'good' for positive amounts" do
      account.stub(amount: 43.71)
      decorator.amount_class.should == 'good'
    end

    it "is 'bad' for negative amounts" do
      account.stub(amount: -1.43)
      decorator.amount_class.should == 'bad'
    end

    it "is 'neutral' for zero amounts" do
      account.stub(amount: 0)
      decorator.amount_class.should == 'neutral'
    end
  end

  describe "#display_amount" do
    it "shows a dollar amount for positive funds" do
      account.stub(amount: 12)
      decorator.display_amount.should == "$12.00"
    end

    it "shows $0.00 for no amount" do
      account.stub(amount: 0)
      decorator.display_amount.should == "$0.00"
    end

    it "shows a parenthesized amount for negative values" do
      account.stub(amount: -12.43)
      decorator.display_amount.should == "($12.43)"
    end
  end

  describe "#formatted_created_at" do
    let(:time_now){"January 3rd, 2013".to_datetime}

    it "returns a properly formatted time" do
      account.stub(created_at: time_now)
      decorator.formatted_created_at.should == "Jan 03, 2013"
    end
  end
end
