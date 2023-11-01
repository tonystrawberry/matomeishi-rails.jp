# frozen_string_literal: true

##
## This concern is used to handle exceptions in the application.
## It is included in the ApplicationController.
##

module ExceptionHandler
  extend ActiveSupport::Concern
  included do
    rescue_from StandardError do |e|
      Rails.logger.error("StandardError: #{e}.")
      Rails.logger.error(e.backtrace.join("\n"))

      Rails.logger.debug { "StandardError: #{e}." }
      Rails.logger.debug e.backtrace.join("\n")

      # Send the error to Bugsnag
      Bugsnag.notify(e)

      render json: {
        errors: []
      }, status: :internal_server_error
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      Rails.logger.warn("ActiveRecord::RecordNotFound: #{e}.")

      render json: {
        errors: []
      }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Rails.logger.warn("ActiveRecord::RecordInvalid: #{e}.")

      # Send the error to Bugsnag
      Bugsnag.notify(e)

      render json: {
        errors: []
      }, status: :unprocessable_entity
    end

    rescue_from RailsParam::InvalidParameterError do |e|
      Rails.logger.warn("RailsParam::InvalidParameterError: #{e}.")

      render json: {
        errors: []
      }, status: :bad_request
    end
  end
end
