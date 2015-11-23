Rails.application.routes.draw do
  devise_for :admin_users
  namespace :backend do
    root to: 'dashboard#index'
    resources :competitions
    resources :people
    resources :places
  end
  resources :competitions, only: [:index, :show]
  resources :people, only: [:index, :show]
  resources :places, only: [:index, :show]
  resources :teams, only: [:index, :show]
  resources :years, only: [:index, :show]
  resources :events, only: [:index, :show]
  namespace :series do
    resources :rounds, only: [:index, :show]
    resources :assessments, only: [:show]
  end
  namespace :api do
    resources :users, only: [:show, :create] do
      collection do
        get :status
      end
    end
  end
  scope :images do
    get 'person_la_positions/:person_id', controller: :images, action: :la_positions, as: :images_person_la_positions
  end

  get :impressum, to: 'pages#legal_notice'
  get :feuerwehrsport, to: 'pages#firesport_overview'
  get :last_competitions, to: 'pages#last_competitions_overview'
  root to: 'pages#dashboard'
end
