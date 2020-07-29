json.extract! review_theme, :id, :review_id, :theme_id, :category_id, :sentiment, :created_at, :updated_at
json.url review_theme_url(review_theme, format: :json)
