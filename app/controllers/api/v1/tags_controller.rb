# frozen_string_literal: true

##
## BusinessCardsController
## BusinessCardsController is a controller for business cards
##
class Api::V1::TagsController < ApplicationController
  before_action :authenticate_user!

  ## Get all tags of the current user
  def index
    tags = current_user.tags.order(id: :desc)

    render json: TagSerializer.new(tags).serializable_hash, status: :ok
  end
end
