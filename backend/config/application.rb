require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.action_controller.default_url_options = {
      host: ENV.fetch("APP_HOST") { "localhost" },
      port: ENV.fetch("APP_PORT") { "3000" }
    }
  end
end
