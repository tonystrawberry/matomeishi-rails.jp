# frozen_string_literal: true

# Service object for destroying a business card for the current user
# Usage:
#   BusinessCard::DestroyBusinessCard.call(user: user, business_card_code: 'abc123')
module BusinessCards
  class DestroyBusinessCard
    include Callable

    attr_reader :business_card

    # Initializes the service
    # @param user [User] the user for which to destroy the business card
    # @param business_card_code [String] the code of the business card to destroy
    def initialize(user:, business_card_code:)
      @business_card = user.business_cards.find_by!(code: business_card_code)
    end

    # Destroy the business card
    # @return [void]
    def call
      @business_card.destroy!
    end
  end
end
