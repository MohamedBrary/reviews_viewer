# TODO more test coverage, other than these smoke tests
# - I would rather test both underlying services through this service as an interface
# - test cases should cover each filter, match all, and pagination cases
describe SearchReviewsService do
  context '.call' do

    # a very nice article on how to properly integrate and test ES
    # https://bonsai.io/blog/testing-elasticsearch-ruby-gems.html
    it 'searches the index when asked to' do
      expect_any_instance_of(SearchReviewsIndexService).to receive(:call).and_call_original
      SearchReviewsService.new(source: SearchReviewsService::SOURCE_INDEX).call
    end

    it 'searches the database when asked to' do
      reviews = FactoryBot.create_list(:review, 3)
      expect_any_instance_of(SearchReviewsDatabaseService).to receive(:call).and_call_original
      result = SearchReviewsService.new(source: SearchReviewsService::SOURCE_DB).call
      expect(result.count).to eq(3)
    end

  end
end
