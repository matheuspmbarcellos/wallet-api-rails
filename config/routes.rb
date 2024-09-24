  Rails.application.routes.draw do
    mount Rswag::Ui::Engine => '/api-docs'

    post 'login', to: 'users#login'
    
    resources :users, only: [:show, :create, :update] 
        
    resources :wallets, only: [:show] do
      member do
        patch 'limit'
        patch 'purchase'
      end
      resources :cards, only: [:index, :show, :create, :destroy] do
        member do
          patch 'pay'
        end
      end
    end

  end