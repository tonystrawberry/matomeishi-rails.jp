# frozen_string_literal: true

# == Schema Information
#
# Table name: business_card_tags
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_card_id :bigint           not null
#  tag_id           :bigint           not null
#
# Indexes
#
#  index_business_card_tags_on_business_card_id  (business_card_id)
#  index_business_card_tags_on_tag_id            (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_card_id => business_cards.id)
#  fk_rails_...  (tag_id => tags.id)
#
require 'rails_helper'

RSpec.describe BusinessCardTag do
  pending "add some examples to (or delete) #{__FILE__}"
end
