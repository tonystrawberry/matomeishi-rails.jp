# frozen_string_literal: true

##
## BusinessCardsController
## BusinessCardsController is a controller for business cards
##
class Api::V1::BusinessCardsController < ApplicationController
  before_action :authenticate_user!

  ## Get paginated list of business cards of the current user
  def index
    param!(:page, Integer, default: 1)
    param!(:q, String, default: '')
    param!(:tags, Array, default: [])

    business_cards = current_user.business_cards.order(id: :desc).page(params[:page]).per(12)

    options = {}
    options[:include] = [:tags, :'tags.name', :'tags.color', :'tags.description']
    render json: {
      business_cards: BusinessCardSerializer.new(business_cards, options).serializable_hash,
      current_page: business_cards.current_page,
      total_count: business_cards.total_count,
      total_pages: business_cards.total_pages,
      is_last_page: business_cards.last_page?
    }, status: :ok
  end

  ## Get a business card of the current user
  def show
    param!(:code, String, required: true)

    business_card = current_user.business_cards.find_by!(code: params[:code])

    render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :ok
  end

  ## Create a business card for the current user
  def create
    param!(:front_image, ActionDispatch::Http::UploadedFile, required: true)
    param!(:back_image, ActionDispatch::Http::UploadedFile, required: true)

    ActiveRecord::Base.transaction do
      business_card = current_user.business_cards.new(name: "Business Card #{current_user.business_cards.count + 1}")
      business_card.save!

      business_card.front_image.attach(
        key: "#{business_card.id}-front-image",
        io: params[:front_image],
        filename: "#{business_card.id}-front-image.jpg"
      )

      business_card.back_image.attach(
        key: "#{business_card.id}-back-image",
        io: params[:back_image],
        filename: "#{business_card.id}-back-image.jpg"
      )
    end

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
