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
require 'rails_helper'

RSpec.describe BusinessCard do
  pending "add some examples to (or delete) #{__FILE__}"
end
