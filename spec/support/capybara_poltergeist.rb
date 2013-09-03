require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false

def render_page(filename)
  file_location = Rails.root.join("tmp", filename)
  page.driver.render(file_location, full: true)
  `open #{file_location}`
end
