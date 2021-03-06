RSpec.describe "Account History", js: true do
  let(:budget){Budget.new(current_user)}
  before(:each) do
    login
  end

  describe "Viewing account history" do
    let(:account){budget.new_account(name: "Emergency Fund", priority: 9, enabled: true, negative_overflow_id: 0)}
    before(:each) do
      account.save!
      quick_fund = account.quick_funds.build(fund_type: "Deposit", amount: 45.83, description: "Extra money")
      quick_fund.save!
      @quick_fund2 = account.quick_funds.build(fund_type: "Withdraw", amount: 25.83, description: "Car broke down!")
      @quick_fund2.save!
      @history1 = quick_fund.account_histories.first
      @history2 = @quick_fund2.account_histories.first
    end

    it "let's me view the quick fund when opening the accordion item" do
      visit accounts_path

      accordion = open_accordion("Emergency Fund")
      within(".sidebar") do
        within("h1") do
          expect(page).to have_content("Emergency Fund")
          expect(page).to have_content("$20.00")
        end

        within("#account_history_#{@history1.id}") do
          expect(page).to have_content("$45.83")
          click_link "Details"
          expect(page).to have_content("Quick Fund Deposit")
        end

        within("#account_history_#{@history2.id}") do
          expect(page).to have_content("($25.83)")
          click_link "Details"
          expect(page).to have_content("Quick Fund Withdrawal")
          click_link "Quick Fund Withdrawal"
        end

        within("#quick_fund_#{@quick_fund2.id}") do
          expect(page).to have_content("Car broke down!")
        end
      end
    end
  end
end
