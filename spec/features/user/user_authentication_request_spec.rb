require 'spec_helper'

describe "Authentication" do
  let(:current_user){User.create(
    first_name: "Mittens",
    last_name: "The Cat",
    email: "mittens@example.net",
    password: "s3cret"
  )}

  it "let's a user login" do
    current_user
    visit new_sessions_path
    current_path.should == "/login"
    fill_in "email", with: "mittens@example.net"
    fill_in "password", with: "s3cret"
    click_button "Login"

    current_path.should == accounts_path
    within("header") do
      page.should have_content("mittens@example.net")
      page.should have_content("Log Out")
    end
  end

  it "denies login with the wrong password" do
    current_user
    visit new_sessions_path
    fill_in "email", with: "mittens@example.net"
    fill_in "password", with: "secret"
    click_button "Login"

    current_path.should == sessions_path
    page.should have_content("Invalid username or password")
  end
end
