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

    business_cards = business_cards.where(meeting_date: (filter_parameters[:meeting_date_from])..) if filter_parameters[:meeting_date_from].present?
    business_cards = business_cards.where(meeting_date: ..(filter_parameters[:meeting_date_to])) if filter_parameters[:meeting_date_to].present?

    business_cards.distinct.order(id: :desc).page(page).per(12)
  end

  # Attach the provided images to the business card
  # @param front_image [ActionDispatch::Http::UploadedFile] the front image
  # @param back_image [ActionDispatch::Http::UploadedFile] the back image
  def attach_images(front_image:, back_image:)
    if front_image.present?
      self.front_image.attach(
        key: "#{user.id}/#{id}-front-image",
        io: front_image.tempfile,
        filename: "#{id}-front-image.png",
        content_type: 'image/png',
        identify: false
      )
    end

    if back_image.present?
      self.back_image.attach(
        key: "#{user.id}/#{id}-back-image",
        io: back_image.tempfile,
        filename: "#{id}-back-image.png",
        content_type: 'image/png',
        identify: false
      )
    end
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

  # Analyze the business card and save the analyzed data
  # @param language_hints [Array<String>] the language hints for the OCR API
  def analyze!(language_hints: ['en'])
    openai_json = BusinessCardAnalyzer.new(business_card: self, language_hints: language_hints).analyze

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
  rescue BusinessCardAnalyzer::AnalysisFailed
    self.status = :failed
    save!
  end

  private

  # Called on :before_create
  # Generate a unique code for the business card
  def generate_code
    self.code = SecureRandom.hex(10)
  end
end
