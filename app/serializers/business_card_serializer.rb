# frozen_string_literal: true

# == Schema Information
#
# Table name: business_cards
#
#  id         :bigint           not null, primary key
#  code       :string(100)      not null
#  name       :string(100)      not null
#  status     :integer          default("analyzing"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_business_cards_on_code     (code) UNIQUE
#  index_business_cards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class BusinessCardSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :status, :code, :front_image_url, :back_image_url

  attribute :front_image_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.front_image, only_path: true) if object.front_image.attached?
  end

  attribute :back_image_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.back_image, only_path: true) if object.back_image.attached?
  end
end
