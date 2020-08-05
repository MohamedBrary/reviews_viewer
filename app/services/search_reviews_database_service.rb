class SearchReviewsDatabaseService
  attr_accessor :base_scope, :comment_filter, :category_ids_filter, :theme_ids_filter,
                :pagination_params

  def initialize(base_scope: nil, comment_filter: '', category_ids_filter: [], theme_ids_filter: [], pagination_params: {})
    @base_scope ||= Review.all
    @comment_filter = comment_filter.presence
    @category_ids_filter = category_ids_filter.presence
    @theme_ids_filter = theme_ids_filter.presence
    @pagination_params = pagination_params.presence
  end

  def call
    filter
  end

  # ------
  # Filtering

  def filter
    scope = base_scope
    scope = filter_by_comment(scope, comment_filter) if comment_filter
    scope = filter_by_category_ids(scope, category_ids_filter) if category_ids_filter
    scope = filter_by_theme_ids(scope, theme_ids_filter) if theme_ids_filter
    scope = scope.paginate(pagination_params) if pagination_params.present?
    scope.order(id: :asc)
  end

  def filter_by_comment(scope=nil, comment_filter)
    scope ||= base_scope
    scope.where('comment ILIKE ?', "%#{comment_filter}%")
  end

  def filter_by_category_ids(scope=nil, category_ids_filter)
    scope ||= base_scope
    # we use the overlap operator '&&' so if any category match we return it
    scope.where('category_ids && ARRAY[?]::int[]', category_ids_filter)
  end

  def filter_by_theme_ids(scope=nil, theme_ids_filter)
    scope ||= base_scope
    # we use the overlap operator '&&' so if any theme match we return it
    scope.where('theme_ids && ARRAY[?]::int[]', theme_ids_filter)
  end

end
