require_relative 'factories_helper.rb'

#-------------
#------- Usage

# FactoryBot.create(:review)
# FactoryBot.build(:review, :with_themes)
# FactoryBot.create_list(:review, 3, category_ids: [1,2,3])

FactoryBot.define do
  factory :review do

    comment { Faker::Movies::VForVendetta.quote }
    posted_at { FactoriesHelper.past_date }

    trait :with_themes do
      after(:create) do |review|
        create_list(:review_theme, rand(1..3), review: review)
        review.set_category_and_theme_ids
      end
    end

  end
end
