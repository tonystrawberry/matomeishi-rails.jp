# frozen_string_literal: true

require 'jwt'
require 'net/http'

##
## ApplicationController - The base class for all controllers
##
class ApplicationController < ActionController::API
  before_bugsnag_notify :add_user_info_to_bugsnag

  include ExceptionHandler

  # Authenticate user before every action
  before_action :authenticate_user!

  private

  # :nocov:
  ## Add user info to Bugsnag
  ## This will allow us to see the user info in the Bugsnag dashboard
  def add_user_info_to_bugsnag(event)
    event.set_user(current_user.id, current_user.email, current_user.name) if current_user.present?
  end

  ## Authenticate the user with the token
  def authenticate_user!
    # Check if the user is authenticated with the token
    if current_user.present?
      # If the user is authenticated, continue with the request
    else
      # If the user is not authenticated, return :unauthorized
      render json: {}, status: :unauthorized
    end
  end

  ## Get the current user from the token
  def current_user
    # Get the token from the request header
    token = request.headers['x-firebase-token']

    # If the token is present, decode it and return the user
    if token
      decoded_payload = decode_token(token)

      user = User.find_or_initialize_by(uid: decoded_payload[0]['user_id'])
      user.name = decoded_payload[0]['name']
      user.email = decoded_payload[0]['email']
      user.providers.push(decoded_payload[0]['firebase']['sign_in_provider']) if user.providers.exclude?(decoded_payload[0]['firebase']['sign_in_provider'])
      user.save!
    end

    # Return the user
    user
  end

  ## Decode a Firebase Authentication JWT token and verify its signature
  ## @param [String] - token
  ## @return [Hash] - payload
  def decode_token(token)
    # Decode the JWT token without verifying its signature to obtain the kid
    decoded_payload = JWT.decode(
      token,
      nil, # The public key will be used for verification separately
      false, # Do not perform signature verification here
      algorithm: 'RS256'
    )

    # Obtain the public key based on the key ID (kid) from the JWT header
    key_id = decoded_payload[1]['kid']
    public_key_pem = fetch_google_public_keys[key_id]

    return render json: {}, status: :unauthorized unless public_key_pem

    # Create a public key object from the PEM-formatted string
    certificate = OpenSSL::X509::Certificate.new(public_key_pem)
    public_key = certificate.public_key

    # Decode the JWT token and verify its signature using the public key
    # The JWT token is verified against the following claims:
    #   - iat (issued at)
    #   - aud (audience)
    #   - iss (issuer)
    JWT.decode(
      token,
      public_key,
      true,
      algorithm: 'RS256',
      verify_iat: true,
      verify_aud: true,
      aud: 'matomeishi',
      verify_iss: true,
      iss: 'https://securetoken.google.com/matomeishi'
    )
  end

  ## Fetch Google's public keys for verifying Firebase Authentication JWT tokens
  ## @return [Hash] - public keys
  def fetch_google_public_keys
    uri = URI('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com')
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
  # :nocov:
end
