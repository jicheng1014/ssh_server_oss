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

ActiveRecord::Schema[8.1].define(version: 2026_01_20_180405) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "server_metrics", force: :cascade do |t|
    t.integer "cpu_cores"
    t.float "cpu_usage"
    t.datetime "created_at", null: false
    t.float "disk_total"
    t.float "disk_usage"
    t.float "memory_total"
    t.float "memory_usage"
    t.integer "server_id", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_metrics_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "host", null: false
    t.string "kernel_version"
    t.datetime "last_checked_at"
    t.text "last_error"
    t.string "name", null: false
    t.string "os_name"
    t.string "os_version"
    t.text "password"
    t.integer "port", default: 22
    t.integer "position", default: 0, null: false
    t.text "private_key"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["host"], name: "index_servers_on_host", unique: true
  end

  create_table "system_private_keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "private_key"
    t.datetime "updated_at", null: false
  end

  create_table "system_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "server_metrics", "servers"
end
