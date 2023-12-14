# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Routes for api/v1/
  namespace :api do
    namespace :v1 do
      # Routes for /business_cards/* (CRUD)
      get '/business_cards', to: 'business_cards#index', as: 'business_cards'
      # Should be placed before /business_cards/:code route
      get 'business_cards/export', to: 'business_cards#export', as: 'business_cards_export'
      get '/business_cards/:code', to: 'business_cards#show', as: 'business_card'
      post '/business_cards/', to: 'business_cards#create', as: 'create_business_card'
      put '/business_cards/:code', to: 'business_cards#update', as: 'update_business_card'
      delete '/business_cards/:code', to: 'business_cards#destroy', as: 'delete_business_card'

      # Routes for /tags/* (CRUD)
      get '/tags', to: 'tags#index', as: 'tags'
      get '/tags/:id', to: 'tags#show', as: 'tag'
      put '/tags/:id', to: 'tags#update', as: 'update_tag'
      delete '/tags/:id', to: 'tags#destroy', as: 'delete_tag'

      # Routes for /subscriptions/*
      get '/subscriptions/current', to: 'subscriptions#current', as: 'current'
      post '/subscriptions', to: 'subscriptions#create_subscription', as: 'create_subscription'
      post '/subscriptions/cancel', to: 'subscriptions#cancel_subscription', as: 'cancel_subscription'
      post '/subscriptions/reactivate', to: 'subscriptions#reactivate_subscription', as: 'reactivate_subscription'
      post '/subscriptions/change_plan', to: 'subscriptions#change_plan', as: 'change_plan'
      post '/subscriptions/cancel_downgrade', to: 'subscriptions#cancel_downgrade', as: 'cancel_downgrade'

      # Routes for /webhooks/*
      post '/webhooks/stripe', to: 'webhooks#stripe', as: 'stripe_webhook'
    end
  end
end
