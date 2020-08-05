class Data::Generator
  BATCH_SIZE = 10_000

  def self.generate_reviews(categories_num: 3, reviews_num: 1000)
    puts "=== Attempting to create #{categories_num} categories and #{reviews_num} reviews"

    # use factories for categories and themes, as they are limited anyway
    categories = FactoryBot.create_list(:category, categories_num, :with_themes)
    category_ids = categories.map(&:id).compact
    themes = Theme.where(category_id: category_ids)
    themes_with_category = themes.pluck(:id, :category_id).to_h
    puts "=== Created #{category_ids.count} categories and #{themes.count} themes"

    # use bulk_insert to create reviews in a light weight mode, as these are the masses
    reviews_count = Review.count
    review_themes_count = ReviewTheme.count
    batches_num = (reviews_num.to_f/BATCH_SIZE).ceil
    puts "=== Creating #{reviews_num} reviews and their themes over #{batches_num} batches of size #{BATCH_SIZE}"

    (1..batches_num).each do |batch_number|
      batch_reviews_num = batch_number==batches_num ?
        (reviews_num%BATCH_SIZE) : BATCH_SIZE

      puts "=== Progress #{batch_number}/#{batches_num} batch is created" if batch_number%10 == 0
      # generate new reviews attributes
      reviews_values = []
      batch_reviews_num.times do |_i|
        theme_ids = []
        category_ids = []
        themes_per_review = [rand(1..themes.count), 3].min # max 3 themes per review
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
          posted_at: Time.zone.today - (Random.rand(365)+1).days,
          theme_ids: theme_ids,
          category_ids: category_ids # ids would be duplicated, but we need that so we can optimize the bulk creation of ReviewTheme later on
        }
      end

      # create the new review records
      Review.bulk_insert(
        values: reviews_values,
        ignore: true,
        set_size: BATCH_SIZE
      )

      # generate new review themes attributes
      review_themes_values = []
      # find_each will override the limit condition, so we have to do this query over 2 steps
      new_review_ids = Review.order(created_at: :desc).limit(batch_reviews_num).ids
      new_reviews = Review.where(id: new_review_ids)
      new_reviews.find_each do |review|
        new_review_themes_count = review.theme_ids.count
        new_review_themes_count.times do |i|
          review_themes_values << {
            review_id: review.id,
            theme_id: review.theme_ids[i],
            category_id: review.category_ids[i],
            sentiment: ReviewTheme::SENTIMENTS.sample
          }
        end
      end

      # create the review theme records
      ReviewTheme.bulk_insert(
        values: review_themes_values,
        ignore: true,
        set_size: BATCH_SIZE
      )

      # index new reviews
      Review.import_to_index(new_reviews)
    end
    reviews_count = Review.count - reviews_count
    puts "=== Created #{reviews_count} reviews"

    review_themes_count = ReviewTheme.count - review_themes_count
    puts "=== Created #{review_themes_count} review themes"

    puts '=== Generation is done!'
  end

end
