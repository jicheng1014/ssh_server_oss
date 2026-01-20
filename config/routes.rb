Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index"

  resources :servers do
    member do
      post :refresh
    end
    collection do
      post :refresh_all
      patch :sort
    end
  end

  resources :settings, only: [:index] do
    collection do
      patch :update_monitor_interval
      get :export_servers
      get :import_servers
      post :import_servers_process
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "servers#index"
end
