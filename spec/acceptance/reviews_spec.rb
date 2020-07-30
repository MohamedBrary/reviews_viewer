require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Reviews' do
  explanation 'Reviews resource'

  get '/reviews.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
      # make sure these categories has some reviews
      FactoryBot.create_list(:review_theme, 2, category: Category.first)
      FactoryBot.create_list(:review_theme, 2, category: Category.last)
      # make sure these themes has some reviews
      FactoryBot.create_list(:review_theme, 2, theme: Theme.first)
      FactoryBot.create_list(:review_theme, 2, theme: Theme.last)
      # make a weird review comment to test the text search
      FactoryBot.create(:review, comment: 'A_Unique_Comment')
    end

    with_options with_example: true do
      parameter :comment, 'We can match any part of the review comment, with this parameter'
      parameter :category_ids, 'Any review that has any of the category ids provided, will be matched'
      parameter :theme_ids, 'Any review that has any of the theme ids provided, will be matched'
    end

    context '200' do
      example_request 'Getting a list of reviews' do
        expect(status).to eq(200)
      end

      example 'Filtering reviews by category_ids' do
        category_ids = [Category.first.id].sort
        request = { category_ids: category_ids }

        do_request(request)

        expect(status).to eq(200)

        response_json = JSON.parse(response_body)
        response_json.each do |filtered_review|
          # every returned review should at least have one of the requested catefory ids
          review_category_ids = Review.find(filtered_review['id']).review_themes.pluck(:category_id)
          expect((category_ids & review_category_ids).any?).to eq(true)
        end
      end

      example 'Filtering reviews by theme_ids' do
        theme_ids = [Theme.first.id].sort
        request = { theme_ids: theme_ids }

        do_request(request)

        expect(status).to eq(200)

        response_json = JSON.parse(response_body)
        response_json.each do |filtered_review|
          # every returned review should at least have one of the requested catefory ids
          review_theme_ids = Review.find(filtered_review['id']).review_themes.pluck(:theme_id)
          expect((theme_ids & review_theme_ids).any?).to eq(true)
        end
      end

      example 'Filtering reviews by comment' do
        review = Review.where(comment: 'A_Unique_Comment').first
        request = { comment: '_Unique_' }

        do_request(request)

        expect(status).to eq(200)

        response_json = JSON.parse(response_body).first
        expect(response_json['id']).to eq(review.id)
      end
    end

  end

  get '/reviews/categories_sentiment_average.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
    end

    context '200' do
      example_request 'Getting average sentiment per category' do
        expected_entry_count = ReviewTheme.distinct.pluck(:category_id).count

        expect(status).to eq(200)

        response_json = JSON.parse(response_body)['averages']
        expect(response_json.count).to eq(expected_entry_count)
      end

    end

  end

  get '/reviews/themes_sentiment_average.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
    end

    context '200' do
      example_request 'Getting average sentiment per theme' do
        expected_entry_count = ReviewTheme.distinct.pluck(:theme_id).count

        expect(status).to eq(200)

        response_json = JSON.parse(response_body)['averages']
        expect(response_json.count).to eq(expected_entry_count)
      end

    end

  end

  post '/reviews.json' do

    before do
      # create two themes
      FactoryBot.create_list(:theme, 2)
    end

    with_options scope: :review, with_example: true do
      parameter :comment, 'The review comment', required: true
      parameter :posted_at, 'The review intitial creation date', required: true, type: :object
      parameter :id, 'The review intitial id [currently used as internal id as well if provided]', required: true
      with_options scope: :review_themes_attributes, with_example: true do
        parameter :theme_id, 'The theme id', required: true
        parameter :sentiment, 'emotional characteristic of a review’s theme which can be negative
(-1), neutral (0) or positive (+1)', required: true
      end
    end

    context '201' do
      let(:themes) { Theme.limit(2) }

      example 'Create a review with valid params' do
        request = {
          review: {
            comment: 'Review created from API!',
            posted_at: 3.days.ago,
            id: 59457787,
            review_themes_attributes: [
              {
                theme_id: themes.first.id,
                sentiment: ReviewTheme::SENTIMENTS.sample
              },
              {
                theme_id: themes.last.id,
                sentiment: ReviewTheme::SENTIMENTS.sample
              }
            ]
          }
        }

        do_request(request)

        expected_response = Review.last
        expect(status).to eq(201)
        response_json = JSON.parse(response_body)
        expect(response_json['id']).to eq(expected_response.id)
      end
    end

    context '422' do

      example 'Create a review with invalid params', document: false do
        request = {
          review: {
            id: 59457787
          }
        }

        do_request(request)

        expect(status).to eq(422)
      end
    end

  end
end
