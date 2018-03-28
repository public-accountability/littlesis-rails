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

ActiveRecord::Schema.define(version: 20180328171242) do

  create_table "address", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",                                null: false
    t.string   "street1",      limit: 100
    t.string   "street2",      limit: 100
    t.string   "street3",      limit: 100
    t.string   "city",         limit: 50,                  null: false
    t.string   "county",       limit: 50
    t.integer  "state_id"
    t.integer  "country_id"
    t.string   "postal",       limit: 20
    t.string   "latitude",     limit: 20
    t.string   "longitude",    limit: 20
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",               default: false, null: false
    t.integer  "last_user_id"
    t.string   "accuracy",     limit: 30
    t.string   "country_name", limit: 50,                  null: false
    t.string   "state_name",   limit: 50
    t.index ["category_id"], name: "category_id_idx", using: :btree
    t.index ["country_id"], name: "country_id_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["state_id"], name: "state_id_idx", using: :btree
  end

  create_table "address_category", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", limit: 20, null: false
  end

  create_table "address_country", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", limit: 50, null: false
    t.index ["name"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "address_state", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name",         limit: 50, null: false
    t.string "abbreviation", limit: 2,  null: false
    t.bigint "country_id",              null: false
    t.index ["country_id"], name: "country_id_idx", using: :btree
    t.index ["name"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "alias", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",                            null: false
    t.string   "name",         limit: 200,             null: false
    t.string   "context",      limit: 50
    t.integer  "is_primary",               default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.index ["entity_id", "name", "context"], name: "uniqueness_idx", unique: true, using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["name"], name: "name_idx", using: :btree
  end

  create_table "api_request", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "api_key",    limit: 100, null: false
    t.string   "resource",   limit: 200, null: false
    t.string   "ip_address", limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["api_key"], name: "api_key_idx", using: :btree
    t.index ["created_at"], name: "created_at_idx", using: :btree
  end

  create_table "api_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_api_tokens_on_user_id", unique: true, using: :btree
  end

  create_table "api_user", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "api_key",       limit: 100,                        null: false
    t.string   "name_first",    limit: 50,                         null: false
    t.string   "name_last",     limit: 50,                         null: false
    t.string   "email",         limit: 100,                        null: false
    t.text     "reason",        limit: 4294967295,                 null: false
    t.boolean  "is_active",                        default: false, null: false
    t.integer  "request_limit",                    default: 10000, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["api_key"], name: "api_key_idx", using: :btree
    t.index ["api_key"], name: "api_key_unique_idx", unique: true, using: :btree
    t.index ["email"], name: "email_unique_idx", unique: true, using: :btree
  end

  create_table "article", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text     "url",                 limit: 16777215,                   null: false
    t.string   "title",               limit: 200,                        null: false
    t.string   "authors",             limit: 200
    t.text     "body",                limit: 4294967295,                 null: false
    t.text     "description",         limit: 16777215
    t.integer  "source_id"
    t.datetime "published_at"
    t.boolean  "is_indexed",                             default: false, null: false
    t.datetime "reviewed_at"
    t.bigint   "reviewed_by_user_id"
    t.boolean  "is_featured",                            default: false, null: false
    t.boolean  "is_hidden",                              default: false, null: false
    t.datetime "found_at",                                               null: false
    t.index ["source_id"], name: "source_id_idx", using: :btree
  end

  create_table "article_entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "article_id",                  null: false
    t.integer  "entity_id",                   null: false
    t.boolean  "is_featured", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "article_id"], name: "index_article_entities_on_entity_id_and_article_id", unique: true, using: :btree
    t.index ["is_featured"], name: "index_article_entities_on_is_featured", using: :btree
  end

  create_table "article_entity", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "article_id",                                      null: false
    t.integer  "entity_id",                                       null: false
    t.string   "original_name",       limit: 100,                 null: false
    t.boolean  "is_verified",                     default: false, null: false
    t.bigint   "reviewed_by_user_id"
    t.datetime "reviewed_at"
    t.index ["article_id"], name: "article_id_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "article_source", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name",         limit: 100, null: false
    t.string "abbreviation", limit: 10,  null: false
  end

  create_table "articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title",              null: false
    t.string   "url",                null: false
    t.string   "snippet"
    t.datetime "published_at"
    t.string   "created_by_user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "annual_profit"
    t.bigint "entity_id",     null: false
    t.bigint "assets",                     unsigned: true
    t.bigint "marketcap",                  unsigned: true
    t.bigint "net_income"
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "business_industry", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "business_id", null: false
    t.bigint "industry_id", null: false
    t.index ["business_id"], name: "business_id_idx", using: :btree
    t.index ["industry_id"], name: "industry_id_idx", using: :btree
  end

  create_table "business_person", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "sec_cik"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "candidate_district", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "candidate_id", null: false
    t.bigint   "district_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["candidate_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
    t.index ["district_id"], name: "district_id_idx", using: :btree
  end

  create_table "chat_user", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "user_id",    null: false
    t.bigint   "room",       null: false
    t.datetime "updated_at", null: false
    t.index ["room", "updated_at", "user_id"], name: "room_updated_at_user_id_idx", using: :btree
    t.index ["room", "user_id"], name: "room_user_id_idx", unique: true, using: :btree
    t.index ["user_id"], name: "user_id_idx", using: :btree
  end

  create_table "cmp_entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "entity_id"
    t.integer  "cmp_id"
    t.integer  "entity_type", limit: 1, null: false, unsigned: true
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["cmp_id"], name: "index_cmp_entities_on_cmp_id", unique: true, using: :btree
    t.index ["entity_id"], name: "index_cmp_entities_on_entity_id", unique: true, using: :btree
  end

  create_table "couple", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "entity_id",   null: false
    t.integer "partner1_id"
    t.integer "partner2_id"
    t.index ["entity_id"], name: "index_couple_on_entity_id", using: :btree
    t.index ["partner1_id"], name: "index_couple_on_partner1_id", using: :btree
    t.index ["partner2_id"], name: "index_couple_on_partner2_id", using: :btree
  end

  create_table "custom_key", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",         limit: 50,         null: false
    t.text     "value",        limit: 4294967295
    t.string   "description",  limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50,         null: false
    t.bigint   "object_id",                       null: false
    t.index ["object_model", "object_id", "name", "value"], name: "object_name_value_idx", unique: true, length: { value: 100 }, using: :btree
    t.index ["object_model", "object_id", "name"], name: "object_name_idx", unique: true, using: :btree
    t.index ["object_model", "object_id"], name: "object_idx", using: :btree
  end

  create_table "degree", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name",         limit: 50, null: false
    t.string "abbreviation", limit: 10
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "priority",                    default: 0, null: false
    t.integer  "attempts",                    default: 0, null: false
    t.text     "handler",    limit: 16777215,             null: false
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.text     "url",              limit: 65535,                null: false
    t.string   "url_hash",         limit: 40,                   null: false
    t.string   "publication_date", limit: 10
    t.integer  "ref_type",                          default: 1, null: false
    t.text     "excerpt",          limit: 16777215
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["url_hash"], name: "index_documents_on_url_hash", unique: true, using: :btree
  end

  create_table "donation", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "bundler_id"
    t.bigint "relationship_id", null: false
    t.index ["bundler_id"], name: "bundler_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "education", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "degree_id"
    t.string  "field",           limit: 30
    t.boolean "is_dropout"
    t.bigint  "relationship_id",            null: false
    t.index ["degree_id"], name: "degree_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "elected_representative", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "bioguide_id", limit: 20
    t.string "govtrack_id", limit: 20
    t.string "crp_id",      limit: 20
    t.string "pvs_id",      limit: 20
    t.string "watchdog_id", limit: 50
    t.bigint "entity_id",              null: false
    t.index ["crp_id"], name: "crp_id_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "email", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",                               null: false
    t.string   "address",      limit: 60,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",              default: false, null: false
    t.integer  "last_user_id"
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
  end

  create_table "entity", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",         limit: 200
    t.string   "blurb",        limit: 200
    t.text     "summary",      limit: 4294967295
    t.text     "notes",        limit: 4294967295
    t.string   "website",      limit: 100
    t.bigint   "parent_id"
    t.string   "primary_ext",  limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_date",   limit: 10
    t.string   "end_date",     limit: 10
    t.boolean  "is_current"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id"
    t.integer  "merged_id"
    t.boolean  "delta",                           default: true,  null: false
    t.bigint   "link_count",                      default: 0,     null: false
    t.index ["blurb"], name: "blurb_idx", using: :btree
    t.index ["created_at"], name: "created_at_idx", using: :btree
    t.index ["delta"], name: "index_entity_on_delta", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["name", "blurb", "website"], name: "search_idx", using: :btree
    t.index ["name"], name: "name_idx", using: :btree
    t.index ["parent_id"], name: "parent_id_idx", using: :btree
    t.index ["updated_at"], name: "updated_at_idx", using: :btree
    t.index ["website"], name: "website_idx", using: :btree
  end

  create_table "entity_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "entity_id"
    t.integer "field_id"
    t.string  "value",                     null: false
    t.boolean "is_admin",  default: false
    t.index ["entity_id", "field_id"], name: "index_entity_fields_on_entity_id_and_field_id", unique: true, using: :btree
  end

  create_table "extension_definition", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name",         limit: 30,                 null: false
    t.string  "display_name", limit: 50,                 null: false
    t.boolean "has_fields",              default: false, null: false
    t.bigint  "parent_id"
    t.bigint  "tier"
    t.index ["name"], name: "name_idx", using: :btree
    t.index ["parent_id"], name: "parent_id_idx", using: :btree
    t.index ["tier"], name: "tier_idx", using: :btree
  end

  create_table "extension_record", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "entity_id",     null: false
    t.bigint  "definition_id", null: false
    t.integer "last_user_id"
    t.index ["definition_id"], name: "definition_id_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
  end

  create_table "family", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "is_nonbiological"
    t.bigint  "relationship_id",  null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "fedspending_filing", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "relationship_id"
    t.bigint  "amount"
    t.text    "goods",           limit: 4294967295
    t.bigint  "district_id"
    t.string  "fedspending_id",  limit: 30
    t.string  "start_date",      limit: 10
    t.string  "end_date",        limit: 10
    t.boolean "is_current"
    t.index ["district_id"], name: "district_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name",                            null: false
    t.string "display_name",                    null: false
    t.string "type",         default: "string", null: false
    t.index ["name"], name: "index_fields_on_name", unique: true, using: :btree
  end

  create_table "gender", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", limit: 10, null: false
  end

  create_table "generic", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "government_body", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "is_federal"
    t.bigint  "state_id"
    t.string  "city",       limit: 50
    t.string  "county",     limit: 50
    t.bigint  "entity_id",             null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["state_id"], name: "state_id_idx", using: :btree
  end

  create_table "group_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "group_id"
    t.integer "list_id"
    t.boolean "is_featured", default: false, null: false
    t.index ["group_id", "list_id"], name: "index_group_lists_on_group_id_and_list_id", unique: true, using: :btree
    t.index ["list_id"], name: "index_group_lists_on_list_id", using: :btree
  end

  create_table "group_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",   default: false, null: false
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_group_users_on_user_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "tagline"
    t.text     "description",        limit: 16777215
    t.boolean  "is_private",                          default: false, null: false
    t.string   "slug"
    t.integer  "default_network_id"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.text     "findings",           limit: 16777215
    t.text     "howto",              limit: 16777215
    t.integer  "featured_list_id"
    t.string   "cover"
    t.boolean  "delta",                               default: true,  null: false
    t.string   "logo_credit"
    t.index ["campaign_id"], name: "index_groups_on_campaign_id", using: :btree
    t.index ["delta"], name: "index_groups_on_delta", using: :btree
    t.index ["slug"], name: "index_groups_on_slug", unique: true, using: :btree
  end

  create_table "help_pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",                          null: false
    t.string   "title"
    t.text     "markdown",     limit: 16777215
    t.integer  "last_user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["name"], name: "index_help_pages_on_name", unique: true, using: :btree
  end

  create_table "hierarchy", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "image", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id"
    t.string   "filename",     limit: 100,                        null: false
    t.string   "title",        limit: 100,                        null: false
    t.text     "caption",      limit: 4294967295
    t.boolean  "is_featured",                     default: false, null: false
    t.boolean  "is_free"
    t.string   "url",          limit: 400
    t.bigint   "width"
    t.bigint   "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id"
    t.boolean  "has_square",                      default: false, null: false
    t.integer  "address_id"
    t.string   "raw_address",  limit: 200
    t.boolean  "has_face",                        default: false, null: false
    t.integer  "user_id"
    t.index ["address_id"], name: "index_image_on_address_id", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
  end

  create_table "industries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name",        null: false
    t.string "industry_id", null: false
    t.string "sector_name", null: false
    t.index ["industry_id"], name: "index_industries_on_industry_id", unique: true, using: :btree
  end

  create_table "industry", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",       limit: 100, null: false
    t.string   "context",    limit: 30
    t.string   "code",       limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "entity1_id",      null: false
    t.bigint  "entity2_id",      null: false
    t.bigint  "category_id",     null: false
    t.bigint  "relationship_id", null: false
    t.boolean "is_reverse",      null: false
    t.index ["category_id"], name: "category_id_idx", using: :btree
    t.index ["entity1_id", "category_id", "is_reverse"], name: "index_link_on_entity1_id_and_category_id_and_is_reverse", using: :btree
    t.index ["entity1_id", "category_id"], name: "index_link_on_entity1_id_and_category_id", using: :btree
    t.index ["entity1_id"], name: "entity1_id_idx", using: :btree
    t.index ["entity2_id"], name: "entity2_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "lobby_filing", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "federal_filing_id", limit: 50,  null: false
    t.bigint  "amount"
    t.bigint  "year"
    t.string  "period",            limit: 100
    t.string  "report_type",       limit: 100
    t.string  "start_date",        limit: 10
    t.string  "end_date",          limit: 10
    t.boolean "is_current"
  end

  create_table "lobby_filing_lobby_issue", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "issue_id",                           null: false
    t.bigint "lobby_filing_id",                    null: false
    t.text   "specific_issue",  limit: 4294967295
    t.index ["issue_id"], name: "issue_id_idx", using: :btree
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
  end

  create_table "lobby_filing_lobbyist", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "lobbyist_id",     null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
    t.index ["lobbyist_id"], name: "lobbyist_id_idx", using: :btree
  end

  create_table "lobby_filing_relationship", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "lobby_issue", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "lobbying", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "lobbyist", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "lda_registrant_id"
    t.bigint "entity_id",         null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "ls_list", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",              limit: 100,                        null: false
    t.text     "description",       limit: 4294967295
    t.boolean  "is_ranked",                            default: false, null: false
    t.boolean  "is_admin",                             default: false, null: false
    t.boolean  "is_featured",                          default: false, null: false
    t.boolean  "is_network",                           default: false, null: false
    t.string   "display_name",      limit: 50
    t.bigint   "featured_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.boolean  "is_deleted",                           default: false, null: false
    t.string   "custom_field_name", limit: 100
    t.boolean  "delta",                                default: true,  null: false
    t.integer  "creator_user_id"
    t.string   "short_description"
    t.integer  "access",            limit: 1,          default: 0,     null: false
    t.index ["delta"], name: "index_ls_list_on_delta", using: :btree
    t.index ["featured_list_id"], name: "featured_list_id", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["name"], name: "index_ls_list_on_name", using: :btree
  end

  create_table "ls_list_entity", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "list_id",                                    null: false
    t.bigint   "entity_id",                                  null: false
    t.bigint   "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.boolean  "is_deleted",                 default: false, null: false
    t.text     "custom_field", limit: 65535
    t.index ["created_at"], name: "created_at_idx", using: :btree
    t.index ["entity_id", "is_deleted", "list_id"], name: "entity_deleted_list_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["list_id", "is_deleted", "entity_id"], name: "list_deleted_entity_idx", using: :btree
    t.index ["list_id"], name: "list_id_idx", using: :btree
  end

  create_table "map_annotations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "map_id",                               null: false
    t.integer "order",                                null: false
    t.string  "title"
    t.text    "description",            limit: 65535
    t.string  "highlighted_entity_ids"
    t.string  "highlighted_rel_ids"
    t.string  "highlighted_text_ids"
    t.index ["map_id"], name: "index_map_annotations_on_map_id", using: :btree
  end

  create_table "membership", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "dues"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "modification", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "object_name",     limit: 100
    t.integer  "user_id",                     default: 1,     null: false
    t.boolean  "is_create",                   default: false, null: false
    t.boolean  "is_delete",                   default: false, null: false
    t.boolean  "is_merge",                    default: false, null: false
    t.bigint   "merge_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model",    limit: 50,                  null: false
    t.bigint   "object_id",                                   null: false
    t.index ["is_create"], name: "is_create_idx", using: :btree
    t.index ["is_delete"], name: "is_delete_idx", using: :btree
    t.index ["object_id"], name: "object_id_idx", using: :btree
    t.index ["object_model", "object_id"], name: "object_idx", using: :btree
    t.index ["object_model"], name: "object_model_idx", using: :btree
    t.index ["user_id", "is_create", "object_model"], name: "points_summary_idx", using: :btree
    t.index ["user_id"], name: "user_id_idx", using: :btree
  end

  create_table "modification_field", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "modification_id",                    null: false
    t.string "field_name",      limit: 50,         null: false
    t.text   "old_value",       limit: 4294967295
    t.text   "new_value",       limit: 4294967295
    t.index ["modification_id"], name: "modification_id_idx", using: :btree
  end

  create_table "network_map", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "user_id",                                              null: false
    t.text     "data",              limit: 4294967295,                 null: false
    t.string   "entity_ids",        limit: 5000
    t.string   "rel_ids",           limit: 5000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                           default: false, null: false
    t.string   "title",             limit: 100
    t.text     "description",       limit: 4294967295
    t.integer  "width",                                                null: false
    t.integer  "height",                                               null: false
    t.boolean  "is_featured",                          default: false, null: false
    t.string   "zoom",                                 default: "1",   null: false
    t.boolean  "is_private",                           default: false, null: false
    t.string   "thumbnail"
    t.boolean  "delta",                                default: true,  null: false
    t.text     "index_data",        limit: 4294967295
    t.string   "secret"
    t.text     "graph_data",        limit: 16777215
    t.text     "annotations_data",  limit: 65535
    t.integer  "annotations_count",                    default: 0,     null: false
    t.boolean  "list_sources",                         default: false, null: false
    t.boolean  "is_cloneable",                         default: true,  null: false
    t.index ["delta"], name: "index_network_map_on_delta", using: :btree
    t.index ["user_id"], name: "user_id_idx", using: :btree
  end

  create_table "note", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",                                          null: false
    t.string   "title",              limit: 50
    t.text     "body",               limit: 65535,                 null: false
    t.text     "body_raw",           limit: 65535,                 null: false
    t.string   "alerted_user_names", limit: 500
    t.string   "alerted_user_ids",   limit: 500
    t.string   "entity_ids",         limit: 200
    t.string   "relationship_ids",   limit: 200
    t.string   "lslist_ids",         limit: 200
    t.string   "sfguardgroup_ids",   limit: 200
    t.string   "network_ids",        limit: 200
    t.boolean  "is_private",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_legacy",                        default: false, null: false
    t.integer  "sf_guard_user_id"
    t.integer  "new_user_id"
    t.boolean  "delta",                            default: true,  null: false
    t.index ["alerted_user_ids"], name: "alerted_user_ids_idx", length: { alerted_user_ids: 255 }, using: :btree
    t.index ["delta"], name: "index_note_on_delta", using: :btree
    t.index ["entity_ids"], name: "entity_ids_idx", using: :btree
    t.index ["is_private"], name: "is_private_idx", using: :btree
    t.index ["lslist_ids"], name: "lslist_ids_idx", using: :btree
    t.index ["new_user_id"], name: "index_note_on_new_user_id", using: :btree
    t.index ["relationship_ids"], name: "relationship_ids_idx", using: :btree
    t.index ["sf_guard_user_id"], name: "index_note_on_sf_guard_user_id", using: :btree
    t.index ["updated_at"], name: "updated_at_idx", using: :btree
    t.index ["user_id"], name: "user_id_idx", using: :btree
  end

  create_table "note_entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "entity_id"
    t.index ["entity_id"], name: "index_note_entities_on_entity_id", using: :btree
    t.index ["note_id", "entity_id"], name: "index_note_entities_on_note_id_and_entity_id", unique: true, using: :btree
  end

  create_table "note_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_note_groups_on_group_id", using: :btree
    t.index ["note_id", "group_id"], name: "index_note_groups_on_note_id_and_group_id", unique: true, using: :btree
  end

  create_table "note_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "list_id"
    t.index ["list_id"], name: "index_note_lists_on_list_id", using: :btree
    t.index ["note_id", "list_id"], name: "index_note_lists_on_note_id_and_list_id", unique: true, using: :btree
  end

  create_table "note_networks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "network_id"
    t.index ["network_id"], name: "index_note_networks_on_network_id", using: :btree
    t.index ["note_id", "network_id"], name: "index_note_networks_on_note_id_and_network_id", unique: true, using: :btree
  end

  create_table "note_relationships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "relationship_id"
    t.index ["note_id", "relationship_id"], name: "index_note_relationships_on_note_id_and_relationship_id", unique: true, using: :btree
    t.index ["relationship_id"], name: "index_note_relationships_on_relationship_id", using: :btree
  end

  create_table "note_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "note_id"
    t.integer "user_id"
    t.index ["note_id", "user_id"], name: "index_note_users_on_note_id_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_note_users_on_user_id", using: :btree
  end

  create_table "ny_disclosures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "filer_id",                  limit: 10,                null: false
    t.string   "report_id"
    t.string   "transaction_code",          limit: 1,                 null: false
    t.string   "e_year",                    limit: 4,                 null: false
    t.bigint   "transaction_id",                                      null: false
    t.date     "schedule_transaction_date"
    t.date     "original_date"
    t.string   "contrib_code",              limit: 4
    t.string   "contrib_type_code",         limit: 1
    t.string   "corp_name"
    t.string   "first_name"
    t.string   "mid_init"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state",                     limit: 2
    t.string   "zip",                       limit: 5
    t.string   "check_number"
    t.string   "check_date"
    t.float    "amount1",                   limit: 24
    t.float    "amount2",                   limit: 24
    t.string   "description"
    t.string   "other_recpt_code"
    t.string   "purpose_code1"
    t.string   "purpose_code2"
    t.string   "explanation"
    t.string   "transfer_type",             limit: 1
    t.string   "bank_loan_check_box",       limit: 1
    t.string   "crerec_uid"
    t.datetime "crerec_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                                default: true, null: false
    t.index ["contrib_code"], name: "index_ny_disclosures_on_contrib_code", using: :btree
    t.index ["delta"], name: "index_ny_disclosures_on_delta", using: :btree
    t.index ["e_year"], name: "index_ny_disclosures_on_e_year", using: :btree
    t.index ["filer_id", "report_id", "transaction_id", "schedule_transaction_date", "e_year"], name: "index_filer_report_trans_date_e_year", using: :btree
    t.index ["filer_id"], name: "index_ny_disclosures_on_filer_id", using: :btree
    t.index ["original_date"], name: "index_ny_disclosures_on_original_date", using: :btree
  end

  create_table "ny_filer_entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "ny_filer_id"
    t.integer  "entity_id"
    t.boolean  "is_committee"
    t.integer  "cmte_entity_id"
    t.string   "e_year",         limit: 4
    t.string   "filer_id"
    t.string   "office"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_entity_id"], name: "index_ny_filer_entities_on_cmte_entity_id", using: :btree
    t.index ["entity_id"], name: "index_ny_filer_entities_on_entity_id", using: :btree
    t.index ["filer_id"], name: "index_ny_filer_entities_on_filer_id", using: :btree
    t.index ["is_committee"], name: "index_ny_filer_entities_on_is_committee", using: :btree
    t.index ["ny_filer_id"], name: "index_ny_filer_entities_on_ny_filer_id", using: :btree
  end

  create_table "ny_filers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "filer_id",         null: false
    t.string   "name"
    t.string   "filer_type"
    t.string   "status"
    t.string   "committee_type"
    t.integer  "office"
    t.integer  "district"
    t.string   "treas_first_name"
    t.string   "treas_last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["filer_id"], name: "index_ny_filers_on_filer_id", unique: true, using: :btree
    t.index ["filer_type"], name: "index_ny_filers_on_filer_type", using: :btree
  end

  create_table "ny_matches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "ny_disclosure_id"
    t.integer  "donor_id"
    t.integer  "recip_id"
    t.integer  "relationship_id"
    t.integer  "matched_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["donor_id"], name: "index_ny_matches_on_donor_id", using: :btree
    t.index ["ny_disclosure_id"], name: "index_ny_matches_on_ny_disclosure_id", unique: true, using: :btree
    t.index ["recip_id"], name: "index_ny_matches_on_recip_id", using: :btree
    t.index ["relationship_id"], name: "index_ny_matches_on_relationship_id", using: :btree
  end

  create_table "object_tag", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "tag_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50, null: false
    t.bigint   "object_id",               null: false
    t.integer  "last_user_id"
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["object_model", "object_id", "tag_id"], name: "uniqueness_idx", unique: true, using: :btree
    t.index ["object_model", "object_id"], name: "object_idx", using: :btree
    t.index ["tag_id"], name: "tag_id_idx", using: :btree
  end

  create_table "org", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name",              limit: 200, null: false
    t.string "name_nick",         limit: 100
    t.bigint "employees"
    t.bigint "revenue"
    t.string "fedspending_id",    limit: 10
    t.string "lda_registrant_id", limit: 10
    t.bigint "entity_id",                     null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "os_candidates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "cycle",                    null: false
    t.string   "feccandid",                null: false
    t.string   "crp_id",                   null: false
    t.string   "name"
    t.string   "party",          limit: 1
    t.string   "distid_runfor"
    t.string   "distid_current"
    t.boolean  "currcand"
    t.boolean  "cyclecand"
    t.string   "crpico",         limit: 1
    t.string   "recipcode",      limit: 2
    t.string   "nopacs",         limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["crp_id"], name: "index_os_candidates_on_crp_id", using: :btree
    t.index ["cycle", "crp_id"], name: "index_os_candidates_on_cycle_and_crp_id", using: :btree
    t.index ["feccandid"], name: "index_os_candidates_on_feccandid", using: :btree
  end

  create_table "os_category", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "category_id",   limit: 10,  null: false
    t.string "category_name", limit: 100, null: false
    t.string "industry_id",   limit: 10,  null: false
    t.string "industry_name", limit: 100, null: false
    t.string "sector_name",   limit: 100, null: false
    t.index ["category_id"], name: "unique_id_idx", unique: true, using: :btree
    t.index ["category_name"], name: "unique_name_idx", unique: true, using: :btree
  end

  create_table "os_committees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "cycle",           limit: 4, null: false
    t.string   "cmte_id",                   null: false
    t.string   "name"
    t.string   "affiliate"
    t.string   "ultorg"
    t.string   "recipid"
    t.string   "recipcode",       limit: 2
    t.string   "feccandid"
    t.string   "party",           limit: 1
    t.string   "primcode",        limit: 5
    t.string   "source"
    t.boolean  "sensitive"
    t.boolean  "foreign"
    t.boolean  "active_in_cycle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_id", "cycle"], name: "index_os_committees_on_cmte_id_and_cycle", using: :btree
    t.index ["cmte_id"], name: "index_os_committees_on_cmte_id", using: :btree
    t.index ["recipid"], name: "index_os_committees_on_recipid", using: :btree
  end

  create_table "os_donations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "cycle",           limit: 4,  null: false
    t.string   "fectransid",      limit: 19, null: false
    t.string   "contribid",       limit: 12
    t.string   "contrib"
    t.string   "recipid",         limit: 9
    t.string   "orgname"
    t.string   "ultorg"
    t.string   "realcode",        limit: 5
    t.date     "date"
    t.integer  "amount"
    t.string   "street"
    t.string   "city"
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 5
    t.string   "recipcode",       limit: 2
    t.string   "transactiontype", limit: 3
    t.string   "cmteid",          limit: 9
    t.string   "otherid",         limit: 9
    t.string   "gender",          limit: 1
    t.string   "microfilm",       limit: 30
    t.string   "occupation"
    t.string   "employer"
    t.string   "source",          limit: 5
    t.string   "fec_cycle_id",    limit: 24, null: false
    t.string   "name_last"
    t.string   "name_first"
    t.string   "name_middle"
    t.string   "name_suffix"
    t.string   "name_prefix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["amount"], name: "index_os_donations_on_amount", using: :btree
    t.index ["contribid"], name: "index_os_donations_on_contribid", using: :btree
    t.index ["cycle"], name: "index_os_donations_on_cycle", using: :btree
    t.index ["date"], name: "index_os_donations_on_date", using: :btree
    t.index ["fec_cycle_id"], name: "index_os_donations_on_fec_cycle_id", unique: true, using: :btree
    t.index ["fectransid", "cycle"], name: "index_os_donations_on_fectransid_and_cycle", using: :btree
    t.index ["fectransid"], name: "index_os_donations_on_fectransid", using: :btree
    t.index ["microfilm"], name: "index_os_donations_on_microfilm", using: :btree
    t.index ["name_last", "name_first"], name: "index_os_donations_on_name_last_and_name_first", using: :btree
    t.index ["realcode", "amount"], name: "index_os_donations_on_realcode_and_amount", using: :btree
    t.index ["realcode"], name: "index_os_donations_on_realcode", using: :btree
    t.index ["recipid", "amount"], name: "index_os_donations_on_recipid_and_amount", using: :btree
    t.index ["recipid"], name: "index_os_donations_on_recipid", using: :btree
    t.index ["state"], name: "index_os_donations_on_state", using: :btree
    t.index ["zip"], name: "index_os_donations_on_zip", using: :btree
  end

  create_table "os_entity_category", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",               null: false
    t.string   "category_id", limit: 10,  null: false
    t.string   "source",      limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "category_id_idx", using: :btree
    t.index ["entity_id", "category_id"], name: "uniqueness_idx", unique: true, using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "os_entity_donor", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",                                      null: false
    t.string   "donor_id",            limit: 12,                              collation: "utf8_general_ci"
    t.bigint   "match_code"
    t.boolean  "is_verified",                    default: false, null: false
    t.bigint   "reviewed_by_user_id"
    t.boolean  "is_processed",                   default: false, null: false
    t.boolean  "is_synced",                      default: true,  null: false
    t.datetime "reviewed_at"
    t.bigint   "locked_by_user_id"
    t.datetime "locked_at"
    t.index ["entity_id", "donor_id"], name: "entity_donor_idx", unique: true, using: :btree
    t.index ["is_synced"], name: "is_synced_idx", using: :btree
    t.index ["locked_at"], name: "locked_at_idx", using: :btree
    t.index ["reviewed_at"], name: "reviewed_at_idx", using: :btree
  end

  create_table "os_entity_preprocess", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",              null: false
    t.string   "cycle",        limit: 4, null: false
    t.datetime "processed_at",           null: false
    t.datetime "updated_at"
    t.index ["entity_id", "cycle"], name: "entity_cycle_idx", unique: true, using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "os_entity_transaction", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "entity_id",                                      null: false
    t.string   "cycle",               limit: 4,                  null: false
    t.string   "transaction_id",      limit: 30,                 null: false
    t.bigint   "match_code"
    t.boolean  "is_verified",                    default: false, null: false
    t.boolean  "is_processed",                   default: false, null: false
    t.boolean  "is_synced",                      default: true,  null: false
    t.bigint   "reviewed_by_user_id"
    t.datetime "reviewed_at"
    t.bigint   "locked_by_user_id"
    t.datetime "locked_at"
    t.index ["entity_id", "cycle", "transaction_id"], name: "entity_cycle_transaction_idx", unique: true, using: :btree
    t.index ["is_synced"], name: "is_synced_idx", using: :btree
    t.index ["locked_at"], name: "locked_at_idx", using: :btree
    t.index ["reviewed_at"], name: "reviewed_at_idx", using: :btree
  end

  create_table "os_matches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "os_donation_id",                  null: false
    t.integer  "donation_id"
    t.integer  "donor_id",                        null: false
    t.integer  "recip_id"
    t.integer  "relationship_id"
    t.integer  "matched_by"
    t.boolean  "is_deleted",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cmte_id"
    t.index ["cmte_id"], name: "index_os_matches_on_cmte_id", using: :btree
    t.index ["donor_id"], name: "index_os_matches_on_donor_id", using: :btree
    t.index ["os_donation_id"], name: "index_os_matches_on_os_donation_id", using: :btree
    t.index ["recip_id"], name: "index_os_matches_on_recip_id", using: :btree
    t.index ["relationship_id"], name: "index_os_matches_on_relationship_id", using: :btree
  end

  create_table "ownership", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "percent_stake"
    t.bigint "shares"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                          null: false
    t.string   "title"
    t.text     "markdown",     limit: 16777215
    t.integer  "last_user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["name"], name: "index_pages_on_name", unique: true, using: :btree
  end

  create_table "person", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name_last",      limit: 50,    null: false
    t.string  "name_first",     limit: 50,    null: false
    t.string  "name_middle",    limit: 50
    t.string  "name_prefix",    limit: 30
    t.string  "name_suffix",    limit: 30
    t.string  "name_nick",      limit: 30
    t.string  "birthplace",     limit: 50
    t.bigint  "gender_id"
    t.bigint  "party_id"
    t.boolean "is_independent"
    t.bigint  "net_worth"
    t.bigint  "entity_id",                    null: false
    t.string  "name_maiden",    limit: 50
    t.text    "nationality",    limit: 65535
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["gender_id"], name: "gender_id_idx", using: :btree
    t.index ["name_last", "name_first", "name_middle"], name: "name_idx", using: :btree
    t.index ["party_id"], name: "party_id_idx", using: :btree
  end

  create_table "phone", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity_id",                               null: false
    t.string   "number",       limit: 20,                 null: false
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",              default: false, null: false
    t.integer  "last_user_id"
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
  end

  create_table "political_candidate", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "is_federal"
    t.boolean "is_state"
    t.boolean "is_local"
    t.string  "pres_fec_id",   limit: 20
    t.string  "senate_fec_id", limit: 20
    t.string  "house_fec_id",  limit: 20
    t.string  "crp_id",        limit: 20
    t.bigint  "entity_id",                null: false
    t.index ["crp_id"], name: "crp_id_idx", using: :btree
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["house_fec_id"], name: "house_fec_id_idx", using: :btree
    t.index ["pres_fec_id"], name: "pres_fec_id_idx", using: :btree
    t.index ["senate_fec_id"], name: "senate_fec_id_idx", using: :btree
  end

  create_table "political_district", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "state_id"
    t.string "federal_district", limit: 2
    t.string "state_district",   limit: 2
    t.string "local_district",   limit: 2
    t.index ["state_id"], name: "state_id_idx", using: :btree
  end

  create_table "political_fundraising", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "fec_id",    limit: 20
    t.bigint "type_id"
    t.bigint "state_id"
    t.bigint "entity_id",            null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
    t.index ["fec_id"], name: "fec_id_idx", using: :btree
    t.index ["state_id"], name: "state_id_idx", using: :btree
    t.index ["type_id"], name: "type_id_idx", using: :btree
  end

  create_table "political_fundraising_type", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "position", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "is_board"
    t.boolean "is_executive"
    t.boolean "is_employee"
    t.bigint  "compensation"
    t.bigint  "boss_id"
    t.bigint  "relationship_id", null: false
    t.index ["boss_id"], name: "boss_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "professional", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "public_company", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "ticker",    limit: 10
    t.bigint "sec_cik"
    t.bigint "entity_id",            null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "queue_entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "queue",                      null: false
    t.integer  "entity_id"
    t.integer  "user_id"
    t.boolean  "is_skipped", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["queue", "entity_id"], name: "index_queue_entities_on_queue_and_entity_id", unique: true, using: :btree
  end

  create_table "reference", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string   "fields",           limit: 200
    t.string   "name",             limit: 100
    t.string   "source",           limit: 1000,             null: false
    t.string   "source_detail"
    t.string   "publication_date", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model",     limit: 50,               null: false
    t.bigint   "object_id",                                 null: false
    t.integer  "last_user_id"
    t.integer  "ref_type",                      default: 1, null: false
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["name"], name: "name_idx", using: :btree
    t.index ["object_model", "object_id", "ref_type"], name: "index_reference_on_object_model_and_object_id_and_ref_type", using: :btree
    t.index ["object_model", "object_id", "updated_at"], name: "object_idx", using: :btree
    t.index ["source"], name: "source_idx", length: { source: 191 }, using: :btree
    t.index ["updated_at"], name: "updated_at_idx", using: :btree
  end

  create_table "reference_excerpt", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "reference_id",                    null: false
    t.text     "body",         limit: 4294967295, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
    t.index ["reference_id"], name: "reference_id_idx", using: :btree
  end

  create_table "references", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "document_id",        null: false
    t.bigint   "referenceable_id",   null: false
    t.string   "referenceable_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["referenceable_id", "referenceable_type"], name: "index_references_on_referenceable_id_and_referenceable_type", using: :btree
  end

  create_table "relationship", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "entity1_id",                                      null: false
    t.bigint   "entity2_id",                                      null: false
    t.bigint   "category_id",                                     null: false
    t.string   "description1", limit: 100
    t.string   "description2", limit: 100
    t.bigint   "amount"
    t.text     "goods",        limit: 4294967295
    t.bigint   "filings"
    t.text     "notes",        limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_date",   limit: 10
    t.string   "end_date",     limit: 10
    t.boolean  "is_current"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id"
    t.bigint   "amount2"
    t.boolean  "is_gte",                          default: false, null: false
    t.index ["category_id"], name: "category_id_idx", using: :btree
    t.index ["entity1_id", "category_id"], name: "entity1_category_idx", using: :btree
    t.index ["entity1_id", "entity2_id"], name: "entity_idx", using: :btree
    t.index ["entity1_id"], name: "entity1_id_idx", using: :btree
    t.index ["entity2_id"], name: "entity2_id_idx", using: :btree
    t.index ["is_deleted", "entity2_id", "category_id", "amount"], name: "index_relationship_is_d_e2_cat_amount", using: :btree
    t.index ["last_user_id"], name: "last_user_id_idx", using: :btree
  end

  create_table "relationship_category", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",                 limit: 30,                    null: false
    t.string   "display_name",         limit: 30,                    null: false
    t.string   "default_description",  limit: 50
    t.text     "entity1_requirements", limit: 65535
    t.text     "entity2_requirements", limit: 65535
    t.boolean  "has_fields",                         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "representative", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "bioguide_id", limit: 20
    t.bigint "entity_id",              null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "representative_district", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint   "representative_id", null: false
    t.bigint   "district_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id"], name: "district_id_idx", using: :btree
    t.index ["representative_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
    t.index ["representative_id"], name: "representative_id_idx", using: :btree
  end

  create_table "scheduled_email", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "from_email", limit: 200,                        null: false
    t.string   "from_name",  limit: 200
    t.string   "to_email",   limit: 200,                        null: false
    t.string   "to_name",    limit: 200
    t.text     "subject",    limit: 65535
    t.text     "body_text",  limit: 4294967295
    t.text     "body_html",  limit: 4294967295
    t.boolean  "is_sent",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "endowment"
    t.bigint  "students"
    t.bigint  "faculty"
    t.bigint  "tuition"
    t.boolean "is_private"
    t.bigint  "entity_id",  null: false
    t.index ["entity_id"], name: "entity_id_idx", using: :btree
  end

  create_table "scraper_meta", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "scraper",    limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["scraper", "namespace", "predicate", "value"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "session_id",                    null: false
    t.text     "data",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "sf_guard_group", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.string   "blurb"
    t.text     "description",     limit: 65535
    t.text     "contest",         limit: 65535
    t.boolean  "is_working",                    default: false, null: false
    t.boolean  "is_private",                    default: false, null: false
    t.string   "display_name",                                  null: false
    t.integer  "home_network_id",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["display_name"], name: "index_sf_guard_group_on_display_name", using: :btree
    t.index ["name"], name: "name", unique: true, using: :btree
  end

  create_table "sf_guard_group_list", primary_key: ["group_id", "list_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "group_id", default: 0, null: false
    t.bigint  "list_id",  default: 0, null: false
    t.index ["list_id"], name: "list_id", using: :btree
  end

  create_table "sf_guard_group_permission", primary_key: ["group_id", "permission_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "group_id",      default: 0, null: false
    t.integer  "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["permission_id"], name: "permission_id", using: :btree
  end

  create_table "sf_guard_permission", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "name", unique: true, using: :btree
  end

  create_table "sf_guard_remember_key", primary_key: ["id", "ip_address"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "id",                                   null: false
    t.integer  "user_id"
    t.string   "remember_key", limit: 32
    t.string   "ip_address",   limit: 50, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["remember_key"], name: "remember_key_idx", using: :btree
    t.index ["user_id"], name: "user_id_idx", using: :btree
  end

  create_table "sf_guard_user", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "username",       limit: 128,                  null: false
    t.string   "algorithm",      limit: 128, default: "sha1", null: false
    t.string   "salt",           limit: 128
    t.string   "password",       limit: 128
    t.boolean  "is_active",                  default: true
    t.boolean  "is_super_admin",             default: false
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                 default: false,  null: false
    t.index ["is_active"], name: "is_active_idx_idx", using: :btree
    t.index ["username"], name: "username", unique: true, using: :btree
  end

  create_table "sf_guard_user_group", primary_key: ["user_id", "group_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",    default: 0, null: false
    t.integer  "group_id",   default: 0, null: false
    t.boolean  "is_owner"
    t.bigint   "score",      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "group_id", using: :btree
  end

  create_table "sf_guard_user_permission", primary_key: ["user_id", "permission_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",       default: 0, null: false
    t.integer  "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["permission_id"], name: "permission_id", using: :btree
  end

  create_table "sf_guard_user_profile", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",                                                       null: false
    t.string   "name_first",                 limit: 50,                         null: false
    t.string   "name_last",                  limit: 50,                         null: false
    t.string   "email",                      limit: 50,                         null: false
    t.text     "reason",                     limit: 4294967295
    t.text     "analyst_reason",             limit: 4294967295
    t.boolean  "is_visible",                                    default: true,  null: false
    t.string   "invitation_code",            limit: 50
    t.boolean  "enable_announcements",                          default: true,  null: false
    t.boolean  "enable_html_editor",                            default: true,  null: false
    t.boolean  "enable_recent_views",                           default: true,  null: false
    t.boolean  "enable_favorites",                              default: true,  null: false
    t.boolean  "enable_pointers",                               default: true,  null: false
    t.string   "public_name",                limit: 50,                         null: false
    t.text     "bio",                        limit: 4294967295
    t.boolean  "is_confirmed",                                  default: false, null: false
    t.string   "confirmation_code",          limit: 100
    t.string   "filename",                   limit: 100
    t.boolean  "ranking_opt_out",                               default: false, null: false
    t.boolean  "watching_opt_out",                              default: false, null: false
    t.boolean  "enable_notes_list",                             default: true,  null: false
    t.boolean  "enable_notes_notifications",                    default: true,  null: false
    t.bigint   "score"
    t.boolean  "show_full_name",                                default: false, null: false
    t.integer  "unread_notes",                                  default: 0
    t.integer  "home_network_id",                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.index ["email"], name: "unique_email_idx", unique: true, using: :btree
    t.index ["public_name"], name: "unique_public_name_idx", unique: true, using: :btree
    t.index ["user_id", "public_name"], name: "user_id_public_name_idx", using: :btree
    t.index ["user_id"], name: "unique_user_idx", unique: true, using: :btree
  end

  create_table "social", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "sphinx_index", primary_key: "name", id: :string, limit: 50, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "updated_at", null: false
  end

  create_table "tag", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",             limit: 100
    t.boolean  "is_visible",                   default: true, null: false
    t.string   "triple_namespace", limit: 30
    t.string   "triple_predicate", limit: 30
    t.string   "triple_value",     limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "tag_id",                    null: false
    t.string   "tagable_class",             null: false
    t.integer  "tagable_id",                null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "last_user_id",  default: 1, null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["tagable_class"], name: "index_taggings_on_tagable_class", using: :btree
    t.index ["tagable_id"], name: "index_taggings_on_tagable_id", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.boolean  "restricted",                default: false
    t.string   "name",                                      null: false
    t.text     "description", limit: 65535,                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "task_meta", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "task",       limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task", "namespace", "predicate"], name: "uniqueness_idx", unique: true, using: :btree
  end

  create_table "toolkit_pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                          null: false
    t.string   "title"
    t.text     "markdown",     limit: 16777215
    t.integer  "last_user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["name"], name: "index_toolkit_pages_on_name", unique: true, using: :btree
  end

  create_table "transaction", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint  "contact1_id"
    t.bigint  "contact2_id"
    t.bigint  "district_id"
    t.boolean "is_lobbying"
    t.bigint  "relationship_id", null: false
    t.index ["contact1_id"], name: "contact1_id_idx", using: :btree
    t.index ["contact2_id"], name: "contact2_id_idx", using: :btree
    t.index ["relationship_id"], name: "relationship_id_idx", using: :btree
  end

  create_table "user_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.string   "resource_type",                  null: false
    t.text     "access_rules",  limit: 16777215
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["user_id", "resource_type"], name: "index_user_permissions_on_user_id_and_resource_type", using: :btree
  end

  create_table "user_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "type",                                    null: false
    t.integer  "user_id",                                 null: false
    t.integer  "status",                      default: 0, null: false
    t.integer  "source_id"
    t.integer  "dest_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "reviewer_id"
    t.integer  "entity_id"
    t.text     "justification", limit: 65535
    t.index ["user_id"], name: "index_user_requests_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email",                                default: "",    null: false
    t.string   "encrypted_password",                   default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_network_id"
    t.integer  "sf_guard_user_id",                                     null: false
    t.string   "username",                                             null: false
    t.string   "remember_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "newsletter"
    t.string   "chatid"
    t.boolean  "is_restricted",                        default: false
    t.boolean  "map_the_power"
    t.text     "about_me",               limit: 65535
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["sf_guard_user_id"], name: "index_users_on_sf_guard_user_id", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "item_type",                           null: false
    t.integer  "item_id",                             null: false
    t.string   "event",                               null: false
    t.string   "whodunnit"
    t.text     "object",           limit: 65535
    t.datetime "created_at"
    t.text     "object_changes",   limit: 4294967295
    t.integer  "entity1_id"
    t.integer  "entity2_id"
    t.text     "association_data", limit: 4294967295
    t.index ["created_at"], name: "index_versions_on_created_at", using: :btree
    t.index ["entity1_id"], name: "index_versions_on_entity1_id", using: :btree
    t.index ["entity2_id"], name: "index_versions_on_entity2_id", using: :btree
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
    t.index ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree
  end

  add_foreign_key "address", "address_category", column: "category_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "address", "entity", name: "address_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "address", "sf_guard_user", column: "last_user_id", name: "address_ibfk_5", on_update: :cascade
  add_foreign_key "address_state", "address_country", column: "country_id", name: "address_state_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alias", "entity", name: "alias_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alias", "sf_guard_user", column: "last_user_id", name: "alias_ibfk_2", on_update: :cascade
  add_foreign_key "api_request", "api_user", column: "api_key", primary_key: "api_key", name: "api_request_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "article", "article_source", column: "source_id", name: "article_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "business", "entity", name: "business_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_industry", "entity", column: "business_id", name: "business_industry_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_industry", "industry", name: "business_industry_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_person", "entity", name: "business_person_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "candidate_district", "political_district", column: "district_id", name: "candidate_district_ibfk_1"
  add_foreign_key "cmp_entities", "entity"
  add_foreign_key "donation", "entity", column: "bundler_id", name: "donation_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "donation", "relationship", name: "donation_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "education", "degree", name: "education_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "education", "relationship", name: "education_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "elected_representative", "entity", name: "elected_representative_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "email", "entity", name: "email_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "email", "sf_guard_user", column: "last_user_id", name: "email_ibfk_2", on_update: :cascade
  add_foreign_key "entity", "entity", column: "parent_id", name: "entity_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "entity", "sf_guard_user", column: "last_user_id", name: "entity_ibfk_2", on_update: :cascade
  add_foreign_key "extension_definition", "extension_definition", column: "parent_id", name: "extension_definition_ibfk_1", on_update: :cascade
  add_foreign_key "extension_record", "entity", name: "extension_record_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "extension_record", "extension_definition", column: "definition_id", name: "extension_record_ibfk_2", on_update: :cascade
  add_foreign_key "extension_record", "sf_guard_user", column: "last_user_id", name: "extension_record_ibfk_3", on_update: :cascade
  add_foreign_key "family", "relationship", name: "family_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "fedspending_filing", "political_district", column: "district_id", name: "fedspending_filing_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "fedspending_filing", "relationship", name: "fedspending_filing_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "government_body", "address_state", column: "state_id", name: "government_body_ibfk_1", on_update: :cascade
  add_foreign_key "government_body", "entity", name: "government_body_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "image", "entity", name: "image_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "image", "sf_guard_user", column: "last_user_id", name: "image_ibfk_2", on_update: :cascade
  add_foreign_key "link", "entity", column: "entity1_id", name: "link_ibfk_3"
  add_foreign_key "link", "entity", column: "entity2_id", name: "link_ibfk_2"
  add_foreign_key "link", "relationship", name: "link_ibfk_1"
  add_foreign_key "link", "relationship_category", column: "category_id", name: "link_ibfk_4"
  add_foreign_key "lobby_filing_lobby_issue", "lobby_filing", name: "lobby_filing_lobby_issue_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobby_issue", "lobby_issue", column: "issue_id", name: "lobby_filing_lobby_issue_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobbyist", "entity", column: "lobbyist_id", name: "lobby_filing_lobbyist_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobbyist", "lobby_filing", name: "lobby_filing_lobbyist_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_relationship", "lobby_filing", name: "lobby_filing_relationship_ibfk_2"
  add_foreign_key "lobby_filing_relationship", "relationship", name: "lobby_filing_relationship_ibfk_1"
  add_foreign_key "lobbying", "relationship", name: "lobbying_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobbyist", "entity", name: "lobbyist_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ls_list", "ls_list", column: "featured_list_id", name: "ls_list_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "ls_list", "sf_guard_user", column: "last_user_id", name: "ls_list_ibfk_1", on_update: :cascade
  add_foreign_key "ls_list_entity", "entity", name: "ls_list_entity_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ls_list_entity", "ls_list", column: "list_id", name: "ls_list_entity_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ls_list_entity", "sf_guard_user", column: "last_user_id", name: "ls_list_entity_ibfk_3", on_update: :cascade
  add_foreign_key "membership", "relationship", name: "membership_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "modification", "sf_guard_user", column: "user_id", name: "modification_ibfk_1", on_update: :cascade
  add_foreign_key "modification_field", "modification", name: "modification_field_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "note", "sf_guard_user", column: "user_id", name: "note_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "object_tag", "sf_guard_user", column: "last_user_id", name: "object_tag_ibfk_2", on_update: :cascade
  add_foreign_key "object_tag", "tag", name: "object_tag_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "org", "entity", name: "org_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "os_entity_category", "entity", name: "os_entity_category_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ownership", "relationship", name: "ownership_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "person", "entity", column: "party_id", name: "person_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "person", "entity", name: "person_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "person", "gender", name: "person_ibfk_2"
  add_foreign_key "phone", "entity", name: "phone_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "phone", "sf_guard_user", column: "last_user_id", name: "phone_ibfk_2", on_update: :cascade
  add_foreign_key "political_candidate", "entity", name: "political_candidate_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "political_district", "address_state", column: "state_id", name: "political_district_ibfk_1", on_update: :cascade
  add_foreign_key "political_fundraising", "address_state", column: "state_id", name: "political_fundraising_ibfk_2", on_update: :cascade
  add_foreign_key "political_fundraising", "entity", name: "political_fundraising_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "political_fundraising", "political_fundraising_type", column: "type_id", name: "political_fundraising_ibfk_1", on_update: :cascade
  add_foreign_key "position", "entity", column: "boss_id", name: "position_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "position", "relationship", name: "position_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "professional", "relationship", name: "professional_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "public_company", "entity", name: "public_company_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "reference", "sf_guard_user", column: "last_user_id", name: "reference_ibfk_1", on_update: :cascade
  add_foreign_key "reference_excerpt", "reference", name: "reference_excerpt_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "reference_excerpt", "sf_guard_user", column: "last_user_id", name: "reference_excerpt_ibfk_2", on_update: :cascade
  add_foreign_key "relationship", "entity", column: "entity1_id", name: "relationship_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "entity", column: "entity2_id", name: "relationship_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "relationship_category", column: "category_id", name: "relationship_ibfk_3", on_update: :cascade
  add_foreign_key "relationship", "sf_guard_user", column: "last_user_id", name: "relationship_ibfk_4", on_update: :cascade
  add_foreign_key "representative", "entity", name: "representative_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "elected_representative", column: "representative_id", name: "representative_district_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "political_district", column: "district_id", name: "representative_district_ibfk_4", on_update: :cascade, on_delete: :cascade
  add_foreign_key "school", "entity", name: "school_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "sf_guard_group_list", "ls_list", column: "list_id", name: "sf_guard_group_list_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "sf_guard_group_list", "sf_guard_group", column: "group_id", name: "sf_guard_group_list_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "sf_guard_group_permission", "sf_guard_group", column: "group_id", name: "sf_guard_group_permission_ibfk_2", on_delete: :cascade
  add_foreign_key "sf_guard_group_permission", "sf_guard_permission", column: "permission_id", name: "sf_guard_group_permission_ibfk_1", on_delete: :cascade
  add_foreign_key "sf_guard_remember_key", "sf_guard_user", column: "user_id", name: "sf_guard_remember_key_ibfk_1", on_delete: :cascade
  add_foreign_key "sf_guard_user_group", "sf_guard_group", column: "group_id", name: "sf_guard_user_group_ibfk_2", on_delete: :cascade
  add_foreign_key "sf_guard_user_group", "sf_guard_user", column: "user_id", name: "sf_guard_user_group_ibfk_1", on_delete: :cascade
  add_foreign_key "sf_guard_user_permission", "sf_guard_permission", column: "permission_id", name: "sf_guard_user_permission_ibfk_2", on_delete: :cascade
  add_foreign_key "sf_guard_user_permission", "sf_guard_user", column: "user_id", name: "sf_guard_user_permission_ibfk_1", on_delete: :cascade
  add_foreign_key "social", "relationship", name: "social_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "transaction", "entity", column: "contact1_id", name: "transaction_ibfk_3", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "entity", column: "contact2_id", name: "transaction_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "relationship", name: "transaction_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_requests", "users"
end
