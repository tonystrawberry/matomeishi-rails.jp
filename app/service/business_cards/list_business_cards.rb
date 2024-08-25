# frozen_string_literal: true

# Service object for listing business cards of the current user with optional filters
# Usage:
#   BusinessCard::ListBusinessCards.call(user: current_user, page: 1, filter_parameters: { q: 'query', tags: ['tag1', 'tag2'] })
module BusinessCards
  class ListBusinessCards
    include Callable

    attr_reader :user, :page, :filter_parameters

    # Initializes the service
    # @param user [User] the user for which to fetch the business cards
    # @param page [Integer] the page number (page size is 12)
    # @param filter_parameters [Hash] the filter parameters
    # @option filter_parameters [String] :q the search query
    # @option filter_parameters [Array<Integer>] :tags the tag IDs
    # @option filter_parameters [Date] :meeting_date_from the meeting date from
    # @option filter_parameters [Date] :meeting_date_to the meeting date to
    def initialize(user:, page:, filter_parameters:)
      @user = user
      @page = page
      @filter_parameters = filter_parameters
    end

    # Fetches the business cards for the provided user with optional filters
    # @return [ActiveRecord::Relation<BusinessCard>] the paginated business cards
    def call
      business_cards = @user.business_cards
      business_cards = business_cards.joins(:tags).where(tags: { id: @filter_parameters[:tags] }) if @filter_parameters[:tags].present?

      if @filter_parameters[:q].present?
        sanitized_query = ActiveRecord::Base.sanitize_sql_like(@filter_parameters[:q])

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

      business_cards = business_cards.where(meeting_date: (@filter_parameters[:meeting_date_from])..) if @filter_parameters[:meeting_date_from].present?
      business_cards = business_cards.where(meeting_date: ..(@filter_parameters[:meeting_date_to])) if @filter_parameters[:meeting_date_to].present?

      business_cards.distinct.order(id: :desc).page(@page).per(12)
    end
  end
end
