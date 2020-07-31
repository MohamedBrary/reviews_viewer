class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.filter(params)
    @reviews = @reviews.paginate(pagination_params) if pagination_params.present?
  end

  # GET /reviews/categories_sentiment_average
  # GET /reviews/categories_sentiment_average.json
  def categories_sentiment_average
    @averages = Review.avg_sentiment_by_category_ids
  end

  # GET /themes_sentiment_average
  # GET /themes_sentiment_average.json
  def themes_sentiment_average
    @averages = Review.avg_sentiment_by_theme_ids
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params)

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /reviews/generate
  # POST /reviews/generate.json
  def generate
    reviews_num = (params[:reviews_num].presence || 1000).to_i
    Generators::Reviews.generate(
      categories_num: (params[:categories_num].presence || 3).to_i,
      reviews_num: reviews_num
    )
    respond_to do |format|
      format.html { redirect_to pages_home_url, notice: "#{reviews_num} Reviews were created!" }
      format.json { render json: {result: "#{reviews_num} Reviews were created!"} }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:id, :comment, :posted_at, :theme_ids, :category_ids,
        review_themes_attributes: [ :id, :theme_id, :sentiment ])
    end

    def reviews_index_params
      params.permit(:comment, :theme_ids, :category_ids, :page, :per_page)
    end

    def pagination_params
      pagination_params = {}
      pagination_params[:per_page] = params[:per_page] if params[:per_page].present?
      pagination_params[:page] = params[:page] if params[:page].present?
      pagination_params
    end
end
