class ReviewTheme < ApplicationRecord
  belongs_to :review
  belongs_to :theme
  belongs_to :category

  before_validation :set_category

  validates :sentiment, presence: true

  def set_category
    self.category = self.theme.category
  end
end
