Rails.application.routes.draw do
  devise_for :users
  
  # Root route
  root 'dashboard#index'
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  
  # Organizations
  resources :organizations do
    member do
      get 'analytics'
    end
    resources :participation_spaces, only: [:index, :new, :create]
  end
  
  # Participation spaces (standalone)
  resources :participation_spaces, except: [:index, :new, :create]
  
  # Parental consents
  resource :parental_consent, only: [:show, :edit, :update]
  
  # User profile and settings
  get 'profile', to: 'users#profile'
  get 'profile/edit', to: 'users#edit', as: :edit_user
  patch 'profile', to: 'users#update'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
