# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resource :users, only: %i[create]
  resource :session, only: %i[create show destroy]
  resources :products, only: %i[index create show update destroy] do
    member do
      post 'purchase'
    end
  end
end
