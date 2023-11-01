# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id                   :bigint           not null, primary key
#  business_cards_count :integer          default(0), not null
#  color                :string(7)        not null
#  description          :text
#  name                 :string(100)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe TagSerializer do
  describe 'attributes' do
    subject { described_class.new(tag).serializable_hash[:data][:attributes] }

    let(:tag) { build(:tag) }

    it { is_expected.to include(id: tag.id) }
    it { is_expected.to include(name: tag.name) }
    it { is_expected.to include(description: tag.description) }
    it { is_expected.to include(color: tag.color) }
    it { is_expected.to include(business_cards_count: tag.business_cards_count) }
  end
end
