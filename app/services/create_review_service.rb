class CreateReviewService
  attr_accessor :review_params, :index_review

  def initialize(review_params, index_review: true)
    @review_params = review_params
    @index_review = index_review
  end

  def call
    @review = Review.new(review_params)

    if @review.persisted?
      @review.set_category_and_theme_ids
      @review.index_record if index_review
    end

    @review
  end

end
