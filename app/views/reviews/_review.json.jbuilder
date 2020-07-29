json.extract! review, :id, :comment, :posted_at, :theme_ids, :category_ids, :created_at, :updated_at
json.url review_url(review, format: :json)
