require 'rails_helper'

RSpec.describe "Income", js: true do
  let(:budget){Budget.new(current_user)}
  before(:each) do
    login
  end

  describe "Recording Income" do
    before(:each) do
      budget.new_account(name: "Savings", priority: 9, enabled: true, add_per_month: "200".to_d, add_per_month_type: "$").save!
      budget.new_account(name: "House", priority: 3, enabled: true, add_per_month: "25".to_d, add_per_month_type: "%").save!
      budget.new_account(name: "Insurance", priority: 8, enabled: true, add_per_month: "451.88".to_d, add_per_month_type: "$", amount: "300".to_d, cap: "700".to_d).save!

      # With these accounts:
      # name      | priority | add_per_month | amount | cap  |
      # ------------------------------------------------------
      # Savings   | 9        | $200          | $0     | --   |
      # House     | 3        | 25%           | $0     | --   |
      # Insurance | 8        | $451.88       | $300   | $700 |
      #
      # And a distribution of $987.65
      #
      # Should distribute like this:
      # name      | amount  |
      # ---------------------
      # Savings   | $200    |
      # Insurance | $400    |
      # House     | $96.91  |
      # Excess    | $290.74 |
    end

    it "let's me add an income value and distributes it amongst my accounts" do
      visit accounts_path
      click_link("Income")

      fill_in "Amount", with: "987.65"
      fill_in "Description", with: "Salary Paycheck"
      click_button("Distribute Funds")

      within(".js-sidebar-content") do
        expect(page).to have_content("Income")
        expect(page).to have_content("Salary Paycheck")
        expect(page).to have_content("$987.65")

        within("[data-account-name='Savings']") do
          expect(page).to have_content("$200")
        end
        within("[data-account-name='Insurance']") do
          expect(page).to have_content("$400")
        end
        within("[data-account-name='House']") do
          expect(page).to have_content("$96.91")
        end
        within("[data-account-name='Undistributed Funds']") do
          expect(page).to have_content("$290.74")
        end
      end
    end
  end
end
