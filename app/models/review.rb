class Review < ApplicationRecord
  include Searchable::Review

  # ---------
  # Relations

  has_many :review_themes
  accepts_nested_attributes_for :review_themes

  # -----------
  # Validations

  validates :comment, :posted_at, presence: true

  # ----
  # Core

  def set_category_and_theme_ids
    update_columns(
      category_ids: review_themes.distinct.pluck(:category_id),
      theme_ids: review_themes.distinct.pluck(:theme_id)
    )
  end

  # -------
  # Class Methods

  class << self

    def set_new_category_and_theme_ids
      Review.where(category_ids: nil).map(&:set_category_and_theme_ids)
    end

    # ------
    # Aggregates
    # TODO move these to aggregate services

    def avg_sentiment_by_category_ids
      ReviewTheme.group(:category_id).average(:sentiment)
    end

    def avg_sentiment_by_theme_ids
      ReviewTheme.group(:theme_id).average(:sentiment)
    end

  end

end
