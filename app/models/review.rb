class Review < ApplicationRecord
  include Searchable::Review

  # ---------
  # Relations

  has_many :review_themes, dependent: :delete_all
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

    # TODO Regarding the average sentiment queries, Postgres does squential scan as the first step so it doesn't scale well,
    # 1) moving this to ElasticSearch would be an option,
    # 2) another option would be adding index on 'review_themes.sentiment' (maybe as a string/keyword, not integer to be faster?) and calculating it on server per category/theme, given that category/theme have limited number, and this query would utilize the index, so it should be faster

    # EXPLAIN Query:
    # ReviewTheme.select('AVG("review_themes"."sentiment") AS average_sentiment, "review_themes"."category_id" AS review_themes_category_id').group('"review_themes"."category_id"').explain
    #   ReviewTheme Load (5025.3ms)  SELECT AVG("review_themes"."sentiment") AS average_sentiment, "review_themes"."category_id" AS review_themes_category_id FROM "review_themes" GROUP BY "review_themes"."category_id"
    # => EXPLAIN for: SELECT AVG("review_themes"."sentiment") AS average_sentiment, "review_themes"."category_id" AS review_themes_category_id FROM "review_themes" GROUP BY "review_themes"."category_id"
    #                                                 QUERY PLAN
    # ----------------------------------------------------------------------------------------------------------
    #  Finalize GroupAggregate  (cost=358217.18..358219.24 rows=75 width=40)
    #    Group Key: category_id
    #    ->  Sort  (cost=358217.18..358217.55 rows=150 width=40)
    #          Sort Key: category_id
    #          ->  Gather  (cost=358196.00..358211.75 rows=150 width=40)
    #                Workers Planned: 2
    #                ->  Partial HashAggregate  (cost=357196.00..357196.75 rows=75 width=40)
    #                      Group Key: category_id
    #                      ->  Parallel Seq Scan on review_themes  (cost=0.00..312284.00 rows=8982400 width=12)

    def avg_sentiment_by_category_ids
      ReviewTheme.group(:category_id).average(:sentiment)
    end

    def avg_sentiment_by_theme_ids
      ReviewTheme.group(:theme_id).average(:sentiment)
    end

  end

end
