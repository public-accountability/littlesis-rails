Lilsis::Application.routes.draw do

  # match "*path", to: "errors#maintenance", via: :all

  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  devise_for :users, controllers: { confirmations: 'users/confirmations'  }, :skip => [:sessions, :registrations]
  as :user do
    get '/login' => 'users/sessions#new', :as => :new_user_session
    post '/login' => 'users/sessions#create', :as => :user_session
    get '/logout' => 'users/sessions#destroy', :as => :destroy_user_session
    get '/join' => 'users/registrations#new', :as => :new_user_registration
    post '/join' => 'users/registrations#create', :as => :user_registration
    get '/users/cancel' => 'users/registrations#cancel', :as => :cancel_user_registration
    get '/users/edit' => 'users/registrations#edit', :as => :edit_user_registration
    patch '/users' => 'users/registrations#update'
    put '/users' => 'users/registrations#update'
    delete '/users' => 'users/registrations#destroy'
    post '/users/api_token' => 'users/registrations#api_token'
  end

  get '/join/success' => 'users#success'

  root to: 'home#index'
  get '/home' => 'home#index'
  get '/contact' => 'home#contact'
  post '/contact' => 'home#contact'
  get '/flag' => 'home#flag'
  post '/flag' => 'home#flag'

  get '/bug_report' => 'errors#bug_report'
  post '/bug_report' => 'errors#file_bug_report'

  scope :admin, controller: 'admin', as: 'admin' do
    get '/', action: :home
    post "/clear_cache", action: :clear_cache
    get '/tags', action: :tags
  end

  resources :hubs, controller: 'campaigns', as: 'campaigns' do
    member do
      get 'search_groups'
      get 'groups'
      get 'admin'
      post 'clear_cache'
      get 'entities'
      get 'edit_findings'
      get 'edit_guide'
      get 'signup'
      post 'subscribe'
      get 'thankyou'
    end
  end

  get '/hubs/:id(/:campaign_tabs_selected_tab)' => 'campaigns#show'

  resources :groups do
    member do
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
      get 'entities'
      post 'clear_cache'
      get 'edit_findings'
      get 'edit_howto'
      get 'edit_advanced'
    end

    collection do
      get 'request_new'
      post 'send_request'
      get 'request_sent'
    end
  end

  get '/groups/:id(/:group_tabs_selected_tab)' => 'groups#show'

  resources :users, only: [:index] do
    member do
      get 'edit_permissions'
      post 'add_permission'
      post 'restrict'
      delete 'delete_permission'
      delete 'destroy'
    end
    collection do
      get 'admin'
    end
  end

  resources :lists do
    member do
      get 'relationships'
      get 'match_donations'
      get 'admin'
      get 'find_articles'
      get 'crop_images'
      get 'street_views'
      get 'members'
      post 'create_map'
      # entities
      post 'add_entity'
      get 'entities/bulk' => 'lists#new_entity_associations'
      post 'entities/bulk' => 'lists#create_entity_associations'
      post 'create_entities'
      post 'update_entity'
      post 'remove_entity'
      # ^- entities
      get 'clear_cache'
      post 'delete'
      get 'interlocks'
      get 'companies'
      get 'government'
      get 'other_orgs'
      get 'references'
      get 'giving'
      get 'funding'
      get 'modifications'
      post 'tags'
    end
  end

  resources :images do
    member do
      get 'crop'
      post 'crop_remote'
    end
  end
  
  constraints(id: /[0-9]+(-[^\/]+)?/) do
    resources :entities do
      member do
        # profile page
        get 'interlocks'
        get 'giving'
        get 'political'
        #get 'relationships'
        get 'datatable'
        get 'match_donations'
        get 'match_ny_donations'
        get 'review_donations'
        get 'review_ny_donations'
        post 'match_donation'
        post 'unmatch_donation'
        get 'contributions'
        get 'references'
        get 'potential_contributions'
        get 'edits' => 'edits#entity'
        get 'edit_twitter'
        post 'add_twitter'
        post 'remove_twitter'
        get 'fields'
        post 'update_fields'
        get 'articles'
        get 'find_articles'
        post 'import_articles'
        post 'remove_article'
        get 'new_article'
        post 'create_article'
        get 'refresh'
        get 'images'
        get 'new_image'
        post 'upload_image'
        post 'remove_image'
        post 'feature_image'
        get 'add_relationship'
        post 'tags'
      end

      collection do
        get 'search_by_name', as: 'name_search'
        get 'search_field_names', as: 'field_name_search'
        get 'next_twitter'
        post 'bulk' => 'entities#create_bulk'
      end
    end
  end

  resources :aliases, only: [:create, :destroy, :update] do
    member do
      patch 'make_primary'
    end
  end

  get "/story_maps/:id",
    controller: 'story_maps',
    action: 'story_map',
    as: "story_map"

  resources :maps do
    member do
      get 'raw'
      post 'clone'
      get 'embedded'
      get 'map_json'
      get 'dev'
      get 'edit/dev' => 'maps#dev_edit'
      get 'embedded/v2' => 'maps#embedded_v2'
      get 'embedded/v2/dev' => 'maps#embedded_v2_dev'
    end

    collection do
      get 'search'
      get 'featured'
      get 'find_nodes'
      get 'node_with_edges'
      get 'edges_with_nodes'
      get 'interlocks'
    end
  end


  get "/maps/:id/:slide",
    controller: 'maps',
    action: 'show',
    as: 'map_slide'

  get "/maps/:id/share/:secret",
    controller: 'maps',
    action: 'show',
    as: 'share_map'

  resources :industries, only: [:show]

  post '/relationships/bulk_add' => 'relationships#bulk_add'
  get '/relationships/find_similar' => 'relationships#find_similar'

  resources :relationships, except: [:index, :new] do
    member do
      post 'reverse_direction'
      post 'tags'
    end
  end

  resources :references, only: [:create, :destroy]
  get "/references/recent" => "references#recent"
  get "/references/entity" => "references#entity"

  get "/search" => "search#basic"
  get "/search/entity" => "search#entity_search"

  get "/home/groups" => "home#groups"
  get "/home/maps" => "home#maps"
  get "/home/lists" => "home#lists"
  get "/home/dashboard" => "home#dashboard"
  get "/home/token" => "home#token"
  get "/home/extension_path" => "home#extension_path"

  get "/home/error" => "home#error"
  
  post "/home/dismiss",
    controller: 'home',
    action: 'dismiss',
    as: 'dismiss_helper'

  # get "/entities/search_by_name",
  #   controller: 'entities',
  #   action: 'search_by_name',
  #   as: 'entity_name_search'

  ########
  # Tags #
  ########

  get '/tags/request' => 'tags#tag_request'
  post '/tags/request' => 'tags#tag_request'
  resources :tags, only: [:edit, :create, :update, :destroy, :show, :index] do
    member do
      get '/edits' => 'tags#edits'
      get '/:tagable_category' => 'tags#show',
          constraints: {
            tagable_category: /#{Tagable.categories.join('|')}/
          }
    end
  end

  #########
  # edits #
  #########

  get "/edits" => "edits#index"

  #########
  # Chat  #
  #########

  get '/chat_login' => 'chat#login'
  post '/chat_auth' => 'chat#chat_auth'

  #######
  # NYS #
  #######

  scope '/nys' do
    get "/" => "nys#index"
    post "/match_donations" => "nys#match_donations"
    get "/candidates" => "nys#candidates"
    get "/pacs" => "nys#pacs"
    get "/:type/new" => "nys#new_filer_entity", constraints: { type: /pacs|candidates/ }
    post "/:type/new" => "nys#create", constraints: { type: /pacs|candidates/ }
    get "/potential_contributions" => "nys#potential_contributions"
    get "/contributions" => "nys#contributions"
  end

  #########
  # Tools #
  #########

  get '/tools/bulk/relationships' => "tools#bulk_relationships"
  get '/tools/merge' => "tools#merge_entities"
  post '/tools/merge' => "tools#merge_entities!"

  #########
  #  API  #
  #########

  namespace :api do
    get '/' => 'api#index'
    get '/entities/search' => 'entities#search'

    resources :entities, only: [:show] do
      member do
        get 'relationships'
        get 'extensions'
        get 'lists'
      end
    end

    resources :relationships, only: [:show]
  end

  #############
  #  Toolkit  #
  #############

  get '/toolkit' => 'toolkit#index'
  get '/toolkit/new' => 'toolkit#new'
  get '/toolkit/pages' => 'toolkit#pages'
  get '/toolkit/index', to: redirect('/toolkit')
  post '/toolkit' => 'toolkit#create'
  get '/toolkit/:page_name/edit' => 'toolkit#edit', :as => 'toolkit_edit'
  patch '/toolkit/:id' => 'toolkit#update', :as => 'toolkit_update'
  get '/toolkit/:page_name' => 'toolkit#display', :as => 'toolkit_display'

  ################
  #  HELP PAGES  #
  ################

  get '/help' => 'help_pages#index'
  get '/help/new' => 'help_pages#new'
  get '/help/pages' => 'help_pages#pages'
  get '/help/index', to: redirect('/help')
  post '/help' => 'help_pages#create'
  get '/help/:page_name/edit' => 'help_pages#edit', :as => 'help_edit'
  patch '/help/:id' => 'help_pages#update', :as => 'help_update'
  get '/help/:page_name' => 'help_pages#display', :as => 'help_display'

  #########
  # Pages #
  #########

  get "/partypolitics" => "pages#partypolitics"
  get "/oligrapher" => "pages#oligrapher_splash"
  get "/donate" => "pages#donate"
  get "/graph" => "graph#all"

  get "/pages/:page/edit" => "pages#edit_by_name", constraints: { page: /[A-z]+[^\/]+/ }
  resources :pages, only: [:new, :create, :edit, :update, :index, :show]

  # edit pages.yml to add more pages
  get "/:page" => "pages#display", constraints: PagesConstraint.new, as: 'pages_display'
  
  match "*path", to: "errors#not_found", via: :all

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
