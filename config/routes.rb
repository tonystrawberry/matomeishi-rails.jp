# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Routes for api/v1/
  namespace :api do
    namespace :v1 do
      # Routes for /business_cards/* (CRUD)
      get '/business_cards', to: 'business_cards#index'
      get 'business_cards/export', to: 'business_cards#export' # Should be placed before /business_cards/:code
      get '/business_cards/:code', to: 'business_cards#show'
      post '/business_cards/', to: 'business_cards#create'
      put '/business_cards/:code', to: 'business_cards#update'
      delete '/business_cards/:code', to: 'business_cards#destroy'

      # Routes for /tags/* (CRUD)
      get '/tags', to: 'tags#index'
      get '/tags/:id', to: 'tags#show'
      put '/tags/:id', to: 'tags#update'
      delete '/tags/:id', to: 'tags#destroy'
    end
  end
end
