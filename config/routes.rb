Lilsis::Application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  devise_for :users
  root to: 'campaigns#index'

  resources :campaigns

  resources :groups do
    member do
      get 'notes'
      get 'edits'
      get 'lists'
      post 'remove_list'
      post 'feature_list'
      post 'unfeature_list'
      get 'new_list'
      post 'add_list'
      post 'join'
      post 'leave'
      get 'users'
      post 'promote_user'
      post 'demote_user'
      post 'remove_user'
      get 'admin'
    end
  end

  resources :users
  resources :lists

  resources :entity do
    member do
      get 'interlocks'
    end
  end

  resources :notes, only: [:new, :create, :destroy]

  get "/notes/:username",
    controller: 'notes',
    action: 'user',
    constraints: { username: /[\w.]+/ },
    as: "user_notes"
  get "/notes/:username/:id",
    controller: 'notes',
    action: 'show',
    constraints: { username: /[\w.]+/, id: /\d+/ },
    as: "note_with_user"

  get "/home/notes" => "home#notes"

  get "/entities/search_by_name",
    controller: 'entities',
    action: 'search_by_name',
    as: 'entity_name_search'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
