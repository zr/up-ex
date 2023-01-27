# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development? || Rails.env.test?
    allow do
      origins "http://#{ENV.fetch('APP_DOMAIN', 'localhost')}:3000"

      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head],
               credentials: true
    end
  end

  if Rails.env.production?
    allow do
      origins(%r{\Ahttps://\w*\.*#{Regexp.escape(ENV.fetch('APP_DOMAIN', 'example.com'))}:\d+\z})

      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head],
               credentials: true
    end
  end
end
