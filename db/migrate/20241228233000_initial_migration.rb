class InitialMigration < ActiveRecord::Migration[7.0]
  def up
    enable_extension "btree_gist"
    enable_extension "pgcrypto"
    enable_extension "plpgsql"

    create_table "aozora_books", force: :cascade do |t|
      t.string "title", null: false
      t.string "author", null: false
      t.bigint "author_id"
      t.bigint "file_id"
      t.text "footnote"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "words_count", default: 0
      t.string "beginning"
      t.integer "access_count", default: 0
      t.string "category_id"
      t.boolean "rights_reserved", default: false
      t.string "first_edition"
      t.integer "published_at"
      t.string "character_type"
      t.boolean "juvenile", default: false, null: false
      t.string "sub_title"
      t.integer "canonical_book_id"
      t.string "source"
      t.index ["access_count"], name: "index_aozora_books_on_access_count"
      t.index ["canonical_book_id"], name: "index_aozora_books_on_canonical_book_id"
      t.index ["category_id"], name: "index_aozora_books_on_category_id"
      t.index ["character_type"], name: "index_aozora_books_on_character_type"
      t.index ["juvenile"], name: "index_aozora_books_on_juvenile"
      t.index ["published_at"], name: "index_aozora_books_on_published_at"
      t.index ["words_count"], name: "index_aozora_books_on_words_count"
    end

    create_table "delayed_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at", precision: nil
      t.datetime "locked_at", precision: nil
      t.datetime "failed_at", precision: nil
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end

    create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.integer "book_id", null: false
      t.string "book_type", null: false
      t.date "start_date", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.date "end_date", null: false
      t.time "delivery_time", default: "2000-01-01 07:00:00", null: false
      t.uuid "user_id", null: false
      t.index ["book_id", "book_type"], name: "index_campaigns_on_book_id_and_book_type"
      t.index ["end_date"], name: "index_campaigns_on_end_date"
      t.index ["start_date"], name: "index_campaigns_on_start_date"
      t.index ["user_id"], name: "index_campaigns_on_user_id"
    end

    create_table "email_digests", primary_key: "digest", id: :string, force: :cascade do |t|
      t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.boolean "trial_ended", default: false, null: false
      t.datetime "canceled_at", precision: nil
      t.index ["canceled_at"], name: "index_email_digests_on_canceled_at"
    end

    create_table "feeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "campaign_id", null: false
      t.uuid "delayed_job_id"
      t.string "title", null: false
      t.text "content", null: false
      t.date "delivery_date", null: false
      t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.text "comment"
      t.index ["delayed_job_id"], name: "index_feeds_on_delayed_job_id"
      t.index ["campaign_id"], name: "index_feeds_on_campaign_id"
    end

    create_table "guten_books", force: :cascade do |t|
      t.string "title", null: false
      t.string "author"
      t.boolean "rights_reserved", default: false
      t.string "language", default: "en"
      t.bigint "downloads", default: 0
      t.integer "words_count", default: 0, null: false
      t.integer "chars_count", default: 0, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "author_id"
      t.string "category_id"
      t.string "beginning"
      t.integer "unique_words_count", default: 0
      t.integer "ngsl_words_count", default: 0
      t.float "ngsl_ratio"
      t.integer "birth_year"
      t.integer "death_year"
      t.integer "canonical_book_id"
      t.string "sub_title"
      t.index ["author_id"], name: "index_guten_books_on_author_id"
      t.index ["canonical_book_id"], name: "index_guten_books_on_canonical_book_id"
      t.index ["category_id"], name: "index_guten_books_on_category_id"
      t.index ["ngsl_ratio"], name: "index_guten_books_on_ngsl_ratio"
    end

    create_table "guten_books_subjects", id: false, force: :cascade do |t|
      t.bigint "guten_book_id"
      t.string "subject_id"
      t.index ["guten_book_id", "subject_id"], name: "index_guten_books_subjects_on_guten_book_id_and_subject_id", unique: true
      t.index ["guten_book_id"], name: "index_guten_books_subjects_on_guten_book_id"
      t.index ["subject_id"], name: "index_guten_books_subjects_on_subject_id"
    end

    create_table "subjects", id: :string, force: :cascade do |t|
      t.integer "books_count", default: 0
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end

    create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "user_id", null: false
      t.uuid "campaign_id", null: false
      t.string "delivery_method", default: "email", null: false
      t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.index ["delivery_method"], name: "index_subscriptions_on_delivery_method"
      t.index ["campaign_id"], name: "index_subscriptions_on_campaign_id"
      t.index ["user_id", "campaign_id"], name: "index_subscriptions_on_user_id_and_campaign_id", unique: true
      t.index ["user_id"], name: "index_subscriptions_on_user_id"
    end

    create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "email", null: false
      t.string "crypted_password"
      t.string "salt"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "stripe_customer_id"
      t.date "trial_start_date"
      t.date "trial_end_date"
      t.string "plan", default: "free", null: false
      t.string "magic_login_token"
      t.datetime "magic_login_token_expires_at", precision: nil
      t.datetime "magic_login_email_sent_at", precision: nil
      t.string "fcm_device_token"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    end

    add_foreign_key "aozora_books", "aozora_books", column: "canonical_book_id"
    add_foreign_key "campaigns", "users"
    add_foreign_key "feeds", "delayed_jobs", on_delete: :nullify
    add_foreign_key "feeds", "campaigns", on_delete: :cascade
    add_foreign_key "guten_books", "guten_books", column: "canonical_book_id"
    add_foreign_key "guten_books_subjects", "guten_books", on_delete: :cascade
    add_foreign_key "guten_books_subjects", "subjects", on_delete: :cascade
    add_foreign_key "subscriptions", "campaigns"
    add_foreign_key "subscriptions", "users"
  end
end
