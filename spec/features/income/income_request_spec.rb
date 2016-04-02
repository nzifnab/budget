require 'rails_helper'

RSpec.describe "Income", js: true do
  let(:budget){Budget.new(current_user)}
  let(:savings){budget.new_account(name: "Savings", priority: 9, enabled: true, add_per_month: "200".to_d, add_per_month_type: "$").tap{|a| a.save!}}
  let(:house){budget.new_account(name: "House", priority: 3, enabled: true, add_per_month: "25".to_d, add_per_month_type: "%").tap{|a| a.save!}}
  let(:insurance){budget.new_account(name: "Insurance", priority: 8, enabled: true, add_per_month: "451.88".to_d, add_per_month_type: "$", amount: "300".to_d, cap: "700".to_d).tap{|a| a.save!}}
  before(:each) do
    login
  end

  describe "Recording Income" do
    before(:each) do

      savings;house;insurance
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

    it "let's me undo an income, reverting the values from all distributed accounts" do
      savings.update_attributes(amount: 150)
      house.update_attributes(amount: 250)
      current_user.update_attributes(undistributed_funds: 100)
      visit incomes_path
      fill_in "Amount", with: "987.65"
      fill_in "Description", with: "Salary Paycheck"
      click_button("Distribute Funds")

      within(".js-sidebar-content") do
        expect(page).to have_content("$987.65")

        expect(savings.reload.amount).to eq("350".to_d)
        expect(house.reload.amount).to eq("346.91".to_d)
        expect(insurance.reload.amount).to eq("700".to_d)
        expect(current_user.reload.undistributed_funds).to eq("390.74".to_d)

        expect {
          click_link "Revert"

          expect(page).not_to have_content("$987.65")
          expect(page).not_to have_content("Salary Paycheck")
          expect(page).to have_content("Income")
          expect(page).not_to have_css("[data-account-name]")
        }.to change {
          AccountHistory.count
        }.from(4).to(0)

        expect(savings.reload.amount).to eq("150".to_d)
        expect(house.reload.amount).to eq("250".to_d)
        expect(insurance.reload.amount).to eq("300".to_d)
        expect(current_user.reload.undistributed_funds).to eq("100".to_d)
      end
    end

    it "shows a validation error if an account had insuficient funds" do
      savings
      visit incomes_path
      fill_in "Amount", with: "987.65"
      fill_in "Description", with: "Salary Paycheck"
      click_button("Distribute Funds")
      savings.update_attributes(amount: 50)
      current_user.update_attributes(undistributed_funds: 2_150)

      visit incomes_path
      within(".js-sidebar-content") do
        click_link "Details"

        expect(page).to have_content("$987.65")

        expect {
          click_link "Revert"

          expect(page).to have_content("Savings - Insufficient Funds")
          expect(page).to have_content("$987.65")
          expect(page).to have_content("Salary Paycheck")
          expect(page).to have_content("Income")
          expect(page).to have_css("[data-account-name='Savings']")
        }.not_to change {
          AccountHistory.count
        }.from(4)

        expect(savings.reload.amount).to eq("50".to_d)
        expect(current_user.reload.undistributed_funds).to eq("2150".to_d)
      end
    end
  end
end
