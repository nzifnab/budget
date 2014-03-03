require 'spec_helper'

describe "Account History", js: true do
  let(:budget){Budget.new}

  describe "Viewing account history" do
    let(:account){budget.new_account(name: "Emergency Fund", priority: 9, enabled: true, negative_overflow_id: 0)}
    before(:each) do
      account.save!
      quick_fund = account.quick_funds.build(fund_type: "Deposit", amount: 45.83, description: "Extra money")
      quick_fund.save!
      quick_fund2 = account.quick_funds.build(fund_type: "Withdraw", amount: 25.83, description: "Car broke down!")
      quick_fund2.save!
      @history1 = quick_fund.account_histories.first
      @history2 = quick_fund2.account_histories.first
    end

    it "let's me view the quick fund when opening the accordion item" do
      visit accounts_path

      accordion = open_accordion("Emergency Fund")
      within(".sidebar") do
        within("h1") do
          page.should have_content("Emergency Fund")
          page.should have_content("$20.00")
        end

        within("#account_history_#{@history1.id}") do
          page.should have_content("$45.83")
          render_page('test.png')
          page.should have_content("Quick Fund Deposit")
        end

        within("#account_history_#{@history2.id}") do
          page.should have_content("($25.83)")
          page.should have_content("Quick Fund Withdrawal")
        end
      end
    end
  end
end
