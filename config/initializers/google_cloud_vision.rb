# frozen_string_literal: true

require 'google/cloud/vision'

return if Rails.env.test? # Don't run this initializer in test environment

Google::Cloud::Vision.configure do |config|
  config.credentials = JSON.parse(Rails.root.join('google-cloud-vision-credentials.json').read)
end
