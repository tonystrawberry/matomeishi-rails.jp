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
#
FactoryBot.define do
  factory :tag do
    
  end
end
