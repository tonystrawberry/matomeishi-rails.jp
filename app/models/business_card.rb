# frozen_string_literal: true

require 'google/cloud/vision' # For OCR API
require 'openai' # For ChatGPT API
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

  enum status: {
    analyzing: 0,
    analyzed: 1,
    failed: 2
  }, _prefix: true

  before_create :generate_code

  CSV_HEADERS = [
    'Code',
    'First Name',
    'Last Name',
    'First Name Phonetic',
    'Last Name Phonetic',
    'Company',
    'Job Title',
    'Department',
    'Website',
    'Email',
    'Address',
    'Mobile Phone',
    'Home Phone',
    'Fax',
    'Meeting Date',
    'Notes',
    'Status',
    'Created At',
    'Updated At'
  ].freeze

  ###################
  ## Class Methods ##
  ###################

  # Returns the business cards for the provided user
  # Supports pagination, filtering by tags, search query, and meeting date
  # @param user [User] the user for which to fetch the business cards
  # @param page [Integer] the page number
  # @param filter_parameters [Hash] the filter parameters
  # @option filter_parameters [String] :q the search query
  # @option filter_parameters [Array<Integer>] :tags the tag IDs
  # @option filter_parameters [Date] :meeting_date_from the meeting date from
  # @option filter_parameters [Date] :meeting_date_to the meeting date to
  # @return [ActiveRecord::Relation<BusinessCard>] the paginated business cards
  def self.list_for(user:, page: 1, filter_parameters: {})
    business_cards = user.business_cards

    business_cards = business_cards.joins(:tags).where(tags: { id: filter_parameters[:tags] }) if filter_parameters[:tags].present?

    if filter_parameters[:q].present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(filter_parameters[:q])

      business_cards = business_cards.where(
        'first_name ILIKE :q OR
        last_name ILIKE :q OR
        first_name_phonetic ILIKE :q OR
        last_name_phonetic ILIKE :q OR
        company ILIKE :q OR
        email ILIKE :q OR
        mobile_phone ILIKE :q OR
        home_phone ILIKE :q OR
        fax ILIKE :q OR
        notes ILIKE :q',
        q: "%#{sanitized_query}%"
      )
    end

    business_cards = business_cards.where('meeting_date >= ?', filter_parameters[:meeting_date_from]) if filter_parameters[:meeting_date_from].present?
    business_cards = business_cards.where('meeting_date <= ?', filter_parameters[:meeting_date_to]) if filter_parameters[:meeting_date_to].present?

    business_cards.distinct.order(id: :desc).page(page).per(12)
  end

  # Initialize a business card for the provided user
  # @param user [User] the user for which to initialize the business card
  # @param language_hints [Array<String>] the language hints for the OCR API
  # @param front_image [ActionDispatch::Http::UploadedFile] the front image of the business card
  # @param back_image [ActionDispatch::Http::UploadedFile] the back image of the business card
  # @return [BusinessCard] the initialized business card
  def self.initialize_for(user:, language_hints: ['en'], front_image: nil, back_image: nil)
    business_card = user.business_cards.new

    ActiveRecord::Base.transaction do
      business_card.save!

      if front_image.present?
        business_card.front_image.attach(
          key: "#{user.id}/#{business_card.id}-front-image",
          io: front_image.tempfile,
          filename: "#{business_card.id}-front-image.png",
          content_type: 'image/png',
          identify: false
        )
      end

      if back_image.present?
        business_card.back_image.attach(
          key: "#{user.id}/#{business_card.id}-back-image",
          io: back_image.tempfile,
          filename: "#{business_card.id}-back-image.png",
          content_type: 'image/png',
          identify: false
        )
      end
    end

    business_card.analyze!(language_hints: language_hints)
    business_card.reload
  end

  # Get the CSV file content for the business cards of the provided user
  # @param user [User] the user for which to get the CSV file content
  # @return [String] the CSV file content
  def self.to_csv(user:)
    business_cards = user.business_cards.order(id: :desc)

    CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS

      business_cards.each do |business_card|
        csv << [
          business_card.code,
          business_card.first_name,
          business_card.last_name,
          business_card.first_name_phonetic,
          business_card.last_name_phonetic,
          business_card.company,
          business_card.job_title,
          business_card.department,
          business_card.website,
          business_card.email,
          business_card.address,
          business_card.mobile_phone,
          business_card.home_phone,
          business_card.fax,
          business_card.meeting_date&.to_date,
          business_card.notes,
          business_card.status,
          business_card.created_at,
          business_card.updated_at
        ]
      end
    end
  end

  ######################
  ## Instance Methods ##
  ######################

  # Analyze the business card
  # Calls OCR API to analyze the business card (front and back images)
  # Get the text from the images
  # Submit the text to the ChatGPT API to get the entities in a JSON format
  # Save the entities in the database # | TODO: export the logic to a service or implement a OpenAI API client wrapper
  # @param language_hints [Array<String>] the language hints for the OCR API
  def analyze!(language_hints: ['en'])
    image_annotator = Google::Cloud::Vision.image_annotator(version: :v1, transport: :grpc)

    images = [front_image.url]
    images << back_image.url if back_image.attached?

    response = image_annotator.text_detection(images: images,
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

  # Update the business card with the provided attributes and tags
  # @param attributes [Hash] the attributes to update
  # @param tags [Array<Hash>] the tags to update
  # @option tags [Integer] :tagId the tag ID (if the tag already exists)
  # @option tags [String] :name the tag name (if the tag does not exist)
  def update_by!(attributes:, tags:)
    ActiveRecord::Base.transaction do
      update!(attributes: attributes)

      # Delete all tags of the business card before adding new tags
      business_card_tags.destroy_all

      tags.each do |tag|
        if tag[:tagId].present?
          business_card_tags.create!(tag_id: tag[:tagId])
        else
          tag = user.tags.create!(name: tag[:name], color: '#000000', description: '')
          business_card_tags.create!(tag: tag)
        end
      end

      save!
    end
  end

  private

  # Called on :before_create
  # Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
