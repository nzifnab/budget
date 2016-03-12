require 'rails_helper'

RSpec.describe AccountDecorator do
  let(:account){Account.new}
  let(:decorator){AccountDecorator.decorate(account)}

  describe "#prioritized_name" do
    it "prepends the priority to the name for display" do
      account.priority = 3
      account.name = "Bob's Tool Shed"
      expect(decorator.prioritized_name).to eq "(3) Bob's Tool Shed"
    end
  end

  # good, bad, or neutral
  describe "#amount_class" do
    it "is 'good' for positive amounts" do
      account.amount = 43.71
      expect(decorator.amount_class).to eq 'good'
    end

    it "is 'bad' for negative amounts" do
      account.amount = -1.43
      expect(decorator.amount_class).to eq 'bad'
    end

    it "is 'neutral' for zero amounts" do
      account.amount = 0
      expect(decorator.amount_class).to eq 'neutral'
    end
  end

  describe "#display_amount" do
    it "shows a dollar amount for positive funds" do
      account.amount = 12
      expect(decorator.display_amount).to eq "$12.00"
    end

    it "shows $0.00 for no amount" do
      account.amount = 0
      expect(decorator.display_amount).to eq "$0.00"
    end

    it "shows a parenthesized amount for negative values" do
      account.amount = -12.43
      expect(decorator.display_amount).to eq "($12.43)"
    end
  end

  describe "#formatted_created_at" do
    let(:time_now){"January 3rd, 2013".to_datetime}

    it "returns a properly formatted time" do
      account.created_at = time_now
      expect(decorator.formatted_created_at).to eq "Jan 03, 2013"
    end
  end

  describe "#negative_overflow_label" do
    it "labels it with 'Negatives allowed?' when the id is nil" do
      account.negative_overflow_id = nil
      expect(decorator.negative_overflow_label).to eq "Negatives?"
    end

    it "labels it with 'Negatives allowed?' when the id is the account's own id" do
      allow(account).to receive_messages(id: 24)
      account.negative_overflow_id = 24
      expect(decorator.negative_overflow_label).to eq "Negatives?"
    end

    it "labels it with 'Negatives overflow into' when the id is something else" do
      allow(account).to receive_messages(id: 25)
      account.negative_overflow_id = 24
      expect(decorator.negative_overflow_label).to eq "Negative overflow"
    end
  end

  describe "#negative_overflow_name" do
    let(:overflow_account){Account.new(name: "Credit Card")}

    it "returns 'No' if the id is nil" do
      account.negative_overflow_id = nil
      expect(decorator.negative_overflow_name).to eq "No"
    end

    it "returns 'Yes' if the id is self" do
      allow(account).to receive_messages(id: 29)
      account.negative_overflow_id = 29
      expect(decorator.negative_overflow_name).to eq "Yes"
    end

    it "returns the name of an account if the id is something else" do
      allow(account).to receive_messages(id: 20)
      account.negative_overflow_id = 25
      allow(account).to receive_messages(negative_overflow_account: overflow_account)
      expect(decorator.negative_overflow_name).to eq "Credit Card"
    end
  end

  describe "#js_sort_parts" do
    it "starts the value with '0' for disabled accounts" do
      account.enabled = false
      expect(decorator.js_sort_parts[0]).to eq "0"
    end

    it "starts the value with '1' for enabled accounts" do
      account.enabled = true
      expect(decorator.js_sort_parts[0]).to eq "1"
    end

    it "left-pads the priority with '0's" do
      account.priority = 3
      expect(decorator.js_sort_parts[1]).to eq "03"
    end

    it "doesn't left-pad a priority of 10" do
      account.priority = 10
      expect(decorator.js_sort_parts[1]).to eq "10"
    end

    it "uses '0' for negative amounts" do
      account.amount = "-34.29".to_d
      expect(decorator.js_sort_parts[2]).to eq "0"
    end

    it "uses a '1' for positive amounts" do
      account.amount = "34.29".to_d
      expect(decorator.js_sort_parts[2]).to eq "1"
    end

    it "uses the digit length with 2 decimal places" do
      account.amount = "307.9153".to_d
      expect(decorator.js_sort_parts[3]).to eq "05"
    end

    it "is the same length for a negative number" do
      account.amount = "-307.9153".to_d
      expect(decorator.js_sort_parts[3]).to eq "05"
    end

    it "doesn't pad an absurdly large number" do
      account.amount = "#{"5"*10}.3".to_d
      expect(decorator.js_sort_parts[3]).to eq "12"
    end

    it "removes the decimal place for positive amounts" do
      account.amount = "307.9153".to_d
      expect(decorator.js_sort_parts[4]).to eq "30792"
    end

    it "inverts negative amounts" do
      account.amount = "-324.25".to_d
      # '99999' minus '32425' (for absolute-valued no-decimal number)
      expect(decorator.js_sort_parts[4]).to eq "67574"
    end
  end
end
