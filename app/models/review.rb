class Review < ApplicationRecord
  has_many :review_themes
  accepts_nested_attributes_for :review_themes

  validates :comment, :posted_at, presence: true

  def set_category_and_theme_ids
    update_columns(
      category_ids: review_themes.distinct.pluck(:category_id),
      theme_ids: review_themes.distinct.pluck(:theme_id)
    )
  end

  def self.set_new_category_and_theme_ids
    Review.where(category_ids: nil).map(&:set_category_and_theme_ids)
  end

end
