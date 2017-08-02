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

ActiveRecord::Schema.define(version: 20170802165123) do

  create_table "address", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8,                   null: false
    t.string   "street1",      limit: 100
    t.string   "street2",      limit: 100
    t.string   "street3",      limit: 100
    t.string   "city",         limit: 50,                  null: false
    t.string   "county",       limit: 50
    t.integer  "state_id",     limit: 4
    t.integer  "country_id",   limit: 4
    t.string   "postal",       limit: 20
    t.string   "latitude",     limit: 20
    t.string   "longitude",    limit: 20
    t.integer  "category_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",               default: false, null: false
    t.integer  "last_user_id", limit: 4
    t.string   "accuracy",     limit: 30
    t.string   "country_name", limit: 50,                  null: false
    t.string   "state_name",   limit: 50
  end

  add_index "address", ["category_id"], name: "category_id_idx", using: :btree
  add_index "address", ["country_id"], name: "country_id_idx", using: :btree
  add_index "address", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "address", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "address", ["state_id"], name: "state_id_idx", using: :btree

  create_table "address_category", force: :cascade do |t|
    t.string "name", limit: 20, null: false
  end

  create_table "address_country", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  add_index "address_country", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "address_state", force: :cascade do |t|
    t.string  "name",         limit: 50, null: false
    t.string  "abbreviation", limit: 2,  null: false
    t.integer "country_id",   limit: 8,  null: false
  end

  add_index "address_state", ["country_id"], name: "country_id_idx", using: :btree
  add_index "address_state", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "alias", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8,               null: false
    t.string   "name",         limit: 200,             null: false
    t.string   "context",      limit: 50
    t.integer  "is_primary",   limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id", limit: 4
  end

  add_index "alias", ["entity_id", "name", "context"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "alias", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "alias", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "alias", ["name"], name: "name_idx", using: :btree

  create_table "api_request", force: :cascade do |t|
    t.string   "api_key",    limit: 100, null: false
    t.string   "resource",   limit: 200, null: false
    t.string   "ip_address", limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_request", ["api_key"], name: "api_key_idx", using: :btree
  add_index "api_request", ["created_at"], name: "created_at_idx", using: :btree

  create_table "api_user", force: :cascade do |t|
    t.string   "api_key",       limit: 100,                        null: false
    t.string   "name_first",    limit: 50,                         null: false
    t.string   "name_last",     limit: 50,                         null: false
    t.string   "email",         limit: 100,                        null: false
    t.text     "reason",        limit: 4294967295,                 null: false
    t.boolean  "is_active",                        default: false, null: false
    t.integer  "request_limit", limit: 4,          default: 10000, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_user", ["api_key"], name: "api_key_idx", using: :btree
  add_index "api_user", ["api_key"], name: "api_key_unique_idx", unique: true, using: :btree
  add_index "api_user", ["email"], name: "email_unique_idx", unique: true, using: :btree

  create_table "article", force: :cascade do |t|
    t.text     "url",                 limit: 16777215,                   null: false
    t.string   "title",               limit: 200,                        null: false
    t.string   "authors",             limit: 200
    t.text     "body",                limit: 4294967295,                 null: false
    t.text     "description",         limit: 16777215
    t.integer  "source_id",           limit: 4
    t.datetime "published_at"
    t.boolean  "is_indexed",                             default: false, null: false
    t.datetime "reviewed_at"
    t.integer  "reviewed_by_user_id", limit: 8
    t.boolean  "is_featured",                            default: false, null: false
    t.boolean  "is_hidden",                              default: false, null: false
    t.datetime "found_at",                                               null: false
  end

  add_index "article", ["source_id"], name: "source_id_idx", using: :btree

  create_table "article_entities", force: :cascade do |t|
    t.integer  "article_id",  limit: 4,                 null: false
    t.integer  "entity_id",   limit: 4,                 null: false
    t.boolean  "is_featured",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_entities", ["entity_id", "article_id"], name: "index_article_entities_on_entity_id_and_article_id", unique: true, using: :btree
  add_index "article_entities", ["is_featured"], name: "index_article_entities_on_is_featured", using: :btree

  create_table "article_entity", force: :cascade do |t|
    t.integer  "article_id",          limit: 4,                   null: false
    t.integer  "entity_id",           limit: 4,                   null: false
    t.string   "original_name",       limit: 100,                 null: false
    t.boolean  "is_verified",                     default: false, null: false
    t.integer  "reviewed_by_user_id", limit: 8
    t.datetime "reviewed_at"
  end

  add_index "article_entity", ["article_id"], name: "article_id_idx", using: :btree
  add_index "article_entity", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "article_source", force: :cascade do |t|
    t.string "name",         limit: 100, null: false
    t.string "abbreviation", limit: 10,  null: false
  end

  create_table "articles", force: :cascade do |t|
    t.string   "title",              limit: 255, null: false
    t.string   "url",                limit: 255, null: false
    t.string   "snippet",            limit: 255
    t.datetime "published_at"
    t.string   "created_by_user_id", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.integer  "bootsy_resource_id",   limit: 4
    t.string   "bootsy_resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file",       limit: 255
    t.integer  "image_gallery_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business", force: :cascade do |t|
    t.integer "annual_profit", limit: 8
    t.integer "entity_id",     limit: 8, null: false
  end

  add_index "business", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "business_industry", force: :cascade do |t|
    t.integer "business_id", limit: 8, null: false
    t.integer "industry_id", limit: 8, null: false
  end

  add_index "business_industry", ["business_id"], name: "business_id_idx", using: :btree
  add_index "business_industry", ["industry_id"], name: "industry_id_idx", using: :btree

  create_table "business_person", force: :cascade do |t|
    t.integer "sec_cik",   limit: 8
    t.integer "entity_id", limit: 8, null: false
  end

  add_index "business_person", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",        limit: 255,      null: false
    t.string   "tagline",     limit: 255
    t.text     "description", limit: 16777215
    t.string   "logo",        limit: 255
    t.string   "cover",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",        limit: 255
    t.text     "findings",    limit: 16777215
    t.text     "howto",       limit: 16777215
    t.text     "custom_html", limit: 16777215
    t.string   "logo_credit", limit: 255
  end

  add_index "campaigns", ["slug"], name: "index_campaigns_on_slug", unique: true, using: :btree

  create_table "candidate_district", force: :cascade do |t|
    t.integer  "candidate_id", limit: 8, null: false
    t.integer  "district_id",  limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "candidate_district", ["candidate_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "candidate_district", ["district_id"], name: "district_id_idx", using: :btree

  create_table "chat_user", force: :cascade do |t|
    t.integer  "user_id",    limit: 8, null: false
    t.integer  "room",       limit: 8, null: false
    t.datetime "updated_at",           null: false
  end

  add_index "chat_user", ["room", "updated_at", "user_id"], name: "room_updated_at_user_id_idx", using: :btree
  add_index "chat_user", ["room", "user_id"], name: "room_user_id_idx", unique: true, using: :btree
  add_index "chat_user", ["user_id"], name: "user_id_idx", using: :btree

  create_table "couple", force: :cascade do |t|
    t.integer "entity_id",   limit: 4, null: false
    t.integer "partner1_id", limit: 4
    t.integer "partner2_id", limit: 4
  end

  add_index "couple", ["entity_id"], name: "index_couple_on_entity_id", using: :btree
  add_index "couple", ["partner1_id"], name: "index_couple_on_partner1_id", using: :btree
  add_index "couple", ["partner2_id"], name: "index_couple_on_partner2_id", using: :btree

  create_table "custom_key", force: :cascade do |t|
    t.string   "name",         limit: 50,         null: false
    t.text     "value",        limit: 4294967295
    t.string   "description",  limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50,         null: false
    t.integer  "object_id",    limit: 8,          null: false
  end

  add_index "custom_key", ["object_model", "object_id", "name", "value"], name: "object_name_value_idx", unique: true, length: {"object_model"=>nil, "object_id"=>nil, "name"=>nil, "value"=>100}, using: :btree
  add_index "custom_key", ["object_model", "object_id", "name"], name: "object_name_idx", unique: true, using: :btree
  add_index "custom_key", ["object_model", "object_id"], name: "object_idx", using: :btree

  create_table "degree", force: :cascade do |t|
    t.string "name",         limit: 50, null: false
    t.string "abbreviation", limit: 10
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,        default: 0, null: false
    t.integer  "attempts",   limit: 4,        default: 0, null: false
    t.text     "handler",    limit: 16777215,             null: false
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "domain", force: :cascade do |t|
    t.string "name", limit: 40,  null: false
    t.string "url",  limit: 200, null: false
  end

  create_table "donation", force: :cascade do |t|
    t.integer "bundler_id",      limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "donation", ["bundler_id"], name: "bundler_id_idx", using: :btree
  add_index "donation", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "education", force: :cascade do |t|
    t.integer "degree_id",       limit: 8
    t.string  "field",           limit: 30
    t.boolean "is_dropout"
    t.integer "relationship_id", limit: 8,  null: false
  end

  add_index "education", ["degree_id"], name: "degree_id_idx", using: :btree
  add_index "education", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "elected_representative", force: :cascade do |t|
    t.string  "bioguide_id", limit: 20
    t.string  "govtrack_id", limit: 20
    t.string  "crp_id",      limit: 20
    t.string  "pvs_id",      limit: 20
    t.string  "watchdog_id", limit: 50
    t.integer "entity_id",   limit: 8,  null: false
  end

  add_index "elected_representative", ["crp_id"], name: "crp_id_idx", using: :btree
  add_index "elected_representative", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "email", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8,                  null: false
    t.string   "address",      limit: 60,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",              default: false, null: false
    t.integer  "last_user_id", limit: 4
  end

  add_index "email", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "email", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "entity", force: :cascade do |t|
    t.string   "name",         limit: 200
    t.string   "blurb",        limit: 200
    t.text     "summary",      limit: 4294967295
    t.text     "notes",        limit: 4294967295
    t.string   "website",      limit: 100
    t.integer  "parent_id",    limit: 8
    t.string   "primary_ext",  limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_date",   limit: 10
    t.string   "end_date",     limit: 10
    t.boolean  "is_current"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id", limit: 4
    t.integer  "merged_id",    limit: 4
    t.boolean  "delta",                           default: true,  null: false
    t.integer  "link_count",   limit: 8,          default: 0,     null: false
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

  create_table "entity_fields", force: :cascade do |t|
    t.integer "entity_id", limit: 4
    t.integer "field_id",  limit: 4
    t.string  "value",     limit: 255,                 null: false
    t.boolean "is_admin",              default: false
  end

  add_index "entity_fields", ["entity_id", "field_id"], name: "index_entity_fields_on_entity_id_and_field_id", unique: true, using: :btree

  create_table "extension_definition", force: :cascade do |t|
    t.string  "name",         limit: 30,                 null: false
    t.string  "display_name", limit: 50,                 null: false
    t.boolean "has_fields",              default: false, null: false
    t.integer "parent_id",    limit: 8
    t.integer "tier",         limit: 8
  end

  add_index "extension_definition", ["name"], name: "name_idx", using: :btree
  add_index "extension_definition", ["parent_id"], name: "parent_id_idx", using: :btree
  add_index "extension_definition", ["tier"], name: "tier_idx", using: :btree

  create_table "extension_record", force: :cascade do |t|
    t.integer "entity_id",     limit: 8, null: false
    t.integer "definition_id", limit: 8, null: false
    t.integer "last_user_id",  limit: 4
  end

  add_index "extension_record", ["definition_id"], name: "definition_id_idx", using: :btree
  add_index "extension_record", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "extension_record", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "external_key", force: :cascade do |t|
    t.integer "entity_id",   limit: 8,   null: false
    t.string  "external_id", limit: 200, null: false
    t.integer "domain_id",   limit: 8,   null: false
  end

  add_index "external_key", ["domain_id"], name: "domain_id_idx", using: :btree
  add_index "external_key", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "external_key", ["external_id", "domain_id"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "family", force: :cascade do |t|
    t.boolean "is_nonbiological"
    t.integer "relationship_id",  limit: 8, null: false
  end

  add_index "family", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "fec_filing", force: :cascade do |t|
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

  create_table "fedspending_filing", force: :cascade do |t|
    t.integer "relationship_id", limit: 8
    t.integer "amount",          limit: 8
    t.text    "goods",           limit: 4294967295
    t.integer "district_id",     limit: 8
    t.string  "fedspending_id",  limit: 30
    t.string  "start_date",      limit: 10
    t.string  "end_date",        limit: 10
    t.boolean "is_current"
  end

  add_index "fedspending_filing", ["district_id"], name: "district_id_idx", using: :btree
  add_index "fedspending_filing", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "fields", force: :cascade do |t|
    t.string "name",         limit: 255,                    null: false
    t.string "display_name", limit: 255,                    null: false
    t.string "type",         limit: 255, default: "string", null: false
  end

  add_index "fields", ["name"], name: "index_fields_on_name", unique: true, using: :btree

  create_table "gender", force: :cascade do |t|
    t.string "name", limit: 10, null: false
  end

  create_table "generic", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "generic", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "government_body", force: :cascade do |t|
    t.boolean "is_federal"
    t.integer "state_id",   limit: 8
    t.string  "city",       limit: 50
    t.string  "county",     limit: 50
    t.integer "entity_id",  limit: 8,  null: false
  end

  add_index "government_body", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "government_body", ["state_id"], name: "state_id_idx", using: :btree

  create_table "group_lists", force: :cascade do |t|
    t.integer "group_id",    limit: 4
    t.integer "list_id",     limit: 4
    t.boolean "is_featured",           default: false, null: false
  end

  add_index "group_lists", ["group_id", "list_id"], name: "index_group_lists_on_group_id_and_list_id", unique: true, using: :btree
  add_index "group_lists", ["list_id"], name: "index_group_lists_on_list_id", using: :btree

  create_table "group_users", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",             default: false, null: false
  end

  add_index "group_users", ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true, using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "tagline",            limit: 255
    t.text     "description",        limit: 16777215
    t.boolean  "is_private",                          default: false, null: false
    t.string   "slug",               limit: 255
    t.integer  "default_network_id", limit: 4
    t.integer  "campaign_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo",               limit: 255
    t.text     "findings",           limit: 16777215
    t.text     "howto",              limit: 16777215
    t.integer  "featured_list_id",   limit: 4
    t.string   "cover",              limit: 255
    t.boolean  "delta",                               default: true,  null: false
    t.string   "logo_credit",        limit: 255
  end

  add_index "groups", ["campaign_id"], name: "index_groups_on_campaign_id", using: :btree
  add_index "groups", ["delta"], name: "index_groups_on_delta", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

  create_table "hierarchy", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "hierarchy", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "image", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8,                          null: false
    t.string   "filename",     limit: 100,                        null: false
    t.string   "title",        limit: 100,                        null: false
    t.text     "caption",      limit: 4294967295
    t.boolean  "is_featured",                     default: false, null: false
    t.boolean  "is_free"
    t.string   "url",          limit: 400
    t.integer  "width",        limit: 8
    t.integer  "height",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id", limit: 4
    t.boolean  "has_square",                      default: false, null: false
    t.integer  "address_id",   limit: 4
    t.string   "raw_address",  limit: 200
    t.boolean  "has_face",                        default: false, null: false
  end

  add_index "image", ["address_id"], name: "index_image_on_address_id", using: :btree
  add_index "image", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "image", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "industries", force: :cascade do |t|
    t.string "name",        limit: 255, null: false
    t.string "industry_id", limit: 255, null: false
    t.string "sector_name", limit: 255, null: false
  end

  add_index "industries", ["industry_id"], name: "index_industries_on_industry_id", unique: true, using: :btree

  create_table "industry", force: :cascade do |t|
    t.string   "name",       limit: 100, null: false
    t.string   "context",    limit: 30
    t.string   "code",       limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link", force: :cascade do |t|
    t.integer "entity1_id",      limit: 8, null: false
    t.integer "entity2_id",      limit: 8, null: false
    t.integer "category_id",     limit: 8, null: false
    t.integer "relationship_id", limit: 8, null: false
    t.boolean "is_reverse",                null: false
  end

  add_index "link", ["category_id"], name: "category_id_idx", using: :btree
  add_index "link", ["entity1_id", "category_id", "is_reverse"], name: "index_link_on_entity1_id_and_category_id_and_is_reverse", using: :btree
  add_index "link", ["entity1_id", "category_id"], name: "index_link_on_entity1_id_and_category_id", using: :btree
  add_index "link", ["entity1_id"], name: "entity1_id_idx", using: :btree
  add_index "link", ["entity2_id"], name: "entity2_id_idx", using: :btree
  add_index "link", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobby_filing", force: :cascade do |t|
    t.string  "federal_filing_id", limit: 50,  null: false
    t.integer "amount",            limit: 8
    t.integer "year",              limit: 8
    t.string  "period",            limit: 100
    t.string  "report_type",       limit: 100
    t.string  "start_date",        limit: 10
    t.string  "end_date",          limit: 10
    t.boolean "is_current"
  end

  create_table "lobby_filing_lobby_issue", force: :cascade do |t|
    t.integer "issue_id",        limit: 8,          null: false
    t.integer "lobby_filing_id", limit: 8,          null: false
    t.text    "specific_issue",  limit: 4294967295
  end

  add_index "lobby_filing_lobby_issue", ["issue_id"], name: "issue_id_idx", using: :btree
  add_index "lobby_filing_lobby_issue", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree

  create_table "lobby_filing_lobbyist", force: :cascade do |t|
    t.integer "lobbyist_id",     limit: 8, null: false
    t.integer "lobby_filing_id", limit: 8, null: false
  end

  add_index "lobby_filing_lobbyist", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
  add_index "lobby_filing_lobbyist", ["lobbyist_id"], name: "lobbyist_id_idx", using: :btree

  create_table "lobby_filing_relationship", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
    t.integer "lobby_filing_id", limit: 8, null: false
  end

  add_index "lobby_filing_relationship", ["lobby_filing_id"], name: "lobby_filing_id_idx", using: :btree
  add_index "lobby_filing_relationship", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobby_issue", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "lobbying", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "lobbying", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "lobbyist", force: :cascade do |t|
    t.integer "lda_registrant_id", limit: 8
    t.integer "entity_id",         limit: 8, null: false
  end

  add_index "lobbyist", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "ls_list", force: :cascade do |t|
    t.string   "name",              limit: 100,                        null: false
    t.text     "description",       limit: 4294967295
    t.boolean  "is_ranked",                            default: false, null: false
    t.boolean  "is_admin",                             default: false, null: false
    t.boolean  "is_featured",                          default: false, null: false
    t.boolean  "is_network",                           default: false, null: false
    t.string   "display_name",      limit: 50
    t.integer  "featured_list_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id",      limit: 4
    t.boolean  "is_deleted",                           default: false, null: false
    t.string   "custom_field_name", limit: 100
    t.boolean  "delta",                                default: true,  null: false
    t.boolean  "is_private",                           default: false
    t.integer  "creator_user_id",   limit: 4
    t.string   "short_description", limit: 255
  end

  add_index "ls_list", ["delta"], name: "index_ls_list_on_delta", using: :btree
  add_index "ls_list", ["featured_list_id"], name: "featured_list_id", using: :btree
  add_index "ls_list", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "ls_list", ["name"], name: "index_ls_list_on_name", using: :btree

  create_table "ls_list_entity", force: :cascade do |t|
    t.integer  "list_id",      limit: 8,                     null: false
    t.integer  "entity_id",    limit: 8,                     null: false
    t.integer  "rank",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id", limit: 4
    t.boolean  "is_deleted",                 default: false, null: false
    t.text     "custom_field", limit: 65535
  end

  add_index "ls_list_entity", ["created_at"], name: "created_at_idx", using: :btree
  add_index "ls_list_entity", ["entity_id", "is_deleted", "list_id"], name: "entity_deleted_list_idx", using: :btree
  add_index "ls_list_entity", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "ls_list_entity", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "ls_list_entity", ["list_id", "is_deleted", "entity_id"], name: "list_deleted_entity_idx", using: :btree
  add_index "ls_list_entity", ["list_id"], name: "list_id_idx", using: :btree

  create_table "map_annotations", force: :cascade do |t|
    t.integer "map_id",                 limit: 4,     null: false
    t.integer "order",                  limit: 4,     null: false
    t.string  "title",                  limit: 255
    t.text    "description",            limit: 65535
    t.string  "highlighted_entity_ids", limit: 255
    t.string  "highlighted_rel_ids",    limit: 255
    t.string  "highlighted_text_ids",   limit: 255
  end

  add_index "map_annotations", ["map_id"], name: "index_map_annotations_on_map_id", using: :btree

  create_table "membership", force: :cascade do |t|
    t.integer "dues",            limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "membership", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "modification", force: :cascade do |t|
    t.string   "object_name",     limit: 100
    t.integer  "user_id",         limit: 4,   default: 1,     null: false
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

  create_table "modification_field", force: :cascade do |t|
    t.integer "modification_id", limit: 8,          null: false
    t.string  "field_name",      limit: 50,         null: false
    t.text    "old_value",       limit: 4294967295
    t.text    "new_value",       limit: 4294967295
  end

  add_index "modification_field", ["modification_id"], name: "modification_id_idx", using: :btree

  create_table "network_map", force: :cascade do |t|
    t.integer  "user_id",           limit: 8,                          null: false
    t.text     "data",              limit: 4294967295,                 null: false
    t.string   "entity_ids",        limit: 5000
    t.string   "rel_ids",           limit: 5000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                           default: false, null: false
    t.string   "title",             limit: 100
    t.text     "description",       limit: 4294967295
    t.integer  "width",             limit: 4,                          null: false
    t.integer  "height",            limit: 4,                          null: false
    t.boolean  "is_featured",                          default: false, null: false
    t.string   "zoom",              limit: 255,        default: "1",   null: false
    t.boolean  "is_private",                           default: false, null: false
    t.string   "thumbnail",         limit: 255
    t.boolean  "delta",                                default: true,  null: false
    t.text     "index_data",        limit: 4294967295
    t.string   "secret",            limit: 255
    t.text     "graph_data",        limit: 16777215
    t.text     "annotations_data",  limit: 65535
    t.integer  "annotations_count", limit: 4,          default: 0,     null: false
    t.boolean  "list_sources",                         default: false, null: false
    t.boolean  "is_cloneable",                         default: true,  null: false
  end

  add_index "network_map", ["delta"], name: "index_network_map_on_delta", using: :btree
  add_index "network_map", ["user_id"], name: "user_id_idx", using: :btree

  create_table "note", force: :cascade do |t|
    t.integer  "user_id",            limit: 4,                     null: false
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
    t.integer  "sf_guard_user_id",   limit: 4
    t.integer  "new_user_id",        limit: 4
    t.boolean  "delta",                            default: true,  null: false
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

  create_table "note_entities", force: :cascade do |t|
    t.integer "note_id",   limit: 4
    t.integer "entity_id", limit: 4
  end

  add_index "note_entities", ["entity_id"], name: "index_note_entities_on_entity_id", using: :btree
  add_index "note_entities", ["note_id", "entity_id"], name: "index_note_entities_on_note_id_and_entity_id", unique: true, using: :btree

  create_table "note_groups", force: :cascade do |t|
    t.integer "note_id",  limit: 4
    t.integer "group_id", limit: 4
  end

  add_index "note_groups", ["group_id"], name: "index_note_groups_on_group_id", using: :btree
  add_index "note_groups", ["note_id", "group_id"], name: "index_note_groups_on_note_id_and_group_id", unique: true, using: :btree

  create_table "note_lists", force: :cascade do |t|
    t.integer "note_id", limit: 4
    t.integer "list_id", limit: 4
  end

  add_index "note_lists", ["list_id"], name: "index_note_lists_on_list_id", using: :btree
  add_index "note_lists", ["note_id", "list_id"], name: "index_note_lists_on_note_id_and_list_id", unique: true, using: :btree

  create_table "note_networks", force: :cascade do |t|
    t.integer "note_id",    limit: 4
    t.integer "network_id", limit: 4
  end

  add_index "note_networks", ["network_id"], name: "index_note_networks_on_network_id", using: :btree
  add_index "note_networks", ["note_id", "network_id"], name: "index_note_networks_on_note_id_and_network_id", unique: true, using: :btree

  create_table "note_relationships", force: :cascade do |t|
    t.integer "note_id",         limit: 4
    t.integer "relationship_id", limit: 4
  end

  add_index "note_relationships", ["note_id", "relationship_id"], name: "index_note_relationships_on_note_id_and_relationship_id", unique: true, using: :btree
  add_index "note_relationships", ["relationship_id"], name: "index_note_relationships_on_relationship_id", using: :btree

  create_table "note_users", force: :cascade do |t|
    t.integer "note_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "note_users", ["note_id", "user_id"], name: "index_note_users_on_note_id_and_user_id", unique: true, using: :btree
  add_index "note_users", ["user_id"], name: "index_note_users_on_user_id", using: :btree

  create_table "ny_disclosures", force: :cascade do |t|
    t.string   "filer_id",                  limit: 10,                 null: false
    t.string   "report_id",                 limit: 255
    t.string   "transaction_code",          limit: 1,                  null: false
    t.string   "e_year",                    limit: 4,                  null: false
    t.integer  "transaction_id",            limit: 8,                  null: false
    t.date     "schedule_transaction_date"
    t.date     "original_date"
    t.string   "contrib_code",              limit: 4
    t.string   "contrib_type_code",         limit: 1
    t.string   "corp_name",                 limit: 255
    t.string   "first_name",                limit: 255
    t.string   "mid_init",                  limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "address",                   limit: 255
    t.string   "city",                      limit: 255
    t.string   "state",                     limit: 2
    t.string   "zip",                       limit: 5
    t.string   "check_number",              limit: 255
    t.string   "check_date",                limit: 255
    t.float    "amount1",                   limit: 24
    t.float    "amount2",                   limit: 24
    t.string   "description",               limit: 255
    t.string   "other_recpt_code",          limit: 255
    t.string   "purpose_code1",             limit: 255
    t.string   "purpose_code2",             limit: 255
    t.string   "explanation",               limit: 255
    t.string   "transfer_type",             limit: 1
    t.string   "bank_loan_check_box",       limit: 1
    t.string   "crerec_uid",                limit: 255
    t.datetime "crerec_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                                 default: true, null: false
  end

  add_index "ny_disclosures", ["contrib_code"], name: "index_ny_disclosures_on_contrib_code", using: :btree
  add_index "ny_disclosures", ["delta"], name: "index_ny_disclosures_on_delta", using: :btree
  add_index "ny_disclosures", ["e_year"], name: "index_ny_disclosures_on_e_year", using: :btree
  add_index "ny_disclosures", ["filer_id", "report_id", "transaction_id", "schedule_transaction_date", "e_year"], name: "index_filer_report_trans_date_e_year", using: :btree
  add_index "ny_disclosures", ["filer_id"], name: "index_ny_disclosures_on_filer_id", using: :btree
  add_index "ny_disclosures", ["original_date"], name: "index_ny_disclosures_on_original_date", using: :btree

  create_table "ny_filer_entities", force: :cascade do |t|
    t.integer  "ny_filer_id",    limit: 4
    t.integer  "entity_id",      limit: 4
    t.boolean  "is_committee"
    t.integer  "cmte_entity_id", limit: 4
    t.string   "e_year",         limit: 4
    t.string   "filer_id",       limit: 255
    t.string   "office",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ny_filer_entities", ["cmte_entity_id"], name: "index_ny_filer_entities_on_cmte_entity_id", using: :btree
  add_index "ny_filer_entities", ["entity_id"], name: "index_ny_filer_entities_on_entity_id", using: :btree
  add_index "ny_filer_entities", ["filer_id"], name: "index_ny_filer_entities_on_filer_id", using: :btree
  add_index "ny_filer_entities", ["is_committee"], name: "index_ny_filer_entities_on_is_committee", using: :btree
  add_index "ny_filer_entities", ["ny_filer_id"], name: "index_ny_filer_entities_on_ny_filer_id", using: :btree

  create_table "ny_filers", force: :cascade do |t|
    t.string   "filer_id",         limit: 255, null: false
    t.string   "name",             limit: 255
    t.string   "filer_type",       limit: 255
    t.string   "status",           limit: 255
    t.string   "committee_type",   limit: 255
    t.integer  "office",           limit: 4
    t.integer  "district",         limit: 4
    t.string   "treas_first_name", limit: 255
    t.string   "treas_last_name",  limit: 255
    t.string   "address",          limit: 255
    t.string   "city",             limit: 255
    t.string   "state",            limit: 255
    t.string   "zip",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ny_filers", ["filer_id"], name: "index_ny_filers_on_filer_id", unique: true, using: :btree
  add_index "ny_filers", ["filer_type"], name: "index_ny_filers_on_filer_type", using: :btree

  create_table "ny_matches", force: :cascade do |t|
    t.integer  "ny_disclosure_id", limit: 4
    t.integer  "donor_id",         limit: 4
    t.integer  "recip_id",         limit: 4
    t.integer  "relationship_id",  limit: 4
    t.integer  "matched_by",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ny_matches", ["donor_id"], name: "index_ny_matches_on_donor_id", using: :btree
  add_index "ny_matches", ["ny_disclosure_id"], name: "index_ny_matches_on_ny_disclosure_id", unique: true, using: :btree
  add_index "ny_matches", ["recip_id"], name: "index_ny_matches_on_recip_id", using: :btree
  add_index "ny_matches", ["relationship_id"], name: "index_ny_matches_on_relationship_id", using: :btree

  create_table "object_tag", force: :cascade do |t|
    t.integer  "tag_id",       limit: 8,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model", limit: 50, null: false
    t.integer  "object_id",    limit: 8,  null: false
    t.integer  "last_user_id", limit: 4
  end

  add_index "object_tag", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "object_tag", ["object_model", "object_id", "tag_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "object_tag", ["object_model", "object_id"], name: "object_idx", using: :btree
  add_index "object_tag", ["tag_id"], name: "tag_id_idx", using: :btree

  create_table "org", force: :cascade do |t|
    t.string  "name",              limit: 200, null: false
    t.string  "name_nick",         limit: 100
    t.integer "employees",         limit: 8
    t.integer "revenue",           limit: 8
    t.string  "fedspending_id",    limit: 10
    t.string  "lda_registrant_id", limit: 10
    t.integer "entity_id",         limit: 8,   null: false
  end

  add_index "org", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_candidates", force: :cascade do |t|
    t.string   "cycle",          limit: 255, null: false
    t.string   "feccandid",      limit: 255, null: false
    t.string   "crp_id",         limit: 255, null: false
    t.string   "name",           limit: 255
    t.string   "party",          limit: 1
    t.string   "distid_runfor",  limit: 255
    t.string   "distid_current", limit: 255
    t.boolean  "currcand"
    t.boolean  "cyclecand"
    t.string   "crpico",         limit: 1
    t.string   "recipcode",      limit: 2
    t.string   "nopacs",         limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os_candidates", ["crp_id"], name: "index_os_candidates_on_crp_id", using: :btree
  add_index "os_candidates", ["cycle", "crp_id"], name: "index_os_candidates_on_cycle_and_crp_id", using: :btree
  add_index "os_candidates", ["feccandid"], name: "index_os_candidates_on_feccandid", using: :btree

  create_table "os_category", force: :cascade do |t|
    t.string "category_id",   limit: 10,  null: false
    t.string "category_name", limit: 100, null: false
    t.string "industry_id",   limit: 10,  null: false
    t.string "industry_name", limit: 100, null: false
    t.string "sector_name",   limit: 100, null: false
  end

  add_index "os_category", ["category_id"], name: "unique_id_idx", unique: true, using: :btree
  add_index "os_category", ["category_name"], name: "unique_name_idx", unique: true, using: :btree

  create_table "os_committees", force: :cascade do |t|
    t.string   "cycle",           limit: 4,   null: false
    t.string   "cmte_id",         limit: 255, null: false
    t.string   "name",            limit: 255
    t.string   "affiliate",       limit: 255
    t.string   "ultorg",          limit: 255
    t.string   "recipid",         limit: 255
    t.string   "recipcode",       limit: 2
    t.string   "feccandid",       limit: 255
    t.string   "party",           limit: 1
    t.string   "primcode",        limit: 5
    t.string   "source",          limit: 255
    t.boolean  "sensitive"
    t.boolean  "foreign"
    t.boolean  "active_in_cycle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os_committees", ["cmte_id", "cycle"], name: "index_os_committees_on_cmte_id_and_cycle", using: :btree
  add_index "os_committees", ["cmte_id"], name: "index_os_committees_on_cmte_id", using: :btree
  add_index "os_committees", ["recipid"], name: "index_os_committees_on_recipid", using: :btree

  create_table "os_donations", force: :cascade do |t|
    t.string   "cycle",           limit: 4,   null: false
    t.string   "fectransid",      limit: 19,  null: false
    t.string   "contribid",       limit: 12
    t.string   "contrib",         limit: 255
    t.string   "recipid",         limit: 9
    t.string   "orgname",         limit: 255
    t.string   "ultorg",          limit: 255
    t.string   "realcode",        limit: 5
    t.date     "date"
    t.integer  "amount",          limit: 4
    t.string   "street",          limit: 255
    t.string   "city",            limit: 255
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 5
    t.string   "recipcode",       limit: 2
    t.string   "transactiontype", limit: 3
    t.string   "cmteid",          limit: 9
    t.string   "otherid",         limit: 9
    t.string   "gender",          limit: 1
    t.string   "microfilm",       limit: 30
    t.string   "occupation",      limit: 255
    t.string   "employer",        limit: 255
    t.string   "source",          limit: 5
    t.string   "fec_cycle_id",    limit: 24,  null: false
    t.string   "name_last",       limit: 255
    t.string   "name_first",      limit: 255
    t.string   "name_middle",     limit: 255
    t.string   "name_suffix",     limit: 255
    t.string   "name_prefix",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os_donations", ["amount"], name: "index_os_donations_on_amount", using: :btree
  add_index "os_donations", ["contribid"], name: "index_os_donations_on_contribid", using: :btree
  add_index "os_donations", ["cycle"], name: "index_os_donations_on_cycle", using: :btree
  add_index "os_donations", ["date"], name: "index_os_donations_on_date", using: :btree
  add_index "os_donations", ["fec_cycle_id"], name: "index_os_donations_on_fec_cycle_id", unique: true, using: :btree
  add_index "os_donations", ["fectransid", "cycle"], name: "index_os_donations_on_fectransid_and_cycle", using: :btree
  add_index "os_donations", ["fectransid"], name: "index_os_donations_on_fectransid", using: :btree
  add_index "os_donations", ["microfilm"], name: "index_os_donations_on_microfilm", using: :btree
  add_index "os_donations", ["name_last", "name_first"], name: "index_os_donations_on_name_last_and_name_first", using: :btree
  add_index "os_donations", ["realcode", "amount"], name: "index_os_donations_on_realcode_and_amount", using: :btree
  add_index "os_donations", ["realcode"], name: "index_os_donations_on_realcode", using: :btree
  add_index "os_donations", ["recipid", "amount"], name: "index_os_donations_on_recipid_and_amount", using: :btree
  add_index "os_donations", ["recipid"], name: "index_os_donations_on_recipid", using: :btree
  add_index "os_donations", ["state"], name: "index_os_donations_on_state", using: :btree
  add_index "os_donations", ["zip"], name: "index_os_donations_on_zip", using: :btree

  create_table "os_entity_category", force: :cascade do |t|
    t.integer  "entity_id",   limit: 8,   null: false
    t.string   "category_id", limit: 10,  null: false
    t.string   "source",      limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os_entity_category", ["category_id"], name: "category_id_idx", using: :btree
  add_index "os_entity_category", ["entity_id", "category_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "os_entity_category", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_entity_donor", force: :cascade do |t|
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

  create_table "os_entity_preprocess", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8, null: false
    t.string   "cycle",        limit: 4, null: false
    t.datetime "processed_at",           null: false
    t.datetime "updated_at"
  end

  add_index "os_entity_preprocess", ["entity_id", "cycle"], name: "entity_cycle_idx", unique: true, using: :btree
  add_index "os_entity_preprocess", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "os_entity_transaction", force: :cascade do |t|
    t.integer  "entity_id",           limit: 4,                  null: false
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

  create_table "os_matches", force: :cascade do |t|
    t.integer  "os_donation_id",  limit: 4,                 null: false
    t.integer  "donation_id",     limit: 4
    t.integer  "donor_id",        limit: 4,                 null: false
    t.integer  "recip_id",        limit: 4
    t.integer  "relationship_id", limit: 4
    t.integer  "reference_id",    limit: 4
    t.integer  "matched_by",      limit: 4
    t.boolean  "is_deleted",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cmte_id",         limit: 4
  end

  add_index "os_matches", ["cmte_id"], name: "index_os_matches_on_cmte_id", using: :btree
  add_index "os_matches", ["donor_id"], name: "index_os_matches_on_donor_id", using: :btree
  add_index "os_matches", ["os_donation_id"], name: "index_os_matches_on_os_donation_id", using: :btree
  add_index "os_matches", ["recip_id"], name: "index_os_matches_on_recip_id", using: :btree
  add_index "os_matches", ["reference_id"], name: "index_os_matches_on_reference_id", using: :btree
  add_index "os_matches", ["relationship_id"], name: "index_os_matches_on_relationship_id", using: :btree

  create_table "ownership", force: :cascade do |t|
    t.integer "percent_stake",   limit: 8
    t.integer "shares",          limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "ownership", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "person", force: :cascade do |t|
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
    t.string  "name_maiden",    limit: 50
  end

  add_index "person", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "person", ["gender_id"], name: "gender_id_idx", using: :btree
  add_index "person", ["name_last", "name_first", "name_middle"], name: "name_idx", using: :btree
  add_index "person", ["party_id"], name: "party_id_idx", using: :btree

  create_table "phone", force: :cascade do |t|
    t.integer  "entity_id",    limit: 8,                   null: false
    t.string   "number",       limit: 20,                  null: false
    t.string   "type",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",               default: false, null: false
    t.integer  "last_user_id", limit: 4
  end

  add_index "phone", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "phone", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "political_candidate", force: :cascade do |t|
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

  create_table "political_district", force: :cascade do |t|
    t.integer "state_id",         limit: 8
    t.string  "federal_district", limit: 2
    t.string  "state_district",   limit: 2
    t.string  "local_district",   limit: 2
  end

  add_index "political_district", ["state_id"], name: "state_id_idx", using: :btree

  create_table "political_fundraising", force: :cascade do |t|
    t.string  "fec_id",    limit: 20
    t.integer "type_id",   limit: 8
    t.integer "state_id",  limit: 8
    t.integer "entity_id", limit: 8,  null: false
  end

  add_index "political_fundraising", ["entity_id"], name: "entity_id_idx", using: :btree
  add_index "political_fundraising", ["fec_id"], name: "fec_id_idx", using: :btree
  add_index "political_fundraising", ["state_id"], name: "state_id_idx", using: :btree
  add_index "political_fundraising", ["type_id"], name: "type_id_idx", using: :btree

  create_table "political_fundraising_type", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "position", force: :cascade do |t|
    t.boolean "is_board"
    t.boolean "is_executive"
    t.boolean "is_employee"
    t.integer "compensation",    limit: 8
    t.integer "boss_id",         limit: 8
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "position", ["boss_id"], name: "boss_id_idx", using: :btree
  add_index "position", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "professional", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "professional", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "public_company", force: :cascade do |t|
    t.string  "ticker",    limit: 10
    t.integer "sec_cik",   limit: 8
    t.integer "entity_id", limit: 8,  null: false
  end

  add_index "public_company", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "queue_entities", force: :cascade do |t|
    t.string   "queue",      limit: 255,                 null: false
    t.integer  "entity_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "is_skipped",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "queue_entities", ["queue", "entity_id"], name: "index_queue_entities_on_queue_and_entity_id", unique: true, using: :btree

  create_table "reference", force: :cascade do |t|
    t.string   "fields",           limit: 200
    t.string   "name",             limit: 100
    t.string   "source",           limit: 1000,             null: false
    t.string   "source_detail",    limit: 255
    t.string   "publication_date", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_model",     limit: 50,               null: false
    t.integer  "object_id",        limit: 8,                null: false
    t.integer  "last_user_id",     limit: 4
    t.integer  "ref_type",         limit: 4,    default: 1, null: false
  end

  add_index "reference", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "reference", ["name"], name: "name_idx", using: :btree
  add_index "reference", ["object_model", "object_id", "ref_type"], name: "index_reference_on_object_model_and_object_id_and_ref_type", using: :btree
  add_index "reference", ["object_model", "object_id", "updated_at"], name: "object_idx", using: :btree
  add_index "reference", ["source"], name: "source_idx", length: {"source"=>255}, using: :btree
  add_index "reference", ["updated_at"], name: "updated_at_idx", using: :btree

  create_table "reference_excerpt", force: :cascade do |t|
    t.integer  "reference_id", limit: 8,          null: false
    t.text     "body",         limit: 4294967295, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id", limit: 4
  end

  add_index "reference_excerpt", ["last_user_id"], name: "last_user_id_idx", using: :btree
  add_index "reference_excerpt", ["reference_id"], name: "reference_id_idx", using: :btree

  create_table "relationship", force: :cascade do |t|
    t.integer  "entity1_id",   limit: 8,                          null: false
    t.integer  "entity2_id",   limit: 8,                          null: false
    t.integer  "category_id",  limit: 8,                          null: false
    t.string   "description1", limit: 100
    t.string   "description2", limit: 100
    t.integer  "amount",       limit: 8
    t.text     "goods",        limit: 4294967295
    t.integer  "filings",      limit: 8
    t.text     "notes",        limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_date",   limit: 10
    t.string   "end_date",     limit: 10
    t.boolean  "is_current"
    t.boolean  "is_deleted",                      default: false, null: false
    t.integer  "last_user_id", limit: 4
    t.integer  "amount2",      limit: 8
    t.boolean  "is_gte",                          default: false, null: false
  end

  add_index "relationship", ["category_id"], name: "category_id_idx", using: :btree
  add_index "relationship", ["entity1_id", "category_id"], name: "entity1_category_idx", using: :btree
  add_index "relationship", ["entity1_id", "entity2_id"], name: "entity_idx", using: :btree
  add_index "relationship", ["entity1_id"], name: "entity1_id_idx", using: :btree
  add_index "relationship", ["entity2_id"], name: "entity2_id_idx", using: :btree
  add_index "relationship", ["is_deleted", "entity2_id", "category_id", "amount"], name: "index_relationship_is_d_e2_cat_amount", using: :btree
  add_index "relationship", ["last_user_id"], name: "last_user_id_idx", using: :btree

  create_table "relationship_category", force: :cascade do |t|
    t.string   "name",                 limit: 30,                    null: false
    t.string   "display_name",         limit: 30,                    null: false
    t.string   "default_description",  limit: 50
    t.text     "entity1_requirements", limit: 65535
    t.text     "entity2_requirements", limit: 65535
    t.boolean  "has_fields",                         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationship_category", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "representative", force: :cascade do |t|
    t.string  "bioguide_id", limit: 20
    t.integer "entity_id",   limit: 8,  null: false
  end

  add_index "representative", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "representative_district", force: :cascade do |t|
    t.integer  "representative_id", limit: 8, null: false
    t.integer  "district_id",       limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "representative_district", ["district_id"], name: "district_id_idx", using: :btree
  add_index "representative_district", ["representative_id", "district_id"], name: "uniqueness_idx", unique: true, using: :btree
  add_index "representative_district", ["representative_id"], name: "representative_id_idx", using: :btree

  create_table "scheduled_email", force: :cascade do |t|
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

  create_table "school", force: :cascade do |t|
    t.integer "endowment",  limit: 8
    t.integer "students",   limit: 8
    t.integer "faculty",    limit: 8
    t.integer "tuition",    limit: 8
    t.boolean "is_private"
    t.integer "entity_id",  limit: 8, null: false
  end

  add_index "school", ["entity_id"], name: "entity_id_idx", using: :btree

  create_table "scraper_meta", force: :cascade do |t|
    t.string   "scraper",    limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scraper_meta", ["scraper", "namespace", "predicate", "value"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,        null: false
    t.text     "data",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sf_guard_group", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "blurb",           limit: 255
    t.text     "description",     limit: 65535
    t.text     "contest",         limit: 65535
    t.boolean  "is_working",                    default: false, null: false
    t.boolean  "is_private",                    default: false, null: false
    t.string   "display_name",    limit: 255,                   null: false
    t.integer  "home_network_id", limit: 4,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_group", ["display_name"], name: "index_sf_guard_group_on_display_name", using: :btree
  add_index "sf_guard_group", ["name"], name: "name", unique: true, using: :btree

  create_table "sf_guard_group_list", id: false, force: :cascade do |t|
    t.integer "group_id", limit: 4, default: 0, null: false
    t.integer "list_id",  limit: 8, default: 0, null: false
  end

  add_index "sf_guard_group_list", ["list_id"], name: "list_id", using: :btree

  create_table "sf_guard_group_permission", id: false, force: :cascade do |t|
    t.integer  "group_id",      limit: 4, default: 0, null: false
    t.integer  "permission_id", limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_group_permission", ["permission_id"], name: "permission_id", using: :btree

  create_table "sf_guard_permission", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_permission", ["name"], name: "name", unique: true, using: :btree

  create_table "sf_guard_remember_key", id: false, force: :cascade do |t|
    t.integer  "id",           limit: 4,               null: false
    t.integer  "user_id",      limit: 4
    t.string   "remember_key", limit: 32
    t.string   "ip_address",   limit: 50, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_remember_key", ["remember_key"], name: "remember_key_idx", using: :btree
  add_index "sf_guard_remember_key", ["user_id"], name: "user_id_idx", using: :btree

  create_table "sf_guard_user", force: :cascade do |t|
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

  create_table "sf_guard_user_group", id: false, force: :cascade do |t|
    t.integer  "user_id",    limit: 4, default: 0, null: false
    t.integer  "group_id",   limit: 4, default: 0, null: false
    t.boolean  "is_owner"
    t.integer  "score",      limit: 8, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_group", ["group_id"], name: "group_id", using: :btree

  create_table "sf_guard_user_permission", id: false, force: :cascade do |t|
    t.integer  "user_id",       limit: 4, default: 0, null: false
    t.integer  "permission_id", limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_permission", ["permission_id"], name: "permission_id", using: :btree

  create_table "sf_guard_user_profile", force: :cascade do |t|
    t.integer  "user_id",                    limit: 4,                          null: false
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
    t.integer  "score",                      limit: 8
    t.boolean  "show_full_name",                                default: false, null: false
    t.integer  "unread_notes",               limit: 4,          default: 0
    t.integer  "home_network_id",            limit: 4,                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_guard_user_profile", ["email"], name: "unique_email_idx", unique: true, using: :btree
  add_index "sf_guard_user_profile", ["public_name"], name: "unique_public_name_idx", unique: true, using: :btree
  add_index "sf_guard_user_profile", ["user_id", "public_name"], name: "user_id_public_name_idx", using: :btree
  add_index "sf_guard_user_profile", ["user_id"], name: "unique_user_idx", unique: true, using: :btree

  create_table "social", force: :cascade do |t|
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "social", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "sphinx_index", primary_key: "name", force: :cascade do |t|
    t.datetime "updated_at", null: false
  end

  create_table "tag", force: :cascade do |t|
    t.string   "name",             limit: 100
    t.boolean  "is_visible",                   default: true, null: false
    t.string   "triple_namespace", limit: 30
    t.string   "triple_predicate", limit: 30
    t.string   "triple_value",     limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag", ["name"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4,   null: false
    t.string   "tagable_class", limit: 255, null: false
    t.integer  "tagable_id",    limit: 4,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["tagable_class"], name: "index_taggings_on_tagable_class", using: :btree
  add_index "taggings", ["tagable_id"], name: "index_taggings_on_tagable_id", using: :btree

  create_table "task_meta", force: :cascade do |t|
    t.string   "task",       limit: 100, null: false
    t.string   "namespace",  limit: 50,  null: false
    t.string   "predicate",  limit: 50,  null: false
    t.string   "value",      limit: 50,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_meta", ["task", "namespace", "predicate"], name: "uniqueness_idx", unique: true, using: :btree

  create_table "topic_industries", force: :cascade do |t|
    t.integer "topic_id",    limit: 4
    t.integer "industry_id", limit: 4
  end

  add_index "topic_industries", ["topic_id", "industry_id"], name: "index_topic_industries_on_topic_id_and_industry_id", unique: true, using: :btree

  create_table "topic_lists", force: :cascade do |t|
    t.integer "topic_id", limit: 4
    t.integer "list_id",  limit: 4
  end

  add_index "topic_lists", ["topic_id", "list_id"], name: "index_topic_lists_on_topic_id_and_list_id", unique: true, using: :btree

  create_table "topic_maps", force: :cascade do |t|
    t.integer "topic_id", limit: 4
    t.integer "map_id",   limit: 4
  end

  add_index "topic_maps", ["topic_id", "map_id"], name: "index_topic_maps_on_topic_id_and_map_id", unique: true, using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",            limit: 255,                   null: false
    t.string   "slug",            limit: 255,                   null: false
    t.text     "description",     limit: 65535
    t.boolean  "is_deleted",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_list_id", limit: 4
    t.text     "shortcuts",       limit: 65535
  end

  add_index "topics", ["default_list_id"], name: "index_topics_on_default_list_id", using: :btree
  add_index "topics", ["name"], name: "index_topics_on_name", unique: true, using: :btree
  add_index "topics", ["slug"], name: "index_topics_on_slug", unique: true, using: :btree

  create_table "transaction", force: :cascade do |t|
    t.integer "contact1_id",     limit: 8
    t.integer "contact2_id",     limit: 8
    t.integer "district_id",     limit: 8
    t.boolean "is_lobbying"
    t.integer "relationship_id", limit: 8, null: false
  end

  add_index "transaction", ["contact1_id"], name: "contact1_id_idx", using: :btree
  add_index "transaction", ["contact2_id"], name: "contact2_id_idx", using: :btree
  add_index "transaction", ["relationship_id"], name: "relationship_id_idx", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_network_id",     limit: 4
    t.integer  "sf_guard_user_id",       limit: 4,                   null: false
    t.string   "username",               limit: 255,                 null: false
    t.string   "remember_token",         limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "newsletter"
    t.string   "chatid",                 limit: 255
    t.boolean  "is_restricted",                      default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["sf_guard_user_id"], name: "index_users_on_sf_guard_user_id", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",        limit: 255,        null: false
    t.integer  "item_id",          limit: 4,          null: false
    t.string   "event",            limit: 255,        null: false
    t.string   "whodunnit",        limit: 255
    t.text     "object",           limit: 65535
    t.datetime "created_at"
    t.text     "object_changes",   limit: 4294967295
    t.integer  "entity1_id",       limit: 4
    t.integer  "entity2_id",       limit: 4
    t.text     "association_data", limit: 4294967295
  end

  add_index "versions", ["entity1_id"], name: "index_versions_on_entity1_id", using: :btree
  add_index "versions", ["entity2_id"], name: "index_versions_on_entity2_id", using: :btree
  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "address", "address_category", column: "category_id", name: "address_ibfk_4", on_update: :cascade, on_delete: :nullify
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
  add_foreign_key "fec_filing", "relationship", name: "fec_filing_ibfk_1", on_update: :cascade, on_delete: :cascade
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
end
