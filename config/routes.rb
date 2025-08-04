Rails.application.routes.draw do
  # Web UI (Turbo / HTML)
  root 'conversions#index'
  resources :conversions, only: [:index, :create]

  # API (JSON responses)
  namespace :api, defaults: { format: :json } do
    post 'convert', to: 'conversions#convert'
    resources :conversions, only: [:index]
  end
end
