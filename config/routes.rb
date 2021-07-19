Lilsis::Application.routes.draw do

  # match "*path", to: "errors#maintenance", via: :all

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
    put '/users/settings' => 'users/registrations#update_settings'
  end

  get '/join/success' => 'users#success'

  root to: 'home#index'
  get '/home' => 'home#index'
  get '/flag' => 'home#flag'
  post '/flag' => 'home#flag'
  post '/home/newsletter_signup' => 'home#newsletter_signup'
  post '/home/pai_signup(/:tag)' => 'home#pai_signup'

  get '/bug_report' => 'errors#bug_report'
  post '/bug_report' => 'errors#file_bug_report'

  resources :contact, only: [:index, :create]

  #########
  # ADMIN #
  #########

  scope :admin, controller: 'admin', as: 'admin' do
    get '/', action: :home
    get '/tags', action: :tags
    get '/stats', action: :stats
    get '/test', action: :test
    get '/entity_matcher', action: :entity_matcher
    get '/tracker', action: :tracker
  end

  resources :dashboard_bulletins, except: [:show]

  resources :users, only: [:edit] do
    member do
      get 'edit_permissions'
      post 'add_permission'
      post 'restrict'
      delete 'delete_permission'
      delete 'destroy'
      get 'image'
      post 'upload_image'
    end
    collection do
      get 'admin'
      post 'check_username'
    end
  end

  get '/users/:username' => 'users#show', as: :user_page
  get '/users/:username/edits' => 'users#edits', as: :user_edits
  get '/users/:username/maps' => 'maps#user', as: :user_maps

  resources :lists do
    member do
      get 'admin'
      get 'crop_images'
      get 'members'
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

    resources :entities, only: :create, controller: 'lists/entities'
    resources :entity_associations, path: 'entities/bulk', only: [:new, :create], controller: 'lists/entity_associations'
    resources :list_entities, only: [:create, :update, :destroy], controller: 'lists/list_entities'
  end

  resources :ls_images, only: [], path: 'images', controller: 'images' do
    member do
      get 'crop'
      post 'crop'
      post 'update'
    end
  end

  post '/entities/validate' => 'entities#validate'

  match 'person/:id/*remainder', via: :all, constraints: {id: /[0-9]+/}, to: 'entities/routes#redirect_to_canonical'
  match 'org/:id/*remainder', via: :all, constraints: {id: /[0-9]+/}, to: 'entities/routes#redirect_to_canonical'

  # Generate entity routes for the primary extensions so we can humanize them
  %i[entities org person].each do |path_prefix|
    constraints(id: /[0-9]+(-[^\/]+)?/) do
      resources path_prefix, controller: 'entities' do
        member do
          # profile page
          get ':tab', to: 'entities#show', constraints: {tab: /interlocks|giving/}, as: 'tab'
          get 'political'
          get 'datatable'
          get 'match_donations'
          get 'review_donations'
          post 'match_donation'
          post 'unmatch_donation'
          get 'contributions'
          get 'references'
          get 'potential_contributions'
          get 'edits' => redirect("/#{path_prefix}/%{id}/history")
          get 'history' => 'edits#entity'
          get 'add_relationship'
          post 'tags'
        end

        resources :images, controller: 'entities/images'
        resources :list_entities, only: :create, controller: 'entities/list_entities'

        collection do
          post 'bulk' => 'entities#create_bulk'
        end
      end
    end
  end

  resources :permission_passes, except: [:show] do
    get 'apply' => 'permission_passes#apply'
  end

  #############
  # Datatable #
  #############

  get '/datatable/entity/:id', to: 'datatable#entity', constraints: { id: /\d+/ }

  #####################
  # deletion requests #
  #####################

  namespace :deletion_requests do
    resources :entities, only: [:new, :create] do
      member do
        get 'review', to: 'entities#review'
        post 'review', to: 'entities#commit_review'
      end
    end

    resources :lists, only: [:new, :create] do
      member do
        get 'review', to: 'lists#review'
        post 'review', to: 'lists#commit_review'
      end
    end

    resources :images, only: [:show, :create] do
      member do
        get 'review', to: 'images#review'
        post 'review', to: 'images#commit_review'
      end
    end
  end

  resources :aliases, only: [:create, :destroy, :update] do
    member do
      patch 'make_primary'
    end
  end

  get '/maps', to: redirect('/maps/featured')

  resources :maps, only: [:show, :new] do
    member do
      get 'raw'
      post 'feature'
      get 'embedded'
      get 'map_json'
      get 'embedded/v2' => 'maps#embedded_v2'
    end

    collection do
      get 'search'
      get 'featured'
      get 'all'
      get 'find_nodes'
      get 'node_with_edges'
      get 'edges_with_nodes'
      get 'interlocks'
    end
  end

  get "/maps/:id/share/:secret",
      controller: 'maps',
      action: 'show',
      as: 'share_map'

  resources :oligrapher, only: [:new, :show, :create, :update, :destroy], controller: 'oligrapher' do
    collection do
      get '/get_edges', action: :get_edges
      get '/find_connections', action: :find_connections
      get '/find_nodes', action: :find_nodes
      get '/get_interlocks', action: :get_interlocks
      get '/example', action: :example
    end

    member do
      post '/editors', action: :editors
      post '/confirm_editor', action: :confirm_editor
      get 'lock'
      get 'screenshot'
      post 'lock'
      post 'release_lock'
      post 'clone'
      get 'embedded'
    end
  end

  get "/oligrapher/:id/share/:secret",
    controller: 'oligrapher',
    action: 'show',
    as: 'share_oligrapher'

  get '/relationships/bulk_add' => 'relationships#bulk_add'
  post '/relationships/bulk_add' => 'relationships#bulk_add!'
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

  get "/home/maps" => "home#maps"
  get "/home/lists" => "home#lists"
  get "/home/dashboard" => "home#dashboard"
  get "/home/token" => "home#token"

  post "/home/dismiss",
    controller: 'home',
    action: 'dismiss',
    as: 'dismiss_helper'

  resources :documents, only: [:edit, :update]

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

  ##################
  # External Links #
  ##################

  resources :external_links, only: %i[create update]

  #########
  # edits #
  #########

  get "/edits" => "edits#index"

  #######
  # NYS #
  #######

  scope '/nys' do
    get "/" => "nys#index"
    post "/match_donations" => "nys#match_donations"
    post "/unmatch_donations" => "nys#unmatch_donations"
    get "/candidates" => "nys#candidates"
    get "/pacs" => "nys#pacs"
    get "/:type/new" => "nys#new_filer_entity", constraints: { type: /pacs|candidates/ }
    post "/:type/new" => "nys#create", constraints: { type: /pacs|candidates/ }
    post "/ny_filer_entity" => "nys#create_ny_filer_entity"
    get "/potential_contributions" => "nys#potential_contributions"
    get "/contributions" => "nys#contributions"
    get 'match' => 'nys#match'
    get '/datatable' => 'nys#datatable'
  end

  #########
  # Merge #
  #########

  get '/merge' => "merge#merge"
  post '/merge' => "merge#merge!"
  get '/merge/redundant' => "merge#redundant_merge_review"

  #########
  #  API  #
  #########

  namespace :api do
    get '/' => 'api#index'
    get '/entities/search' => 'entities#search'

    resources :entities, only: [:show] do
      member do
        get 'relationships'
        get 'connections'
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

  # Editable Pages
  get "/pages/:page/edit" => "pages#edit_by_name", constraints: { page: /[A-z]+[^\/]+/ }
  resources :pages, only: [:new, :create, :edit, :update, :index, :show]
  get "/:page" => "pages#display", constraints: PagesConstraint.new, as: 'pages_display'
  # Other Pages
  get "/oligrapher" => "pages#oligrapher"
  get "/donate" => "pages#donate"
  get "/swamped" => "pages#swamped"
  post "/swamped" => "pages#swamped"
  get '/bulk_data' => 'pages#bulk_data'
  get '/public_data/:file' => 'pages#public_data', constraints: { file: /(entities|relationships)\.json(\.gz)?/ }

  ############
  # Partners #
  ############

  scope :partners do
    get '/corporate-mapping-project' => 'partners#cmp'
  end

  ##############################
  # external entities and data #
  ##############################

  get '/external_data/:dataset' => 'external_data#dataset', constraints: DatasetConstraint.new
  # Overview page
  get '/datasets' => 'datasets#index'
  # Table Of ExternalEntites/ExternalRelationships for the given dataset
  # get '/datasets/:dataset' => 'datasets#dataset', constraints: DatasetConstraint.new, as: 'dataset'
  get '/datasets/:dataset' => 'datasets#show', constraints: DatasetConstraint.new, as: 'dataset'

  namespace :fec do
    constraints(id: /[0-9]+(-[^\/]+)?/) do
      get '/entities/:id/contributions', action: :contributions, as: :entity_contributions
      get '/entities/:id/match_contributions', action: :match_contributions, as: :entity_match_contributions
      post '/entities/:id/donor_match', action: :donor_match, as: :entity_donor_match
      delete '/contribution_unmatch', action: :contribution_unmatch
    end
  end

  resources :external_entities, only: %i[show update] do
    get 'random', on: :collection, action: :random
    get '/:dataset/random', on: :collection, action: :random, constraints: DatasetConstraint.new
    get '/:dataset/:id', on: :collection, action: :show, constraints: DatasetConstraint.new(check_id: true)
  end

  resources :external_relationships, only: %i[show update] do
    get 'random', on: :collection, action: :random
  end

  match "*path",
        to: "errors#not_found",
        via: :all,
        constraints: ->(req) { req.path.exclude? 'rails/active_storage' }

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
