# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ExceptionHandler' do
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

  describe 'rescue_from StandardError' do
    before do
      # Make current_user.business_cards raises a StandardError
      allow_any_instance_of(User).to receive(:business_cards).and_raise(StandardError)
    end

    it 'returns a :internal_surver_error' do
      get api_v1_business_cards_path, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to eq({
        errors: []
      }.to_json)
    end
  end

  describe 'rescue_from ActiveRecord::RecordNotFound' do
    before do
      # Make current_user.business_cards raises a ActiveRecord::RecordNotFound
      allow_any_instance_of(User).to receive(:business_cards).and_raise(ActiveRecord::RecordNotFound)
    end

    it 'returns a :internal_surver_error' do
      get api_v1_business_cards_path, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq({
        errors: []
      }.to_json)
    end
  end

  describe 'rescue_from ActiveRecord::RecordInvalid' do
    before do
      # Make current_user.business_cards raises a ActiveRecord::RecordInvalid
      allow_any_instance_of(User).to receive(:business_cards).and_raise(ActiveRecord::RecordInvalid)
    end

    it 'returns a :internal_surver_error' do
      get api_v1_business_cards_path, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to eq({
        errors: []
      }.to_json)
    end
  end

  describe 'rescue_from RailsParam::InvalidParameterError' do
    before do
      # Make current_user.business_cards raises a RailsParam::InvalidParameterError
      allow_any_instance_of(User).to receive(:business_cards).and_raise(RailsParam::InvalidParameterError.new('test'))
    end

    it 'returns a :internal_surver_error' do
      get api_v1_business_cards_path, headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq({
        errors: []
      }.to_json)
    end
  end
end
