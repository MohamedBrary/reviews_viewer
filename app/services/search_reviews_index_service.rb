class SearchReviewsIndexService
  attr_accessor :base_scope, :comment_filter, :category_ids_filter, :theme_ids_filter,
                :pagination_params

  def initialize(base_scope: nil, comment_filter: '', category_ids_filter: [], theme_ids_filter: [], pagination_params: {})
    @base_scope ||= Review.all
    @comment_filter = comment_filter.presence
    @category_ids_filter = category_ids_filter.presence
    @theme_ids_filter = theme_ids_filter.presence
    # TODO handle pagination
    @pagination_params = pagination_params.presence
  end

  def call
    index_filter
  end

  # ------
  # Filtering

  def index_filter
    query_json = nil
    query_json = Review.filter_by_comment_query(query_json, comment_filter) if comment_filter
    query_json = Review.filter_by_category_ids_filter_query(query_json, category_ids_filter) if category_ids_filter
    query_json = Review.filter_by_theme_ids_filter_query(query_json, theme_ids_filter) if theme_ids_filter
    # match all records in case no filters are called
    query_json ||= Review.match_all_query

    Review.search(query_json).results
  end

end
