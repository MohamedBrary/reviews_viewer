class CreateReviewThemes < ActiveRecord::Migration[6.0]
  def change
    create_table :review_themes do |t|
      t.references :review, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :sentiment

      t.timestamps
    end
  end
end
