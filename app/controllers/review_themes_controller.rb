class ReviewThemesController < ApplicationController
  before_action :set_review_theme, only: [:show, :edit, :update, :destroy]

  # GET /review_themes
  # GET /review_themes.json
  def index
    @review_themes = ReviewTheme.all
  end

  # GET /review_themes/1
  # GET /review_themes/1.json
  def show
  end

  # GET /review_themes/new
  def new
    @review_theme = ReviewTheme.new
  end

  # GET /review_themes/1/edit
  def edit
  end

  # POST /review_themes
  # POST /review_themes.json
  def create
    @review_theme = ReviewTheme.new(review_theme_params)

    respond_to do |format|
      if @review_theme.save
        format.html { redirect_to @review_theme, notice: 'Review theme was successfully created.' }
        format.json { render :show, status: :created, location: @review_theme }
      else
        format.html { render :new }
        format.json { render json: @review_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /review_themes/1
  # PATCH/PUT /review_themes/1.json
  def update
    respond_to do |format|
      if @review_theme.update(review_theme_params)
        format.html { redirect_to @review_theme, notice: 'Review theme was successfully updated.' }
        format.json { render :show, status: :ok, location: @review_theme }
      else
        format.html { render :edit }
        format.json { render json: @review_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /review_themes/1
  # DELETE /review_themes/1.json
  def destroy
    @review_theme.destroy
    respond_to do |format|
      format.html { redirect_to review_themes_url, notice: 'Review theme was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_theme
      @review_theme = ReviewTheme.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_theme_params
      params.require(:review_theme).permit(:review_id, :theme_id, :category_id, :sentiment)
    end
end
