class Review < ApplicationRecord

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

    # TODO All that should move to command/service objects

    # ------
    # Filtering

    def filter(filter_params)
      # TODO proper sanitization
      comment_filter = filter_params['comment'].presence
      category_ids_filter = filter_params['category_ids'].presence
      theme_ids_filter = filter_params['theme_ids'].presence

      scope = Review.all
      scope = scope.filter_by_comment(scope, comment_filter) if comment_filter
      scope = scope.filter_by_category_ids(scope, category_ids_filter) if category_ids_filter
      scope = scope.filter_by_theme_ids(scope, theme_ids_filter) if theme_ids_filter
      scope
    end

    def filter_by_comment(scope=nil, comment_filter)
      scope ||= Review
      scope.where('comment ILIKE ?', "%#{comment_filter}%")
    end

    def filter_by_category_ids(scope=nil, category_ids_filter)
      scope ||= Review
      # we use the overlap operator '&&' so if any category match we return it
      scope.where('category_ids && ARRAY[?]::int[]', category_ids_filter)
    end

    def filter_by_theme_ids(scope=nil, theme_ids_filter)
      scope ||= Review
      # we use the overlap operator '&&' so if any theme match we return it
      scope.where('theme_ids && ARRAY[?]::int[]', theme_ids_filter)
    end

    # ------
    # Aggregates

    def avg_sentiment_by_category_ids
      ReviewTheme.group(:category_id).average(:sentiment)
    end

    def avg_sentiment_by_theme_ids
      ReviewTheme.group(:theme_id).average(:sentiment)
    end

    def set_new_category_and_theme_ids
      Review.where(category_ids: nil).map(&:set_category_and_theme_ids)
    end

  end

end
