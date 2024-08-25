# frozen_string_literal: true

require 'google/cloud/vision' # For OCR API
require 'openai' # For ChatGPT API

# Service object for analyzing a business card by
# extracting the name, phone number, and email address via OCR (Google Vision API) and ChatGPT.
# Usage:
#   AnalyzeBusinessCard.new(business_card: business_card, language_hints: ['en']).call
module BusinessCards
  class AnalyzeBusinessCard
    include Callable

    class AnalysisFailedError < StandardError; end

    # Initializes the service
    # @param business_card [BusinessCard] the business card to analyze
    # @param language_hints [Array<String>] the language hints for the OCR
    def initialize(business_card:, language_hints: [])
      @business_card = business_card
      @language_hints = language_hints
    end

    # Analyze the business card
    # @return [BusinessCard] the analyzed business card
    def call
      openai_json = analyze

      @business_card.status = :analyzed

      @business_card.attributes = {
        first_name: openai_json['first_name'],
        last_name: openai_json['last_name'],
        first_name_phonetic: openai_json['first_name_phonetic'],
        last_name_phonetic: openai_json['last_name_phonetic'],
        company: openai_json['company'],
        job_title: openai_json['job_title'],
        department: openai_json['department'],
        website: openai_json['website'],
        address: openai_json['address'],
        email: openai_json['email'],
        mobile_phone: openai_json['mobile_phone'],
        home_phone: openai_json['home_phone'],
        fax: openai_json['fax']
      }

      @business_card.save!

      @business_card
    rescue AnalysisFailedError
      @business_card.status = :failed
      @business_card.save!

      @business_card
    end

    private

    # Analyze the business card:
    #  - calls OCR API to get the raw text from the images
    #  - submit the text to the ChatGPT API to get the entities in a JSON format
    # @return [Hash] - The analyzed business card data
    #   * :first_name [String] - The first name
    #   * :last_name [String] - The last name
    #   * :first_name_phonetic [String] - The first name phonetic
    #   * :last_name_phonetic [String] - The last name phonetic
    #   * :company [String] - The company
    #   * :job_title [String] - The job title
    #   * :department [String] - The department
    #   * :website [String] - The website
    #   * :address [String] - The address
    #   * :email [String] - The email
    #   * :mobile_phone [String] - The mobile phone
    #   * :home_phone [String] - The home phone
    #   * :fax [String] - The fax
    def analyze
      image_annotator = Google::Cloud::Vision.image_annotator(version: :v1, transport: :grpc)

      images = [@business_card.front_image.url]
      images << @business_card.back_image.url if @business_card.back_image.attached?

      response = image_annotator.text_detection(images: images,
                                                image_context: { 'language_hints' => @language_hints })

      # Get the raw text from the response
      text_to_analyze = ''

      response.responses.each_with_index do |res, index|
        text_to_analyze += "Front Business Card Text >> \n #{res.full_text_annotation&.text}\n\n" if index.zero?
        text_to_analyze += "Back Business Card Text >> \n #{res.full_text_annotation&.text}\n\n" if index == 1
      end

      Rails.logger.info "BusinessCard#analyze! | Text to Analyze:\n #{text_to_analyze}"

      retries = 0

      begin
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

        raise AnalysisFailedError if retries >= 3

        retries += 1
        retry
      end

      {
        'first_name' => openai_json['first_name'],
        'last_name' => openai_json['last_name'],
        'first_name_phonetic' => openai_json['first_name_phonetic'],
        'last_name_phonetic' => openai_json['last_name_phonetic'],
        'company' => openai_json['company'],
        'job_title' => openai_json['job_title'],
        'department' => openai_json['department'],
        'website' => openai_json['website'],
        'address' => openai_json['address'],
        'email' => openai_json['email'],
        'mobile_phone' => openai_json['mobile_phone'],
        'home_phone' => openai_json['home_phone'],
        'fax' => openai_json['fax']
      }
    end
  end
end
