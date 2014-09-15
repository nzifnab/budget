RSpec.describe "Authentication" do
  let(:current_user){User.create!(
    first_name: "Mittens",
    last_name: "The Cat",
    email: "mittens@example.net",
    password: "s3cret",
    password_confirmation: "s3cret"
  )}

  it "let's a user login" do
    current_user
    visit session_path
    expect(current_path).to eq "/login"
    fill_in "Email", with: "mittens@example.net"
    fill_in "Password", with: "s3cret"
    click_button "Login"
    expect(current_path).to eq accounts_path
    within("header") do
      expect(page).to have_content("mittens@example.net")
      expect(page).to have_content("Logout")
    end
  end

  it "denies login with the wrong password" do
    current_user
    visit session_path
    fill_in "Email", with: "mittens@example.net"
    fill_in "Password", with: "secret"
    click_button "Login"

    expect(current_path).to eq session_path
    expect(page).to have_content("Invalid email or password")
  end

  it "requires me to login before visiting the app" do
    visit accounts_path
    expect(current_path).to eq session_path
  end
end
