require_relative 'factories_helper.rb'

#-------------
#------- Usage

# FactoryBot.create(:theme, :with_themes)
# FactoryBot.build(:theme)
# FactoryBot.create_list(:theme, 3, category: Category.first)

FactoryBot.define do
  factory :theme do
    name { Faker::Science.unique.element }
    category { FactoriesHelper.sample_record_or_generate(Category) }
  end
end
