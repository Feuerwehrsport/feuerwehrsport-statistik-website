Rails.application.routes.draw do
  devise_for :admin_users

  # backend: area for admin users
  namespace :backend do
    root to: 'dashboard#index'
    resources :admin_users
    resources :appointments
    resources :change_requests, only: [:index]
    resources :competitions
    resources :competition_files
    resources :events
    resources :group_scores
    resources :group_score_categories
    resources :group_score_types
    resources :imports, only: [:index]
    resources :links
    resources :nations
    resources :news
    resources :people
    resources :person_participations
    resources :places
    resources :repairs, only: [] do
      collection do
        get :teams
      end
    end
    resources :scores
    resources :score_types
    namespace :series do
      resources :rounds, only: [:new, :create, :show, :index]
    end
    resources :teams
  end

  # api for interacting with ajax requests
  namespace :api do
    resources :api_users, only: [:create] do
      collection do
        post :status
        post :logout
      end
    end
    resources :appointments, only: [:create, :show, :update]
    resources :change_requests, only: [:create, :index, :update] do
      resources :files, only: [:show], to: 'change_requests#files'
    end
    resources :competitions, only: [:create, :show, :index, :update]
    resources :events, only: [:create, :show, :index]
    resources :group_score_types, only: [:create, :index]
    resources :group_score_categories, only: [:create, :index]
    resources :group_scores, only: [:show, :update] do
      member { put :person_participation }
    end
    resources :imports, only: [] do
      collection do 
        post :check_lines
        post :scores
      end
    end
    resources :links, only: [:create]
    resources :nations, only: [:show, :index]
    resources :people, only: [:create, :show, :index, :update] do
      member { post :merge }
    end
    resources :places, only: [:create, :show, :index, :update]
    resources :score_types, only: [:index]
    resources :scores, only: [:show, :update]
    resources :teams, only: [:create, :show, :index, :update] do
      member { post :merge }
    end
  end

  # following controllers will write html cache
  resources :change_logs, only: [:index, :show]
  resources :appointments, only: [:index, :show]
  resources :competitions, only: [:index, :show] do
    member { post :files }
  end
  resources :people, only: [:index, :show]
  resources :places, only: [:index, :show]
  resources :teams, only: [:index, :show]
  resources :news, only: [:index, :show]
  resources :years, only: [:index, :show] do
    member do
      get :best_performance
      get :best_scores
    end
  end
  resources :events, only: [:index, :show]
  namespace :series do
    resources :rounds, only: [:index, :show]
    resources :assessments, only: [:show]
  end
  scope :images do
    get 'person_la_positions/:person_id', controller: :images, action: :la_positions, as: :images_person_la_positions
  end

  get :rss, to: 'pages#rss'
  get :impressum, to: 'pages#legal_notice'
  get :feuerwehrsport, to: 'pages#firesport_overview'
  get :wettkampf_manager, to: 'pages#wettkampf_manager'
  get :last_competitions, to: 'pages#last_competitions_overview'
  get :records, to: 'pages#records'
  get :best_of, to: 'pages#best_of'
  root to: 'pages#dashboard'

  # error handling
  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"
end
