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
    post '/create' => 'results#create', as: :api_create
    # bug in slack need to make it a get not a post
    get '/create_from_txt' => 'slack#create_from_txt', as: :api_create_from_txt_get
    get '/show' => 'slack#show_leaderboard', as: :api_show
  end

  root to: 'dashboard#show'
end
