Rails.application.routes.draw do
  
  resources :users, only: [:show, :create, :update, :destroy] do
    collection do
      post 'login'
      delete 'logout'
    end
    resources :wallets, only: [:show] do
      member do
        patch 'set_custom_limit'
        post 'spend'
      end
      resources :cards do
        member do
          post 'pay'
        end
      end
    end
  end

end