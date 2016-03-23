RSpec.describe "Account Management", js: true do
  let(:budget){Budget.new(current_user)}
  before(:each) do
    login
  end

  describe "Creating a new account" do

    before(:each) do
      budget.new_account(name: "Savings Account", priority: 9, enabled: true).save!
      budget.new_account(name: "Insurance", priority: 3, enabled: true).save!
      budget.new_account(name: "Disabled Account", priority: 8, enabled: false).save!
    end

    it "Inserts new accounts into the correct priority location" do
      visit accounts_path
      accordion = open_accordion("New Account")
      within(accordion[:content]) do
        fill_in "Name", with: "Checking Account"
        fill_in "Description", with: "Wells Fargo checking account"
        fill_in "Priority", with: "7"
        fill_in "Add Per Month", with: "32"
        check "Enabled"
        select "Disallow Negatives", from: "Negative overflows into"
        click_button "Save Account"
      end

      expect(page).not_to have_selector("##{accordion[:content][:id]}", visible: true)
      accordion = find_accordion("New Account")
      expect(accordion[:content]).not_to be_visible

      # find all of them so we can assert it was inserted in the right spot
      expect(page).to have_selector(".accordion-header", text: "Checking Account")
      headers = page.all(".accordion-header")
      expect(headers.size).to eq 5
      expect(headers[0]).to have_content("New Account")
      expect(headers[1]).to have_content("Savings Account")
      expect(headers[2]).to have_content("Checking Account")
      expect(headers[3]).to have_content("Insurance")
      expect(headers[4]).to have_content("Disabled Account")

      checking_accordion = find_accordion("Checking Account")
      expect(checking_accordion[:content]).to be_visible

      within(checking_accordion[:content]) do
        expect(page).to have_content("Wells Fargo checking account")
      end
      within(checking_accordion[:header]) do
        expect(page).to have_content("$0.00")
        expect(page).to have_content("(7) Checking Account")
      end
    end
  end

  describe "editing accounts" do
    let!(:account){budget.new_account(name: "Savings Account", priority: 10, enabled: true).save}

    it "let's me edit accounts inline" do
      visit accounts_path
      accordion = open_accordion("Savings Account")
      within(accordion[:content]) do
        click_link "Edit"
        expect(find_field("Name").value).to eq "Savings Account"
        expect(find_field("Priority").value).to eq "10"
        expect(find_field("account_description").value).to eq ""
        fill_in "account_description", with: "Important Money"
        fill_in "Name", with: "Emergency Funds"
        click_button "Update"
      end

      # Have to find it again because updating removes/re-adds the
      # element to the page
      accordion = open_accordion("Emergency Funds")
      within(accordion[:content]) do
        expect(page).to have_content("Important Money")
      end
    end
  end

  describe "Deposits/Withdrawals" do
    let(:account){budget.new_account(name: "Food", priority: 6, enabled: true, amount: 200)}

    it "let's me withdraw funds from an account" do
      account.save
      visit accounts_path
      accordion = open_accordion("Food")
      within(accordion[:content]) do
        fill_in "Amount", with: "25"
        fill_in "Description", with: "Groceries"
        click_button "Withdraw"
      end

      accordion = open_accordion("Food")
      within(accordion[:header]) do
        expect(page).to have_content("$175.00")
        within(".header-notice") do
          expect(page).to have_content("($25.00)")
        end
      end
    end

    it "let's me deposit funds into an account" do
      account.save
      visit accounts_path
      accordion = open_accordion("Food")
      within(accordion[:content]) do
        fill_in "Amount", with: "80"
        fill_in "Description", with: "Regurgitation"
        click_button "Deposit"
      end

      within(".header-notice"){expect(page).to have_content("$80.00")}
      accordion = open_accordion("Food")
      within(accordion[:header]) do
        expect(page).to have_content("$280.00")
        within(".header-notice") do
          expect(page).to have_content("$80.00")
        end
      end
    end

    it "doesn't let me withdraw if negatives are disallowed" do
      account.negative_overflow_id = nil
      account.amount = 30
      account.save
      visit accounts_path
      accordion = open_accordion("Food")
      within(accordion[:content]) do
        fill_in "Amount", with: "31"
        fill_in "Description", with: "Too much food!"
        click_button "Withdraw"
      end

      expect(page).to have_content("Insufficient Funds")
      accordion = open_accordion("Food")
      within(accordion[:header]) do
        expect(page).to have_content("$30.00")
        expect(page).not_to have_css(".header-notice")
      end

      within(accordion[:content]) do
        within(".form-error") do
          expect(page).to have_content("Insufficient Funds")
        end
      end
    end
  end
end
