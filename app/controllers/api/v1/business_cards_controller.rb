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
        param!(:front_image, ActionDispatch::Http::UploadedFile, required: true)
        param!(:back_image, ActionDispatch::Http::UploadedFile)
        param!(:language_hints, String, default: '["en"]') # Default language hints is English

        language_hints = JSON.parse(params[:language_hints])

        business_card = BusinessCard.initialize_for(
          user: current_user,
          language_hints: language_hints,
          front_image: params[:front_image],
          back_image: params[:back_image]
        )

        render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :created
      end

      # PUT /api/v1/business_cards/:code
      # Update a business card of the current user
      def update
        param!(:address, String)
        param!(:company, String)
        param!(:department, String)
        param!(:email, String)
        param!(:fax, String)
        param!(:first_name, String, required: true)
        param!(:first_name_phonetic, String)
        param!(:home_phone, String)
        param!(:job_title, String)
        param!(:last_name, String)
        param!(:last_name_phonetic, String)
        param!(:meeting_date, DateTime)
        param!(:mobile_phone, String)
        param!(:notes, String)
        param!(:tags, Array)
        param!(:website, String)

        business_card = current_user.business_cards.find_by!(code: params[:code])

        attributes = {
          address: params[:address],
          company: params[:company],
          department: params[:department],
          email: params[:email],
          fax: params[:fax],
          first_name: params[:first_name],
          first_name_phonetic: params[:first_name_phonetic],
          home_phone: params[:home_phone],
          job_title: params[:job_title],
          last_name: params[:last_name],
          last_name_phonetic: params[:last_name_phonetic],
          meeting_date: params[:meeting_date],
          mobile_phone: params[:mobile_phone],
          notes: params[:notes],
          website: params[:website]
        }

        business_card.update_by!(attributes: attributes, tags: params[:tags])

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
    end
  end
end
