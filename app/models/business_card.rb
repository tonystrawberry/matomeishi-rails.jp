# frozen_string_literal: true

require 'google/cloud/vision'
require 'openai'

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
#  meeting_date        :datetime
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
  ## Save the entities in the database # | TODO: export the logic to a service or implement a OpenAI API client wrapper
  def analyze!(language_hints: ['en'])
    image_annotator = Google::Cloud::Vision.image_annotator(version: :v1, transport: :grpc)

    response = image_annotator.text_detection(images: [front_image.url, back_image.url],
                                              image_context: { 'language_hints' => language_hints })

    # Get the raw text from the response
    text_to_analyze = ''

    response.responses.each_with_index do |res, index|
      text_to_analyze += "Front Business Card Text >> \n #{res.full_text_annotation&.text}\n\n" if index.zero?
      text_to_analyze += "Back Business Card Text >> \n #{res.full_text_annotation&.text}\n\n" if index == 1
    end

    Rails.logger.info "BusinessCard#analyze! | Text to Analyze:\n #{text_to_analyze}"

    retries = 0

    begin
      # Pass to ChatGPT API
      client = OpenAI::Client.new

      response = client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [{ role: 'user', content: "
            Return me the JSON containing the entities from the business card text below.
            The JSON file should contain the following keys:
            - first_name
            - last_name
            - first_name_phonetic
            - last_name_phonetic
            - company
            - job_title
            - department
            - website
            - address
            - email
            - mobile_phone
            - home_phone
            - fax
            If the key does not seem to be present, please return null as the value.

            #{text_to_analyze}
          " }],
          temperature: 0.7
        }
      )

      openai_json = JSON.parse(response.dig('choices', 0, 'message', 'content'))
    rescue JSON::ParserError => e
      Rails.logger.error "BusinessCard#analyze! | #{e.message}\n #{e.backtrace.join("\n")}"

      # Retry at most 3 times
      if retries < 3
        retries += 1
        retry
      else
        self.status = :failed
        save!
        return
      end
    end

    self.status = :analyzed
    self.first_name = openai_json['first_name']
    self.last_name = openai_json['last_name']
    self.first_name_phonetic = openai_json['first_name_phonetic']
    self.last_name_phonetic = openai_json['last_name_phonetic']
    self.job_title = openai_json['job_title']
    self.department = openai_json['department']
    self.website = openai_json['website']
    self.address = openai_json['address']
    self.company = openai_json['company']
    self.email = openai_json['email']
    self.mobile_phone = openai_json['mobile_phone']
    self.home_phone = openai_json['home_phone']
    self.fax = openai_json['fax']

    save!
  end

  private

  ## Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
