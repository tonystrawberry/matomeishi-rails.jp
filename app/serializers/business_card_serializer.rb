# frozen_string_literal: true

# == Schema Information
#
# Table name: business_cards
#
#  id                  :bigint           not null, primary key
#  address             :string
#  code                :string(100)      not null
#  company             :string(100)
#  department          :string(100)
#  email               :string(100)
#  fax                 :string(100)
#  first_name          :string(100)
#  first_name_phonetic :string
#  home_phone          :string(100)
#  job_title           :string(100)
#  last_name           :string(100)
#  last_name_phonetic  :string
#  meeting_date        :datetime
#  mobile_phone        :string(100)
#  notes               :text
#  status              :integer          default("analyzing"), not null
#  website             :string(100)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
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
  attributes :id,
              :code,
              :company,
              :department,
              :job_title,
              :website,
              :address,
              :email,
              :fax,
              :first_name,
              :first_name_phonetic,
              :home_phone,
              :last_name,
              :last_name_phonetic,
              :meeting_date,
              :mobile_phone,
              :notes,
              :status,
              :created_at,
              :updated_at

  has_many :tags

  attribute :front_image_url do |object|
    object.front_image.url if object.front_image.attached?
  end

  attribute :back_image_url do |object|
    object.back_image.url if object.back_image.attached?
  end
end
