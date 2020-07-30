Rails.application.routes.draw do

  resources :reviews do
    collection do
      get :categories_sentiment_average
      get :themes_sentiment_average
    end
  end

  resources :review_themes
  resources :themes
  resources :categories

end
