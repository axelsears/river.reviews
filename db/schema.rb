# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170905125925) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "municipalities", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.string "zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_municipalities_on_state_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "abbreviation", limit: 2
    t.string "name", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "waterways", force: :cascade do |t|
    t.string "name"
    t.string "site_id"
    t.bigint "municipality_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["municipality_id"], name: "index_waterways_on_municipality_id"
  end

  add_foreign_key "municipalities", "states"
  add_foreign_key "waterways", "municipalities"
end
