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

ActiveRecord::Schema[7.0].define(version: 2023_12_12_142535) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_card_tags", force: :cascade do |t|
    t.bigint "business_card_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_card_id"], name: "index_business_card_tags_on_business_card_id"
    t.index ["tag_id"], name: "index_business_card_tags_on_tag_id"
  end

  create_table "business_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "last_name", limit: 100
    t.string "first_name", limit: 100
    t.string "company", limit: 100
    t.string "job_title", limit: 100
    t.string "department", limit: 100
    t.string "website", limit: 100
    t.string "email", limit: 100
    t.string "address"
    t.integer "status", default: 0, null: false
    t.string "code", limit: 100, null: false
    t.string "mobile_phone", limit: 100
    t.string "home_phone", limit: 100
    t.string "fax", limit: 100
    t.date "meeting_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name_phonetic"
    t.string "first_name_phonetic"
    t.index ["code"], name: "index_business_cards_on_code", unique: true
    t.index ["user_id"], name: "index_business_cards_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 100, null: false
    t.text "description"
    t.string "color", limit: 7, null: false
    t.integer "business_cards_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "user_billings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_customer_id"], name: "index_user_billings_on_stripe_customer_id", unique: true
    t.index ["user_id"], name: "index_user_billings_on_user_id"
  end

  create_table "user_invoices", force: :cascade do |t|
    t.bigint "user_billing_id", null: false
    t.bigint "user_subscription_id", null: false
    t.float "total"
    t.string "stripe_invoice_id"
    t.datetime "term_from"
    t.datetime "term_to"
    t.string "stripe_status"
    t.string "invoice_pdf"
    t.datetime "paid_at"
    t.integer "plan_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_invoice_id"], name: "index_user_invoices_on_stripe_invoice_id", unique: true
    t.index ["user_billing_id"], name: "index_user_invoices_on_user_billing_id"
    t.index ["user_subscription_id"], name: "index_user_invoices_on_user_subscription_id"
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.bigint "user_billing_id", null: false
    t.string "subscription_id"
    t.datetime "term_from"
    t.datetime "term_to"
    t.integer "plan_type"
    t.string "status"
    t.float "price"
    t.boolean "cancel_at_period_end", default: false
    t.string "payment_intent_status"
    t.integer "will_downgrade_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_user_subscriptions_on_subscription_id", unique: true
    t.index ["user_billing_id"], name: "index_user_subscriptions_on_user_billing_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "email", null: false
    t.string "uid", null: false
    t.string "providers", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_card_tags", "business_cards"
  add_foreign_key "business_card_tags", "tags"
  add_foreign_key "business_cards", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "user_billings", "users"
  add_foreign_key "user_invoices", "user_billings"
  add_foreign_key "user_invoices", "user_subscriptions"
  add_foreign_key "user_subscriptions", "user_billings"
end
