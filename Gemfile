source "https://rubygems.org"
ruby '2.2.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.6'
gem 'pg'

gem 'haml-rails'
gem 'haml'
gem 'uglifier'
gem 'jbuilder'
#gem 'squeel'
gem 'will_paginate'
gem 'valid_email'



# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby'
gem 'bcrypt'

gem 'therubyracer'
gem 'execjs'
gem 'draper'

# TEMPORARY due to mail validator issue:
# https://github.com/hallelujah/valid_email/issues/33
#gem 'mail', '~> 2.5.0'

platform :ruby do
  gem 'puma'
end

group :production do
  gem 'rails_12factor'
end

#gem 'sprockets', '~> 2.11.0' # TEMPORARY until `compass-rails` fixes it's issue...
# https://github.com/Compass/compass-rails/issues/144...
# AND until the argument # is fixed: https://github.com/sstephenson/sprockets/issues/540
gem 'compass'#, '~> 1.0.1'
gem 'compass-rails'#, '~> 2.0.0'
gem 'coffee-rails'
gem 'sass-rails'#, '4.0.1' # 4.0.2 and 4.0.3 force a lower version of sass
                          # which causes compass to go from 1.x to 0.12
gem 'font-awesome-sass'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'susy'
gem 'breakpoint'

group :development, :test do
  gem 'rspec-rails'
  gem 'autotest-rails'
  gem 'ZenTest'
  gem 'poltergeist'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'teaspoon-jasmine'
  gem 'active_record_query_trace'
end

group :test do
  gem 'timecop'
end

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
