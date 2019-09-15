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

ActiveRecord::Schema.define(version: 20190913164501) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "admin_services", force: :cascade do |t|
    t.string   "handles_regex_eval",         limit: 255
    t.string   "shortname",                  limit: 255
    t.string   "longname",                   limit: 255
    t.string   "display_name_eval",          limit: 255
    t.text     "account_matchers_eval",      limit: 65535
    t.string   "service_url_example",        limit: 255
    t.string   "service_url_canonical_eval", limit: 255
    t.boolean  "archived",                                 default: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "agencies", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shortname",                  limit: 255
    t.string   "info_url",                   limit: 255
    t.string   "mongo_id",                   limit: 255
    t.string   "parent_mongo_id",            limit: 255
    t.integer  "parent_id",                  limit: 4
    t.integer  "draft_outlet_count",         limit: 4,   default: 0
    t.integer  "draft_mobile_app_count",     limit: 4,   default: 0
    t.integer  "published_outlet_count",     limit: 4,   default: 0
    t.integer  "published_mobile_app_count", limit: 4,   default: 0
    t.integer  "draft_gallery_count",        limit: 4,   default: 0
    t.integer  "published_gallery_count",    limit: 4,   default: 0
    t.integer  "api_id",                     limit: 4
    t.string   "omb_name",                   limit: 255
    t.boolean  "stats_enabled"
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.string   "token",        limit: 255
    t.string   "email",        limit: 255
    t.string   "phone",        limit: 255
    t.boolean  "admin"
    t.integer  "access_count", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "duration",     limit: 255, default: "short"
  end

  add_index "auth_tokens", ["email"], name: "index_auth_tokens_on_email", using: :btree
  add_index "auth_tokens", ["token"], name: "index_auth_tokens_on_token", unique: true, using: :btree

  create_table "email_messages", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "to",         limit: 65535
    t.string   "subject",    limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "galleries", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "short_description", limit: 65535
    t.text     "long_description",  limit: 65535
    t.integer  "status",            limit: 4,     default: 0
  end

  create_table "gallery_agencies", force: :cascade do |t|
    t.integer "gallery_id", limit: 4
    t.integer "agency_id",  limit: 4
  end

  create_table "gallery_items", force: :cascade do |t|
    t.integer "gallery_id", limit: 4
    t.integer "item_id",    limit: 4
    t.string  "item_type",  limit: 255
    t.integer "item_order", limit: 4,   default: 0
  end

  create_table "gallery_official_tags", force: :cascade do |t|
    t.integer "gallery_id",      limit: 4
    t.integer "official_tag_id", limit: 4
  end

  create_table "gallery_users", force: :cascade do |t|
    t.integer "gallery_id", limit: 4
    t.integer "user_id",    limit: 4
  end

  create_table "mobile_app_agencies", force: :cascade do |t|
    t.integer "mobile_app_id", limit: 4
    t.integer "agency_id",     limit: 4
  end

  add_index "mobile_app_agencies", ["agency_id"], name: "index_mobile_app_agencies_on_agency_id", using: :btree
  add_index "mobile_app_agencies", ["mobile_app_id"], name: "index_mobile_app_agencies_on_mobile_app_id", using: :btree

  create_table "mobile_app_official_tags", force: :cascade do |t|
    t.integer "mobile_app_id",   limit: 4
    t.integer "official_tag_id", limit: 4
  end

  add_index "mobile_app_official_tags", ["mobile_app_id"], name: "index_mobile_app_official_tags_on_mobile_app_id", using: :btree
  add_index "mobile_app_official_tags", ["official_tag_id"], name: "index_mobile_app_official_tags_on_official_tag_id", using: :btree

  create_table "mobile_app_users", force: :cascade do |t|
    t.integer "mobile_app_id", limit: 4
    t.integer "user_id",       limit: 4
  end

  add_index "mobile_app_users", ["mobile_app_id"], name: "index_mobile_app_users_on_mobile_app_id", using: :btree
  add_index "mobile_app_users", ["user_id"], name: "index_mobile_app_users_on_user_id", using: :btree

  create_table "mobile_app_versions", force: :cascade do |t|
    t.integer  "mobile_app_id",     limit: 4
    t.text     "store_url",         limit: 16777215
    t.string   "platform",          limit: 255
    t.string   "version_number",    limit: 255
    t.datetime "publish_date"
    t.text     "description",       limit: 16777215
    t.text     "whats_new",         limit: 16777215
    t.text     "screenshot",        limit: 16777215
    t.string   "device",            limit: 255
    t.string   "language",          limit: 255
    t.string   "average_rating",    limit: 255
    t.integer  "number_of_ratings", limit: 4
    t.string   "mongo_id",          limit: 255
  end

  add_index "mobile_app_versions", ["platform"], name: "index_mobile_app_versions_on_platform", using: :btree

  create_table "mobile_apps", force: :cascade do |t|
    t.text     "name",                 limit: 16777215
    t.text     "short_description",    limit: 16777215
    t.text     "long_description",     limit: 16777215
    t.text     "icon_url",             limit: 16777215
    t.string   "language",             limit: 255
    t.integer  "agency_id",            limit: 4
    t.integer  "status",               limit: 4,        default: 0
    t.string   "mongo_id",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "validated_at"
    t.integer  "primary_contact_id",   limit: 4
    t.integer  "secondary_contact_id", limit: 4
    t.integer  "primary_agency_id",    limit: 4
    t.integer  "secondary_agency_id",  limit: 4
    t.text     "notes",                limit: 65535
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "item_id",           limit: 4
    t.string   "item_type",         limit: 255
    t.string   "message",           limit: 255
    t.string   "message_type",      limit: 255
    t.string   "notification_type", limit: 255
    t.boolean  "has_read",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "official_tags", force: :cascade do |t|
    t.string   "tag_text",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "draft_gallery_count",        limit: 4,   default: 0
    t.integer  "draft_mobile_app_count",     limit: 4,   default: 0
    t.integer  "draft_outlet_count",         limit: 4,   default: 0
    t.integer  "published_gallery_count",    limit: 4,   default: 0
    t.integer  "published_mobile_app_count", limit: 4,   default: 0
    t.integer  "published_outlet_count",     limit: 4,   default: 0
    t.integer  "tag_type",                   limit: 4,   default: 0
  end

  create_table "outlet_official_tags", force: :cascade do |t|
    t.integer "outlet_id",       limit: 4
    t.integer "official_tag_id", limit: 4
  end

  add_index "outlet_official_tags", ["official_tag_id"], name: "index_outlet_official_tags_on_official_tag_id", using: :btree
  add_index "outlet_official_tags", ["outlet_id"], name: "index_outlet_official_tags_on_outlet_id", using: :btree

  create_table "outlet_related_policies", force: :cascade do |t|
    t.integer  "outlet_id",         limit: 4
    t.integer  "related_policy_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "outlet_users", force: :cascade do |t|
    t.integer "outlet_id", limit: 4
    t.integer "user_id",   limit: 4
  end

  add_index "outlet_users", ["outlet_id"], name: "index_outlet_users_on_outlet_id", using: :btree
  add_index "outlet_users", ["user_id"], name: "index_outlet_users_on_user_id", using: :btree

  create_table "outlets", force: :cascade do |t|
    t.string   "service_url",           limit: 255
    t.string   "organization",          limit: 255
    t.string   "account",               limit: 255
    t.string   "language",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "service",               limit: 255
    t.integer  "status",                limit: 4,        default: 0
    t.text     "short_description",     limit: 16777215
    t.text     "long_description",      limit: 16777215
    t.integer  "twitter_followers",     limit: 4
    t.integer  "twitter_posts",         limit: 4
    t.integer  "twitter_interactions",  limit: 4
    t.integer  "facebook_followers",    limit: 4
    t.integer  "facebook_likes",        limit: 4
    t.integer  "facebook_posts",        limit: 4
    t.integer  "facebook_interactions", limit: 4
    t.integer  "youtube_subscribers",   limit: 4
    t.integer  "youtube_view_count",    limit: 4
    t.integer  "youtube_comment_count", limit: 4
    t.integer  "youtube_video_count",   limit: 4
    t.integer  "instagram_followers",   limit: 4
    t.integer  "instagram_posts",       limit: 4
    t.string   "access_token",          limit: 255
    t.datetime "validated_at"
    t.integer  "primary_contact_id",    limit: 4
    t.integer  "secondary_contact_id",  limit: 4
    t.integer  "primary_agency_id",     limit: 4
    t.integer  "secondary_agency_id",   limit: 4
    t.text     "notes",                 limit: 65535
  end

  add_index "outlets", ["account"], name: "index_outlets_on_account", using: :btree
  add_index "outlets", ["service", "account"], name: "index_outlets_on_service_and_account", using: :btree
  add_index "outlets", ["service"], name: "index_outlets_on_service", using: :btree

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message",    limit: 65535
    t.string   "username",   limit: 255
    t.integer  "item",       limit: 4
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "related_policies", force: :cascade do |t|
    t.boolean  "service_wide"
    t.string   "service",      limit: 255
    t.string   "title",        limit: 255
    t.string   "url",          limit: 255
    t.string   "description",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "outlet_id",  limit: 4
    t.integer  "agency_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["agency_id"], name: "index_sponsorships_on_agency_id", using: :btree
  add_index "sponsorships", ["outlet_id", "agency_id"], name: "index_sponsorships_on_outlet_id_and_agency_id", unique: true, using: :btree
  add_index "sponsorships", ["outlet_id"], name: "index_sponsorships_on_outlet_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                        limit: 255,      default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                limit: 4,        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",           limit: 255
    t.string   "last_sign_in_ip",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user",                         limit: 255,                      null: false
    t.integer  "agency_id",                    limit: 4
    t.string   "phone",                        limit: 255
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.text     "groups",                       limit: 16777215
    t.integer  "role",                         limit: 4,        default: 0
    t.boolean  "agency_notifications",                          default: false
    t.boolean  "agency_notifications_emails",                   default: false
    t.boolean  "contact_notifications",                         default: true
    t.boolean  "contact_notifications_emails",                  default: true
    t.integer  "email_notification_type",      limit: 4,        default: 0
    t.string   "provider",                     limit: 255
    t.string   "uid",                          limit: 255
  end

end
