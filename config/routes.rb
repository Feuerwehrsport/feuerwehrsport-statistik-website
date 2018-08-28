Rails.application.routes.draw do
  # backend: area for admin users
  namespace :backend do
    root to: 'dashboards#index'
    namespace :bla do
      resources :badges
      resource :badge_generator, only: %i[new]
    end
    resources :dashboards, only: [] do
      collection do
        get :administration
      end
    end
    resources :admin_users, only: %i[show edit update index destroy]
    resources :appointments
    resources :change_requests, only: [:index]
    namespace :caching do
      resource :cleaner, only: %i[new create]
    end
    resources :competitions
    resources :competition_files
    resources :events
    resources :group_scores
    resources :group_score_categories
    resources :group_score_types
    resources :imports, only: [:index]
    resources :import_requests do
      collection { get :decide_login }
    end
    resources :links
    resources :nations
    resources :news_articles
    namespace :people do
      resource :cleaner, only: %i[show]
    end
    resources :people
    resources :person_participations
    resources :person_spellings
    resources :places
    namespace :repairs do
      resource :team_score_move
    end
    resource :registration
    resources :scores
    resources :score_types
    namespace :series do
      resources :rounds do
        resource :import, only: %i[new create], controller: :round_imports
      end
      resources :cups, only: [:destroy]
    end
    resources :teams
    resources :team_spellings
    resources :unchecked_teams
  end

  # api for interacting with ajax requests
  namespace :api do
    resources :api_users, only: [:create] do
      collection do
        post :status
        post :logout
      end
    end
    resources :appointments, only: %i[create show update]
    resources :change_requests, only: %i[create index update] do
      resources :files, only: [:show], to: 'change_requests#files'
    end
    resources :competitions, only: %i[create show index update] do
      resource :competition_files, only: [:create]
    end
    resources :events, only: %i[create show index]
    resources :group_score_types, only: %i[create index]
    resources :group_score_categories, only: %i[create index]
    resources :group_scores, only: %i[show update] do
      member { put :person_participation }
    end
    resources :imports, only: [] do
      collection do
        post :check_lines
        post :scores
      end
    end
    resources :links, only: %i[create show destroy]
    resources :nations, only: %i[show index]
    resources :people, only: %i[create show index update] do
      member { post :merge }
    end
    resources :person_spellings, only: [:index]
    resources :places, only: %i[create show index update]
    resources :score_types, only: [:index]
    resources :scores, only: %i[show index update]
    namespace :series do
      resources :assessments, only: [:index]
      resources :cups, only: [:index]
      resources :participations, only: %i[create show index update destroy]
      resources :rounds, only: %i[create show update index]
      resources :team_assessments, only: [:index]
    end
    resources :suggestions, only: [] do
      collection do
        post :people
        post :teams
      end
    end
    resources :team_members, only: [:index]
    resources :team_spellings, only: [:index]
    resources :teams, only: %i[create show index update] do
      member { post :merge }
    end
  end

  namespace :registrations do
    root to: redirect('/registrations/competitions')
    resources :competitions do
      collection { get :new_select_template }
      resource :registration_times, only: %i[edit update]
      resource :publishings, only: %i[edit update]
      resource :tags, only: %i[edit update]
      resources :assessments, only: %i[new create index edit update destroy]
      resource :team_creation, only: %i[new create]
      resources :teams, only: %i[show edit update destroy] do
        collection { get :new_select_gender }
      end
      resource :person_creation, only: %i[new create]
      resources :people, only: %i[show edit update destroy]
      resources :person_participations, only: %i[edit update]
      resource :mail, only: %i[new create]
    end
  end

  get 'wa/:slug', to: 'registrations/competitions#slug_handle', as: :registrations_slug

  # following controllers will write html cache
  resources :change_logs, only: %i[index show]
  resources :appointments, only: %i[index show]
  resources :competitions, only: %i[index show]
  resources :people, only: %i[index show]
  resources :places, only: %i[index show]
  resources :teams, only: %i[index show]
  resources :news_articles, only: %i[index show]
  resources :years, only: %i[index show] do
    member do
      get :best_performance
      get :best_scores
    end
    scope module: :years do
      resources :inprovements, only: %i[index show]
    end
  end
  resources :events, only: %i[index show]
  namespace :series do
    get ':slug', to: 'rounds#index'
    resources :rounds, only: %i[index show]
    resources :assessments, only: [:show]
  end
  scope :images do
    get 'person_la_positions/:person_id', controller: :images, action: :la_positions, as: :images_person_la_positions
  end

  get :rss, to: 'pages#rss'
  get :impressum, to: 'pages#legal_notice'
  get :datenschutz, to: 'pages#datenschutz'
  get :feuerwehrsport, to: 'pages#firesport_overview'
  get :wettkampf_manager, to: 'pages#wettkampf_manager'
  get :online_anmeldungen, to: 'pages#online_anmeldungen'
  get :last_competitions, to: 'pages#last_competitions_overview'
  get :records, to: 'pages#records'
  get :best_of, to: 'pages#best_of'
  get :about, to: 'pages#about'
  root to: 'pages#dashboard'

  namespace :bla do
    resources :badges, only: %i[index]
  end

  resource :session, controller: 'm3/login/sessions', only: %i[new create show destroy]
  get 'verify_login/:token', to: 'm3/login/verifications#verify', as: :verify_login
  resources :password_reset, controller: 'm3/login/password_resets', only: %i[new create index edit update]
  resources :expired_login, controller: 'm3/login/expired_logins', only: %i[new create index]
  resources :changed_email_addresses, controller: 'm3/login/changed_email_addresses', only: %i[edit update]

  get 'association_select/:association', as: :association_select, to: 'association_select#show'

  resources :assets, controller: 'm3/assets', only: %i[index new create edit update destroy]
  resources :image_assets, controller: 'm3/image_assets', only: %i[index new create edit update destroy]

  namespace :ipo do
    resources :registrations do
      collection { get :finish }
    end
  end

  get 'wk-linux-install', to: redirect('https://raw.githubusercontent.com/Feuerwehrsport/wettkampf-manager/release/doc/scripts/basic-install.sh')

  # error handling
  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unacceptable', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
