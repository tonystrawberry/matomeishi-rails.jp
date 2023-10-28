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

RSpec.describe Tag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
