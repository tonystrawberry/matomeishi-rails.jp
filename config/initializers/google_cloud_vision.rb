require "google/cloud/vision"

Google::Cloud::Vision.configure do |config|
  config.credentials = JSON.parse(File.read(Rails.root.join("config", "google-cloud-vision-credentials.json")))
end
