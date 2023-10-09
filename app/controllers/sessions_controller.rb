# frozen_string_literal: true

##
## SessionsController
## Handles the sign up and sign in of the user
##
class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[signup signin]

  ## Sign up the user with the token
  ## Get the token from the request header and decode it
  ## Verify the token using Google's token info endpoint
  ## If the token is valid, create a new user
  def signup
    token = request.headers['x-firebase-token']

    decoded_payload = decode_token(token)

    user = User.create!(
      name: decoded_payload[0]['name'],
      email: decoded_payload[0]['email'],
      uid: decoded_payload[0]['uid'],
      provider: decoded_payload[0]['provider']
    )

    render json: UserSerializer.new(user).serializable_hash, status: :created
  end

  ## Sign in the user with the token
  ## Get the token from the request header and decode it
  ## Verify the token using Google's token info endpoint
  ## If the token is valid, return the user
  def signin
    token = request.headers['x-firebase-token']

    decoded_payload = decode_token(token)

    user = User.find_by(uid: decoded_payload[0]['uid'])

    render json: UserSerializer.new(user).serializable_hash, status: :ok
  end
end
