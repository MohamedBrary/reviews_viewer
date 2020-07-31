class PagesController < ApplicationController
  def home
    @database_info = {
      reviews_count: Review.count,
      categories_count: Category.count,
      themes_count: Theme.count,
      review_themes_count: ReviewTheme.count
    }
  end

  def api_documentation
  end

  def read_me
  end
end
