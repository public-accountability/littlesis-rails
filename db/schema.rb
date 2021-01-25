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

ActiveRecord::Schema.define(version: 2021_01_23_144348) do

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "address", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "street1", limit: 100
    t.string "street2", limit: 100
    t.string "street3", limit: 100
    t.string "city", limit: 50, null: false
    t.string "county", limit: 50
    t.integer "state_id"
    t.integer "country_id"
    t.string "postal", limit: 20
    t.string "latitude", limit: 20
    t.string "longitude", limit: 20
    t.integer "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.bigint "last_user_id"
    t.string "accuracy", limit: 30
    t.string "country_name", limit: 50, null: false
    t.string "state_name", limit: 50
    t.index ["category_id"], name: "category_id_idx"
    t.index ["country_id"], name: "country_id_idx"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["last_user_id"], name: "last_user_id_idx"
    t.index ["state_id"], name: "state_id_idx"
  end

  create_table "address_category", id: :integer, default: nil, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false
  end

  create_table "address_country", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.index ["name"], name: "uniqueness_idx", unique: true
  end

  create_table "address_state", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "abbreviation", limit: 2, null: false
    t.bigint "country_id", null: false
    t.index ["country_id"], name: "country_id_idx"
    t.index ["name"], name: "uniqueness_idx", unique: true
  end

  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "street1", size: :medium
    t.text "street2", size: :medium
    t.text "street3", size: :medium
    t.text "city", size: :medium
    t.string "state"
    t.string "country"
    t.text "normalized_address", size: :medium
    t.bigint "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_addresses_on_location_id"
  end

  create_table "alias", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "name", limit: 200, null: false
    t.string "context", limit: 50
    t.integer "is_primary", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "name", "context"], name: "uniqueness_idx", unique: true
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["name"], name: "name_idx"
  end

  create_table "api_tokens", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "token", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id", unique: true
  end

  create_table "article", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "url", size: :medium, null: false
    t.string "title", limit: 200, null: false
    t.string "authors", limit: 200
    t.text "body", size: :long, null: false
    t.text "description", size: :medium
    t.integer "source_id"
    t.datetime "published_at"
    t.boolean "is_indexed", default: false, null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_user_id"
    t.boolean "is_featured", default: false, null: false
    t.boolean "is_hidden", default: false, null: false
    t.datetime "found_at", null: false
    t.index ["source_id"], name: "source_id_idx"
  end

  create_table "article_entities", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "entity_id", null: false
    t.boolean "is_featured", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "article_id"], name: "index_article_entities_on_entity_id_and_article_id", unique: true
    t.index ["is_featured"], name: "index_article_entities_on_is_featured"
  end

  create_table "article_entity", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "entity_id", null: false
    t.string "original_name", limit: 100, null: false
    t.boolean "is_verified", default: false, null: false
    t.bigint "reviewed_by_user_id"
    t.datetime "reviewed_at"
    t.index ["article_id"], name: "article_id_idx"
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "article_source", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "abbreviation", limit: 10, null: false
  end

  create_table "articles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title", null: false
    t.string "url", null: false
    t.string "snippet"
    t.datetime "published_at"
    t.string "created_by_user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "annual_profit"
    t.bigint "entity_id", null: false
    t.bigint "assets", unsigned: true
    t.bigint "marketcap", unsigned: true
    t.bigint "net_income"
    t.bigint "aum"
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "business_industry", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "industry_id", null: false
    t.index ["business_id"], name: "business_id_idx"
    t.index ["industry_id"], name: "industry_id_idx"
  end

  create_table "business_person", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sec_cik"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "candidate_district", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "district_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["candidate_id", "district_id"], name: "uniqueness_idx", unique: true
    t.index ["district_id"], name: "district_id_idx"
  end

  create_table "cmp_entities", id: :integer, charset: "utf8", force: :cascade do |t|
    t.bigint "entity_id"
    t.integer "cmp_id"
    t.integer "entity_type", limit: 1, null: false, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "strata", limit: 1, unsigned: true
    t.index ["cmp_id"], name: "index_cmp_entities_on_cmp_id", unique: true
    t.index ["entity_id"], name: "index_cmp_entities_on_entity_id", unique: true
  end

  create_table "cmp_relationships", charset: "utf8", force: :cascade do |t|
    t.string "cmp_affiliation_id", null: false
    t.integer "cmp_org_id", null: false
    t.integer "cmp_person_id", null: false
    t.bigint "relationship_id"
    t.integer "status19", limit: 1
    t.index ["cmp_affiliation_id"], name: "index_cmp_relationships_on_cmp_affiliation_id", unique: true
  end

  create_table "common_names", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_common_names_on_name", unique: true
  end

  create_table "couple", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "partner1_id"
    t.integer "partner2_id"
    t.index ["entity_id"], name: "index_couple_on_entity_id"
    t.index ["partner1_id"], name: "index_couple_on_partner1_id"
    t.index ["partner2_id"], name: "index_couple_on_partner2_id"
  end

  create_table "custom_key", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.text "value", size: :long
    t.string "description", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "object_model", limit: 50, null: false
    t.bigint "object_id", null: false
    t.index ["object_model", "object_id", "name", "value"], name: "object_name_value_idx", unique: true, length: { value: 100 }
    t.index ["object_model", "object_id", "name"], name: "object_name_idx", unique: true
    t.index ["object_model", "object_id"], name: "object_idx"
  end

  create_table "dashboard_bulletins", charset: "utf8", force: :cascade do |t|
    t.text "markdown"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.index ["created_at"], name: "index_dashboard_bulletins_on_created_at"
  end

  create_table "degree", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "abbreviation", limit: 10
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :medium, null: false
    t.text "last_error", size: :medium
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.string "url_hash", limit: 40
    t.string "publication_date", limit: 10
    t.integer "ref_type", default: 1, null: false
    t.text "excerpt", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url_hash"], name: "index_documents_on_url_hash", unique: true
  end

  create_table "donation", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "bundler_id"
    t.bigint "relationship_id", null: false
    t.index ["bundler_id"], name: "bundler_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "edited_entities", charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "version_id", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_edited_entities_on_created_at"
    t.index ["entity_id", "version_id", "user_id"], name: "index_edited_entities_on_entity_id_and_version_id_and_user_id", unique: true
    t.index ["entity_id", "version_id"], name: "index_edited_entities_on_entity_id_and_version_id", unique: true
  end

  create_table "education", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "degree_id"
    t.string "field", limit: 30
    t.boolean "is_dropout"
    t.bigint "relationship_id", null: false
    t.index ["degree_id"], name: "degree_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "elected_representative", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "bioguide_id", limit: 20
    t.string "govtrack_id", limit: 20
    t.string "crp_id", limit: 20
    t.string "pvs_id", limit: 20
    t.string "watchdog_id", limit: 50
    t.bigint "entity_id", null: false
    t.text "fec_ids"
    t.index ["crp_id"], name: "crp_id_idx"
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "email", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "address", limit: 60, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.integer "last_user_id"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["last_user_id"], name: "last_user_id_idx"
  end

  create_table "entity", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 200
    t.string "blurb", limit: 200
    t.text "summary", size: :long
    t.text "notes", size: :long
    t.string "website", limit: 100
    t.bigint "parent_id"
    t.string "primary_ext", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
    t.boolean "is_deleted", default: false, null: false
    t.integer "last_user_id"
    t.integer "merged_id"
    t.boolean "delta", default: true, null: false
    t.bigint "link_count", default: 0, null: false
    t.index ["blurb"], name: "blurb_idx"
    t.index ["created_at"], name: "created_at_idx"
    t.index ["delta"], name: "index_entity_on_delta"
    t.index ["last_user_id"], name: "last_user_id_idx"
    t.index ["name", "blurb", "website"], name: "search_idx"
    t.index ["name"], name: "name_idx"
    t.index ["parent_id"], name: "parent_id_idx"
    t.index ["updated_at"], name: "updated_at_idx"
    t.index ["website"], name: "website_idx"
  end

  create_table "entity_fields", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "entity_id"
    t.integer "field_id"
    t.string "value", null: false
    t.boolean "is_admin", default: false
    t.index ["entity_id", "field_id"], name: "index_entity_fields_on_entity_id_and_field_id", unique: true
  end

  create_table "extension_definition", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "display_name", limit: 50, null: false
    t.boolean "has_fields", default: false, null: false
    t.bigint "parent_id"
    t.bigint "tier"
    t.index ["name"], name: "name_idx"
    t.index ["parent_id"], name: "parent_id_idx"
    t.index ["tier"], name: "tier_idx"
  end

  create_table "extension_record", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.bigint "definition_id", null: false
    t.integer "last_user_id"
    t.index ["definition_id"], name: "definition_id_idx"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["last_user_id"], name: "last_user_id_idx"
  end

  create_table "external_data", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "dataset", limit: 1, null: false
    t.string "dataset_id", null: false
    t.text "data", size: :long, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset", "dataset_id"], name: "index_external_data_on_dataset_and_dataset_id", unique: true
    t.index ["dataset"], name: "index_external_data_on_dataset"
  end

  create_table "external_data_fec_candidates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cand_id", null: false
    t.text "cand_name"
    t.string "cand_pty_affiliation"
    t.integer "cand_election_yr", limit: 1
    t.string "cand_office_st", limit: 2
    t.string "cand_office", limit: 1
    t.string "cand_office_district", limit: 2
    t.string "cand_ici", limit: 1
    t.string "cand_status", limit: 1
    t.text "cand_pcc"
    t.text "cand_st1"
    t.text "cand_st2"
    t.text "cand_city"
    t.string "cand_st", limit: 2
    t.string "cand_zip"
    t.integer "fec_year", limit: 2, null: false
    t.index ["cand_id", "fec_year"], name: "index_external_data_fec_candidates_on_cand_id_and_fec_year", unique: true
  end

  create_table "external_data_fec_committees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cmte_id", null: false
    t.text "cmte_nm"
    t.text "tres_nm"
    t.text "cmte_st1"
    t.text "cmte_st2"
    t.text "cmte_city"
    t.string "cmte_st", limit: 2
    t.string "cmte_zip"
    t.string "cmte_dsgn", limit: 1
    t.string "cmte_tp", limit: 2
    t.text "cmte_pty_affiliation"
    t.string "cmte_filing_freq", limit: 1
    t.string "org_tp", limit: 1
    t.text "connected_org_nm"
    t.string "cand_id"
    t.integer "fec_year", limit: 2, null: false
    t.index ["cmte_id", "fec_year"], name: "index_external_data_fec_committees_on_cmte_id_and_fec_year", unique: true
  end

  create_table "external_data_fec_contributions", primary_key: "sub_id", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cmte_id", null: false
    t.text "amndt_ind"
    t.text "rpt_tp"
    t.text "transaction_pgi"
    t.string "image_num"
    t.string "transaction_tp"
    t.string "entity_tp"
    t.text "name"
    t.text "city"
    t.text "state"
    t.text "zip_code"
    t.text "employer"
    t.text "occupation"
    t.text "transaction_dt"
    t.decimal "transaction_amt", precision: 10
    t.string "other_id"
    t.string "tran_id"
    t.integer "file_num"
    t.text "memo_cd"
    t.text "memo_text"
    t.integer "fec_year", null: false
  end

  create_table "external_data_nycc", primary_key: "district", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "personid", limit: 2, null: false
    t.text "council_district"
    t.text "last_name"
    t.text "first_name"
    t.text "full_name"
    t.text "photo_url"
    t.text "twitter"
    t.text "email"
    t.text "party"
    t.text "website"
    t.text "gender"
    t.text "title"
    t.text "district_office"
    t.text "legislative_office"
  end

  create_table "external_data_nys_disclosures", primary_key: "dataset_id", id: :string, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "filer_id", null: false
    t.string "freport_id"
    t.string "transaction_code"
    t.string "e_year"
    t.string "t3_trid"
    t.date "date1_10"
    t.date "date2_12"
    t.string "contrib_code_20"
    t.string "contrib_type_code_25"
    t.string "corp_30"
    t.string "first_name_40"
    t.string "mid_init_42"
    t.string "last_name_44"
    t.string "addr_1_50"
    t.string "city_52"
    t.string "state_54"
    t.string "zip_56"
    t.string "check_no_60"
    t.string "check_date_62"
    t.float "amount_70"
    t.float "amount2_72"
    t.string "description_80"
    t.string "other_recpt_code_90"
    t.string "purpose_code1_100"
    t.string "purpose_code2_1"
    t.string "explanation_110"
    t.string "xfer_type_120"
    t.string "chkbox_130"
    t.string "crerec_uid"
    t.datetime "crerec_date"
    t.index ["dataset_id"], name: "index_external_data_nys_disclosures_on_dataset_id"
    t.index ["date1_10"], name: "index_external_data_nys_disclosures_on_date1_10"
    t.index ["filer_id"], name: "index_external_data_nys_disclosures_on_filer_id"
  end

  create_table "external_data_nys_filers", primary_key: "filer_id", id: :string, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "name"
    t.string "filer_type"
    t.string "status"
    t.string "committee_type"
    t.string "office"
    t.string "district"
    t.text "treas_first_name"
    t.text "treas_last_name"
    t.text "address"
    t.text "city"
    t.string "state"
    t.string "zip"
  end

  create_table "external_entities", charset: "latin1", force: :cascade do |t|
    t.integer "dataset", limit: 1, null: false
    t.text "match_data", size: :long
    t.bigint "external_data_id"
    t.bigint "entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "priority", limit: 1, default: 0, null: false
    t.string "primary_ext", limit: 6
    t.index ["entity_id"], name: "index_external_entities_on_entity_id"
    t.index ["external_data_id"], name: "index_external_entities_on_external_data_id"
    t.index ["priority"], name: "index_external_entities_on_priority"
  end

  create_table "external_links", charset: "utf8", force: :cascade do |t|
    t.integer "link_type", limit: 1, null: false, unsigned: true
    t.bigint "entity_id", null: false
    t.string "link_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_external_links_on_entity_id"
    t.index ["link_type", "link_id"], name: "index_external_links_on_link_type_and_link_id", unique: true
  end

  create_table "external_relationships", charset: "latin1", force: :cascade do |t|
    t.bigint "external_data_id", null: false
    t.bigint "relationship_id"
    t.integer "dataset", limit: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "entity1_id"
    t.bigint "entity2_id"
    t.integer "category_id", limit: 2, null: false
    t.index ["external_data_id"], name: "fk_rails_5025111f98"
    t.index ["relationship_id"], name: "fk_rails_632542e80c"
  end

  create_table "family", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.boolean "is_nonbiological"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "fields", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name", null: false
    t.string "type", default: "string", null: false
    t.index ["name"], name: "index_fields_on_name", unique: true
  end

  create_table "generic", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "government_body", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.boolean "is_federal"
    t.bigint "state_id"
    t.string "city", limit: 50
    t.string "county", limit: 50
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["state_id"], name: "state_id_idx"
  end

  create_table "help_pages", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
    t.text "markdown", size: :medium
    t.integer "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_help_pages_on_name", unique: true
  end

  create_table "hierarchy", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "image", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id"
    t.string "filename", limit: 100, null: false
    t.text "caption", size: :long
    t.boolean "is_featured", default: false, null: false
    t.boolean "is_free"
    t.string "url", limit: 400
    t.bigint "width"
    t.bigint "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "has_square", default: false, null: false
    t.integer "address_id"
    t.string "raw_address", limit: 200
    t.boolean "has_face", default: false, null: false
    t.integer "user_id"
    t.index ["address_id"], name: "index_image_on_address_id"
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "industries", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "industry_id", null: false
    t.string "sector_name", null: false
    t.index ["industry_id"], name: "index_industries_on_industry_id", unique: true
  end

  create_table "industry", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "context", limit: 30
    t.string "code", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity1_id", null: false
    t.bigint "entity2_id", null: false
    t.bigint "category_id", null: false
    t.bigint "relationship_id", null: false
    t.boolean "is_reverse", null: false
    t.index ["category_id"], name: "category_id_idx"
    t.index ["entity1_id", "category_id", "is_reverse"], name: "index_link_on_entity1_id_and_category_id_and_is_reverse"
    t.index ["entity1_id", "category_id"], name: "index_link_on_entity1_id_and_category_id"
    t.index ["entity1_id"], name: "entity1_id_idx"
    t.index ["entity2_id"], name: "entity2_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "lobby_filing", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "federal_filing_id", limit: 50, null: false
    t.bigint "amount"
    t.bigint "year"
    t.string "period", limit: 100
    t.string "report_type", limit: 100
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
  end

  create_table "lobby_filing_lobby_issue", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.text "specific_issue", size: :long
    t.index ["issue_id"], name: "issue_id_idx"
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx"
  end

  create_table "lobby_filing_lobbyist", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "lobbyist_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx"
    t.index ["lobbyist_id"], name: "lobbyist_id_idx"
  end

  create_table "lobby_filing_relationship", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "lobby_filing_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "lobby_issue", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "lobbying", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "lobbyist", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "lda_registrant_id"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "city", size: :medium
    t.text "country", size: :medium
    t.text "subregion", size: :medium
    t.integer "region", limit: 1
    t.decimal "lat", precision: 10
    t.decimal "lng", precision: 10
    t.bigint "entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entity_id"], name: "index_locations_on_entity_id"
    t.index ["region"], name: "index_locations_on_region"
  end

  create_table "ls_list", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description", size: :long
    t.boolean "is_ranked", default: false, null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_featured", default: false, null: false
    t.string "display_name", limit: 50
    t.bigint "featured_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "last_user_id"
    t.boolean "is_deleted", default: false, null: false
    t.string "custom_field_name", limit: 100
    t.boolean "delta", default: true, null: false
    t.integer "creator_user_id"
    t.string "short_description"
    t.integer "access", limit: 1, default: 0, null: false
    t.integer "entity_count", default: 0
    t.string "sort_by"
    t.index ["delta"], name: "index_ls_list_on_delta"
    t.index ["featured_list_id"], name: "featured_list_id"
    t.index ["last_user_id"], name: "last_user_id_idx"
    t.index ["name"], name: "index_ls_list_on_name"
  end

  create_table "ls_list_entity", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "entity_id", null: false
    t.bigint "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "last_user_id"
    t.text "custom_field"
    t.index ["created_at"], name: "created_at_idx"
    t.index ["entity_id", "list_id"], name: "index_ls_list_entity_on_entity_id_and_list_id"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["last_user_id"], name: "last_user_id_idx"
    t.index ["list_id"], name: "list_id_idx"
  end

  create_table "map_annotations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "map_id", null: false
    t.integer "order", null: false
    t.string "title"
    t.text "description"
    t.string "highlighted_entity_ids"
    t.string "highlighted_rel_ids"
    t.string "highlighted_text_ids"
    t.index ["map_id"], name: "index_map_annotations_on_map_id"
  end

  create_table "membership", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "dues"
    t.bigint "relationship_id", null: false
    t.text "elected_term"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "network_map", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "entity_ids", limit: 5000
    t.string "rel_ids", limit: 5000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.string "title", limit: 100
    t.text "description", size: :long
    t.integer "width", null: false
    t.integer "height", null: false
    t.boolean "is_featured", default: false, null: false
    t.string "zoom", default: "1", null: false
    t.boolean "is_private", default: false, null: false
    t.string "thumbnail"
    t.boolean "delta", default: true, null: false
    t.text "index_data", size: :long
    t.string "secret"
    t.text "graph_data", size: :medium
    t.text "annotations_data"
    t.integer "annotations_count", default: 0, null: false
    t.boolean "list_sources", default: false, null: false
    t.boolean "is_cloneable", default: true, null: false
    t.integer "oligrapher_version", limit: 1, default: 2, null: false
    t.text "editors"
    t.text "settings"
    t.text "screenshot", size: :medium
    t.index ["delta"], name: "index_network_map_on_delta"
    t.index ["user_id"], name: "user_id_idx"
  end

  create_table "ny_disclosures", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "filer_id", limit: 10, null: false
    t.string "report_id"
    t.string "transaction_code", limit: 1, null: false
    t.string "e_year", limit: 4, null: false
    t.bigint "transaction_id", null: false
    t.date "schedule_transaction_date"
    t.date "original_date"
    t.string "contrib_code", limit: 4
    t.string "contrib_type_code", limit: 1
    t.string "corp_name"
    t.string "first_name"
    t.string "mid_init"
    t.string "last_name"
    t.string "address"
    t.string "city"
    t.string "state", limit: 2
    t.string "zip", limit: 5
    t.string "check_number"
    t.string "check_date"
    t.float "amount1"
    t.float "amount2"
    t.string "description"
    t.string "other_recpt_code"
    t.string "purpose_code1"
    t.string "purpose_code2"
    t.string "explanation"
    t.string "transfer_type", limit: 1
    t.string "bank_loan_check_box", limit: 1
    t.string "crerec_uid"
    t.datetime "crerec_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
    t.index ["contrib_code"], name: "index_ny_disclosures_on_contrib_code"
    t.index ["delta"], name: "index_ny_disclosures_on_delta"
    t.index ["e_year"], name: "index_ny_disclosures_on_e_year"
    t.index ["filer_id", "report_id", "transaction_id", "schedule_transaction_date", "e_year"], name: "index_filer_report_trans_date_e_year", length: { report_id: 191 }
    t.index ["filer_id"], name: "index_ny_disclosures_on_filer_id"
    t.index ["original_date"], name: "index_ny_disclosures_on_original_date"
  end

  create_table "ny_filer_entities", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "ny_filer_id"
    t.integer "entity_id"
    t.boolean "is_committee"
    t.integer "cmte_entity_id"
    t.string "e_year", limit: 4
    t.string "filer_id"
    t.string "office"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_entity_id"], name: "index_ny_filer_entities_on_cmte_entity_id"
    t.index ["entity_id"], name: "index_ny_filer_entities_on_entity_id"
    t.index ["filer_id"], name: "index_ny_filer_entities_on_filer_id"
    t.index ["is_committee"], name: "index_ny_filer_entities_on_is_committee"
    t.index ["ny_filer_id"], name: "index_ny_filer_entities_on_ny_filer_id"
  end

  create_table "ny_filers", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "filer_id", null: false
    t.string "name"
    t.string "filer_type"
    t.string "status"
    t.string "committee_type"
    t.integer "office"
    t.integer "district"
    t.string "treas_first_name"
    t.string "treas_last_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["filer_id"], name: "index_ny_filers_on_filer_id", unique: true
    t.index ["filer_type"], name: "index_ny_filers_on_filer_type"
  end

  create_table "ny_matches", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "ny_disclosure_id"
    t.integer "donor_id"
    t.integer "recip_id"
    t.integer "relationship_id"
    t.integer "matched_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["donor_id"], name: "index_ny_matches_on_donor_id"
    t.index ["ny_disclosure_id"], name: "index_ny_matches_on_ny_disclosure_id", unique: true
    t.index ["recip_id"], name: "index_ny_matches_on_recip_id"
    t.index ["relationship_id"], name: "index_ny_matches_on_relationship_id"
  end

  create_table "object_tag", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "object_model", limit: 50, null: false
    t.bigint "object_id", null: false
    t.integer "last_user_id"
    t.index ["last_user_id"], name: "last_user_id_idx"
    t.index ["object_model", "object_id", "tag_id"], name: "uniqueness_idx", unique: true
    t.index ["object_model", "object_id"], name: "object_idx"
    t.index ["tag_id"], name: "tag_id_idx"
  end

  create_table "org", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.string "name_nick", limit: 100
    t.bigint "employees"
    t.bigint "revenue"
    t.string "fedspending_id", limit: 10
    t.string "lda_registrant_id", limit: 10
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "os_candidates", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "cycle", null: false
    t.string "feccandid", null: false
    t.string "crp_id", null: false
    t.string "name"
    t.string "party", limit: 1
    t.string "distid_runfor"
    t.string "distid_current"
    t.boolean "currcand"
    t.boolean "cyclecand"
    t.string "crpico", limit: 1
    t.string "recipcode", limit: 2
    t.string "nopacs", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["crp_id"], name: "index_os_candidates_on_crp_id"
    t.index ["cycle", "crp_id"], name: "index_os_candidates_on_cycle_and_crp_id"
    t.index ["feccandid"], name: "index_os_candidates_on_feccandid"
  end

  create_table "os_category", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "category_id", limit: 10, null: false
    t.string "category_name", limit: 100, null: false
    t.string "industry_id", limit: 10, null: false
    t.string "industry_name", limit: 100, null: false
    t.string "sector_name", limit: 100, null: false
    t.index ["category_id"], name: "unique_id_idx", unique: true
    t.index ["category_name"], name: "unique_name_idx", unique: true
  end

  create_table "os_committees", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "cycle", limit: 4, null: false
    t.string "cmte_id", null: false
    t.string "name"
    t.string "affiliate"
    t.string "ultorg"
    t.string "recipid"
    t.string "recipcode", limit: 2
    t.string "feccandid"
    t.string "party", limit: 1
    t.string "primcode", limit: 5
    t.string "source"
    t.boolean "sensitive"
    t.boolean "foreign"
    t.boolean "active_in_cycle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_id", "cycle"], name: "index_os_committees_on_cmte_id_and_cycle"
    t.index ["cmte_id"], name: "index_os_committees_on_cmte_id"
    t.index ["recipid"], name: "index_os_committees_on_recipid"
  end

  create_table "os_donations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "cycle", limit: 4, null: false
    t.string "fectransid", limit: 19, null: false
    t.string "contribid", limit: 12
    t.string "contrib"
    t.string "recipid", limit: 9
    t.string "orgname"
    t.string "ultorg"
    t.string "realcode", limit: 5
    t.date "date"
    t.integer "amount"
    t.string "street"
    t.string "city"
    t.string "state", limit: 2
    t.string "zip", limit: 5
    t.string "recipcode", limit: 2
    t.string "transactiontype", limit: 3
    t.string "cmteid", limit: 9
    t.string "otherid", limit: 9
    t.string "gender", limit: 1
    t.string "microfilm", limit: 30
    t.string "occupation"
    t.string "employer"
    t.string "source", limit: 5
    t.string "fec_cycle_id", limit: 24, null: false
    t.string "name_last"
    t.string "name_first"
    t.string "name_middle"
    t.string "name_suffix"
    t.string "name_prefix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["amount"], name: "index_os_donations_on_amount"
    t.index ["contribid"], name: "index_os_donations_on_contribid"
    t.index ["cycle"], name: "index_os_donations_on_cycle"
    t.index ["date"], name: "index_os_donations_on_date"
    t.index ["fec_cycle_id"], name: "index_os_donations_on_fec_cycle_id", unique: true
    t.index ["fectransid", "cycle"], name: "index_os_donations_on_fectransid_and_cycle"
    t.index ["fectransid"], name: "index_os_donations_on_fectransid"
    t.index ["microfilm"], name: "index_os_donations_on_microfilm"
    t.index ["name_last", "name_first"], name: "index_os_donations_on_name_last_and_name_first"
    t.index ["realcode", "amount"], name: "index_os_donations_on_realcode_and_amount"
    t.index ["realcode"], name: "index_os_donations_on_realcode"
    t.index ["recipid", "amount"], name: "index_os_donations_on_recipid_and_amount"
    t.index ["recipid"], name: "index_os_donations_on_recipid"
    t.index ["state"], name: "index_os_donations_on_state"
    t.index ["zip"], name: "index_os_donations_on_zip"
  end

  create_table "os_entity_category", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "category_id", limit: 10, null: false
    t.string "source", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "category_id_idx"
    t.index ["entity_id", "category_id"], name: "uniqueness_idx", unique: true
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "os_entity_donor", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "donor_id", limit: 12, collation: "utf8_general_ci"
    t.bigint "match_code"
    t.boolean "is_verified", default: false, null: false
    t.bigint "reviewed_by_user_id"
    t.boolean "is_processed", default: false, null: false
    t.boolean "is_synced", default: true, null: false
    t.datetime "reviewed_at"
    t.bigint "locked_by_user_id"
    t.datetime "locked_at"
    t.index ["entity_id", "donor_id"], name: "entity_donor_idx", unique: true
    t.index ["is_synced"], name: "is_synced_idx"
    t.index ["locked_at"], name: "locked_at_idx"
    t.index ["reviewed_at"], name: "reviewed_at_idx"
  end

  create_table "os_matches", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "os_donation_id", null: false
    t.integer "donation_id"
    t.integer "donor_id", null: false
    t.integer "recip_id"
    t.integer "relationship_id"
    t.integer "matched_by"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cmte_id"
    t.index ["cmte_id"], name: "index_os_matches_on_cmte_id"
    t.index ["donor_id"], name: "index_os_matches_on_donor_id"
    t.index ["os_donation_id"], name: "index_os_matches_on_os_donation_id"
    t.index ["recip_id"], name: "index_os_matches_on_recip_id"
    t.index ["relationship_id"], name: "index_os_matches_on_relationship_id"
  end

  create_table "ownership", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "percent_stake"
    t.bigint "shares"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "pages", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
    t.text "markdown", size: :medium
    t.integer "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_pages_on_name", unique: true
  end

  create_table "permission_passes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "event_name"
    t.string "token", null: false
    t.datetime "valid_from", null: false
    t.datetime "valid_to", null: false
    t.text "abilities", size: :medium, null: false
    t.integer "creator_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "person", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name_last", limit: 50, null: false
    t.string "name_first", limit: 50, null: false
    t.string "name_middle", limit: 50
    t.string "name_prefix", limit: 30
    t.string "name_suffix", limit: 30
    t.string "name_nick", limit: 30
    t.string "birthplace", limit: 50
    t.bigint "gender_id"
    t.bigint "party_id"
    t.boolean "is_independent"
    t.bigint "net_worth"
    t.bigint "entity_id", null: false
    t.string "name_maiden", limit: 50
    t.text "nationality"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["gender_id"], name: "gender_id_idx"
    t.index ["name_last", "name_first", "name_middle"], name: "name_idx"
    t.index ["party_id"], name: "party_id_idx"
  end

  create_table "phone", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "number", limit: 20, null: false
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.integer "last_user_id"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["last_user_id"], name: "last_user_id_idx"
  end

  create_table "political_candidate", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.boolean "is_federal"
    t.boolean "is_state"
    t.boolean "is_local"
    t.string "pres_fec_id", limit: 20
    t.string "senate_fec_id", limit: 20
    t.string "house_fec_id", limit: 20
    t.string "crp_id", limit: 20
    t.bigint "entity_id", null: false
    t.index ["crp_id"], name: "crp_id_idx"
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["house_fec_id"], name: "house_fec_id_idx"
    t.index ["pres_fec_id"], name: "pres_fec_id_idx"
    t.index ["senate_fec_id"], name: "senate_fec_id_idx"
  end

  create_table "political_district", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "state_id"
    t.string "federal_district", limit: 2
    t.string "state_district", limit: 2
    t.string "local_district", limit: 2
    t.index ["state_id"], name: "state_id_idx"
  end

  create_table "political_fundraising", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "fec_id", limit: 20
    t.bigint "type_id"
    t.bigint "state_id"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
    t.index ["fec_id"], name: "fec_id_idx"
    t.index ["state_id"], name: "state_id_idx"
    t.index ["type_id"], name: "type_id_idx"
  end

  create_table "political_fundraising_type", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "position", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.boolean "is_board"
    t.boolean "is_executive"
    t.boolean "is_employee"
    t.bigint "compensation"
    t.bigint "boss_id"
    t.bigint "relationship_id", null: false
    t.index ["boss_id"], name: "boss_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "professional", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "public_company", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "ticker", limit: 10
    t.bigint "sec_cik"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "references", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "referenceable_id", null: false
    t.string "referenceable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referenceable_id", "referenceable_type"], name: "index_references_on_referenceable_id_and_referenceable_type"
  end

  create_table "relationship", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "entity1_id", null: false
    t.bigint "entity2_id", null: false
    t.bigint "category_id", null: false
    t.string "description1", limit: 100
    t.string "description2", limit: 100
    t.bigint "amount"
    t.string "currency"
    t.text "goods", size: :long
    t.bigint "filings"
    t.text "notes", size: :long
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
    t.boolean "is_deleted", default: false, null: false
    t.integer "last_user_id"
    t.bigint "amount2"
    t.boolean "is_gte", default: false, null: false
    t.index ["category_id"], name: "category_id_idx"
    t.index ["entity1_id", "category_id"], name: "entity1_category_idx"
    t.index ["entity1_id", "entity2_id"], name: "entity_idx"
    t.index ["entity1_id"], name: "entity1_id_idx"
    t.index ["entity2_id"], name: "entity2_id_idx"
    t.index ["is_deleted", "entity2_id", "category_id", "amount"], name: "index_relationship_is_d_e2_cat_amount"
    t.index ["last_user_id"], name: "last_user_id_idx"
  end

  create_table "relationship_category", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "display_name", limit: 30, null: false
    t.string "default_description", limit: 50
    t.text "entity1_requirements"
    t.text "entity2_requirements"
    t.boolean "has_fields", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "uniqueness_idx", unique: true
  end

  create_table "representative", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "bioguide_id", limit: 20
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "representative_district", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "representative_id", null: false
    t.bigint "district_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id"], name: "district_id_idx"
    t.index ["representative_id", "district_id"], name: "uniqueness_idx", unique: true
    t.index ["representative_id"], name: "representative_id_idx"
  end

  create_table "school", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "endowment"
    t.bigint "students"
    t.bigint "faculty"
    t.bigint "tuition"
    t.boolean "is_private"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "entity_id_idx"
  end

  create_table "social", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "sphinx_index", primary_key: "name", id: { type: :string, limit: 50 }, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "updated_at", null: false
  end

  create_table "swamp_tips", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tag", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 100
    t.boolean "is_visible", default: true, null: false
    t.string "triple_namespace", limit: 30
    t.string "triple_predicate", limit: 30
    t.string "triple_value", limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "uniqueness_idx", unique: true
  end

  create_table "taggings", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.string "tagable_class", null: false
    t.integer "tagable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_user_id", default: 1, null: false
    t.index ["last_user_id"], name: "fk_rails_5607f02466"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["tagable_class"], name: "index_taggings_on_tagable_class"
    t.index ["tagable_id"], name: "index_taggings_on_tagable_id"
  end

  create_table "tags", id: :integer, charset: "latin1", force: :cascade do |t|
    t.boolean "restricted", default: false
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "toolkit_pages", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
    t.text "markdown", size: :medium
    t.integer "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_toolkit_pages_on_name", unique: true
  end

  create_table "transaction", charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "contact1_id"
    t.bigint "contact2_id"
    t.bigint "district_id"
    t.boolean "is_lobbying"
    t.bigint "relationship_id", null: false
    t.index ["contact1_id"], name: "contact1_id_idx"
    t.index ["contact2_id"], name: "contact2_id_idx"
    t.index ["relationship_id"], name: "relationship_id_idx"
  end

  create_table "unmatched_ny_filers", charset: "utf8", force: :cascade do |t|
    t.bigint "ny_filer_id", null: false
    t.integer "disclosure_count", null: false
    t.index ["disclosure_count"], name: "index_unmatched_ny_filers_on_disclosure_count"
    t.index ["ny_filer_id"], name: "index_unmatched_ny_filers_on_ny_filer_id", unique: true
  end

  create_table "user_permissions", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "user_id"
    t.string "resource_type", null: false
    t.text "access_rules", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "resource_type"], name: "index_user_permissions_on_user_id_and_resource_type"
  end

  create_table "user_profiles", charset: "utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name_first"
    t.string "name_last"
    t.string "location"
    t.text "reason", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "user_requests", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.integer "user_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "source_id"
    t.integer "dest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reviewer_id"
    t.integer "entity_id"
    t.text "justification"
    t.integer "list_id"
    t.index ["user_id"], name: "index_user_requests_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "default_network_id"
    t.string "username", null: false
    t.string "remember_token"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean "newsletter"
    t.boolean "is_restricted", default: false
    t.boolean "map_the_power"
    t.text "about_me"
    t.integer "role", limit: 1, default: 0, null: false
    t.text "abilities"
    t.text "settings"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.text "object_changes", size: :long
    t.integer "entity1_id"
    t.integer "entity2_id"
    t.text "association_data", size: :long
    t.bigint "other_id"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["entity1_id"], name: "index_versions_on_entity1_id"
    t.index ["entity2_id"], name: "index_versions_on_entity2_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  create_table "web_requests", charset: "latin1", force: :cascade do |t|
    t.string "remote_address"
    t.datetime "time"
    t.string "host"
    t.string "http_method"
    t.text "uri"
    t.integer "status", limit: 2
    t.integer "body_bytes"
    t.float "request_time"
    t.text "referer"
    t.text "user_agent"
    t.string "request_id", null: false
    t.index ["request_id"], name: "index_web_requests_on_request_id", unique: true
    t.index ["time"], name: "idx_web_requests_time"
    t.index ["time"], name: "index_web_requests_on_time"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "address", "address_category", column: "category_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "address", "entity", name: "address_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "addresses", "locations"
  add_foreign_key "alias", "entity", name: "alias_ibfk_1", on_update: :cascade, on_delete: :cascade
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
  add_foreign_key "entity", "entity", column: "parent_id", name: "entity_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "entity", "users", column: "last_user_id", on_update: :cascade
  add_foreign_key "extension_definition", "extension_definition", column: "parent_id", name: "extension_definition_ibfk_1", on_update: :cascade
  add_foreign_key "extension_record", "entity", name: "extension_record_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "extension_record", "extension_definition", column: "definition_id", name: "extension_record_ibfk_2", on_update: :cascade
  add_foreign_key "external_relationships", "external_data", on_delete: :cascade
  add_foreign_key "external_relationships", "relationship", on_delete: :nullify
  add_foreign_key "family", "relationship", name: "family_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "government_body", "address_state", column: "state_id", name: "government_body_ibfk_1", on_update: :cascade
  add_foreign_key "government_body", "entity", name: "government_body_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "image", "entity", name: "image_ibfk_1", on_update: :cascade, on_delete: :cascade
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
  add_foreign_key "ls_list_entity", "entity", name: "ls_list_entity_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ls_list_entity", "ls_list", column: "list_id", name: "ls_list_entity_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "membership", "relationship", name: "membership_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "object_tag", "tag", name: "object_tag_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "org", "entity", name: "org_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "os_entity_category", "entity", name: "os_entity_category_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ownership", "relationship", name: "ownership_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "person", "entity", column: "party_id", name: "person_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "person", "entity", name: "person_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "phone", "entity", name: "phone_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "political_candidate", "entity", name: "political_candidate_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "political_district", "address_state", column: "state_id", name: "political_district_ibfk_1", on_update: :cascade
  add_foreign_key "political_fundraising", "address_state", column: "state_id", name: "political_fundraising_ibfk_2", on_update: :cascade
  add_foreign_key "political_fundraising", "entity", name: "political_fundraising_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "political_fundraising", "political_fundraising_type", column: "type_id", name: "political_fundraising_ibfk_1", on_update: :cascade
  add_foreign_key "position", "entity", column: "boss_id", name: "position_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "position", "relationship", name: "position_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "professional", "relationship", name: "professional_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "public_company", "entity", name: "public_company_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "entity", column: "entity1_id", name: "relationship_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "entity", column: "entity2_id", name: "relationship_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "relationship_category", column: "category_id", name: "relationship_ibfk_3", on_update: :cascade
  add_foreign_key "relationship", "users", column: "last_user_id", on_update: :cascade
  add_foreign_key "representative", "entity", name: "representative_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "elected_representative", column: "representative_id", name: "representative_district_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "political_district", column: "district_id", name: "representative_district_ibfk_4", on_update: :cascade, on_delete: :cascade
  add_foreign_key "school", "entity", name: "school_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "social", "relationship", name: "social_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "taggings", "users", column: "last_user_id", on_update: :cascade
  add_foreign_key "transaction", "entity", column: "contact1_id", name: "transaction_ibfk_3", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "entity", column: "contact2_id", name: "transaction_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "relationship", name: "transaction_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_requests", "users"
end
