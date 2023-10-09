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
class BusinessCard < ApplicationRecord
  has_one_attached :front_image
  has_one_attached :back_image

  validates :name, presence: true, length: { maximum: 100 }

  belongs_to :user

  enum status: {
    analyzing: 0,
    analyzed: 1,
    failed: 2
  }, _prefix: true

  before_create :generate_code

  private

  ## Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
