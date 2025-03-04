require_relative 'factories_helper.rb'

#-------------
#------- Usage

# FactoryBot.create(:category, :with_themes)
# FactoryBot.build(:category)
# FactoryBot.create_list(:category, 3)

FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department(max: 1) }

    trait :with_themes do
      after(:create) do |category|
        create_list(:theme, rand(1..5), category: category)
      end
    end

  end
end
