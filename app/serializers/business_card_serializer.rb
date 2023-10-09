# frozen_string_literal: true

# == Schema Information
#
# Table name: business_cards
#
#  id         :bigint           not null, primary key
#  name       :string(100)      not null
#  status     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_business_cards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class BusinessCardSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :person_name, :front_image_url, :back_image_url
end
