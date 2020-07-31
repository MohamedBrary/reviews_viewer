# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_29_183211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "intarray"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "review_themes", force: :cascade do |t|
    t.bigint "review_id", null: false
    t.bigint "theme_id", null: false
    t.bigint "category_id", null: false
    t.integer "sentiment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_review_themes_on_category_id"
    t.index ["review_id"], name: "index_review_themes_on_review_id"
    t.index ["theme_id"], name: "index_review_themes_on_theme_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "comment"
    t.datetime "posted_at"
    t.integer "theme_ids", array: true
    t.integer "category_ids", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_ids"], name: "index_reviews_on_category_ids", opclass: :gin__int_ops, using: :gin
    t.index ["comment"], name: "index_reviews_on_comment", opclass: :gin_trgm_ops, using: :gin
    t.index ["theme_ids"], name: "index_reviews_on_theme_ids", opclass: :gin__int_ops, using: :gin
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_themes_on_category_id"
  end

  add_foreign_key "review_themes", "categories"
  add_foreign_key "review_themes", "reviews"
  add_foreign_key "review_themes", "themes"
  add_foreign_key "themes", "categories"
end
