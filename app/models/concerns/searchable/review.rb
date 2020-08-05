module Searchable
  module Review
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model

      mapping do
        # the default standard analyzer is enough
        # index_options: 'offsets' => to support faster highliting
        indexes :comment, index_options: 'offsets'

        indexes :posted_at, type: 'date'

        # by default ES supports arrays without indication
        # using type keyword instead of integer, to make it faster for filtering
        # as integer type is optimized for ranges
        indexes :category_ids, type: 'keyword'
        indexes :theme_ids, type: 'keyword'
      end

    end

    class_methods do
      # ------
      # Query Builders

      def query_skeleton
        {
          query:  {
            bool: {
            }
          },
          sort: { id: 'asc' },
          size: 10_000
        }
      end

      def match_all_query
        query = query_skeleton
        query[:query] = { match_all: {} }
        query
      end

      def filter_by_comment_query(query_json, comment_filter)
        # {
        #   query:  {
        #     bool: [
        #       {
        #         must: {
        #           match: { comment: comment_filter }
        #         }
        #       }
        #     ]
        #   },
        #   highlight: { fields: { comment: {} } }
        # }
        query_json ||= query_skeleton
        query_json[:query][:bool][:must] = {
          match: { comment: comment_filter }
        }
        # TODO highlight isn't working in this query, check the comments on the end of this file
        # query_json[:query][:highlight] = { fields: { comment: {} } }
        query_json
      end

      def filter_by_category_ids_filter_query(query_json, category_ids_filter)
        # {
        #   query:  {
        #     bool: {
        #       filter: {
        #         terms:{ category_ids: category_ids_filter }
        #       }
        #     }
        #   }
        # }

        query_json ||= query_skeleton
        query_json[:query][:bool][:filter] ||= []
        query_json[:query][:bool][:filter] << {
          terms:{ category_ids: category_ids_filter }
        }
        query_json
      end

      def filter_by_theme_ids_filter_query(query_json, theme_ids_filter)
        # {
        #   query:  {
        #     bool: {
        #       filter: {
        #         terms:{ theme_ids: theme_ids_filter }
        #       }
        #     }
        #   }
        # }

        query_json ||= query_skeleton
        query_json[:query][:bool][:filter] ||= []
        query_json[:query][:bool][:filter] << {
          terms:{ theme_ids: theme_ids_filter }
        }
        query_json
      end

      # ------
      # Utils

      def create_index
        __elasticsearch__.create_index! force: true
      end

      def import_to_index(scope=nil)
        scope ||= Review
        scope.import
      end

      def reindex
        import(force: true)
      end
    end

    def index_record
      # TODO use Sidekiq to do this in the background
      __elasticsearch__.index_document
    end

    def as_indexed_json(options={})
      # Currently we persist these fields in the model to help database search
      # So this is done as if the database was strictly normalized for benchmarking purposes
      as_json_options = {
        except: [:created_at, :updated_at]
      }.merge(options)

      as_json(as_json_options).merge(
        category_ids: review_themes.distinct.pluck(:category_id),
        theme_ids: review_themes.distinct.pluck(:theme_id)
      )
    end

  end
end

# {
#   query:  {
#     bool: {
#       must: {
#         match:{ comment: comment_filter }
#       },
#       filter: [
#         {terms:{ category_ids: category_ids_filter }},
#         {terms:{ theme_ids: theme_ids_filter }}
#       ]
#     }
#   },
#   highlight: { fields: { comment: {} } }
# }
# query = {
#   query:  {
#     bool: {
#       must: {
#         match:{ comment: 'complete' }
#       },
#       filter: [
#         {terms:{ category_ids: [1218] }},
#         {terms:{ theme_ids: [6374] }}
#       ]
#     }
#   },
#   highlight: { fields: { comment: {} } }
# }
# client = Elasticsearch::Client.new(log: true)
# client.indices.validate_query(body: query, explain: true)
# > GET http://localhost:9200/_validate/query?explain=true [status:200, request:0.008s, query:n/a]
# > {"query":{"bool":{"must":{"match":{"comment":"complete"}},"filter":[{"terms":{"category_ids":[1218]}},{"terms":{"theme_ids":[6374]}}]}},"highlight":{"fields":{"comment":{}}}}
# < {"valid":false,"error":"org.elasticsearch.common.ParsingException: request does not support [highlight]"}
