# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140707010619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_histories", force: true do |t|
    t.decimal  "amount",           precision: 10, scale: 2
    t.text     "description"
    t.integer  "overflow_from_id"
    t.integer  "account_id"
    t.integer  "quick_fund_id"
    t.integer  "income_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_histories", ["account_id"], name: "index_account_histories_on_account_id", using: :btree
  add_index "account_histories", ["income_id"], name: "index_account_histories_on_income_id", using: :btree
  add_index "account_histories", ["overflow_from_id"], name: "index_account_histories_on_overflow_from_id", using: :btree
  add_index "account_histories", ["quick_fund_id"], name: "index_account_histories_on_quick_fund_id", using: :btree

  create_table "accounts", force: true do |t|
    t.text     "name"
    t.text     "description"
    t.integer  "priority"
    t.boolean  "enabled"
    t.decimal  "amount",                  precision: 10, scale: 2
    t.integer  "negative_overflow_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prerequisite_account_id"
    t.decimal  "cap"
    t.decimal  "add_per_month",                                    default: 0.0
    t.text     "add_per_month_type",                               default: "$"
    t.decimal  "monthly_cap"
    t.integer  "overflow_into_id"
  end

  add_index "accounts", ["negative_overflow_id"], name: "index_accounts_on_negative_overflow_id", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "quick_funds", force: true do |t|
    t.decimal  "amount",      precision: 10, scale: 2
    t.integer  "account_id"
    t.text     "description"
    t.string   "fund_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quick_funds", ["account_id"], name: "index_quick_funds_on_account_id", using: :btree

  create_table "users", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.string   "password_digest"
    t.decimal  "undistributed_funds", precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_login_at"
  end

end
