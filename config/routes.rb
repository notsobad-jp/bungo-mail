Rails.application.routes.draw do
  get 'campaigns/dogramagra' => "pages#dogramagra"

  resources :books, only: [:index, :show]
  resources :calendars, only: [:show]
  resources :campaigns, shallow: true do
    resources :subscriptions, only: [:create, :destroy]
    resources :feeds
    get :feed, on: :member, defaults: { format: :rss }
  end
  resources :passwords, param: :token
  resources :subscriptions, only: [:index]

  resource :session
  resource :user do
    post :webpush_test, on: :member
  end

  get 'mypage' => 'users#show'
  get 'past_campaigns' => "pages#past_campaigns"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
