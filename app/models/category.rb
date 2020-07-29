class Category < ApplicationRecord
  has_many :themes
  has_many :review_themes

  validates :name, presence: true

  def reviews
    @reviews ||= Review.where('category_ids @> ?', "{#{id}}")
  end

  def to_s
    name
  end
end
