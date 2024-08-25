# frozen_string_literal: true

# Service object for creating a business card for the current user
# Usage:
#   BusinessCard::CreateBusinessCard.call(user: user, front_image: front_image, back_image: back_image, language_hints: ['en'])
module BusinessCards
  class CreateBusinessCard
    include Callable

    attr_reader :user, :front_image, :back_image, :language_hints

    # Initializes the service
    # @param user [User] the user for which to fetch the business cards
    # @param front_image [ActionDispatch::Http::UploadedFile] the front image of the business card
    # @param back_image [ActionDispatch::Http::UploadedFile] the back image of the business card
    # @param language_hints [Array<String>] the language hints for the OCR
    def initialize(user:, front_image:, back_image:, language_hints:)
      @user = user
      @front_image = front_image
      @back_image = back_image
      @language_hints = language_hints
    end

    # Create a business card for the provided user
    # @return [BusinessCard] the created and analyzed business card
    def call
      business_card = @user.business_cards.new(status: :analyzing)

      ActiveRecord::Base.transaction do
        business_card.save!
        attach_images(business_card: business_card, front_image: @front_image, back_image: @back_image)
      end

      BusinessCards::AnalyzeBusinessCard.call(business_card: business_card, language_hints: @language_hints)
    end

    private

    # Attach the images to the business card
    # @param business_card [BusinessCard] the business card to attach the images to
    # @param front_image [ActionDispatch::Http::UploadedFile] the front image
    # @param back_image [ActionDispatch::Http::UploadedFile] the back image
    def attach_images(business_card:, front_image:, back_image:)
      if front_image.present?
        business_card.front_image.attach(
          key: "#{business_card.user.id}/#{business_card.id}-front-image",
          io: front_image.tempfile,
          filename: "#{business_card.id}-front-image.png",
          content_type: 'image/png',
          identify: false
        )
      end

      return if back_image.blank?

      business_card.back_image.attach(
        key: "#{business_card.user.id}/#{business_card.id}-back-image",
        io: back_image.tempfile,
        filename: "#{business_card.id}-back-image.png",
        content_type: 'image/png',
        identify: false
      )
    end
  end
end
