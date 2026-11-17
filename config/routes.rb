# frozen_string_literal: true

Rails.application.routes.draw do
  # health check for load balancers and uptime monitors
  get 'up' => 'rails/health#show', as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: '/admin-jobs'

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
    resources :change_requests, only: [:index] do
      member do
        patch :done
        post :apply
        get 'files/:index', action: :file, as: :file
      end
    end
    namespace :caching do
      resource :cleaner, only: %i[new create]
    end
    resources :competitions
    resources :competition_files
    resources :events
    resources :group_scores
    resources :group_score_categories
    resources :group_score_types
    resources :imports, only: [:index] do
      collection { patch :score_type }
    end
    namespace :imports do
      resources :disciplines, only: %i[new create] do
        collection do
          post :check
          post :team
        end
      end
    end
    resources :import_request_files, only: [] do
      member { patch :transfer }
    end
    resources :import_requests do
      collection { get :decide_login }
    end
    resources :links
    resources :nations
    namespace :people do
      resource :cleaner, only: %i[show]
    end
    resources :people
    resources :person_participations
    resources :person_spellings
    resources :places
    namespace :repairs do
      resource :team_score_move, only: %i[new create] do
        post :execute
      end
    end
    resource :registration
    resources :scores
    resources :score_types
    namespace :series do
      resources :kinds
      %i[person_participations team_participations].each do |participations|
        resources participations, only: %i[new create edit update destroy] do
          member { patch :move }
        end
      end
      resources :rounds do
        resource :import, only: %i[new create], controller: :round_imports
      end
      resources :cups, only: [:destroy]
    end
    resources :teams
    resources :team_spellings
    resources :unchecked_teams do
      member { post :merge }
    end
  end

  # api for interacting with ajax requests
  namespace :api do
    # read only, used by Feusport (ImportSuggestionsJob)
    resources :people, only: :index
    resources :person_spellings, only: :index
    resources :teams, only: :index
    resources :team_members, only: :index
    resources :team_spellings, only: :index
    namespace :series do
      resources :cups, only: :index
      resources :person_assessments, only: :index
      resources :person_participations, only: :index
      resources :rounds, only: :index
      resources :team_assessments, only: :index
      resources :team_participations, only: :index
    end
    # results from Feusport (token, see Api::ImportRequestsController)
    resources :import_requests, only: :create
  end

  # dialogs for anonymous contributions (Hotwire, loaded into the turbo frame "contribution")
  namespace :contributions do
    resource :login, only: %i[new create]
    resources :people, only: %i[new create] do
      resource :change_request, only: %i[new create], controller: :person_change_requests
    end
    resources :teams, only: %i[new create] do
      resource :change_request, only: %i[new create], controller: :team_change_requests
      resource :state, only: %i[edit update], controller: :team_states
      resource :geo_position, only: %i[edit update]
    end
    resources :places, only: [] do
      resource :geo_position, only: %i[edit update]
    end
    resources :competitions, only: [] do
      resource :change_request, only: %i[new create], controller: :competition_change_requests
      resources :files, only: %i[new create], controller: :competition_files
    end
    resources :links, only: %i[new create] do
      resource :report, only: %i[new create], controller: :link_reports
    end
    resources :scores, only: [] do
      resource :team, only: %i[edit update], controller: :score_teams
    end
    resources :group_scores, only: [] do
      resource :participations, only: :edit, controller: :group_score_participations
      resources :positions, only: %i[edit update], param: :position, controller: :group_score_positions
    end
  end

  # following controllers will write html cache
  resources :change_logs, only: %i[index show]
  resources :competitions, only: %i[index show]
  resources :people, only: %i[index show]
  resources :places, only: %i[index show]
  resources :teams, only: %i[index show]
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
    resources :kinds, only: %i[index]
    get ':slug', to: 'rounds#index'
    resources :rounds, only: %i[show]
    resources :person_assessments, only: [:show]
  end
  scope :images do
    get 'person_la_positions/:person_id', controller: :images, action: :la_positions, as: :images_person_la_positions
  end

  get :impressum, to: 'pages#legal_notice'
  get :datenschutz, to: 'pages#datenschutz'
  get :feuerwehrsport, to: 'pages#firesport_overview'
  get :last_competitions, to: 'pages#last_competitions_overview'
  get :records, to: 'pages#records'
  get :best_of, to: 'pages#best_of'
  get :about, to: 'pages#about'
  root to: 'pages#dashboard'

  namespace :bla do
    resources :badges, only: %i[index]
  end

  resource :session, only: %i[new create show destroy]
  get 'verify_login/:token', to: 'verifications#verify', as: :verify_login
  resources :password_reset, controller: 'password_resets', only: %i[new create index edit update]
  resources :expired_login, controller: 'expired_logins', only: %i[new create index]
  resources :changed_email_addresses, only: %i[edit update]

  get 'association_select/:association', as: :association_select, to: 'association_select#show'

  # error handling
  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unacceptable', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
