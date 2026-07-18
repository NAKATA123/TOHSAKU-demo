# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_07_18_142104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cars", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "car_model"
    t.string "car_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "shaken_expiry_date"
    t.index ["customer_id"], name: "index_cars_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loaner_cars", force: :cascade do |t|
    t.string "name"
    t.string "car_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "shaken_expiry_date"
  end

  create_table "notices", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "notice_date"
    t.index ["notice_date"], name: "index_notices_on_notice_date", unique: true
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.text "endpoint"
    t.string "p256dh_key"
    t.string "auth_key"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rentals", force: :cascade do |t|
    t.bigint "loaner_car_id", null: false
    t.bigint "repair_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.string "customer_name"
    t.index ["created_by_id"], name: "index_rentals_on_created_by_id"
    t.index ["loaner_car_id"], name: "index_rentals_on_loaner_car_id"
    t.index ["repair_id"], name: "index_rentals_on_repair_id"
  end

  create_table "repairs", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.text "description"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "received_at"
    t.date "completed_at"
    t.index ["car_id"], name: "index_repairs_on_car_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "name"
    t.string "employee_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
  end

  add_foreign_key "cars", "customers"
  add_foreign_key "rentals", "loaner_cars"
  add_foreign_key "rentals", "repairs"
  add_foreign_key "rentals", "users", column: "created_by_id"
  add_foreign_key "repairs", "cars"
end
