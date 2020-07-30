require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Reviews' do
  explanation 'Reviews resource'

  get '/reviews.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
    end

    with_options with_example: true do
      parameter :comment
      parameter :theme_ids
      parameter :category_ids
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
        response_category_ids = response_json.map { |r| r['category_ids'] }.flatten.uniq.sort
        expect(response_category_ids).to eq(category_ids)
      end
    end

  end

  get '/reviews/categories.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
    end

    context '200' do
      example_request 'Getting average sentiment per category' do
        expect(status).to eq(200)
      end

    end

  end

  get '/reviews/themes.json' do

    before do
      FactoryBot.create_list(:category, 2, :with_themes)
      FactoryBot.create_list(:review, 4, :with_themes)
    end

    context '200' do
      example_request 'Getting average sentiment per theme' do
        expect(status).to eq(200)
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

    context "200" do
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
        expect(status).to eq(200)
        expect(response_body).to eq(expected_response)
      end
    end

    context "400" do

      example 'Create a review with invalid params' do
        request = {
          review: {
            id: 59457787
          }
        }

        do_request(request)

        expect(status).to eq(400)
      end
    end

  end
end
