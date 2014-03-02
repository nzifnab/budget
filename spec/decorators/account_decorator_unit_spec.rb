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
      decorator.negative_overflow_label.should == "Negative overflow"
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

  describe "#js_sort_parts" do
    it "starts the value with '0' for disabled accounts" do
      account.enabled = false
      decorator.js_sort_parts[0].should == "0"
    end

    it "starts the value with '1' for enabled accounts" do
      account.enabled = true
      decorator.js_sort_parts[0].should == "1"
    end

    it "left-pads the priority with '0's" do
      account.priority = 3
      decorator.js_sort_parts[1].should == "03"
    end

    it "doesn't left-pad a priority of 10" do
      account.priority = 10
      decorator.js_sort_parts[1].should == "10"
    end

    it "uses '0' for negative amounts" do
      account.amount = "-34.29".to_d
      decorator.js_sort_parts[2].should == "0"
    end

    it "uses a '1' for positive amounts" do
      account.amount = "34.29".to_d
      decorator.js_sort_parts[2].should == "1"
    end

    it "uses the digit length with 2 decimal places" do
      account.amount = "307.9153".to_d
      decorator.js_sort_parts[3].should == "05"
    end

    it "is the same length for a negative number" do
      account.amount = "-307.9153".to_d
      decorator.js_sort_parts[3].should == "05"
    end

    it "doesn't pad an absurdly large number" do
      account.amount = "#{"5"*10}.3".to_d
      decorator.js_sort_parts[3].should == "12"
    end

    it "removes the decimal place for positive amounts" do
      account.amount = "307.9153".to_d
      decorator.js_sort_parts[4].should == "30792"
    end

    it "inverts negative amounts" do
      account.amount = "-324.25".to_d
      # '99999' minus '32425' (for absolute-valued no-decimal number)
      decorator.js_sort_parts[4].should == "67574"
    end
  end
end
