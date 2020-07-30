class CreateReviewThemes < ActiveRecord::Migration[6.0]
  def change
    create_table :review_themes do |t|
      t.references :review, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      # adding redundant category reference in this many to many table
      # to have a performance boost, for Category related aggregated queries
      t.references :category, null: false, foreign_key: true
      t.integer :sentiment

      t.timestamps
    end
  end
end
