Budgeteer::Application.routes.draw do
  root 'sessions#new'
  #root 'accounts#index'

  #resource :session, only: [:new, :create]


  resources :accounts, only: [:index, :create, :edit, :update], shallow: true do
    resources :quick_funds, only: [:create, :show]
  end

  resources :incomes, only: [:index, :create, :show]

  resources :account_histories, only: [:index]

  match '/login' => 'sessions#new', as: :session, via: :get
  match '/login' => 'sessions#create', via: :post
  match '/logout' => 'sessions#destroy', as: :logout, via: :delete
  unless Rails.env.production?
    match '/__backdoor_login__/:id' => 'sessions#backdoor', as: :backdoor_login, via: :get
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
