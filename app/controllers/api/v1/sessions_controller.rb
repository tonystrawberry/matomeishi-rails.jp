# frozen_string_literal: true

##
## SessionsController
## Handles the sign up and sign in of the user
##
class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[signup signin]

  ## Sign in the user with the token
  ## Get the token from the request header and decode it
  ## Verify the token using Google's token info endpoint
  ## If the token is valid, return the user
  def signin
    token = request.headers['x-firebase-token']

    decoded_payload = decode_token(token)

    user = User.find_or_create_by!(uid: decoded_payload[0]['user_id']) do |user|
      user.name = decoded_payload[0]['name']
      user.email = decoded_payload[0]['email']
      user.provider = decoded_payload[0]['firebase']['sign_in_provider']
    end

    render json: UserSerializer.new(user).serializable_hash, status: :ok
  end
end
