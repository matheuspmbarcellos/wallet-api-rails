  Rails.application.routes.draw do

    post 'login', to: 'users#login'
    
    resources :users, only: [:show, :create, :update] do      
      resources :wallets, only: [:show] do
        member do
          patch 'set_custom_limit'
          patch 'spend'
        end
        resources :cards, only: [:index, :show, :create, :destroy] do
          member do
            patch 'pay'
          end
        end
      end
    end

  end
