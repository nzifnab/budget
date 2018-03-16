require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Budgeteer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Mountain Time (US & Canada)'
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :old_password]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_view.field_error_proc = Proc.new {|html_tag, instance|
      "#{html_tag}".html_safe
    }

    # Generate structure.sql instead of schema.rb for DB schema.
    config.active_record.schema_format = :sql

    config.assets.precompile += %w(
      screen.css
      *.gif
      *.png
      *.jpg
    )

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
