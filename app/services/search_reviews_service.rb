class SearchReviewsService
  SOURCE_DB = 'db'.freeze
  SOURCE_INDEX = 'index'.freeze
  SOURCES = [SOURCE_DB, SOURCE_INDEX].freeze

  attr_accessor :source, :filter_params

  def initialize(search_params)
    @source = search_params[:source].presence
    @filter_params = search_params.except(:source)
  end

  def call
    case source
    when SOURCE_INDEX
      SearchReviewsIndexService.new(filter_params).call
    else
      SearchReviewsDatabaseService.new(filter_params).call
    end
  end

end
