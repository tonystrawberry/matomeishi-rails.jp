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
require 'rails_helper'

RSpec.describe BusinessCardSerializer do
  describe 'attributes' do
    subject { described_class.new(business_card).serializable_hash[:data][:attributes] }

    let(:business_card) { build(:business_card) }

    it { is_expected.to include(id: business_card.id) }
    it { is_expected.to include(code: business_card.code) }
    it { is_expected.to include(first_name: business_card.first_name) }
    it { is_expected.to include(last_name: business_card.last_name) }
    it { is_expected.to include(first_name_phonetic: business_card.first_name_phonetic) }
    it { is_expected.to include(last_name_phonetic: business_card.last_name_phonetic) }
    it { is_expected.to include(company: business_card.company) }
    it { is_expected.to include(department: business_card.department) }
    it { is_expected.to include(job_title: business_card.job_title) }
    it { is_expected.to include(email: business_card.email) }
    it { is_expected.to include(website: business_card.website) }
    it { is_expected.to include(address: business_card.address) }
    it { is_expected.to include(home_phone: business_card.home_phone) }
    it { is_expected.to include(mobile_phone: business_card.mobile_phone) }
    it { is_expected.to include(fax: business_card.fax) }
    it { is_expected.to include(notes: business_card.notes) }
    it { is_expected.to include(meeting_date: business_card.meeting_date) }
    it { is_expected.to include(status: business_card.status) }
    it { is_expected.to include(created_at: business_card.created_at) }
    it { is_expected.to include(updated_at: business_card.updated_at) }
  end
end
