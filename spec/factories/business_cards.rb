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
#  meeting_date        :date
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
FactoryBot.define do
  factory :business_card do
    user

    code { Faker::Code.unique.asin }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    first_name_phonetic { Faker::Name.first_name }
    last_name_phonetic { Faker::Name.last_name }
    company { Faker::Company.name }
    department { Faker::Company.profession }
    job_title { Faker::Company.profession }
    email { Faker::Internet.email }
    website { Faker::Internet.url }
    address { Faker::Address.full_address }
    home_phone { Faker::PhoneNumber.phone_number }
    mobile_phone { Faker::PhoneNumber.phone_number }
    fax { Faker::PhoneNumber.phone_number }
    notes { Faker::Lorem.paragraph }
    status { BusinessCard.statuses.keys.sample }
    meeting_date { Faker::Date.between(from: 2.days.ago, to: Time.zone.today) }

    trait :with_analyzing_state do
      first_name { nil }
      last_name { nil }
      first_name_phonetic { nil }
      last_name_phonetic { nil }
      company { nil }
      department { nil }
      job_title { nil }
      email { nil }
      website { nil }
      address { nil }
      home_phone { nil }
      mobile_phone { nil }
      fax { nil }
      notes { nil }
      status { :analyzing }
      meeting_date { nil }
    end
  end
end
