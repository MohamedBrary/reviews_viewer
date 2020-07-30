class ReviewTheme < ApplicationRecord
  SENTIMENTS = [-1, 0, 1].freeze

  belongs_to :review
  belongs_to :theme
  belongs_to :category

  before_validation :set_category

  validates :sentiment, presence: true

  def set_category
    self.category = self.theme.category
  end

  def senitment_as_percentage
    # logic: -1 => 0%, and 1 => 100%
    ((senitment+1)*50)
  end

  def self.senitment_as_percentage(senitment)
    # logic: -1 => 0%, and 1 => 100%
    ((senitment+1)*50)
  end
end
