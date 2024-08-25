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

RSpec.describe BusinessCard do
  describe 'validations' do
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:first_name_phonetic).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name_phonetic).is_at_most(100) }
    it { is_expected.to validate_length_of(:job_title).is_at_most(100) }
    it { is_expected.to validate_length_of(:department).is_at_most(100) }
    it { is_expected.to validate_length_of(:website).is_at_most(100) }
    it { is_expected.to validate_length_of(:company).is_at_most(100) }
    it { is_expected.to validate_length_of(:email).is_at_most(100) }
    it { is_expected.to validate_length_of(:mobile_phone).is_at_most(100) }
    it { is_expected.to validate_length_of(:home_phone).is_at_most(100) }
    it { is_expected.to validate_length_of(:fax).is_at_most(100) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:business_card_tags) }
    it { is_expected.to have_many(:tags).through(:business_card_tags) }
    it { is_expected.to have_one_attached(:front_image) }
    it { is_expected.to have_one_attached(:back_image) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(analyzing: 0, analyzed: 1, failed: 2).with_prefix }
  end

  describe 'callbacks' do
    describe 'before_create' do
      describe '#generate_code' do
        let(:business_card) { create(:business_card) }

        it 'generates code' do
          expect(business_card.code).to be_present
        end
      end
    end
  end
end
