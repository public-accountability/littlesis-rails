# frozen_string_literal: true

LittleSis::Application.routes.draw do
  # match "*path", to: "errors#maintenance", via: :all

  devise_for :users, controllers: { confirmations: 'users/confirmations', passwords: 'users/passwords' }, :skip => [:sessions, :registrations]
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
  get '/test' => 'home#test'
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
    get '/object_space_dump', action: :object_space_dump
  end

  resources :dashboard_bulletins, except: [:show]

  resources :users, only: [:edit] do
    member do
      get 'edit_permissions'
      post 'add_permission'
      post 'restrict'
      delete 'delete_permission'
      delete 'destroy'
      # get 'image'
      # post 'upload_image'
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
      get 'members'
      get 'references'
      get 'modifications'
      post 'tags'
    end

    resources :interlocks, only: :index, controller: 'lists/interlocks'
    get ':interlocks_tab', to: 'lists/interlocks#show', constraints: { interlocks_tab: /companies|government|other_orgs|giving|funding/ }, as: 'interlocks_tab'
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

  # Legacy PHP profile pages...some links are still out there
  match 'person/:id/*remainder', via: :all, constraints: { id: /[0-9]+/ }, to: 'entities/routes#redirect_to_canonical'
  match 'org/:id/*remainder', via: :all, constraints: { id: /[0-9]+/ }, to: 'entities/routes#redirect_to_canonical'

  # Generate entity routes for the primary extensions so we can humanize them
  # /entities/:id = /org/:id = /person/:id
  %i[entities org person].each do |path_prefix|
    constraints(id: %r{[0-9]+(-[^/]+)?}) do
      resources path_prefix, controller: 'entities' do
        member do
          # to view legacy profile page:
          # get ':tab', to: 'entities#show', constraints: {tab: /interlocks|giving/}, as: 'tab'
          # new profile page
          get ':active_tab', action: :profile, constraints: { active_tab: /relationships|interlocks|giving|data/ }, as: 'profile'
          get 'profile(/:active_tab)', action: :profile, constraints: { active_tab: /relationships|interlocks|giving|data/ }

          get 'political'
          get 'datatable'
          get 'references'
          get 'edits' => redirect("/#{path_prefix}/%{id}/history")
          get 'history' => 'edits#entity'
          get 'add_relationship'
          post 'tags'

          get 'grouped_links/:subcategory/:page',
              constraints: { subcategory: Regexp.new(Link::Subcategory::SUBCATEGORIES.join('|')), page: /[0-9]+/ },
              to: 'entities#grouped_links'
          get 'source_links'
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

  get '/maps', to: redirect('/oligrapher')

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

  get "/oligrapher/:id/share/:secret",
      controller: 'oligrapher',
      action: 'show',
      as: 'share_oligrapher'

  resources :oligrapher, except: [:edit], controller: 'oligrapher' do
    collection do
      get '/get_edges', action: :get_edges
      get '/find_connections', action: :find_connections
      get '/find_nodes', action: :find_nodes
      get '/get_interlocks', action: :get_interlocks
      get '/about' => "pages#oligrapher"
      get '/search', action: :search
      get '/perform_search', action: :perform_search
      get '/grid', action: :grid
    end

    member do
      post '/editors', action: :editors
      post '/confirm_editor', action: :confirm_editor
      post 'featured'
      get 'lock'
      get 'screenshot'
      post 'lock'
      post 'release_lock'
      post 'clone'
      get 'embedded'
    end
  end

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
  get "/references/documents" => "references#documents"

  get "/search" => "search#basic"
  get "/search/entity" => "search#entity_search"

  get "/home/token" => "home#token"
  get "/home/maps" => "home#maps"
  get "/home/lists" => "home#lists"

  get "/home/dashboard" => "home#dashboard"
  get "/home/dashboard/edits" => "home#dashboard_edits"
  get "/home/dashboard/maps" => "home#dashboard_maps"

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

  #########################################
  # External Links & Featured Resources   #
  #########################################

  resources :external_links, only: %i[create update]
  resources :featured_resources, only: %i[create destroy]

  #########
  # edits #
  #########

  get "/edits" => "edits#index"

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
  get "/pages/:page/edit" => "pages#edit_by_name", constraints: { page: %r{[A-z]+[^/]+} }
  resources :pages, only: [:new, :create, :edit, :update, :index, :show]

  get "/newsletter" => "pages#newsletter"
  get "/disclaimer" => "pages#disclaimer"
  get "/about" => "pages#about"

  # Other Pages
  get "/donate" => "pages#donate"
  get "/swamped" => "pages#swamped"
  post "/swamped" => "pages#swamped"
  get '/bulk_data' => 'pages#bulk_data'
  get '/public_data/:file' => 'pages#public_data',
      constraints: { file: /(entities|relationships)\.json(\.gz)?/ }

  ############
  # Partners #
  ############

  scope :partners do
    get '/corporate-mapping-project' => 'partners#cmp'
  end

  #################
  # External Data #
  #################

  # Overview page
  get '/datasets' => 'datasets#index'
  # Table Of ExternalEntites/ExternalRelationships for the given dataset
  # get '/datasets/:dataset' => 'datasets#dataset', constraints: DatasetConstraint.new, as: 'dataset'
  get '/datasets/:dataset' => 'datasets#show', constraints: DatasetConstraint.new, as: 'dataset'

  namespace :fec do
    constraints(id: %r{[0-9]+(-[^/]+)?}) do
      get '/entities/:id/contributions', action: :contributions, as: :contributions
      get '/entities/:id/match_contributions', action: :match_contributions, as: :match_contributions

      get '/fec_matches/:id', action: :fec_match, as: :match
      get '/committies/:cmte_id', action: :committees
      get '/candidates/:cand_id', action: :candidates

      post '/fec_contributions/:id/hide_entity', action: :hide_entity
      post '/fec_contributions/:id/show_entity', action: :show_entity
      post '/fec_matches', action: :create_fec_match, as: :create_match
      delete '/fec_matches/:id', action: :delete_fec_match, as: :delete_match
    end
  end

  namespace :nys, constraints: { id: /[0-9]+/ } do
    get '/committee/:id', action: :committee, as: :committee
    get '/committee/:id/contributions', action: :contributions, as: :committee_contributions
  end

  get 'relationship/view/id/:id', constraints: { id: /[0-9]+/ }, to: 'relationships/routes#redirect_to_canonical'

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
