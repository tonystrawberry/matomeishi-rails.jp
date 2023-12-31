# frozen_string_literal: true

require 'csv' # For exporting business cards to CSV

##
## Api::V1::BusinessCardsController
## Api::V1::BusinessCardsController is a controller for business cards
##
module Api
  module V1
    class BusinessCardsController < ApplicationController
      before_action :authenticate_user!

      ## GET /api/v1/business_cards
      ## Get paginated list of business cards of the current user
      def index
        param!(:page, Integer, default: 1)
        param!(:q, String, default: '')
        param!(:tags, Array, default: [])
        param!(:meeting_date_from, Date)
        param!(:meeting_date_to, Date)

        business_cards = current_user.business_cards

        business_cards = business_cards.joins(:tags).where(tags: { id: params[:tags] }) if params[:tags].present?

        # Should search through all fields of the business card
        if params[:q].present?
          business_cards = business_cards.where(
            'first_name ILIKE :q OR
        last_name ILIKE :q OR
        first_name_phonetic ILIKE :q OR
        last_name_phonetic ILIKE :q OR
        company ILIKE :q OR
        email ILIKE :q OR
        mobile_phone ILIKE :q OR
        home_phone ILIKE :q OR
        fax ILIKE :q OR
        notes ILIKE :q',
            q: "%#{params[:q]}%"
          )
        end

        # Get business cards that have meeting date between meeting_date_from and meeting_date_to
        business_cards = business_cards.where('meeting_date >= ?', params[:meeting_date_from]) if params[:meeting_date_from].present?

        business_cards = business_cards.where('meeting_date <= ?', params[:meeting_date_to]) if params[:meeting_date_to].present?

        business_cards = business_cards.distinct.order(id: :desc).page(params[:page]).per(12)

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

      ## GET /api/v1/business_cards/:code
      ## Get a business card of the current user
      def show
        param!(:code, String, required: true)

        business_card = current_user.business_cards.find_by!(code: params[:code])

        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        render json: BusinessCardSerializer.new(business_card, options).serializable_hash, status: :ok
      end

      ## POST /api/v1/business_cards
      ## Create a business card for the current user
      def create
        param!(:front_image, ActionDispatch::Http::UploadedFile, required: true)
        param!(:back_image, ActionDispatch::Http::UploadedFile)
        param!(:language_hints, String, default: '["en"]') # Default language hints is English

        language_hints = JSON.parse(params[:language_hints])

        business_card = current_user.business_cards.new

        ActiveRecord::Base.transaction do
          business_card.save!

          %w[front back].each do |attachment_type|
            next if params[:"#{attachment_type}_image"].blank?

            business_card.send("#{attachment_type}_image").attach(
              key: "#{current_user.id}/#{business_card.id}-#{attachment_type}-image",
              io: params[:"#{attachment_type}_image"].tempfile,
              filename: "#{business_card.id}-#{attachment_type}-image.png",
              content_type: 'image/png',
              identify: false
            )
          end
        end

        business_card.analyze!(language_hints: language_hints)
        business_card.reload

        render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :created
      end

      ## PUT /api/v1/business_cards/:code
      ## Update a business card of the current user
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

        ActiveRecord::Base.transaction do
          business_card.update!(
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
          )

          # Delete all tags of the business card before readding new tags
          business_card.business_card_tags.destroy_all

          params[:tags].each do |tag|
            if tag[:tagId].present?
              business_card.business_card_tags.create!(tag_id: tag[:tagId])
            else
              tag = current_user.tags.create!(name: tag[:name], color: '#000000', description: '')
              business_card.business_card_tags.create!(tag: tag)
            end
          end

          business_card.save!
        end

        render json: BusinessCardSerializer.new(business_card).serializable_hash, status: :ok
      end

      ## DELETE /api/v1/business_cards/:code
      ## Delete a business card of the current user
      def destroy
        param!(:code, String, required: true)

        business_card = current_user.business_cards.find_by!(code: params[:code])

        business_card.destroy!

        render status: :no_content
      end

      ## GET /api/v1/business_cards/export
      ## Export all business cards of the current user
      def export
        business_cards = current_user.business_cards.order(id: :desc)

        headers = [
          'Code',
          'First Name',
          'Last Name',
          'First Name Phonetic',
          'Last Name Phonetic',
          'Company',
          'Job Title',
          'Department',
          'Website',
          'Email',
          'Address',
          'Mobile Phone',
          'Home Phone',
          'Fax',
          'Meeting Date',
          'Notes',
          'Status',
          'Created At',
          'Updated At'
        ]

        csv_data = CSV.generate(headers: true) do |csv|
          csv << headers

          business_cards.each do |business_card|
            csv << [
              business_card.code,
              business_card.first_name,
              business_card.last_name,
              business_card.first_name_phonetic,
              business_card.last_name_phonetic,
              business_card.company,
              business_card.job_title,
              business_card.department,
              business_card.website,
              business_card.email,
              business_card.address,
              business_card.mobile_phone,
              business_card.home_phone,
              business_card.fax,
              business_card.meeting_date&.to_date,
              business_card.notes,
              business_card.status,
              business_card.created_at,
              business_card.updated_at
            ]
          end
        end

        send_data(csv_data, type: 'text/csv', filename: "business-cards-#{current_user.id}-#{Time.now.to_i}.csv")
      end
    end
  end
end
