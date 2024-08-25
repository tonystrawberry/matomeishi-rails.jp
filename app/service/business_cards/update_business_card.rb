# frozen_string_literal: true

# Service object for updating a business card for the current user
# Usage:
#   BusinessCard::UpdateBusinessCard.call(user: user, business_card_code: 'abc123', attributes: { first_name: 'John' })
module BusinessCards
  class UpdateBusinessCard
    include Callable

    attr_reader :business_card, :attributes

    # Initializes the service
    # @param user [User] the user for which to update the business card
    # @param business_card_code [String] the code of the business card to update
    # @param attributes [Hash] the attributes to update
    def initialize(user:, business_card_code:, attributes:)
      @business_card = user.business_cards.find_by!(code: business_card_code)
      @attributes = attributes
    end

    # Update the business card
    # @return [BusinessCard] the updated business card
    def call
      ActiveRecord::Base.transaction do
        @business_card.business_card_tags.destroy_all
        @business_card.update!(@attributes)
      end

      @business_card
    end
  end
end
