# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Routes for api/v1/
  namespace :api do
    namespace :v1 do
      # Routes for /signup and /signin
      post '/signup', to: 'sessions#signup'
      post '/signin', to: 'sessions#signin'

      # Routes for /business_cards
      resources :business_cards, only: %i[index show create update destroy]
    end
  end
end
