Rails.application.routes.draw do
  
  resources :users, only: [:show, :create, :update] do
    collection do
      post 'login'
    end
    resources :wallets, only: [:show] do
      member do
        patch 'set_custom_limit'
        patch 'spend'
      end
      resources :cards [:index, :show, :create, :destroy] do
        member do
          patch 'pay'
        end
      end
    end
  end
end
