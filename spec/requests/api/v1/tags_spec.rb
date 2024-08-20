# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Tags' do
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
    before do
      create_list(:tag, 13, user: user) # rubocop:disable FactoryBot/ExcessiveCreateList | We are paginating with a page size of 12 so we need at least 13 records
    end

    it 'returns all tags of the current user' do
      get api_v1_tags_path, headers: { 'x-firebase-token' => 'token' }

      tags = user.tags.order(id: :desc)
      serialized_tags = TagSerializer.new(tags).serializable_hash

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(serialized_tags.to_json)
    end
  end

  describe 'GET /show (def show)' do
    let(:tag) { create(:tag, user: user) }

    it 'returns the tag' do
      get api_v1_tag_path(tag), headers: { 'x-firebase-token' => 'token' }

      serialized_tag = TagSerializer.new(tag).serializable_hash

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(serialized_tag.to_json)
    end
  end

  describe 'PUT /update (def update)' do
    let(:tag) { create(:tag, user: user) }

    it 'updates the tag' do
      put api_v1_tag_path(id: tag.id), params: { name: 'new_name', color: '#000000', description: 'new description' },
                                       headers: { 'x-firebase-token' => 'token' }

      tag.reload

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(TagSerializer.new(tag).serializable_hash.to_json)

      expect(tag.name).to eq('new_name')
      expect(tag.color).to eq('#000000')
      expect(tag.description).to eq('new description')
    end
  end

  describe 'DELETE /destroy (def destroy)' do
    let(:tag) { create(:tag, user: user) }

    it 'deletes the tag' do
      delete api_v1_tag_path(id: tag.id), headers: { 'x-firebase-token' => 'token' }

      expect(response).to have_http_status(:ok)

      expect(Tag.find_by(id: tag.id)).to be_nil
    end
  end
end
