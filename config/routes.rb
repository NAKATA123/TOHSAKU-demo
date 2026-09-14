Rails.application.routes.draw do
  get "healthz", to: proc { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  # root "home#top"
  root "loaner_cars#index"

  get "settings", to: "settings#index"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :repairs do
    member do
      patch :update_status
    end
  end

  resources :loaner_cars, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :rentals, only: [:index]
    collection do
      patch :reorder
    end
  end

  resources :rentals, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      patch :returned
    end
  end

  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :notices, only: [:create, :update]
  resources :push_subscriptions, only: [:create, :destroy]

end
