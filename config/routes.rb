Rails.application.routes.draw do
  devise_for :admin_users
  namespace :backend do
    root to: 'dashboard#index'
    resources :admin_users
    resources :appointments
    resources :competitions
    resources :competition_files
    resources :events
    resources :group_scores
    resources :group_score_categories
    resources :group_score_types
    resources :links
    resources :nations
    resources :news
    resources :people
    resources :person_participations
    resources :places
    resources :scores
    resources :score_types
    resources :teams
  end
  resources :appointments, only: [:index, :show]
  resources :competitions, only: [:index, :show] do
    member { post :files }
  end
  resources :people, only: [:index, :show]
  resources :places, only: [:index, :show]
  resources :teams, only: [:index, :show]
  resources :news, only: [:index, :show]
  resources :years, only: [:index, :show]
  resources :events, only: [:index, :show]
  namespace :series do
    resources :rounds, only: [:index, :show]
    resources :assessments, only: [:show]
  end
  namespace :api do
    resources :users, only: [:create] do
      collection do
        post :status
      end
    end
    resources :appointments, only: [:create, :show]
    resources :change_requests, only: [:create]
    resources :events, only: [:index]
    resources :group_scores, only: [:show] do
      member { put :person_participation }
    end
    resources :links, only: [:create]
    resources :people, only: [:index]
    resources :places, only: [:index]
    resources :teams, only: [:create, :show, :index, :update]
  end
  scope :images do
    get 'person_la_positions/:person_id', controller: :images, action: :la_positions, as: :images_person_la_positions
  end

  get :impressum, to: 'pages#legal_notice'
  get :feuerwehrsport, to: 'pages#firesport_overview'
  get :wettkampf_manager, to: 'pages#wettkampf_manager'
  get :last_competitions, to: 'pages#last_competitions_overview'
  root to: 'pages#dashboard'
end
