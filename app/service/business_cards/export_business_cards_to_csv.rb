# frozen_string_literal: true

# Service object for exporting the business cards to a CSV format
# Usage:
#   BusinessCard::ExportBusinessCardsToCsv.call(user: user)
module BusinessCards
  class ExportBusinessCardsToCsv
    include Callable

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

    attr_reader :user

    # Initializes the service
    # @param user [User] the user for which to export the business cards
    def initialize(user:)
      @user = user
    end

    # Export the business cards to a CSV format
    # @return [String] the CSV content
    def call
      business_cards = @user.business_cards.order(id: :desc)

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
  end
end
