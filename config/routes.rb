Rails.application.routes.draw do
  get 'campaigns/dogramagra' => "pages#dogramagra"

  resources :books, only: [:index, :show]
  resources :campaigns, shallow: true do
    resources :feeds
  end
  resources :passwords, param: :token
  resources :subscriptions

  resource :session
  resource :user do
    post :webpush_test, on: :member
  end

  get 'login' => 'sessions#new'
  delete 'logout' => 'sessions#destroy'
  get 'mypage' => 'users#show'
  get 'signup' => 'users#new'
  get 'past_campaigns' => "pages#past_campaigns"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
