require "api_constraints"

Rails.application.routes.draw do
  get 'testreacts/index'

  mount Ckeditor::Engine => "/ckeditor"
  mount ActionCable.server => "/cable"
  namespace :api, defaults: {format: "json"} do
    devise_scope :user do
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      get "confirmation", to: "confirmations#new"
      put "confirmation", to: "confirmations#update"
      get "password", to: "passwords#new"
      post "password", to: "passwords#create"
      put "password", to: "passwords#update"
      put "user_token", to: "user_tokens#update"
    end

    scope module: :v1, constraints: ApiConstraints.new(version: 1,
      default: true) do
      resources :users, only: [:show, :update, :index]
      resources :invoices, only: :index
      resource :user_setting, only: [:update, :show]
      namespace :shipper do
        resources :invoices, only: [:update, :index, :show]
        resources :user_invoices, only: [:create, :destroy, :update]
        resources :rates, only: [:create, :update, :destroy]
        resources :reports, only: :create
        resources :black_lists, only: [:create, :index, :destroy]
        resources :favorite_lists, only: [:create, :index, :destroy]
        resources :reviews, only: :index
        resources :destroy_all_black_lists, only: :index
        resources :destroy_all_favorite_lists, only: :index
        resources :notifications, only: [:index, :update]
      end
      namespace :shop do
        resources :invoices, except: [:edit, :new]
        resources :user_invoices, only: :update
        resources :list_shippers, only: :index
        resources :reports, only: [:create, :show]
        resources :rates, only: [:create, :update, :destroy]
        resources :black_lists, only: [:create, :index, :destroy]
        resources :favorite_lists, only: [:create, :index, :destroy]
        resources :reviews, only: :index
        resources :destroy_all_favorite_lists, only: :index
        resources :destroy_all_black_lists, only: :index
        resources :notifications, only: [:index, :update]
      end
    end
  end

  root "pages#index"
  get "/pages/:page", to: "pages#show"
  get "shop/invoices/status/:status", to: "shop/invoices#index"
  get "shop/shippers/type/:type", to: "shop/shippers#index"

  devise_for :users, path: "", path_names: {sign_out: "logout"},
    controllers: {
      sessions: "sessions",
      registrations: "registrations"
  }

  resources :feed_backs, only: [:new, :create]
  namespace :shop do
    root to: "pages#index", as: :root
    resources :invoices
    resources :list_shippers, only: :index
    resources :reports, only: [:new, :create]
    resources :rates, only: [:new, :create]
    resources :user_invoices, only: :update
    resources :shippers, only: [:index, :update]
    resources :notifications, only: :index
  end

  resources :shops
  resources :shippers, only: :show
  namespace :admin do
    root to: "users#index", as: :root
    resources :users
    resources :invoices
  end
  get "/realtime/new", to: "realtime#new"
  get "/testreacts/index", to: "testreacts#index"
end
