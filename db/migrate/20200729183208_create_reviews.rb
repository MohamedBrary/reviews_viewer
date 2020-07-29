class CreateReviews < ActiveRecord::Migration[6.0]
  enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

  def change
    create_table :reviews do |t|
      t.string :comment
      t.timestamp :posted_at
      t.integer :theme_ids, array: true
      t.integer :category_ids, array: true

      t.timestamps
    end

    # for faster similarity queries
    # we don't expect '=' operations, only like/ilike, so we don't need another btree index
    # and from Postgres manual on using gin vs gist:
    # | As a rule of thumb, a GIN index is faster to search than a GiST index,
    # | but slower to build or update
    # so we are using GIN here, as we need faster search
    add_index :reviews, :comment, using: 'gin', opclass: :gin_trgm_ops

    # we need to index the individual values of the fields, so we can do filter
    # by category or theme ids faster
    add_index :reviews, :theme_ids, using: 'gin'
    add_index :reviews, :category_ids, using: 'gin'
  end
end
