require 'spec_helper'

describe "Account Management", js: true do
  describe "Creating a new account" do
    let(:budget){Budget.new}

    before(:each) do
      budget.new_account(name: "Savings Account", priority: 9, enabled: true).submit
      budget.new_account(name: "Insurance", priority: 3, enabled: true).submit
      budget.new_account(name: "Disabled Account", priority: 8, enabled: false).submit
    end

    it "Inserts new accounts into the correct priority location" do
      puts budget.accounts.size
      visit accounts_path
      accordion = open_accordion("New Account")
      within(accordion[:content]) do
        fill_in "Name", with: "Checking Account"
        fill_in "Description", with: "Wells Fargo checking account"
        fill_in "Priority", with: "7"
        check "Enabled"
        select "Disallow Negatives", from: "Negative overflows into"
        click_button "Save Account"
      end

      # TEMPORARY while the submission is not using 'remote: true':
      #accordion = find_accordion("New Account")
      
      page.should_not have_selector("##{accordion[:content][:id]}", visible: true)
      accordion[:content].should_not be_visible

      # find all of them so we can assert it was inserted in the right spot
      page.should have_selector(".accordion-header", text: "Checking Account")
      headers = page.all(".accordion-header")

      headers.size.should == 5
      headers[0].should have_content("New Account")
      headers[1].should have_content("Savings Account")
      headers[2].should have_content("Checking Account")
      headers[3].should have_content("Insurance")
      headers[4].should have_content("Disabled Account")

      checking_accordion = find_accordion("Checking Account")
      checking_accordion[:content].should be_visible

      within(checking_accordion[:content]) do
        page.should have_content("Wells Fargo checking account")
      end
      within(checking_accordion[:header]) do
        page.should have_content("$0.00")
        page.should have_content("(7) Checking Account")
      end
    end
  end
end
