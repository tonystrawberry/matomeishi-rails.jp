# frozen_string_literal: true

##
## Api::V1::BusinessCardsController
## Api::V1::BusinessCardsController is a controller for business cards
##
module Api
  module V1
    class BusinessCardsController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/business_cards
      # Get paginated list of business cards of the current user with optional filters
      def index
        param!(:page, Integer, default: 1)
        param!(:q, String, default: '')
        param!(:tags, Array, default: [])
        param!(:meeting_date_from, Date)
        param!(:meeting_date_to, Date)

        business_cards = BusinessCard.list_for(
          user: current_user,
          page: params[:page],
          filter_parameters: {
            q: params[:q],
            tags: params[:tags],
            meeting_date_from: params[:meeting_date_from],
            meeting_date_to: params[:meeting_date_to]
          }
        )

        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        render json: {
          business_cards: BusinessCardSerializer.new(business_cards, options).serializable_hash,
          current_page: business_cards.current_page,
          total_count: business_cards.total_count,
          total_pages: business_cards.total_pages,
          is_last_page: business_cards.last_page?
        }, status: :ok
      end

      # GET /api/v1/business_cards/:code
      # Get a business card of the current user
      def show
        param!(:code, String, required: true)

        business_card = current_user.business_cards.find_by!(code: params[:code])

        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        render json: BusinessCardSerializer.new(business_card, options).serializable_hash, status: :ok
      end

      # POST /api/v1/business_cards
      # Create a business card for the current user
      def create
        param!(:business_card, Hash, required: true) do |business_card|
          business_card.param!(:front_image, ActionDispatch::Http::UploadedFile, required: true)
          business_card.param!(:back_image, ActionDispatch::Http::UploadedFile)
        end
        param!(:language_hints, String, default: '["en"]') # Default language hints is English

        language_hints = JSON.parse(params[:language_hints])

        business_card = current_user.business_cards.new(status: :analyzing)

        ActiveRecord::Base.transaction do
          business_card.save!
          business_card.attach_images(front_image: business_card_create_params[:front_image], back_image: business_card_create_params[:back_image])
        end

        business_card.analyze!(language_hints: language_hints)

        render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :created
      end

      # PUT /api/v1/business_cards/:code
      # Update a business card of the current user
      def update
        param!(:code, String, required: true)
        param!(:business_card, Hash, required: true) do |business_card|
          business_card.param!(:address, String)
          business_card.param!(:company, String)
          business_card.param!(:department, String)
          business_card.param!(:email, String)
          business_card.param!(:fax, String)
          business_card.param!(:first_name, String, required: true)
          business_card.param!(:first_name_phonetic, String)
          business_card.param!(:home_phone, String)
          business_card.param!(:job_title, String)
          business_card.param!(:last_name, String)
          business_card.param!(:last_name_phonetic, String)
          business_card.param!(:meeting_date, DateTime)
          business_card.param!(:mobile_phone, String)
          business_card.param!(:notes, String)
          business_card.param!(:business_card_tags_attributes, Array)
          business_card.param!(:website, String)
        end

        business_card = current_user.business_cards.find_by!(code: params[:code])

        ActiveRecord::Base.transaction do
          business_card.business_card_tags.destroy_all
          business_card.update!(business_card_update_params)
        end

        render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :ok
      end

      # DELETE /api/v1/business_cards/:code
      # Delete a business card of the current user
      def destroy
        param!(:code, String, required: true)

        business_card = current_user.business_cards.find_by!(code: params[:code])

        business_card.destroy!

        render status: :no_content
      end

      # GET /api/v1/business_cards/export
      # Export all business cards of the current user
      def export
        csv_data = BusinessCard.to_csv(user: current_user)

        send_data(csv_data, type: 'text/csv', filename: "business-cards-#{current_user.id}-#{Time.now.to_i}.csv")
      end

      private

      # Used in #create
      # Returns the permitted parameters for creating a business card
      # @return [ActionController::Parameters]
      def business_card_create_params
        params.require(:business_card).permit(:front_image, :back_image)
      end

      # Used in #update
      # Returns the permitted parameters for creating or updating a business card
      # @return [ActionController::Parameters]
      def business_card_update_params
        permitted_params = params.require(:business_card).permit(
          :address,
          :company,
          :department,
          :email,
          :fax,
          :first_name,
          :first_name_phonetic,
          :home_phone,
          :job_title,
          :last_name,
          :last_name_phonetic,
          :meeting_date,
          :mobile_phone,
          :notes,
          :website,
          business_card_tags_attributes: [:_destroy, { tag_attributes: %i[id name] }]
        )

        permitted_params[:business_card_tags_attributes].each do |business_card_tag|
          business_card_tag[:tag_attributes][:user] = current_user
        end

        permitted_params
      end
    end
  end
end
