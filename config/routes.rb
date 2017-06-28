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

  get '/results' => 'results_export#export', as: :export

  namespace :api do
    post '/api_ai/' => 'api_ai#create', as: :apiai_create

    post '/results' => 'results#create', as: :api_create
    get '/active_players' => 'results#active_players', as: :api_active_players

    post '/slack' => 'slack#slack', as: :api_slack
    get '/show' => 'slack#show_leaderboard', as: :api_show

    get '/player/:player' => 'player#lookup', as: :api_lookup

  end

  root to: 'dashboard#show'
end
