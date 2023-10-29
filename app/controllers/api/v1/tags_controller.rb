# frozen_string_literal: true

##
## Api::V1::TagsController
## Api::V1::TagsController is a controller for tags
##
module Api
  module V1
    class TagsController < ApplicationController
      before_action :authenticate_user!

      ## GET /api/v1/tags
      ## Get all tags of the current user
      def index
        tags = current_user.tags.order(id: :desc)

        render json: TagSerializer.new(tags).serializable_hash, status: :ok
      end

      ## GET /api/v1/tags/:id
      ## Get a tag of the current user
      def show
        param!(:id, Integer, required: true)

        tag = current_user.tags.find(params[:id])

        render json: TagSerializer.new(tag).serializable_hash, status: :ok
      end

      ## PUT /api/v1/tags/:id
      ## Update a tag of the current user
      def update
        param!(:id, Integer, required: true)
        param!(:name, String, required: true)
        param!(:color, String, default: '#000000')
        param!(:description, String, default: '')

        tag = current_user.tags.find(params[:id])

        tag.name = params[:name]
        tag.color = params[:color]
        tag.description = params[:description]
        tag.save!

        render json: TagSerializer.new(tag).serializable_hash, status: :ok
      end

      ## DELETE /api/v1/tags/:id
      ## Delete a tag of the current user
      def destroy
        param!(:id, Integer, required: true)

        tag = current_user.tags.find(params[:id])

        tag.destroy!

        render json: {}, status: :ok
      end
    end
  end
end
