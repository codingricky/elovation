Elovation::Application.routes.draw do
  devise_for :users, :skip => :registrations, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" } do
  end

  resources :games do
    resources :results, only: [:create, :destroy, :new]
    resources :ratings, only: [:index]
  end

  resources :players do
    resources :games, only: [:show], controller: 'player_games'
  end

  get '/dashboard' => 'dashboard#show', as: :dashboard
  get '/daily/:id', to: 'daily_ratings#index', as: :daily_ratings
  get '/leaderboard' => 'leaderboard#show', as: :leaderboard
  get '/leaderboard_image' => 'leaderboard#show_image', as: :leaderboard_show_image

  namespace :api do
    get '/results' => 'results#create', as: :api_results
  end

  root to: 'dashboard#show'
end
