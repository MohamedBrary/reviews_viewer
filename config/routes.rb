Rails.application.routes.draw do
  resources :reviews do
    collection do
      get :categories_sentiment_average
      get :themes_sentiment_average
      post :generate
    end
  end

  resources :review_themes
  resources :themes
  resources :categories

  get 'pages/home'
  get 'pages/api_documentation'
  get 'pages/read_me'

  root 'pages#home'
end
