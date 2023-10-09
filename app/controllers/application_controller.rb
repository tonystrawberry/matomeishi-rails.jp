# frozen_string_literal: true

##
## ApplicationController - The base class for all controllers
##
class ApplicationController < ActionController::API
  include ExceptionHandler

  # Authenticate user before every action
  before_action :authenticate_user!

  private

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

      user = User.find_by(uid: decoded_payload[0]['uid'])
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

    raise GRPC::Unauthenticated unless public_key_pem

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
      aud: 'matomeishi-rails',
      verify_iss: true,
      iss: 'https://securetoken.google.com/matomeishi-rails'
    )
  end

  ## Fetch Google's public keys for verifying Firebase Authentication JWT tokens
  ## @return [Hash] - public keys
  def fetch_google_public_keys
    uri = URI('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com')
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
