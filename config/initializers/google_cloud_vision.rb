# frozen_string_literal: true

require 'google/cloud/vision'

Google::Cloud::Vision.configure do |config|
  config.credentials = JSON.parse(Rails.root.join('google-cloud-vision-credentials.json').read)
end
