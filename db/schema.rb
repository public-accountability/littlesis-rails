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

ActiveRecord::Schema.define(version: 20141006212617) do

  create_table "address", force: true do |t|
    t.integer  "entity_id",    limit: 8,                   null: false
    t.string   "street1",      limit: 100,                 null: false
    t.string   "street2",      limit: 100
    t.string   "street3",      limit: 100
    t.string   "city",         limit: 50,                  null: false
    t.string   "county",       limit: 50
    t.integer  "state_id",     limit: 8,                   null: false
    t.integer  "country_id",   limit: 8,   default: 1,     null: false
    t.string   "postal",       limit: 5
    t.string   "latitude",     limit: 20
    t.string   "longitude",    limit: 20
    t.integer  "category_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",               default: false, null: false
    t.integer  "last_user_id"
    t.string   "accuracy",     limit: 30
  end

  add_index "address", ["category_id"], name: "category_id_idx", using: :btree
  add_index "address", ["country_id"], name: "country_id_idx", using: :btree
  add_index "address", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "address", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "address", ["state_id"], name: "state_id_idx", using: :btree

  create_table "address_category", force: true do |t|
    t.string "name", limit: 20, null: false
  end

  create_table "address_country", force: true do |t|
    t.string "name", limit: 50, null: false
  end

  add_index "address_country", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "address_state", force: true do |t|
    t.string  "name",         limit: 50, null: false
    t.string  "abbreviation", limit: 2,  null: false
    t.integer "country_id",   limit: 8,  null: false
  end

  add_index "address_state", ["country_id"], name: "country_id_idx", using: :btree
  add_index "address_state", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "alias", force: true do |t|
    t.integer  "entity_id",    limit: 8,               null: false
    t.string   "name",         limit: 200,             null: false
    t.string   "context",      limit: 50
    t.integer  "is_primary",               default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
  end

  add_index "alias", ["entity_id", "name", "context"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "alias", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "alias", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "alias", ["name"], name: "name_idx", using: :btree

  create_table "api_request", force: true do |t|
    t.string   "api_key",    limit: 100, null: false
    t.string   "resource",   limit: 200, null: false
    t.string   "ip_address", limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_request", ["api_key"], name: "api_key_idx", using: :btree
  add_index "api_request", ["created_at"], name: "created_at_idx", using: :btree

  create_table "api_user", force: true do |t|
    t.string   "api_key",       limit: 100,                        null: false
    t.string   "name_first",    limit: 50,                         null: false
    t.string   "name_last",     limit: 50,                         null: false
    t.string   "email",         limit: 100,                        null: false
    t.text     "reason",        limit: 2147483647,                 null: false
    t.boolean  "is_active",                        default: false, null: false
    t.integer  "request_limit",                    default: 10000, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_user", ["api_key"], name: "api_key_idx", using: :btree
  add_index "api_user", ["api_key"], name: "api_key_unique_idx", unique: true, using: :btree
  add_index "api_user", ["email"], name: "email_unique_idx", unique: true, using: :btree

  create_table "article", force: true do |t|
    t.text     "url",                 limit: 16777215,                   null: false
    t.string   "title",               limit: 200,                        null: false
    t.string   "authors",             limit: 200
    t.text     "body",                limit: 2147483647,                 null: false
    t.text     "description",         limit: 16777215
    t.integer  "source_id"
    t.datetime "published_at"
    t.boolean  "is_indexed",                             default: false, null: false
    t.datetime "reviewed_at"
    t.integer  "reviewed_by_user_id", limit: 8
    t.boolean  "is_featured",                            default: false, null: false
    t.boolean  "is_hidden",                              default: false, null: false
    t.datetime "found_at",                                               null: false
  end

  add_index "article", ["source_id"], name: "source_id_idx", using: :btree

  create_table "article_entity", force: true do |t|
    t.integer  "article_id",                                      null: false
    t.integer  "entity_id",                                       null: false
    t.string   "original_name",       limit: 100,                 null: false
    t.boolean  "is_verified",                     default: false, null: false
    t.integer  "reviewed_by_user_id", limit: 8
    t.datetime "reviewed_at"
  end

  add_index "article_entity", ["article_id"], name: "article_id_idx", using: :btree
  add_index "article_entity", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "article_source", force: true do |t|
    t.string "name",         limit: 100, null: false
    t.string "abbreviation", limit: 10,  null: false
  end

  create_table "bootsy_image_galleries", force: true do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: true do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business", force: true do |t|
    t.integer "annual_profit", limit: 8
    t.integer "entity_id",     limit: 8, null: false
  end

  add_index "business", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "business_industry", force: true do |t|
    t.integer "business_id", limit: 8, null: false
    t.integer "industry_id", limit: 8, null: false
  end

  add_index "business_industry", ["business_id"], name: "business_id_idx", using: :btree
  add_index "business_industry", ["industry_id"], name: "industry_id_idx", using: :btree

  create_table "business_person", force: true do |t|
    t.integer "sec_cik",   limit: 8
    t.integer "entity_id", limit: 8, null: false
  end

  add_index "business_person", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "campaigns", force: true do |t|
    t.string   "name",                         null: false
    t.string   "tagline"
    t.text     "description", limit: 16777215
    t.string   "logo"
    t.string   "cover"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "findings",    limit: 16777215
    t.text     "howto",       limit: 16777215
    t.text     "custom_html", limit: 16777215
    t.string   "logo_credit"
  end

  add_index "campaigns", ["slug"], name: "index_campaigns_on_slug", unique: true, using: :btree

  create_table "candidate_district", force: true do |t|
    t.integer  "candidate_id", limit: 8, null: false
    t.integer  "district_id",  limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "candidate_district", ["candidate_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "candidate_district", ["district_id"], name: "district_id_idx", using: :btree

  create_table "chat_user", force: true do |t|
    t.integer  "user_id",    limit: 8, null: false
    t.integer  "room",       limit: 8, null: false
    t.datetime "updated_at",           null: false
  end

  add_index "chat_user", ["room", "updated_at", "user_id"], name: "room_updated_at_user_id_idx", using: :btree
  add_index "chat_user", ["room", "user_id"], name: "room_user_id_idx", unique: true, using: :btree
  add_index "chat_user", ["user_id"], name: "user_id_idx", using: :btree

  create_table "custom_key", force: true do |t|
    t.string   "name",         limit: 50,         null: false
    t.text     "value",        limit: 2147483647
    t.string   "description",  limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50,         null: false
    t.integer  "object_id",    limit: 8,          null: false
  end

  add_index "custom_key", ["object_model", "object_id", "name", "value"], name: "object_name_value_idx", unique: true, length: {"object_model"=>nil, "object_id"=>nil, "name"=>nil, "value"=>100}, using: :btree
  add_index "custom_key", ["object_model", "object_id", "name"], name: "object_name_idx", unique: true, using: :btree
  add_index "custom_key", ["object_model", "object_id"], name: "object_idx", using: :btree

  create_table "degree", force: true do |t|
    t.string "name",         limit: 50, null: false
    t.string "abbreviation", limit: 10
  end

  create_table "delayed_jobs", force: true do |t|
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
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "domain", force: true do |t|
    t.string "name", limit: 40,  null: false
    t.string "url",  limit: 200, null: false
  end

  create_table "donation", force: true do |t|
    t.integer "bundler_id",      limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "donation", ["bundler_id"], name: "bundler_id_idx", using: :btree
  add_index "donation", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "education", force: true do |t|
    t.integer "degree_id",       limit: 8
    t.string  "field",           limit: 30
    t.boolean "is_dropout"
    t.integer "relationship_id", limit: 8,  null: false
  end

  add_index "education", ["degree_id"], name: "degree_id_idx", using: :btree
  add_index "education", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "elected_representative", force: true do |t|
    t.string  "bioguide_id", limit: 20
    t.string  "govtrack_id", limit: 20
    t.string  "crp_id",      limit: 20
    t.string  "pvs_id",      limit: 20
    t.string  "watchdog_id", limit: 50
    t.integer "entity_id",   limit: 8,  null: false
  end

  add_index "elected_representative", ["crp_id"], name: "crp_id_idx", using: :btree
  add_index "elected_representative", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "email", force: true do |t|
    t.integer  "entity_id",    limit: 8,                  null: false
    t.string   "address",      limit: 60,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",              default: false, null: false
    t.integer  "last_user_id"
  end

  add_index "email", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "email", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "entity", force: true do |t|
    t.string   "name",         limit: 200
    t.string   "blurb",        limit: 200
    t.text     "summary",      limit: 2147483647
    t.text     "notes",        limit: 2147483647
    t.string   "website",      limit: 100
    t.integer  "parent_id",    limit: 8
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
  end

  add_index "entity", ["blurb"], name: "blurb_idx", using: :btree
  add_index "entity", ["created_at"], name: "created_at_idx", using: :btree
  add_index "entity", ["delta"], name: "index_entity_on_delta", using: :btree
  add_index "entity", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "entity", ["name", "blurb", "website"], name: "search_idx", using: :btree
  add_index "entity", ["name"], name: "name_idx", using: :btree
  add_index "entity", ["parent_id"], name: "parent_id_idx", using: :btree
  add_index "entity", ["updated_at"], name: "updated_at_idx", using: :btree
  add_index "entity", ["website"], name: "website_idx", using: :btree

  create_table "extension_definition", force: true do |t|
    t.string  "name",         limit: 30,                 null: false
    t.string  "display_name", limit: 50,                 null: false
    t.boolean "has_fields",              default: false, null: false
    t.integer "parent_id",    limit: 8
    t.integer "tier",         limit: 8
  end

  add_index "extension_definition", ["name"], name: "name_idx", using: :btree
  add_index "extension_definition", ["parent_id"], name: "parent_id_idx", using: :btree
  add_index "extension_definition", ["tier"], name: "tier_idx", using: :btree

  create_table "extension_record", force: true do |t|
    t.integer "entity_id",     limit: 8, null: false
    t.integer "definition_id", limit: 8, null: false
    t.integer "last_user_id"
  end

  add_index "extension_record", ["definition_id"], name: "definition_id_idx", using: :btree
  add_index "extension_record", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "extension_record", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "external_key", force: true do |t|
    t.integer "entity_id",   limit: 8,   null: false
    t.string  "external_id", limit: 200, null: false
    t.integer "domain_id",   limit: 8,   null: false
  end

  add_index "external_key", ["domain_id"], name: "domain_id_idx", using: :btree
  add_index "external_key", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "external_key", ["external_id", "domain_id"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "family", force: true do |t|
    t.boolean "is_nonbiological"
    t.integer "relationship_id",  limit: 8, null: false
  end

  add_index "family", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "fec_filing", force: true do |t|
    t.integer "relationship_id", limit: 8
    t.integer "amount",          limit: 8
    t.string  "fec_filing_id",   limit: 30
    t.integer "crp_cycle",       limit: 8
    t.string  "crp_id",          limit: 30, null: false
    t.string  "start_date",      limit: 10
    t.string  "end_date",        limit: 10
    t.boolean "is_current"
  end

  add_index "fec_filing", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "fedspending_filing", force: true do |t|
    t.integer "relationship_id", limit: 8
    t.integer "amount",          limit: 8
    t.text    "goods",           limit: 2147483647
    t.integer "district_id",     limit: 8
    t.string  "fedspending_id",  limit: 30
    t.string  "start_date",      limit: 10
    t.string  "end_date",        limit: 10
    t.boolean "is_current"
  end

  add_index "fedspending_filing", ["district_id"], name: "district_id_idx", using: :btree
  add_index "fedspending_filing", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "gender", force: true do |t|
    t.string "name", limit: 10, null: false
  end

  create_table "government_body", force: true do |t|
    t.boolean "is_federal"
    t.integer "state_id",   limit: 8
    t.string  "city",       limit: 50
    t.string  "county",     limit: 50
    t.integer "entity_id",  limit: 8,  null: false
  end

  add_index "government_body", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "government_body", ["state_id"], name: "state_id_idx", using: :btree

  create_table "group_lists", force: true do |t|
    t.integer "group_id"
    t.integer "list_id"
    t.boolean "is_featured", default: false, null: false
  end

  add_index "group_lists", ["group_id", "list_id"], name: "index_group_lists_on_group_id_and_list_id", unique: true, using: :btree
  add_index "group_lists", ["list_id"], name: "index_group_lists_on_list_id", using: :btree

  create_table "group_users", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",   default: false, null: false
  end

  add_index "group_users", ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true, using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: true do |t|
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
  end

  add_index "groups", ["campaign_id"], name: "index_groups_on_campaign_id", using: :btree
  add_index "groups", ["delta"], name: "index_groups_on_delta", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

  create_table "image", force: true do |t|
    t.integer  "entity_id",    limit: 8,                          null: false
    t.string   "filename",     limit: 100,                        null: false
    t.string   "title",        limit: 100,                        null: false
    t.text     "caption",      limit: 2147483647
    t.boolean  "is_featured",                     default: false, null: false
    t.boolean  "is_free"
    t.string   "url",          limit: 200
    t.integer  "width",        limit: 8
    t.integer  "height",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id"
    t.boolean  "has_square",                      default: false, null: false
  end

  add_index "image", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "image", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "industry", force: true do |t|
    t.string   "name",       limit: 100, null: false
    t.string   "context",    limit: 30
    t.string   "code",       limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link", force: true do |t|
    t.integer "entity1_id",      limit: 8, null: false
    t.integer "entity2_id",      limit: 8, null: false
    t.integer "category_id",     limit: 8, null: false
    t.integer "relationship_id", limit: 8, null: false
    t.boolean "is_reverse",                null: false
  end

  add_index "link", ["category_id"], name: "category_id_idx", using: :btree
  add_index "link", ["entity1_id"], name: "entity1_id_idx", using: :btree
  add_index "link", ["entity2_id"], name: "entity2_id_idx", using: :btree
  add_index "link", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobby_filing", force: true do |t|
    t.string  "federal_filing_id", limit: 50,  null: false
    t.integer "amount",            limit: 8
    t.integer "year",              limit: 8
    t.string  "period",            limit: 100
    t.string  "report_type",       limit: 100
    t.string  "start_date",        limit: 10
    t.string  "end_date",          limit: 10
    t.boolean "is_current"
  end

  create_table "lobby_filing_lobby_issue", force: true do |t|
    t.integer "issue_id",        limit: 8,          null: false
    t.integer "lobby_filing_id", limit: 8,          null: false
    t.text    "specific_issue",  limit: 2147483647
  end

  add_index "lobby_filing_lobby_issue", ["issue_id"], name: "issue_id_idx", using: :btree
  add_index "lobby_filing_lobby_issue", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree

  create_table "lobby_filing_lobbyist", force: true do |t|
    t.integer "lobbyist_id",     limit: 8, null: false
    t.integer "lobby_filing_id", limit: 8, null: false
  end

  add_index "lobby_filing_lobbyist", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
  add_index "lobby_filing_lobbyist", ["lobbyist_id"], name: "lobbyist_id_idx", using: :btree

  create_table "lobby_filing_relationship", force: true do |t|
    t.integer "relationship_id", limit: 8, null: false
    t.integer "lobby_filing_id", limit: 8, null: false
  end

  add_index "lobby_filing_relationship", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
  add_index "lobby_filing_relationship", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobby_issue", force: true do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "lobbying", force: true do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "lobbying", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobbyist", force: true do |t|
    t.integer "lda_registrant_id", limit: 8
    t.integer "entity_id",         limit: 8, null: false
  end

  add_index "lobbyist", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "ls_list", force: true do |t|
    t.string   "name",             limit: 100,                        null: false
    t.text     "description",      limit: 2147483647
    t.boolean  "is_ranked",                           default: false, null: false
    t.boolean  "is_admin",                            default: false, null: false
    t.boolean  "is_featured",                         default: false, null: false
    t.boolean  "is_network",                          default: false, null: false
    t.string   "display_name",     limit: 50
    t.integer  "featured_list_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.boolean  "is_deleted",                          default: false, null: false
  end

  add_index "ls_list", ["featured_list_id"], name: "featured_list_id", using: :btree
  add_index "ls_list", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "ls_list", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "ls_list_entity", force: true do |t|
    t.integer  "list_id",      limit: 8,                 null: false
    t.integer  "entity_id",    limit: 8,                 null: false
    t.integer  "rank",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.boolean  "is_deleted",             default: false, null: false
  end

  add_index "ls_list_entity", ["created_at"], name: "created_at_idx", using: :btree
  add_index "ls_list_entity", ["entity_id", "is_deleted", "list_id"], name: "entity_deleted_list_idx", using: :btree
  add_index "ls_list_entity", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "ls_list_entity", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "ls_list_entity", ["list_id", "is_deleted", "entity_id"], name: "list_deleted_entity_idx", using: :btree
  add_index "ls_list_entity", ["list_id"], name: "list_id_idx", using: :btree

  create_table "membership", force: true do |t|
    t.integer "dues",            limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "membership", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "modification", force: true do |t|
    t.string   "object_name",     limit: 100
    t.integer  "user_id",                     default: 1,     null: false
    t.boolean  "is_create",                   default: false, null: false
    t.boolean  "is_delete",                   default: false, null: false
    t.boolean  "is_merge",                    default: false, null: false
    t.integer  "merge_object_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model",    limit: 50,                  null: false
    t.integer  "object_id",       limit: 8,                   null: false
  end

  add_index "modification", ["is_create"], name: "is_create_idx", using: :btree
  add_index "modification", ["is_delete"], name: "is_delete_idx", using: :btree
  add_index "modification", ["object_id"], name: "object_id_idx", using: :btree
  add_index "modification", ["object_model", "object_id"], name: "object_idx", using: :btree
  add_index "modification", ["object_model"], name: "object_model_idx", using: :btree
  add_index "modification", ["user_id", "is_create", "object_model"], name: "points_summary_idx", using: :btree
  add_index "modification", ["user_id"], name: "user_id_idx", using: :btree

  create_table "modification_field", force: true do |t|
    t.integer "modification_id", limit: 8,          null: false
    t.string  "field_name",      limit: 50,         null: false
    t.text    "old_value",       limit: 2147483647
    t.text    "new_value",       limit: 2147483647
  end

  add_index "modification_field", ["modification_id"], name: "modification_id_idx", using: :btree

  create_table "network_map", force: true do |t|
    t.integer  "user_id",     limit: 8,                          null: false
    t.text     "data",        limit: 2147483647,                 null: false
    t.string   "entity_ids",  limit: 5000
    t.string   "rel_ids",     limit: 5000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                     default: false, null: false
    t.string   "title",       limit: 100
    t.text     "description", limit: 2147483647
    t.integer  "width",                                          null: false
    t.integer  "height",                                         null: false
    t.boolean  "is_featured",                    default: false, null: false
    t.string   "zoom",                           default: "1",   null: false
    t.boolean  "is_private",                     default: false, null: false
    t.string   "thumbnail"
    t.boolean  "delta",                          default: true,  null: false
    t.text     "index_data",  limit: 2147483647
  end

  add_index "network_map", ["delta"], name: "index_network_map_on_delta", using: :btree
  add_index "network_map", ["user_id"], name: "user_id_idx", using: :btree

  create_table "note", force: true do |t|
    t.integer  "user_id",                                        null: false
    t.string   "title",              limit: 50
    t.text     "body",                                           null: false
    t.text     "body_raw",                                       null: false
    t.string   "alerted_user_names", limit: 500
    t.string   "alerted_user_ids",   limit: 500
    t.string   "entity_ids",         limit: 200
    t.string   "relationship_ids",   limit: 200
    t.string   "lslist_ids",         limit: 200
    t.string   "sfguardgroup_ids",   limit: 200
    t.string   "network_ids",        limit: 200
    t.boolean  "is_private",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_legacy",                      default: false, null: false
    t.integer  "sf_guard_user_id"
    t.integer  "new_user_id"
    t.boolean  "delta",                          default: true,  null: false
  end

  add_index "note", ["alerted_user_ids"], name: "alerted_user_ids_idx", length: {"alerted_user_ids"=>255}, using: :btree
  add_index "note", ["delta"], name: "index_note_on_delta", using: :btree
  add_index "note", ["entity_ids"], name: "entity_ids_idx", using: :btree
  add_index "note", ["is_private"], name: "is_private_idx", using: :btree
  add_index "note", ["lslist_ids"], name: "lslist_ids_idx", using: :btree
  add_index "note", ["new_user_id"], name: "index_note_on_new_user_id", using: :btree
  add_index "note", ["relationship_ids"], name: "relationship_ids_idx", using: :btree
  add_index "note", ["sf_guard_user_id"], name: "index_note_on_sf_guard_user_id", using: :btree
  add_index "note", ["updated_at"], name: "updated_at_idx", using: :btree
  add_index "note", ["user_id"], name: "user_id_idx", using: :btree

  create_table "note_entities", force: true do |t|
    t.integer "note_id"
    t.integer "entity_id"
  end

  add_index "note_entities", ["entity_id"], name: "index_note_entities_on_entity_id", using: :btree
  add_index "note_entities", ["note_id", "entity_id"], name: "index_note_entities_on_note_id_and_entity_id", unique: true, using: :btree

  create_table "note_groups", force: true do |t|
    t.integer "note_id"
    t.integer "group_id"
  end

  add_index "note_groups", ["group_id"], name: "index_note_groups_on_group_id", using: :btree
  add_index "note_groups", ["note_id", "group_id"], name: "index_note_groups_on_note_id_and_group_id", unique: true, using: :btree

  create_table "note_lists", force: true do |t|
    t.integer "note_id"
    t.integer "list_id"
  end

  add_index "note_lists", ["list_id"], name: "index_note_lists_on_list_id", using: :btree
  add_index "note_lists", ["note_id", "list_id"], name: "index_note_lists_on_note_id_and_list_id", unique: true, using: :btree

  create_table "note_networks", force: true do |t|
    t.integer "note_id"
    t.integer "network_id"
  end

  add_index "note_networks", ["network_id"], name: "index_note_networks_on_network_id", using: :btree
  add_index "note_networks", ["note_id", "network_id"], name: "index_note_networks_on_note_id_and_network_id", unique: true, using: :btree

  create_table "note_relationships", force: true do |t|
    t.integer "note_id"
    t.integer "relationship_id"
  end

  add_index "note_relationships", ["note_id", "relationship_id"], name: "index_note_relationships_on_note_id_and_relationship_id", unique: true, using: :btree
  add_index "note_relationships", ["relationship_id"], name: "index_note_relationships_on_relationship_id", using: :btree

  create_table "note_users", force: true do |t|
    t.integer "note_id"
    t.integer "user_id"
  end

  add_index "note_users", ["note_id", "user_id"], name: "index_note_users_on_note_id_and_user_id", unique: true, using: :btree
  add_index "note_users", ["user_id"], name: "index_note_users_on_user_id", using: :btree

  create_table "object_tag", force: true do |t|
    t.integer  "tag_id",       limit: 8,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50, null: false
    t.integer  "object_id",    limit: 8,  null: false
    t.integer  "last_user_id"
  end

  add_index "object_tag", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "object_tag", ["object_model", "object_id", "tag_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "object_tag", ["object_model", "object_id"], name: "object_idx", using: :btree
  add_index "object_tag", ["tag_id"], name: "tag_id_idx", using: :btree

  create_table "org", force: true do |t|
    t.string  "name",              limit: 200, null: false
    t.string  "name_nick",         limit: 100
    t.integer "employees",         limit: 8
    t.integer "revenue",           limit: 8
    t.string  "fedspending_id",    limit: 10
    t.string  "lda_registrant_id", limit: 10
    t.integer "entity_id",         limit: 8,   null: false
  end

  add_index "org", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_category", force: true do |t|
    t.string "category_id",   limit: 10,  null: false
    t.string "category_name", limit: 100, null: false
    t.string "industry_id",   limit: 10,  null: false
    t.string "industry_name", limit: 100, null: false
    t.string "sector_name",   limit: 100, null: false
  end

  add_index "os_category", ["category_id"], name: "unique_id_idx", unique: true, using: :btree
  add_index "os_category", ["category_name"], name: "unique_name_idx", unique: true, using: :btree

  create_table "os_entity_category", force: true do |t|
    t.integer  "entity_id",   limit: 8,   null: false
    t.string   "category_id", limit: 10,  null: false
    t.string   "source",      limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os_entity_category", ["category_id"], name: "category_id_idx", using: :btree
  add_index "os_entity_category", ["entity_id", "category_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "os_entity_category", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_entity_donor", force: true do |t|
    t.integer  "entity_id",           limit: 8,                  null: false
    t.string   "donor_id",            limit: 12
    t.integer  "match_code",          limit: 8
    t.boolean  "is_verified",                    default: false, null: false
    t.integer  "reviewed_by_user_id", limit: 8
    t.boolean  "is_processed",                   default: false, null: false
    t.boolean  "is_synced",                      default: true,  null: false
    t.datetime "reviewed_at"
    t.integer  "locked_by_user_id",   limit: 8
    t.datetime "locked_at"
  end

  add_index "os_entity_donor", ["entity_id", "donor_id"], name: "entity_donor_idx", unique: true, using: :btree
  add_index "os_entity_donor", ["is_synced"], name: "is_synced_idx", using: :btree
  add_index "os_entity_donor", ["locked_at"], name: "locked_at_idx", using: :btree
  add_index "os_entity_donor", ["reviewed_at"], name: "reviewed_at_idx", using: :btree

  create_table "os_entity_preprocess", force: true do |t|
    t.integer  "entity_id",    limit: 8, null: false
    t.string   "cycle",        limit: 4, null: false
    t.datetime "processed_at",           null: false
    t.datetime "updated_at"
  end

  add_index "os_entity_preprocess", ["entity_id", "cycle"], name: "entity_cycle_idx", unique: true, using: :btree
  add_index "os_entity_preprocess", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_entity_transaction", force: true do |t|
    t.integer  "entity_id",                                      null: false
    t.string   "cycle",               limit: 4,                  null: false
    t.string   "transaction_id",      limit: 30,                 null: false
    t.integer  "match_code",          limit: 8
    t.boolean  "is_verified",                    default: false, null: false
    t.boolean  "is_processed",                   default: false, null: false
    t.boolean  "is_synced",                      default: true,  null: false
    t.integer  "reviewed_by_user_id", limit: 8
    t.datetime "reviewed_at"
    t.integer  "locked_by_user_id",   limit: 8
    t.datetime "locked_at"
  end

  add_index "os_entity_transaction", ["entity_id", "cycle", "transaction_id"], name: "entity_cycle_transaction_idx", unique: true, using: :btree
  add_index "os_entity_transaction", ["is_synced"], name: "is_synced_idx", using: :btree
  add_index "os_entity_transaction", ["locked_at"], name: "locked_at_idx", using: :btree
  add_index "os_entity_transaction", ["reviewed_at"], name: "reviewed_at_idx", using: :btree

  create_table "ownership", force: true do |t|
    t.integer "percent_stake",   limit: 8
    t.integer "shares",          limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "ownership", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "person", force: true do |t|
    t.string  "name_last",      limit: 50, null: false
    t.string  "name_first",     limit: 50, null: false
    t.string  "name_middle",    limit: 50
    t.string  "name_prefix",    limit: 30
    t.string  "name_suffix",    limit: 30
    t.string  "name_nick",      limit: 30
    t.string  "birthplace",     limit: 50
    t.integer "gender_id",      limit: 8
    t.integer "party_id",       limit: 8
    t.boolean "is_independent"
    t.integer "net_worth",      limit: 8
    t.integer "entity_id",      limit: 8,  null: false
  end

  add_index "person", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "person", ["gender_id"], name: "gender_id_idx", using: :btree
  add_index "person", ["name_last", "name_first", "name_middle"], name: "name_idx", using: :btree
  add_index "person", ["party_id"], name: "party_id_idx", using: :btree

  create_table "phone", force: true do |t|
    t.integer  "entity_id",    limit: 8,                  null: false
    t.string   "number",       limit: 20,                 null: false
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",              default: false, null: false
    t.integer  "last_user_id"
  end

  add_index "phone", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "phone", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "political_candidate", force: true do |t|
    t.boolean "is_federal"
    t.boolean "is_state"
    t.boolean "is_local"
    t.string  "pres_fec_id",   limit: 20
    t.string  "senate_fec_id", limit: 20
    t.string  "house_fec_id",  limit: 20
    t.string  "crp_id",        limit: 20
    t.integer "entity_id",     limit: 8,  null: false
  end

  add_index "political_candidate", ["crp_id"], name: "crp_id_idx", using: :btree
  add_index "political_candidate", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "political_candidate", ["house_fec_id"], name: "house_fec_id_idx", using: :btree
  add_index "political_candidate", ["pres_fec_id"], name: "pres_fec_id_idx", using: :btree
  add_index "political_candidate", ["senate_fec_id"], name: "senate_fec_id_idx", using: :btree

  create_table "political_district", force: true do |t|
    t.integer "state_id",         limit: 8
    t.string  "federal_district", limit: 2
    t.string  "state_district",   limit: 2
    t.string  "local_district",   limit: 2
  end

  add_index "political_district", ["state_id"], name: "state_id_idx", using: :btree

  create_table "political_fundraising", force: true do |t|
    t.string  "fec_id",    limit: 20
    t.integer "type_id",   limit: 8
    t.integer "state_id",  limit: 8
    t.integer "entity_id", limit: 8,  null: false
  end

  add_index "political_fundraising", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "political_fundraising", ["fec_id"], name: "fec_id_idx", using: :btree
  add_index "political_fundraising", ["state_id"], name: "state_id_idx", using: :btree
  add_index "political_fundraising", ["type_id"], name: "type_id_idx", using: :btree

  create_table "political_fundraising_type", force: true do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "position", force: true do |t|
    t.boolean "is_board"
    t.boolean "is_executive"
    t.boolean "is_employee"
    t.integer "compensation",    limit: 8
    t.integer "boss_id",         limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "position", ["boss_id"], name: "boss_id_idx", using: :btree
  add_index "position", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "professional", force: true do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "professional", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "public_company", force: true do |t|
    t.string  "ticker",    limit: 10
    t.integer "sec_cik",   limit: 8
    t.integer "entity_id", limit: 8,  null: false
  end

  add_index "public_company", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "reference", force: true do |t|
    t.string   "fields",           limit: 200
    t.string   "name",             limit: 100
    t.string   "source",           limit: 200, null: false
    t.string   "source_detail",    limit: 50
    t.string   "publication_date", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model",     limit: 50,  null: false
    t.integer  "object_id",        limit: 8,   null: false
    t.integer  "last_user_id"
  end

  add_index "reference", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "reference", ["name"], name: "name_idx", using: :btree
  add_index "reference", ["object_model", "object_id", "updated_at"], name: "object_idx", using: :btree
  add_index "reference", ["source"], name: "source_idx", using: :btree
  add_index "reference", ["updated_at"], name: "updated_at_idx", using: :btree

  create_table "reference_excerpt", force: true do |t|
    t.integer  "reference_id", limit: 8,          null: false
    t.text     "body",         limit: 2147483647, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
  end

  add_index "reference_excerpt", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "reference_excerpt", ["reference_id"], name: "reference_id_idx", using: :btree

  create_table "relationship", force: true do |t|
    t.integer  "entity1_id",   limit: 8,                          null: false
    t.integer  "entity2_id",   limit: 8,                          null: false
    t.integer  "category_id",  limit: 8,                          null: false
    t.string   "description1", limit: 100
    t.string   "description2", limit: 100
    t.integer  "amount",       limit: 8
    t.text     "goods",        limit: 2147483647
    t.integer  "filings",      limit: 8
    t.text     "notes",        limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_date",   limit: 10
    t.string   "end_date",     limit: 10
    t.boolean  "is_current"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id"
  end

  add_index "relationship", ["category_id"], name: "category_id_idx", using: :btree
  add_index "relationship", ["entity1_id", "category_id"], name: "entity1_category_idx", using: :btree
  add_index "relationship", ["entity1_id", "entity2_id"], name: "entity_idx", using: :btree
  add_index "relationship", ["entity1_id"], name: "entity1_id_idx", using: :btree
  add_index "relationship", ["entity2_id"], name: "entity2_id_idx", using: :btree
  add_index "relationship", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "relationship_category", force: true do |t|
    t.string   "name",                 limit: 30,                 null: false
    t.string   "display_name",         limit: 30,                 null: false
    t.string   "default_description",  limit: 50
    t.text     "entity1_requirements"
    t.text     "entity2_requirements"
    t.boolean  "has_fields",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationship_category", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "representative", force: true do |t|
    t.string  "bioguide_id", limit: 20
    t.integer "entity_id",   limit: 8,  null: false
  end

  add_index "representative", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "representative_district", force: true do |t|
    t.integer  "representative_id", limit: 8, null: false
    t.integer  "district_id",       limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "representative_district", ["district_id"], name: "district_id_idx", using: :btree
  add_index "representative_district", ["representative_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "representative_district", ["representative_id"], name: "representative_id_idx", using: :btree

  create_table "scheduled_email", force: true do |t|
    t.string   "from_email", limit: 200,                        null: false
    t.string   "from_name",  limit: 200
    t.string   "to_email",   limit: 200,                        null: false
    t.string   "to_name",    limit: 200
    t.text     "subject"
    t.text     "body_text",  limit: 2147483647
    t.text     "body_html",  limit: 2147483647
    t.boolean  "is_sent",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school", force: true do |t|
    t.integer "endowment",  limit: 8
    t.integer "students",   limit: 8
    t.integer "faculty",    limit: 8
    t.integer "tuition",    limit: 8
    t.boolean "is_private"
    t.integer "entity_id",  limit: 8, null: false
  end

  add_index "school", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "scraper_meta", force: true do |t|
    t.string   "scraper",    limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scraper_meta", ["scraper", "namespace", "predicate", "value"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id",                    null: false
    t.text     "data",       limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sf_guard_group", force: true do |t|
    t.string   "name"
    t.string   "blurb"
    t.text     "description"
    t.text     "contest"
    t.boolean  "is_working",      default: false, null: false
    t.boolean  "is_private",      default: false, null: false
    t.string   "display_name",                    null: false
    t.integer  "home_network_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_group", ["display_name"], name: "index_sf_guard_group_on_display_name", using: :btree
  add_index "sf_guard_group", ["name"], name: "name", unique: true, using: :btree

  create_table "sf_guard_group_list", id: false, force: true do |t|
    t.integer "group_id",           default: 0, null: false
    t.integer "list_id",  limit: 8, default: 0, null: false
  end

  add_index "sf_guard_group_list", ["list_id"], name: "list_id", using: :btree

  create_table "sf_guard_group_permission", id: false, force: true do |t|
    t.integer  "group_id",      default: 0, null: false
    t.integer  "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_group_permission", ["permission_id"], name: "permission_id", using: :btree

  create_table "sf_guard_permission", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_permission", ["name"], name: "name", unique: true, using: :btree

  create_table "sf_guard_remember_key", id: false, force: true do |t|
    t.integer  "id",                                   null: false
    t.integer  "user_id"
    t.string   "remember_key", limit: 32
    t.string   "ip_address",   limit: 50, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_remember_key", ["remember_key"], name: "remember_key_idx", using: :btree
  add_index "sf_guard_remember_key", ["user_id"], name: "user_id_idx", using: :btree

  create_table "sf_guard_user", force: true do |t|
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
  end

  add_index "sf_guard_user", ["is_active"], name: "is_active_idx_idx", using: :btree
  add_index "sf_guard_user", ["username"], name: "username", unique: true, using: :btree

  create_table "sf_guard_user_group", id: false, force: true do |t|
    t.integer  "user_id",              default: 0, null: false
    t.integer  "group_id",             default: 0, null: false
    t.boolean  "is_owner"
    t.integer  "score",      limit: 8, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_group", ["group_id"], name: "group_id", using: :btree

  create_table "sf_guard_user_permission", id: false, force: true do |t|
    t.integer  "user_id",       default: 0, null: false
    t.integer  "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_permission", ["permission_id"], name: "permission_id", using: :btree

  create_table "sf_guard_user_profile", force: true do |t|
    t.integer  "user_id",                                                       null: false
    t.string   "name_first",                 limit: 50,                         null: false
    t.string   "name_last",                  limit: 50,                         null: false
    t.string   "email",                      limit: 50,                         null: false
    t.text     "reason",                     limit: 2147483647
    t.text     "analyst_reason",             limit: 2147483647
    t.boolean  "is_visible",                                    default: true,  null: false
    t.string   "invitation_code",            limit: 50
    t.boolean  "enable_announcements",                          default: true,  null: false
    t.boolean  "enable_html_editor",                            default: true,  null: false
    t.boolean  "enable_recent_views",                           default: true,  null: false
    t.boolean  "enable_favorites",                              default: true,  null: false
    t.boolean  "enable_pointers",                               default: true,  null: false
    t.string   "public_name",                limit: 50,                         null: false
    t.text     "bio",                        limit: 2147483647
    t.boolean  "is_confirmed",                                  default: false, null: false
    t.string   "confirmation_code",          limit: 100
    t.string   "filename",                   limit: 100
    t.boolean  "ranking_opt_out",                               default: false, null: false
    t.boolean  "watching_opt_out",                              default: false, null: false
    t.boolean  "enable_notes_list",                             default: true,  null: false
    t.boolean  "enable_notes_notifications",                    default: true,  null: false
    t.integer  "score",                      limit: 8
    t.boolean  "show_full_name",                                default: false, null: false
    t.integer  "unread_notes",                                  default: 0
    t.integer  "home_network_id",                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_profile", ["email"], name: "unique_email_idx", unique: true, using: :btree
  add_index "sf_guard_user_profile", ["public_name"], name: "unique_public_name_idx", unique: true, using: :btree
  add_index "sf_guard_user_profile", ["user_id", "public_name"], name: "user_id_public_name_idx", using: :btree
  add_index "sf_guard_user_profile", ["user_id"], name: "unique_user_idx", unique: true, using: :btree

  create_table "social", force: true do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "social", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "sphinx_index", primary_key: "name", force: true do |t|
    t.datetime "updated_at", null: false
  end

  create_table "tag", force: true do |t|
    t.string   "name",             limit: 100
    t.boolean  "is_visible",                   default: true, null: false
    t.string   "triple_namespace", limit: 30
    t.string   "triple_predicate", limit: 30
    t.string   "triple_value",     limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "task_meta", force: true do |t|
    t.string   "task",       limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_meta", ["task", "namespace", "predicate"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "theyrule_gender_queue", force: true do |t|
    t.integer  "entity_id",                 null: false
    t.boolean  "is_done",   default: false, null: false
    t.datetime "locked_at"
  end

  create_table "transaction", force: true do |t|
    t.integer "contact1_id",     limit: 8
    t.integer "contact2_id",     limit: 8
    t.integer "district_id",     limit: 8
    t.boolean "is_lobbying"
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "transaction", ["contact1_id"], name: "contact1_id_idx", using: :btree
  add_index "transaction", ["contact2_id"], name: "contact2_id_idx", using: :btree
  add_index "transaction", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_network_id"
    t.integer  "sf_guard_user_id",                    null: false
    t.string   "username",                            null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["sf_guard_user_id"], name: "index_users_on_sf_guard_user_id", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
