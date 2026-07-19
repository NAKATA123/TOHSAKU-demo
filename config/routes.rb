Rails.application.routes.draw do
  get "healthz", to: proc { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  root "home#top"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :customers do
    resources :cars do
      resources :repairs, shallow: true do
        member do
          patch :update_status
        end
      end
    end
  end

  resources :repairs, only: [:index]

  resources :loaner_cars, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :rentals, only: [:index]
  end

  resources :rentals, only: [:new, :create, :show, :edit, :update, :destroy]

  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :notices, only: [:create, :update]
  resources :push_subscriptions, only: [:create, :destroy]

end
