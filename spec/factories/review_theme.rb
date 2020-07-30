require_relative 'factories_helper.rb'

#-------------
#------- Usage

# FactoryBot.create(:review_theme, :with_review_themes)
# FactoryBot.build(:review_theme)
# FactoryBot.create_list(:review_theme, 3, review: Review.first)

FactoryBot.define do
  factory :review_theme do
    sentiment { ReviewTheme::SENTIMENTS.sample }
    theme { FactoriesHelper.sample_record_or_generate(Theme) }
    category { theme.category }
    review { FactoriesHelper.sample_record_or_generate(Review) }
  end
end
