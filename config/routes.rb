Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants
      resources :menus
      resources :menu_items

      post "/json_to_model/convert", to: "json_to_model_converter#convert"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
