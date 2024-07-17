Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :admin, only: [] do
    resources :auth, only: %i(index)
    resources :callback, only: %i(index)
    resources :webhook, only: %i(create)
  end
  resources :google_oauth do
    collection do
      get 'auth/:user_id', to: 'google_oauth#auth', as: 'auth'
      get 'callback'
    end
  end
end
