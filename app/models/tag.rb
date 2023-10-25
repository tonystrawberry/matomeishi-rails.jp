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
class Tag < ApplicationRecord
  # `name` should be lowercase and underscored (numbers accepted)
  validates :name, presence: true, length: { maximum: 100 }, format: { with: /\A[a-z0-9_]+\z/ }
  validates :color, presence: true

  belongs_to :user

  has_many :business_card_tags, dependent: :destroy
  has_many :business_cards, through: :business_card_tags
end
