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

ActiveRecord::Schema.define(version: 20160220012004) do

  create_table "orders", force: :cascade do |t|
    t.integer  "user_client",         limit: 4
    t.integer  "user_driver",         limit: 4
    t.string   "address_origin",      limit: 255
    t.string   "address_destination", limit: 255
    t.string   "reference",           limit: 255
    t.string   "state",               limit: 255
    t.integer  "time_estimated",      limit: 4
    t.string   "payment_type",        limit: 255
    t.string   "promotion_code",      limit: 255
    t.decimal  "amount",                          precision: 10
    t.datetime "start_time"
    t.string   "end_time",            limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "orders", ["user_client"], name: "index_orders_on_user_client", using: :btree
  add_index "orders", ["user_driver"], name: "index_orders_on_user_driver", using: :btree

  create_table "tests", force: :cascade do |t|
    t.string   "username",   limit: 255
    t.string   "passwd",     limit: 255
    t.integer  "state",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "passwd",                 limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "role",                   limit: 255
    t.string   "phone",                  limit: 255
    t.string   "credit_card",            limit: 255
    t.datetime "expiration_credit_card"
    t.integer  "cvv",                    limit: 4
    t.string   "license",                limit: 255
    t.string   "soat",                   limit: 255
    t.string   "brand",                  limit: 255
    t.string   "modele",                 limit: 255
    t.string   "plate",                  limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "state_driver",           limit: 255
  end

  add_foreign_key "orders", "users", column: "user_client"
  add_foreign_key "orders", "users", column: "user_driver"
end
