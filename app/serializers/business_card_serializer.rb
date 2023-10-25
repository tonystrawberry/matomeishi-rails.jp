# frozen_string_literal: true

# == Schema Information
#
# Table name: business_cards
#
#  id           :bigint           not null, primary key
#  code         :string(100)      not null
#  company      :string(100)
#  email        :string(100)
#  fax          :string(100)
#  first_name   :string(100)
#  home_phone   :string(100)
#  last_name    :string(100)
#  meeting_date :datetime
#  mobile_phone :string(100)
#  notes        :text
#  status       :integer          default("analyzing"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
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
  attributes :id, :code, :company, :email, :fax, :first_name, :home_phone, :last_name, :meeting_date, :mobile_phone, :notes, :status, :created_at, :updated_at

  has_many :tags

  attribute :front_image_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.front_image) if object.front_image.attached?
  end

  attribute :back_image_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.back_image) if object.back_image.attached?
  end
end