# frozen_string_literal: true

##
## BusinessCardsController
## BusinessCardsController is a controller for business cards
##
class BusinessCardsController < ApplicationController
  before_action :authenticate_user!

  ## Get paginated list of business cards of the current user
  def index
    param!(:page, Integer, default: 1)
    param!(:per_page, Integer, default: 10)

    business_cards = current_user.business_cards.page(params[:page]).per(params[:per_page])

    render json: BusinessCardSerializer.new(business_cards).serializable_hash, status: :ok
  end

  ## Get a business card of the current user
  def show
    param!(:code, String, required: true)

    business_card = current_user.business_cards.find_by!(code: params[:code])

    render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :ok
  end

  ## Create a business card for the current user
  def create
    param!(:name, String, required: true)
    param!(:front_image, String, required: true)
    param!(:back_image, String, required: true)

    business_card = current_user.business_cards.create!(
      name: params[:name]
    )

    business_card.front_image.attach(
      key: "#{business_card.id}-front-image",
      io: StringIO.new(Base64.decode64(params[:front_image])),
      filename: "#{business_card.id}-front-image.jpg"
    )

    business_card.back_image.attach(
      key: "#{business_card.id}-back-image",
      io: StringIO.new(Base64.decode64(params[:back_image])),
      filename: "#{business_card.id}-back-image.jpg"
    )

    render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :created
  end

  ## Update a business card of the current user
  def update
    param!(:name, String, required: true)

    business_card = current_user.business_cards.find_by!(code: params[:code])

    business_card.update!(
      name: params[:name]
    )

    render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :ok
  end

  ## Delete a business card of the current user
  def destroy
    param!(:code, String, required: true)

    business_card = current_user.business_cards.find_by!(code: params[:code])

    business_card.destroy!

    render status: :no_content
  end
end
