# frozen_string_literal: true

require "google/cloud/vision"

# == Schema Information
#
# Table name: business_cards
#
#  id           :bigint           not null, primary key
#  code         :string(100)      not null
#  company      :string(100)
#  email        :string(100)
#  fax          :string(100)
#  first_name   :string(100)
#  home_phone   :string(100)
#  last_name    :string(100)
#  meeting_date :datetime
#  mobile_phone :string(100)
#  notes        :text
#  status       :integer          default("analyzing"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
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

  validates :first_name, length: { maximum: 100 }
  validates :last_name, length: { maximum: 100 }
  validates :company, length: { maximum: 100 }
  validates :email, length: { maximum: 100 }
  validates :mobile_phone, length: { maximum: 100 }
  validates :home_phone, length: { maximum: 100 }
  validates :fax, length: { maximum: 100 }
  validates :notes, length: { maximum: 1000 }

  belongs_to :user

  has_many :business_card_tags, dependent: :destroy
  has_many :tags, through: :business_card_tags

  enum status: {
    analyzing: 0,
    analyzed: 1,
    failed: 2
  }, _prefix: true

  before_create :generate_code

  ## Analyze the business card
  ## Calls OCR API to analyze the business card (front and back images)
  ## Get the text from the images
  ## Submit the text to the ChatGPT API to get the entities in a JSON format
  ## Save the entities in the database
  def analyze!
    image_annotator = Google::Cloud::Vision.image_annotator(version: :v1, transport: :grpc)

    response = image_annotator.text_detection(images: ["https://rlv.zcache.jp/svc/view?realview=113335724526596936&design=2f033e99-f36a-41f7-8930-2cabf5f07498&style=3.5x2&media=175ptmatte&cornerstyle=normal&envelopes=none&max_dim=1080&zattribution=none"])

    # Get the raw text from the response
    response.responses.each do |res|
      puts res.full_text_annotation.text
    end


  end

  private

  ## Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
