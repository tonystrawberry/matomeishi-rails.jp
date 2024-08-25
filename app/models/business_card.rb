# frozen_string_literal: true

require 'csv' # For exporting business cards to CSV

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

##
## BusinessCard model representing a business card
##
class BusinessCard < ApplicationRecord
  has_one_attached :front_image
  has_one_attached :back_image

  validates :first_name, length: { maximum: 100 }
  validates :last_name, length: { maximum: 100 }
  validates :first_name_phonetic, length: { maximum: 100 }
  validates :last_name_phonetic, length: { maximum: 100 }
  validates :job_title, length: { maximum: 100 }
  validates :department, length: { maximum: 100 }
  validates :website, length: { maximum: 100 }
  validates :company, length: { maximum: 100 }
  validates :email, length: { maximum: 100 }
  validates :mobile_phone, length: { maximum: 100 }
  validates :home_phone, length: { maximum: 100 }
  validates :fax, length: { maximum: 100 }
  validates :notes, length: { maximum: 1000 }

  belongs_to :user

  has_many :business_card_tags, dependent: :destroy
  has_many :tags, through: :business_card_tags

  accepts_nested_attributes_for :business_card_tags, allow_destroy: true, reject_if: :all_blank

  def business_card_tags_attributes=(attributes)
    attributes.each do |attribute|
      business_card_tags.build(attribute)
    end
  end

  enum status: {
    analyzing: 0,
    analyzed: 1,
    failed: 2
  }, _prefix: true

  before_create :generate_code

  private

  # Called on :before_create
  # Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
