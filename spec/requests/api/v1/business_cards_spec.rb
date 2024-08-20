# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe 'Api::V1::BusinessCards' do
  let(:user) { create(:user) }

  before do
    ApplicationController.any_instance.stub(:decode_token).and_return([
                                                                        {
                                                                          'user_id' => user.uid,
                                                                          'name' => user.name,
                                                                          'email' => user.email,
                                                                          'firebase' => {
                                                                            'sign_in_provider' => 'password'
                                                                          }
                                                                        }
                                                                      ])
  end

  describe 'GET /index (def index)' do
    context 'without parameters' do
      before do
        create_list(:business_card, 20, user: user)
      end

      it 'returns a paginated list of business cards of the current user' do
        get api_v1_business_cards_path, headers: { 'x-firebase-token' => 'token' }

        expect(response).to have_http_status(:ok)

        business_cards = user.business_cards.order(id: :desc).page(1).per(12)
        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        business_cards = BusinessCardSerializer.new(business_cards, options).serializable_hash

        expect(response.body).to eq({
          business_cards: business_cards,
          current_page: 1,
          total_count: 20,
          total_pages: 2,
          is_last_page: false
        }.to_json)
      end
    end

    context 'with q parameter' do
      before do
        create_list(:business_card, 20, user: user)
      end

      let!(:business_cards_with_keyword) do
        [
          create(:business_card, user: user, last_name: 'matching string'),
          create(:business_card, user: user, first_name: 'matching string'),
          create(:business_card, user: user, first_name_phonetic: 'matching string'),
          create(:business_card, user: user, last_name_phonetic: 'matching string'),
          create(:business_card, user: user, company: 'matching string'),
          create(:business_card, user: user, email: 'matching string'),
          create(:business_card, user: user, mobile_phone: 'matching string'),
          create(:business_card, user: user, home_phone: 'matching string'),
          create(:business_card, user: user, fax: 'matching string'),
          create(:business_card, user: user, notes: 'matching string')
        ]
      end

      it 'returns a paginated list of business cards of the current user' do
        get api_v1_business_cards_path, params: { page: 1, q: 'matching string' }, headers: { 'x-firebase-token' => 'token' }

        expect(response).to have_http_status(:ok)

        business_cards = user.business_cards
                             .where(id: business_cards_with_keyword.pluck(:id))
                             .order(id: :desc)
                             .page(1)
                             .per(12)
        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        business_cards = BusinessCardSerializer.new(business_cards, options).serializable_hash

        expect(response.body).to eq({
          business_cards: business_cards,
          current_page: 1,
          total_count: business_cards_with_keyword.count,
          total_pages: 1,
          is_last_page: true
        }.to_json)
      end
    end

    context 'with tags parameter' do
      let!(:tag) { create(:tag, user: user) }
      let!(:business_cards_with_tag) { create_list(:business_card, 10, user: user, tags: [tag]) }

      before do
        # Create 10 business cards without the tag
        create_list(:business_card, 10, user: user)
      end

      it 'returns a paginated list of business cards of the current user' do
        get api_v1_business_cards_path,
            params: { page: 1, tags: [tag.id] },
            headers: { 'x-firebase-token' => 'token' }

        expect(response).to have_http_status(:ok)

        business_cards = user.business_cards.where(id: business_cards_with_tag.pluck(:id)).order(id: :desc).page(1).per(12)
        options = {}
        options[:include] = %i[tags tags.name tags.color tags.description]
        serialized_business_cards = BusinessCardSerializer.new(business_cards, options).serializable_hash

        expect(response.body).to eq({
          business_cards: serialized_business_cards,
          current_page: 1,
          total_count: business_cards_with_tag.count,
          total_pages: 1,
          is_last_page: true
        }.to_json)
      end
    end

    context 'with meeting_date_xx parameter' do
      before do
        [
          create(:business_card, user: user, meeting_date: 1.day.ago),
          create(:business_card, user: user, meeting_date: 2.days.ago),
          create(:business_card, user: user, meeting_date: 3.days.ago),
          create(:business_card, user: user, meeting_date: 4.days.ago),
          create(:business_card, user: user, meeting_date: 5.days.ago),
          create(:business_card, user: user, meeting_date: 6.days.ago),
          create(:business_card, user: user, meeting_date: 7.days.ago),
          create(:business_card, user: user, meeting_date: 8.days.ago),
          create(:business_card, user: user, meeting_date: 9.days.ago),
          create(:business_card, user: user, meeting_date: 10.days.ago)
        ]
      end

      context 'with meeting_date_from parameter' do
        it 'returns a paginated list of business cards of the current user' do
          get api_v1_business_cards_path,
              params: { page: 1, meeting_date_from: 5.days.ago.to_date },
              headers: { 'x-firebase-token' => 'token' }

          expect(response).to have_http_status(:ok)

          business_cards = user.business_cards.where(meeting_date: 5.days.ago.to_date..).order(id: :desc).page(1).per(12)
          options = {}
          options[:include] = %i[tags tags.name tags.color tags.description]
          serialized_business_cards = BusinessCardSerializer.new(business_cards, options).serializable_hash

          expect(response.body).to eq({
            business_cards: serialized_business_cards,
            current_page: 1,
            total_count: business_cards.count,
            total_pages: 1,
            is_last_page: true
          }.to_json)
        end
      end

      context 'with meeting_date_to parameter' do
        it 'returns a paginated list of business cards of the current user' do
          get api_v1_business_cards_path,
              params: { page: 1, meeting_date_to: 5.days.ago.to_date },
              headers: { 'x-firebase-token' => 'token' }

          expect(response).to have_http_status(:ok)

          business_cards = user.business_cards.where(meeting_date: ..5.days.ago.to_date).order(id: :desc).page(1).per(12)
          options = {}
          options[:include] = %i[tags tags.name tags.color tags.description]
          serialized_business_cards = BusinessCardSerializer.new(business_cards, options).serializable_hash

          expect(response.body).to eq({
            business_cards: serialized_business_cards,
            current_page: 1,
            total_count: business_cards.count,
            total_pages: 1,
            is_last_page: true
          }.to_json)
        end
      end
    end
  end

  describe 'GET /show (def show)' do
    let!(:business_card) { create(:business_card, user: user) }

    it 'returns a business card of the current user' do
      get api_v1_business_card_path(business_card.code), headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:ok)

      options = {}
      options[:include] = %i[tags tags.name tags.color tags.description]
      serialized_business_card = BusinessCardSerializer.new(business_card, options).serializable_hash

      expect(response.body).to eq(serialized_business_card.to_json)
    end
  end

  describe 'POST /create (def create)' do
    before do
      # Mock the `analyze!` method of `BusinessCard` model
      allow_any_instance_of(BusinessCard).to receive(:analyze!).and_return(true)

      # Mock the `url` and `attach` methods of the `front_image` attribute of `BusinessCard` model
      image = double
      allow(image).to receive_messages(url: 'https://example.com/image.jpg', attach: true, attached?: true)

      allow_any_instance_of(BusinessCard).to receive(:front_image).and_return(image)
      allow_any_instance_of(BusinessCard).to receive(:back_image).and_return(image)
    end

    it 'creates a business card for the current user' do
      post api_v1_create_business_card_path, params: {
        front_image: fixture_file_upload('business-card.jpg', 'image/jpg'),
        back_image: fixture_file_upload('business-card.jpg', 'image/jpg'),
        language_hints: %w[en ja fr]
      }, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PUT /update (def update)' do
    let!(:business_card) { create(:business_card, user: user) }

    let(:tags) { create_list(:tag, 3, user: user) }

    let!(:params) do
      {
        address: Faker::Address.full_address,
        company: Faker::Company.name,
        department: Faker::Company.profession,
        email: Faker::Internet.email,
        fax: Faker::PhoneNumber.phone_number,
        first_name: Faker::Name.first_name,
        first_name_phonetic: Faker::Name.first_name,
        home_phone: Faker::PhoneNumber.phone_number,
        job_title: Faker::Company.profession,
        last_name: Faker::Name.last_name,
        last_name_phonetic: Faker::Name.last_name,
        meeting_date: Time.zone.today,
        mobile_phone: Faker::PhoneNumber.phone_number,
        notes: Faker::Lorem.sentence,
        tags: tags.map { |tag| { tagId: tag.id, name: tag.name } } + [{ tagId: nil, name: 'custom' }],
        website: Faker::Internet.url
      }
    end

    it 'updates a business card of the current user' do
      put api_v1_update_business_card_path(code: business_card.code), params: params.merge(code: business_card.code),
                                                                      headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:ok)

      business_card.reload

      expect(business_card.address).to eq(params[:address])
      expect(business_card.company).to eq(params[:company])
      expect(business_card.department).to eq(params[:department])
      expect(business_card.email).to eq(params[:email])
      expect(business_card.fax).to eq(params[:fax])
      expect(business_card.first_name).to eq(params[:first_name])
      expect(business_card.first_name_phonetic).to eq(params[:first_name_phonetic])
      expect(business_card.home_phone).to eq(params[:home_phone])
      expect(business_card.job_title).to eq(params[:job_title])
      expect(business_card.last_name).to eq(params[:last_name])
      expect(business_card.last_name_phonetic).to eq(params[:last_name_phonetic])
      expect(business_card.meeting_date).to eq(params[:meeting_date])
      expect(business_card.mobile_phone).to eq(params[:mobile_phone])
      expect(business_card.notes).to eq(params[:notes])
      expect(business_card.tags.pluck(:name).sort).to eq(params[:tags].pluck(:name).sort)
      expect(business_card.website).to eq(params[:website])
    end
  end

  describe 'DELETE /destroy (def destroy)' do
    let!(:business_card) { create(:business_card, user: user) }

    it 'deletes a business card of the current user' do
      delete api_v1_delete_business_card_path(code: business_card.code), headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:no_content)

      expect(BusinessCard.find_by(code: business_card.code)).to be_nil
    end
  end

  describe 'GET /export (def export)' do
    before do
      create_list(:business_card, 20, user: user)
    end

    # TODO: add a mock for `send_data` and check the content of the CSV file
    it 'exports a list of business cards of the current user' do
      get api_v1_business_cards_export_path, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:ok)
    end
  end
end
