class Generators::Reviews

  def self.generate(categories_num: 3, reviews_num: 1000)
    # use factories for categories and themes, as they are limited anyway
    categories = FactoryBot.create_list(:category, categories_num, :with_themes)
    category_ids = categories.map(&:id)
    themes = Theme.where(category_id: category_ids)

    themes_with_category = themes.pluck(:id, :category_id).to_h

    # use populator to create reviews in a light weight mode, as these are the masses
    reviews_values = []
    reviews_num.times do |_i|
      theme_ids = []
      category_ids = []
      themes_per_review = rand(1..themes.count)
      themes_per_review.times do |_i|
        theme_id = -1
        loop do
          theme_id = themes_with_category.keys.sample
          break unless theme_id.in?(theme_ids)
        end
        theme_ids << theme_id
        category_ids << themes_with_category[theme_id]
      end

      reviews_values << {
        comment: Faker::TvShows::RickAndMorty.quote,
        posted_at: Time.zone.today - (Random.rand(reviews_num/3) + 1).days,
        theme_ids: theme_ids,
        category_ids: category_ids
      }
    end
    puts "=== Generated #{reviews_values.count} review values"
    reviews_count = Review.count
    Review.bulk_insert(
      values: reviews_values,
      ignore: true,
      set_size: 500,
      return_primary_keys: true
    )
    reviews_count = Review.count - reviews_count
    puts "=== Created #{reviews_count} reviews"

    review_themes_values = []
    new_review_ids = Review.order(created_at: :desc).limit(reviews_count).ids
    Review.where(id: new_review_ids).find_each do |review|
      review_themes_count = review.theme_ids.count
      review_themes_count.times do |i|
        review_themes_values << {
          review_id: review.id,
          theme_id: review.theme_ids[i],
          category_id: review.category_ids[i],
          sentiment: ReviewTheme::SENTIMENTS.sample
        }
      end
    end
    puts "=== Generated #{review_themes_values.count} review themes values"

    review_themes_count = ReviewTheme.count
    ReviewTheme.bulk_insert(
      values: review_themes_values,
      ignore: true,
      set_size: 500,
      return_primary_keys: true
    )
    review_themes_count = ReviewTheme.count - review_themes_count
    puts "=== Created #{review_themes_count} review themes"
  end

end
