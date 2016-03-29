RSpec.describe "Category sums", js: true do
  let(:budget){Budget.new(current_user)}
  before(:each) do
    login
  end

  describe "Viewing sums of accounts" do
    let(:account){budget.new_account(name: "Food", priority: 9, enabled: true, amount: 150)}
    before(:each) do
      account.save!
    end

    it "let's me set a category on an account and view the total in the header" do
      visit accounts_path

      expect(page).not_to have_css(".js-category-sums .box")
      accordion = open_accordion("Food")
      within(accordion[:content]) do
        click_link "Edit"

        select "— Create New Category —", from: "Category"
        fill_in "Category Name", with: "Checking Account"
        click_button "Update"
      end

      within(".js-category-sums .box") do
        expect(page).to have_content("Checking Account")
        expect(page).to have_content("$150.00")
      end

      within(find_accordion("Food")[:content]) do
        expect(page).to have_content("Checking Account")
        fill_in "Amount", with: "250"
        click_button "Deposit"
      end

      within(".js-category-sums .box") do
        expect(page).to have_content("Checking Account")
        expect(page).to have_content("$400.00")
      end
    end
  end
end
