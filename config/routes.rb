Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :admin, only: [] do
    resources :auth, only: %i(index)
    resources :callback, only: %i(index)
    resources :webhook, only: %i(create)
  end
  scope 'calendar' do
    get 'auth/:user_id', to: 'calendar#auth'
  end
  get 'oauth2callback', to: 'calendar#callback'
end
