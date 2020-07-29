class Theme < ApplicationRecord
  belongs_to :category
  has_many :review_themes

  validates :name, presence: true

  def reviews
    @reviews ||= Review.where('theme_ids @> ?', "{#{id}}")
  end
end
