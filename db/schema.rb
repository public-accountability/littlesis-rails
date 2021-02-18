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

ActiveRecord::Schema.define(version: 2021_02_04_151130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "record_type", limit: 255, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "idx_16388_index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "idx_16388_index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "filename", limit: 255, null: false
    t.string "content_type", limit: 255
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 255, null: false
    t.datetime "created_at", null: false
    t.string "service_name", limit: 255, null: false
    t.index ["key"], name: "idx_16397_index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", limit: 255, null: false
    t.index ["blob_id", "variation_digest"], name: "idx_16407_index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "address", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "street1", limit: 100
    t.string "street2", limit: 100
    t.string "street3", limit: 100
    t.string "city", limit: 50, null: false
    t.string "county", limit: 50
    t.bigint "state_id"
    t.bigint "country_id"
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
    t.index ["category_id"], name: "idx_16413_category_id_idx"
    t.index ["country_id"], name: "idx_16413_country_id_idx"
    t.index ["entity_id"], name: "idx_16413_entity_id_idx"
    t.index ["last_user_id"], name: "idx_16413_last_user_id_idx"
    t.index ["state_id"], name: "idx_16413_state_id_idx"
  end

  create_table "address_category", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 20, null: false
  end

  create_table "address_country", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.index ["name"], name: "idx_16446_uniqueness_idx", unique: true
  end

  create_table "address_state", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "abbreviation", limit: 2, null: false
    t.bigint "country_id", null: false
    t.index ["country_id"], name: "idx_16452_country_id_idx"
    t.index ["name"], name: "idx_16452_uniqueness_idx", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.text "street1"
    t.text "street2"
    t.text "street3"
    t.text "city"
    t.string "state", limit: 255
    t.string "country", limit: 255
    t.text "normalized_address"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "idx_16432_index_addresses_on_location_id"
  end

  create_table "alias", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "name", limit: 200, null: false
    t.string "context", limit: 50
    t.bigint "is_primary", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "name", "context"], name: "idx_16458_uniqueness_idx", unique: true
    t.index ["entity_id"], name: "idx_16458_entity_id_idx"
    t.index ["name"], name: "idx_16458_name_idx"
  end

  create_table "api_tokens", id: :serial, force: :cascade do |t|
    t.string "token", limit: 255, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "idx_16466_index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "idx_16466_index_api_tokens_on_user_id", unique: true
  end

  create_table "article", force: :cascade do |t|
    t.text "url", null: false
    t.string "title", limit: 200, null: false
    t.string "authors", limit: 200
    t.text "body", null: false
    t.text "description"
    t.bigint "source_id"
    t.datetime "published_at"
    t.boolean "is_indexed", default: false, null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_user_id"
    t.boolean "is_featured", default: false, null: false
    t.boolean "is_hidden", default: false, null: false
    t.datetime "found_at", null: false
    t.index ["source_id"], name: "idx_16472_source_id_idx"
  end

  create_table "article_entities", id: :serial, force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "entity_id", null: false
    t.boolean "is_featured", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id", "article_id"], name: "idx_16495_index_article_entities_on_entity_id_and_article_id", unique: true
    t.index ["is_featured"], name: "idx_16495_index_article_entities_on_is_featured"
  end

  create_table "article_entity", id: :serial, force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "entity_id", null: false
    t.string "original_name", limit: 100, null: false
    t.boolean "is_verified", default: false, null: false
    t.bigint "reviewed_by_user_id"
    t.datetime "reviewed_at"
    t.index ["article_id"], name: "idx_16502_article_id_idx"
    t.index ["entity_id"], name: "idx_16502_entity_id_idx"
  end

  create_table "article_source", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "abbreviation", limit: 10, null: false
  end

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.string "url", limit: 255, null: false
    t.string "snippet", limit: 255
    t.datetime "published_at"
    t.string "created_by_user_id", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business", force: :cascade do |t|
    t.bigint "annual_profit"
    t.bigint "entity_id", null: false
    t.decimal "assets"
    t.decimal "marketcap"
    t.bigint "net_income"
    t.bigint "aum"
    t.index ["entity_id"], name: "idx_16522_entity_id_idx"
  end

  create_table "business_industry", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.bigint "industry_id", null: false
    t.index ["business_id"], name: "idx_16531_business_id_idx"
    t.index ["industry_id"], name: "idx_16531_industry_id_idx"
  end

  create_table "business_person", force: :cascade do |t|
    t.bigint "sec_cik"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_16537_entity_id_idx"
  end

  create_table "candidate_district", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "district_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["candidate_id", "district_id"], name: "idx_16543_uniqueness_idx", unique: true
    t.index ["district_id"], name: "idx_16543_district_id_idx"
  end

  create_table "cmp_entities", force: :cascade do |t|
    t.bigint "entity_id"
    t.bigint "cmp_id"
    t.integer "entity_type", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "strata", limit: 2
    t.index ["cmp_id"], name: "idx_16549_index_cmp_entities_on_cmp_id", unique: true
    t.index ["entity_id"], name: "idx_16549_index_cmp_entities_on_entity_id", unique: true
  end

  create_table "cmp_relationships", force: :cascade do |t|
    t.string "cmp_affiliation_id", limit: 255, null: false
    t.bigint "cmp_org_id", null: false
    t.bigint "cmp_person_id", null: false
    t.bigint "relationship_id"
    t.integer "status19", limit: 2
    t.index ["cmp_affiliation_id"], name: "idx_16555_index_cmp_relationships_on_cmp_affiliation_id", unique: true
  end

  create_table "common_names", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.index ["name"], name: "idx_16561_index_common_names_on_name", unique: true
  end

  create_table "couple", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.bigint "partner1_id"
    t.bigint "partner2_id"
    t.index ["entity_id"], name: "idx_16568_index_couple_on_entity_id"
    t.index ["partner1_id"], name: "idx_16568_index_couple_on_partner1_id"
    t.index ["partner2_id"], name: "idx_16568_index_couple_on_partner2_id"
  end

  create_table "custom_key", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.text "value"
    t.string "description", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "object_model", limit: 50, null: false
    t.bigint "object_id", null: false
    t.index ["object_model", "object_id", "name", "value"], name: "idx_16574_object_name_value_idx", unique: true
    t.index ["object_model", "object_id", "name"], name: "idx_16574_object_name_idx", unique: true
    t.index ["object_model", "object_id"], name: "idx_16574_object_idx"
  end

  create_table "dashboard_bulletins", force: :cascade do |t|
    t.text "markdown"
    t.string "title", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color", limit: 255
    t.index ["created_at"], name: "idx_16584_index_dashboard_bulletins_on_created_at"
  end

  create_table "degree", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "abbreviation", limit: 10
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.bigint "priority", default: 0, null: false
    t.bigint "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "idx_16602_delayed_jobs_priority"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "url"
    t.string "url_hash", limit: 40
    t.string "publication_date", limit: 10
    t.bigint "ref_type", default: 1, null: false
    t.text "excerpt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url_hash"], name: "idx_16615_index_documents_on_url_hash", unique: true
  end

  create_table "donation", force: :cascade do |t|
    t.bigint "bundler_id"
    t.bigint "relationship_id", null: false
    t.index ["bundler_id"], name: "idx_16628_bundler_id_idx"
    t.index ["relationship_id"], name: "idx_16628_relationship_id_idx"
  end

  create_table "edited_entities", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "version_id", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "idx_16634_index_edited_entities_on_created_at"
    t.index ["entity_id", "version_id", "user_id"], name: "idx_16634_index_edited_entities_on_entity_id_and_version_id_and", unique: true
    t.index ["entity_id", "version_id"], name: "idx_16634_index_edited_entities_on_entity_id_and_version_id", unique: true
  end

  create_table "education", force: :cascade do |t|
    t.bigint "degree_id"
    t.string "field", limit: 30
    t.boolean "is_dropout"
    t.bigint "relationship_id", null: false
    t.index ["degree_id"], name: "idx_16640_degree_id_idx"
    t.index ["relationship_id"], name: "idx_16640_relationship_id_idx"
  end

  create_table "elected_representative", force: :cascade do |t|
    t.string "bioguide_id", limit: 20
    t.string "govtrack_id", limit: 20
    t.string "crp_id", limit: 20
    t.string "pvs_id", limit: 20
    t.string "watchdog_id", limit: 50
    t.bigint "entity_id", null: false
    t.text "fec_ids"
    t.index ["crp_id"], name: "idx_16647_crp_id_idx"
    t.index ["entity_id"], name: "idx_16647_entity_id_idx"
  end

  create_table "email", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "address", limit: 60, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.bigint "last_user_id"
    t.index ["entity_id"], name: "idx_16661_entity_id_idx"
    t.index ["last_user_id"], name: "idx_16661_last_user_id_idx"
  end

  create_table "entity", force: :cascade do |t|
    t.text "name"
    t.text "blurb"
    t.text "summary"
    t.text "notes"
    t.text "website"
    t.bigint "parent_id"
    t.string "primary_ext", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
    t.boolean "is_deleted", default: false, null: false
    t.bigint "last_user_id"
    t.bigint "merged_id"
    t.boolean "delta", default: true, null: false
    t.bigint "link_count", default: 0, null: false
    t.index ["blurb"], name: "idx_16668_blurb_idx"
    t.index ["created_at"], name: "idx_16668_created_at_idx"
    t.index ["delta"], name: "idx_16668_index_entity_on_delta"
    t.index ["last_user_id"], name: "idx_16668_last_user_id_idx"
    t.index ["name", "blurb", "website"], name: "idx_16668_search_idx"
    t.index ["name"], name: "idx_16668_name_idx"
    t.index ["parent_id"], name: "idx_16668_parent_id_idx"
    t.index ["updated_at"], name: "idx_16668_updated_at_idx"
    t.index ["website"], name: "idx_16668_website_idx"
  end

  create_table "entity_fields", force: :cascade do |t|
    t.bigint "entity_id"
    t.bigint "field_id"
    t.text "value", null: false
    t.boolean "is_admin", default: false
    t.index ["entity_id", "field_id"], name: "idx_16686_index_entity_fields_on_entity_id_and_field_id", unique: true
  end

  create_table "example", id: false, force: :cascade do |t|
    t.string "word", limit: 100
    t.bigint "year"
    t.string "cand_id", limit: 100
    t.index ["year", "cand_id"], name: "idx_16691_example_idx", unique: true
  end

  create_table "extension_definition", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "display_name", limit: 50, null: false
    t.boolean "has_fields", default: false, null: false
    t.bigint "parent_id"
    t.bigint "tier"
    t.index ["name"], name: "idx_16698_name_idx"
    t.index ["parent_id"], name: "idx_16698_parent_id_idx"
    t.index ["tier"], name: "idx_16698_tier_idx"
  end

  create_table "extension_record", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.bigint "definition_id", null: false
    t.bigint "last_user_id"
    t.index ["definition_id"], name: "idx_16705_definition_id_idx"
    t.index ["entity_id"], name: "idx_16705_entity_id_idx"
    t.index ["last_user_id"], name: "idx_16705_last_user_id_idx"
  end

  create_table "external_data", force: :cascade do |t|
    t.integer "dataset", limit: 2, null: false
    t.string "dataset_id", limit: 255, null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dataset", "dataset_id"], name: "idx_34330_index_external_data_on_dataset_and_dataset_id", unique: true
    t.index ["dataset"], name: "idx_34330_index_external_data_on_dataset"
  end

  create_table "external_data_fec_candidates", force: :cascade do |t|
    t.string "cand_id", limit: 255, null: false
    t.text "cand_name"
    t.string "cand_pty_affiliation", limit: 255
    t.integer "cand_election_yr", limit: 2
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
    t.string "cand_zip", limit: 255
    t.integer "fec_year", limit: 2, null: false
    t.index "to_tsvector('simple'::regconfig, cand_name)", name: "idx_34339_index_external_data_fec_candidates_on_cand_name", using: :gin
    t.index ["cand_id", "fec_year"], name: "idx_34339_index_external_data_fec_candidates_on_cand_id_and_fec", unique: true
    t.index ["cand_pty_affiliation"], name: "idx_34339_index_external_data_fec_candidates_on_cand_pty_affili"
  end

  create_table "external_data_fec_committees", force: :cascade do |t|
    t.string "cmte_id", limit: 255, null: false
    t.text "cmte_nm"
    t.text "tres_nm"
    t.text "cmte_st1"
    t.text "cmte_st2"
    t.text "cmte_city"
    t.string "cmte_st", limit: 2
    t.string "cmte_zip", limit: 255
    t.string "cmte_dsgn", limit: 1
    t.string "cmte_tp", limit: 2
    t.text "cmte_pty_affiliation"
    t.string "cmte_filing_freq", limit: 1
    t.string "org_tp", limit: 1
    t.text "connected_org_nm"
    t.string "cand_id", limit: 255
    t.integer "fec_year", limit: 2, null: false
    t.index "to_tsvector('simple'::regconfig, cmte_nm)", name: "idx_34356_index_external_data_fec_committees_on_cmte_nm", using: :gin
    t.index "to_tsvector('simple'::regconfig, connected_org_nm)", name: "idx_34356_index_external_data_fec_committees_on_connected_org_n", using: :gin
    t.index ["cmte_id", "fec_year"], name: "idx_34356_index_external_data_fec_committees_on_cmte_id_and_fec", unique: true
    t.index ["cmte_pty_affiliation"], name: "idx_34356_index_external_data_fec_committees_on_cmte_pty_affili"
  end

  create_table "external_data_fec_contributions", id: false, force: :cascade do |t|
    t.bigint "sub_id", null: false
    t.string "cmte_id", limit: 255, null: false
    t.text "amndt_ind"
    t.text "rpt_tp"
    t.text "transaction_pgi"
    t.string "image_num", limit: 255
    t.string "transaction_tp", limit: 255
    t.string "entity_tp", limit: 255
    t.text "name"
    t.text "city"
    t.text "state"
    t.text "zip_code"
    t.text "employer"
    t.text "occupation"
    t.text "transaction_dt"
    t.decimal "transaction_amt", precision: 10
    t.string "other_id", limit: 255
    t.string "tran_id", limit: 255
    t.bigint "file_num"
    t.text "memo_cd"
    t.text "memo_text"
    t.integer "fec_year", limit: 2, null: false
    t.index "to_tsvector('simple'::regconfig, employer)", name: "idx_34370_index_external_data_fec_contributions_on_employer", using: :gin
    t.index "to_tsvector('simple'::regconfig, name)", name: "idx_34370_index_external_data_fec_contributions_on_name", using: :gin
    t.index ["cmte_id"], name: "idx_34370_index_external_data_fec_contributions_on_cmte_id"
    t.index ["fec_year", "sub_id"], name: "idx_34370_index_external_data_fec_contributions_on_fec_year_and", unique: true
    t.index ["transaction_amt"], name: "idx_34370_index_external_data_fec_contributions_on_transaction_"
  end

  create_table "external_data_nycc", id: false, force: :cascade do |t|
    t.bigint "district", null: false
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

  create_table "external_data_nys_disclosures", id: false, force: :cascade do |t|
    t.bigint "filer_id", null: false
    t.text "filer_previous_id"
    t.text "cand_comm_name"
    t.bigint "election_year"
    t.text "election_type"
    t.text "county_desc"
    t.string "filing_abbrev", limit: 1
    t.text "filing_desc"
    t.text "filing_cat_desc"
    t.text "filing_sched_abbrev"
    t.text "filing_sched_desc"
    t.text "loan_lib_number"
    t.string "trans_number", limit: 255, null: false
    t.text "trans_mapping"
    t.datetime "sched_date"
    t.datetime "org_date"
    t.text "cntrbr_type_desc"
    t.text "cntrbn_type_desc"
    t.text "transfer_type_desc"
    t.text "receipt_type_desc"
    t.text "receipt_code_desc"
    t.text "purpose_code_desc"
    t.text "r_subcontractor"
    t.text "flng_ent_name"
    t.text "flng_ent_first_name"
    t.text "flng_ent_middle_name"
    t.text "flng_ent_last_name"
    t.text "flng_ent_add1"
    t.text "flng_ent_city"
    t.text "flng_ent_state"
    t.text "flng_ent_zip"
    t.text "flng_ent_country"
    t.text "payment_type_desc"
    t.text "pay_number"
    t.float "owned_amt"
    t.float "org_amt"
    t.text "loan_other_desc"
    t.text "trans_explntn"
    t.string "r_itemized", limit: 1
    t.string "r_liability", limit: 1
    t.text "election_year_str"
    t.text "office_desc"
    t.text "district"
    t.text "dist_off_cand_bal_prop"
    t.string "r_amend", limit: 1
    t.index "to_tsvector('simple'::regconfig, flng_ent_last_name)", name: "idx_34391_index_external_data_nys_disclosures_on_flng_ent_last_", using: :gin
    t.index "to_tsvector('simple'::regconfig, flng_ent_name)", name: "idx_34391_index_external_data_nys_disclosures_on_flng_ent_name", using: :gin
    t.index ["filer_id"], name: "idx_34391_index_external_data_nys_disclosures_on_filer_id"
    t.index ["org_amt"], name: "idx_34391_index_external_data_nys_disclosures_on_org_amt"
    t.index ["trans_number"], name: "idx_34391_index_external_data_nys_disclosures_on_trans_number", unique: true
  end

  create_table "external_data_nys_filers", force: :cascade do |t|
    t.bigint "filer_id", null: false
    t.text "filer_name"
    t.text "compliance_type_desc"
    t.text "filter_type_desc"
    t.text "filter_status"
    t.text "committee_type_desc"
    t.text "office_desc"
    t.text "district"
    t.text "county_desc"
    t.text "municipality_subdivision_desc"
    t.text "treasurer_first_name"
    t.text "treasurer_middle_name"
    t.text "treasurer_last_name"
    t.text "address"
    t.text "city"
    t.text "state"
    t.text "zipcode"
    t.index "to_tsvector('simple'::regconfig, filer_name)", name: "idx_34436_index_external_data_nys_filers_on_filer_name", using: :gin
    t.index ["filer_id"], name: "idx_34436_index_external_data_nys_filers_on_filer_id", unique: true
  end

  create_table "external_entities", force: :cascade do |t|
    t.integer "dataset", limit: 2, null: false
    t.text "match_data"
    t.bigint "external_data_id"
    t.bigint "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority", limit: 2, default: 0, null: false
    t.string "primary_ext", limit: 6
    t.index ["entity_id"], name: "idx_16711_index_external_entities_on_entity_id"
    t.index ["external_data_id"], name: "idx_16711_index_external_entities_on_external_data_id"
    t.index ["priority"], name: "idx_16711_index_external_entities_on_priority"
  end

  create_table "external_links", force: :cascade do |t|
    t.integer "link_type", limit: 2, null: false
    t.bigint "entity_id", null: false
    t.text "link_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "idx_16722_index_external_links_on_entity_id"
    t.index ["link_type", "link_id"], name: "idx_16722_index_external_links_on_link_type_and_link_id", unique: true
  end

  create_table "external_relationships", force: :cascade do |t|
    t.bigint "external_data_id", null: false
    t.bigint "relationship_id"
    t.integer "dataset", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "entity1_id"
    t.bigint "entity2_id"
    t.integer "category_id", limit: 2, null: false
    t.index ["external_data_id"], name: "idx_34461_fk_rails_5025111f98"
    t.index ["relationship_id"], name: "idx_34461_fk_rails_632542e80c"
  end

  create_table "family", force: :cascade do |t|
    t.boolean "is_nonbiological"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_16728_relationship_id_idx"
  end

  create_table "fields", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "display_name", limit: 255, null: false
    t.string "type", limit: 255, default: "string", null: false
    t.index ["name"], name: "idx_16734_index_fields_on_name", unique: true
  end

  create_table "generic", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_16744_relationship_id_idx"
  end

  create_table "government_body", force: :cascade do |t|
    t.boolean "is_federal"
    t.bigint "state_id"
    t.string "city", limit: 50
    t.string "county", limit: 50
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_16750_entity_id_idx"
    t.index ["state_id"], name: "idx_16750_state_id_idx"
  end

  create_table "help_pages", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "title", limit: 255
    t.text "markdown"
    t.bigint "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_16758_index_help_pages_on_name", unique: true
  end

  create_table "hierarchy", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_16768_relationship_id_idx"
  end

  create_table "image", force: :cascade do |t|
    t.bigint "entity_id"
    t.string "filename", limit: 100, null: false
    t.text "caption"
    t.boolean "is_featured", default: false, null: false
    t.boolean "is_free"
    t.string "url", limit: 400
    t.bigint "width"
    t.bigint "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "has_square", default: false, null: false
    t.bigint "address_id"
    t.string "raw_address", limit: 200
    t.boolean "has_face", default: false, null: false
    t.bigint "user_id"
    t.index ["address_id"], name: "idx_16774_index_image_on_address_id"
    t.index ["entity_id"], name: "idx_16774_entity_id_idx"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "industry_id", limit: 255, null: false
    t.string "sector_name", limit: 255, null: false
    t.index ["industry_id"], name: "idx_16789_index_industries_on_industry_id", unique: true
  end

  create_table "industry", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "context", limit: 30
    t.string "code", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link", force: :cascade do |t|
    t.bigint "entity1_id", null: false
    t.bigint "entity2_id", null: false
    t.bigint "category_id", null: false
    t.bigint "relationship_id", null: false
    t.boolean "is_reverse", null: false
    t.index ["category_id"], name: "idx_16806_category_id_idx"
    t.index ["entity1_id", "category_id", "is_reverse"], name: "idx_16806_index_link_on_entity1_id_and_category_id_and_is_rever"
    t.index ["entity1_id", "category_id"], name: "idx_16806_index_link_on_entity1_id_and_category_id"
    t.index ["entity1_id"], name: "idx_16806_entity1_id_idx"
    t.index ["entity2_id"], name: "idx_16806_entity2_id_idx"
    t.index ["relationship_id"], name: "idx_16806_relationship_id_idx"
  end

  create_table "lobby_filing", force: :cascade do |t|
    t.string "federal_filing_id", limit: 50, null: false
    t.bigint "amount"
    t.bigint "year"
    t.string "period", limit: 100
    t.string "report_type", limit: 100
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
  end

  create_table "lobby_filing_lobby_issue", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.text "specific_issue"
    t.index ["issue_id"], name: "idx_16840_issue_id_idx"
    t.index ["lobby_filing_id"], name: "idx_16840_lobby_filing_id_idx"
  end

  create_table "lobby_filing_lobbyist", force: :cascade do |t|
    t.bigint "lobbyist_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "idx_16834_lobby_filing_id_idx"
    t.index ["lobbyist_id"], name: "idx_16834_lobbyist_id_idx"
  end

  create_table "lobby_filing_relationship", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.bigint "lobby_filing_id", null: false
    t.index ["lobby_filing_id"], name: "idx_16849_lobby_filing_id_idx"
    t.index ["relationship_id"], name: "idx_16849_relationship_id_idx"
  end

  create_table "lobby_issue", force: :cascade do |t|
    t.string "name", limit: 50, null: false
  end

  create_table "lobbying", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_16812_relationship_id_idx"
  end

  create_table "lobbyist", force: :cascade do |t|
    t.bigint "lda_registrant_id"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_16818_entity_id_idx"
  end

  create_table "locations", force: :cascade do |t|
    t.text "city"
    t.text "country"
    t.text "subregion"
    t.integer "region", limit: 2
    t.decimal "lat", precision: 10
    t.decimal "lng", precision: 10
    t.bigint "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "idx_16861_index_locations_on_entity_id"
    t.index ["region"], name: "idx_16861_index_locations_on_region"
  end

  create_table "ls_list", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.boolean "is_ranked", default: false, null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_featured", default: false, null: false
    t.string "display_name", limit: 50
    t.bigint "featured_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "last_user_id"
    t.boolean "is_deleted", default: false, null: false
    t.string "custom_field_name", limit: 100
    t.boolean "delta", default: true, null: false
    t.bigint "creator_user_id"
    t.string "short_description", limit: 255
    t.integer "access", limit: 2, default: 0, null: false
    t.bigint "entity_count", default: 0
    t.string "sort_by", limit: 255
    t.index ["delta"], name: "idx_16872_index_ls_list_on_delta"
    t.index ["featured_list_id"], name: "idx_16872_featured_list_id"
    t.index ["last_user_id"], name: "idx_16872_last_user_id_idx"
    t.index ["name"], name: "idx_16872_index_ls_list_on_name"
  end

  create_table "ls_list_entity", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "entity_id", null: false
    t.integer "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "last_user_id"
    t.text "custom_field"
    t.index ["created_at"], name: "idx_16892_created_at_idx"
    t.index ["entity_id", "list_id"], name: "idx_16892_index_ls_list_entity_on_entity_id_and_list_id"
    t.index ["entity_id"], name: "idx_16892_entity_id_idx"
    t.index ["last_user_id"], name: "idx_16892_last_user_id_idx"
    t.index ["list_id"], name: "idx_16892_list_id_idx"
  end

  create_table "map_annotations", force: :cascade do |t|
    t.bigint "map_id", null: false
    t.bigint "order", null: false
    t.string "title", limit: 255
    t.text "description"
    t.string "highlighted_entity_ids", limit: 255
    t.string "highlighted_rel_ids", limit: 255
    t.string "highlighted_text_ids", limit: 255
    t.index ["map_id"], name: "idx_16901_index_map_annotations_on_map_id"
  end

  create_table "membership", force: :cascade do |t|
    t.bigint "dues"
    t.bigint "relationship_id", null: false
    t.text "elected_term"
    t.index ["relationship_id"], name: "idx_16914_relationship_id_idx"
  end

  create_table "network_map", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "entity_ids"
    t.text "rel_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.text "title"
    t.text "description"
    t.bigint "width", null: false
    t.bigint "height", null: false
    t.boolean "is_featured", default: false, null: false
    t.string "zoom", limit: 255, default: "1", null: false
    t.boolean "is_private", default: false, null: false
    t.text "thumbnail"
    t.boolean "delta", default: true, null: false
    t.text "index_data"
    t.string "secret", limit: 255
    t.text "graph_data"
    t.text "annotations_data"
    t.bigint "annotations_count", default: 0, null: false
    t.boolean "list_sources", default: false, null: false
    t.boolean "is_cloneable", default: true, null: false
    t.integer "oligrapher_version", limit: 2, default: 2, null: false
    t.text "editors"
    t.text "settings"
    t.text "screenshot"
    t.index ["delta"], name: "idx_16923_index_network_map_on_delta"
    t.index ["user_id"], name: "idx_16923_user_id_idx"
  end

  create_table "ny_disclosures", force: :cascade do |t|
    t.string "filer_id", limit: 10, null: false
    t.string "report_id", limit: 255
    t.string "transaction_code", limit: 1, null: false
    t.string "e_year", limit: 4, null: false
    t.bigint "transaction_id", null: false
    t.date "schedule_transaction_date"
    t.date "original_date"
    t.string "contrib_code", limit: 4
    t.string "contrib_type_code", limit: 1
    t.string "corp_name", limit: 255
    t.string "first_name", limit: 255
    t.string "mid_init", limit: 255
    t.string "last_name", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 2
    t.string "zip", limit: 5
    t.string "check_number", limit: 255
    t.string "check_date", limit: 255
    t.float "amount1"
    t.float "amount2"
    t.string "description", limit: 255
    t.string "other_recpt_code", limit: 255
    t.string "purpose_code1", limit: 255
    t.string "purpose_code2", limit: 255
    t.string "explanation", limit: 255
    t.string "transfer_type", limit: 1
    t.string "bank_loan_check_box", limit: 1
    t.string "crerec_uid", limit: 255
    t.datetime "crerec_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "delta", default: true, null: false
    t.index ["contrib_code"], name: "idx_16946_index_ny_disclosures_on_contrib_code"
    t.index ["delta"], name: "idx_16946_index_ny_disclosures_on_delta"
    t.index ["e_year"], name: "idx_16946_index_ny_disclosures_on_e_year"
    t.index ["filer_id", "report_id", "transaction_id", "schedule_transaction_date", "e_year"], name: "idx_16946_index_filer_report_trans_date_e_year"
    t.index ["filer_id"], name: "idx_16946_index_ny_disclosures_on_filer_id"
    t.index ["original_date"], name: "idx_16946_index_ny_disclosures_on_original_date"
  end

  create_table "ny_filer_entities", force: :cascade do |t|
    t.bigint "ny_filer_id"
    t.bigint "entity_id"
    t.boolean "is_committee"
    t.bigint "cmte_entity_id"
    t.string "e_year", limit: 4
    t.string "filer_id", limit: 255
    t.string "office", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_entity_id"], name: "idx_16996_index_ny_filer_entities_on_cmte_entity_id"
    t.index ["entity_id"], name: "idx_16996_index_ny_filer_entities_on_entity_id"
    t.index ["filer_id"], name: "idx_16996_index_ny_filer_entities_on_filer_id"
    t.index ["is_committee"], name: "idx_16996_index_ny_filer_entities_on_is_committee"
    t.index ["ny_filer_id"], name: "idx_16996_index_ny_filer_entities_on_ny_filer_id"
  end

  create_table "ny_filers", force: :cascade do |t|
    t.string "filer_id", limit: 255, null: false
    t.string "name", limit: 255
    t.string "filer_type", limit: 255
    t.string "status", limit: 255
    t.string "committee_type", limit: 255
    t.bigint "office"
    t.bigint "district"
    t.string "treas_first_name", limit: 255
    t.string "treas_last_name", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "zip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["filer_id"], name: "idx_16977_index_ny_filers_on_filer_id", unique: true
    t.index ["filer_type"], name: "idx_16977_index_ny_filers_on_filer_type"
  end

  create_table "ny_matches", force: :cascade do |t|
    t.bigint "ny_disclosure_id"
    t.bigint "donor_id"
    t.bigint "recip_id"
    t.bigint "relationship_id"
    t.bigint "matched_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["donor_id"], name: "idx_17008_index_ny_matches_on_donor_id"
    t.index ["ny_disclosure_id"], name: "idx_17008_index_ny_matches_on_ny_disclosure_id", unique: true
    t.index ["recip_id"], name: "idx_17008_index_ny_matches_on_recip_id"
    t.index ["relationship_id"], name: "idx_17008_index_ny_matches_on_relationship_id"
  end

  create_table "object_tag", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "object_model", limit: 50, null: false
    t.bigint "object_id", null: false
    t.bigint "last_user_id"
    t.index ["last_user_id"], name: "idx_17014_last_user_id_idx"
    t.index ["object_model", "object_id", "tag_id"], name: "idx_17014_uniqueness_idx", unique: true
    t.index ["object_model", "object_id"], name: "idx_17014_object_idx"
    t.index ["tag_id"], name: "idx_17014_tag_id_idx"
  end

  create_table "org", force: :cascade do |t|
    t.text "name", null: false
    t.string "name_nick", limit: 100
    t.bigint "employees"
    t.bigint "revenue"
    t.string "fedspending_id", limit: 10
    t.string "lda_registrant_id", limit: 10
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_17020_entity_id_idx"
  end

  create_table "os_candidates", force: :cascade do |t|
    t.string "cycle", limit: 255, null: false
    t.string "feccandid", limit: 255, null: false
    t.string "crp_id", limit: 255, null: false
    t.string "name", limit: 255
    t.string "party", limit: 1
    t.string "distid_runfor", limit: 255
    t.string "distid_current", limit: 255
    t.boolean "currcand"
    t.boolean "cyclecand"
    t.string "crpico", limit: 1
    t.string "recipcode", limit: 2
    t.string "nopacs", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["crp_id"], name: "idx_17029_index_os_candidates_on_crp_id"
    t.index ["cycle", "crp_id"], name: "idx_17029_index_os_candidates_on_cycle_and_crp_id"
    t.index ["feccandid"], name: "idx_17029_index_os_candidates_on_feccandid"
  end

  create_table "os_category", force: :cascade do |t|
    t.string "category_id", limit: 10, null: false
    t.string "category_name", limit: 100, null: false
    t.string "industry_id", limit: 10, null: false
    t.string "industry_name", limit: 100, null: false
    t.string "sector_name", limit: 100, null: false
    t.index ["category_id"], name: "idx_17045_unique_id_idx", unique: true
    t.index ["category_name"], name: "idx_17045_unique_name_idx", unique: true
  end

  create_table "os_committees", force: :cascade do |t|
    t.string "cycle", limit: 4, null: false
    t.string "cmte_id", limit: 255, null: false
    t.string "name", limit: 255
    t.string "affiliate", limit: 255
    t.string "ultorg", limit: 255
    t.string "recipid", limit: 255
    t.string "recipcode", limit: 2
    t.string "feccandid", limit: 255
    t.string "party", limit: 1
    t.string "primcode", limit: 5
    t.string "source", limit: 255
    t.boolean "sensitive"
    t.boolean "foreign"
    t.boolean "active_in_cycle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cmte_id", "cycle"], name: "idx_17051_index_os_committees_on_cmte_id_and_cycle"
    t.index ["cmte_id"], name: "idx_17051_index_os_committees_on_cmte_id"
    t.index ["recipid"], name: "idx_17051_index_os_committees_on_recipid"
  end

  create_table "os_donations", force: :cascade do |t|
    t.string "cycle", limit: 4, null: false
    t.string "fectransid", limit: 19, null: false
    t.string "contribid", limit: 12
    t.string "contrib", limit: 255
    t.string "recipid", limit: 9
    t.string "orgname", limit: 255
    t.string "ultorg", limit: 255
    t.string "realcode", limit: 5
    t.date "date"
    t.bigint "amount"
    t.string "street", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 2
    t.string "zip", limit: 5
    t.string "recipcode", limit: 2
    t.string "transactiontype", limit: 3
    t.string "cmteid", limit: 9
    t.string "otherid", limit: 9
    t.string "gender", limit: 1
    t.string "microfilm", limit: 30
    t.string "occupation", limit: 255
    t.string "employer", limit: 255
    t.string "source", limit: 5
    t.string "fec_cycle_id", limit: 24, null: false
    t.string "name_last", limit: 255
    t.string "name_first", limit: 255
    t.string "name_middle", limit: 255
    t.string "name_suffix", limit: 255
    t.string "name_prefix", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["amount"], name: "idx_34467_index_os_donations_on_amount"
    t.index ["contribid"], name: "idx_34467_index_os_donations_on_contribid"
    t.index ["cycle"], name: "idx_34467_index_os_donations_on_cycle"
    t.index ["date"], name: "idx_34467_index_os_donations_on_date"
    t.index ["fec_cycle_id"], name: "idx_34467_index_os_donations_on_fec_cycle_id", unique: true
    t.index ["fectransid", "cycle"], name: "idx_34467_index_os_donations_on_fectransid_and_cycle"
    t.index ["fectransid"], name: "idx_34467_index_os_donations_on_fectransid"
    t.index ["microfilm"], name: "idx_34467_index_os_donations_on_microfilm"
    t.index ["name_last", "name_first"], name: "idx_34467_index_os_donations_on_name_last_and_name_first"
    t.index ["realcode", "amount"], name: "idx_34467_index_os_donations_on_realcode_and_amount"
    t.index ["realcode"], name: "idx_34467_index_os_donations_on_realcode"
    t.index ["recipid", "amount"], name: "idx_34467_index_os_donations_on_recipid_and_amount"
    t.index ["recipid"], name: "idx_34467_index_os_donations_on_recipid"
    t.index ["state"], name: "idx_34467_index_os_donations_on_state"
    t.index ["zip"], name: "idx_34467_index_os_donations_on_zip"
  end

  create_table "os_entity_category", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "category_id", limit: 10, null: false
    t.string "source", limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "idx_17069_category_id_idx"
    t.index ["entity_id", "category_id"], name: "idx_17069_uniqueness_idx", unique: true
    t.index ["entity_id"], name: "idx_17069_entity_id_idx"
  end

  create_table "os_entity_donor", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "donor_id", limit: 12
    t.bigint "match_code"
    t.boolean "is_verified", default: false, null: false
    t.bigint "reviewed_by_user_id"
    t.boolean "is_processed", default: false, null: false
    t.boolean "is_synced", default: true, null: false
    t.datetime "reviewed_at"
    t.bigint "locked_by_user_id"
    t.datetime "locked_at"
    t.index ["entity_id", "donor_id"], name: "idx_17076_entity_donor_idx", unique: true
    t.index ["is_synced"], name: "idx_17076_is_synced_idx"
    t.index ["locked_at"], name: "idx_17076_locked_at_idx"
    t.index ["reviewed_at"], name: "idx_17076_reviewed_at_idx"
  end

  create_table "os_matches", force: :cascade do |t|
    t.bigint "os_donation_id", null: false
    t.bigint "donation_id"
    t.bigint "donor_id", null: false
    t.bigint "recip_id"
    t.bigint "relationship_id"
    t.bigint "matched_by"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "cmte_id"
    t.index ["cmte_id"], name: "idx_17086_index_os_matches_on_cmte_id"
    t.index ["donor_id"], name: "idx_17086_index_os_matches_on_donor_id"
    t.index ["os_donation_id"], name: "idx_17086_index_os_matches_on_os_donation_id"
    t.index ["recip_id"], name: "idx_17086_index_os_matches_on_recip_id"
    t.index ["relationship_id"], name: "idx_17086_index_os_matches_on_relationship_id"
  end

  create_table "ownership", force: :cascade do |t|
    t.bigint "percent_stake"
    t.bigint "shares"
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_17093_relationship_id_idx"
  end

  create_table "pages", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "title", limit: 255
    t.text "markdown"
    t.bigint "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_17099_index_pages_on_name", unique: true
  end

  create_table "permission_passes", force: :cascade do |t|
    t.string "event_name", limit: 255
    t.string "token", limit: 255, null: false
    t.datetime "valid_from", null: false
    t.datetime "valid_to", null: false
    t.text "abilities", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person", force: :cascade do |t|
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
    t.index ["entity_id"], name: "idx_17119_entity_id_idx"
    t.index ["gender_id"], name: "idx_17119_gender_id_idx"
    t.index ["name_last", "name_first", "name_middle"], name: "idx_17119_name_idx"
    t.index ["party_id"], name: "idx_17119_party_id_idx"
  end

  create_table "phone", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.string "number", limit: 20, null: false
    t.string "type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.bigint "last_user_id"
    t.index ["entity_id"], name: "idx_17134_entity_id_idx"
    t.index ["last_user_id"], name: "idx_17134_last_user_id_idx"
  end

  create_table "political_candidate", force: :cascade do |t|
    t.boolean "is_federal"
    t.boolean "is_state"
    t.boolean "is_local"
    t.string "pres_fec_id", limit: 20
    t.string "senate_fec_id", limit: 20
    t.string "house_fec_id", limit: 20
    t.string "crp_id", limit: 20
    t.bigint "entity_id", null: false
    t.index ["crp_id"], name: "idx_17142_crp_id_idx"
    t.index ["entity_id"], name: "idx_17142_entity_id_idx"
    t.index ["house_fec_id"], name: "idx_17142_house_fec_id_idx"
    t.index ["pres_fec_id"], name: "idx_17142_pres_fec_id_idx"
    t.index ["senate_fec_id"], name: "idx_17142_senate_fec_id_idx"
  end

  create_table "political_district", force: :cascade do |t|
    t.bigint "state_id"
    t.string "federal_district", limit: 2
    t.string "state_district", limit: 2
    t.string "local_district", limit: 2
    t.index ["state_id"], name: "idx_17152_state_id_idx"
  end

  create_table "political_fundraising", primary_key: "entity_id", force: :cascade do |t|
    t.bigint "id", null: false
    t.string "fec_id", limit: 20
    t.bigint "type_id"
    t.bigint "state_id"
    t.index ["entity_id"], name: "idx_17161_entity_id_idx"
    t.index ["fec_id"], name: "idx_17161_fec_id_idx"
    t.index ["state_id"], name: "idx_17161_state_id_idx"
    t.index ["type_id"], name: "idx_17161_type_id_idx"
  end

  create_table "political_fundraising_type", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "name", limit: 50, null: false
  end

  create_table "position", force: :cascade do |t|
    t.boolean "is_board"
    t.boolean "is_executive"
    t.boolean "is_employee"
    t.bigint "compensation"
    t.bigint "boss_id"
    t.bigint "relationship_id", null: false
    t.index ["boss_id"], name: "idx_17174_boss_id_idx"
    t.index ["relationship_id"], name: "idx_17174_relationship_id_idx"
  end

  create_table "professional", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_17180_relationship_id_idx"
  end

  create_table "public_company", force: :cascade do |t|
    t.string "ticker", limit: 10
    t.bigint "sec_cik"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_17186_entity_id_idx"
  end

  create_table "references", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "referenceable_id", null: false
    t.string "referenceable_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referenceable_id", "referenceable_type"], name: "idx_17193_index_references_on_referenceable_id_and_referenceabl"
  end

  create_table "relationship", force: :cascade do |t|
    t.bigint "entity1_id", null: false
    t.bigint "entity2_id", null: false
    t.bigint "category_id", null: false
    t.string "description1", limit: 100
    t.string "description2", limit: 100
    t.bigint "amount"
    t.string "currency", limit: 255
    t.text "goods"
    t.bigint "filings"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "start_date", limit: 10
    t.string "end_date", limit: 10
    t.boolean "is_current"
    t.boolean "is_deleted", default: false, null: false
    t.bigint "last_user_id"
    t.bigint "amount2"
    t.boolean "is_gte", default: false, null: false
    t.index ["category_id"], name: "idx_17200_category_id_idx"
    t.index ["entity1_id", "category_id"], name: "idx_17200_entity1_category_idx"
    t.index ["entity1_id", "entity2_id"], name: "idx_17200_entity_idx"
    t.index ["entity1_id"], name: "idx_17200_entity1_id_idx"
    t.index ["entity2_id"], name: "idx_17200_entity2_id_idx"
    t.index ["is_deleted", "entity2_id", "category_id", "amount"], name: "idx_17200_index_relationship_is_d_e2_cat_amount"
    t.index ["last_user_id"], name: "idx_17200_last_user_id_idx"
  end

  create_table "relationship_category", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "display_name", limit: 30, null: false
    t.string "default_description", limit: 50
    t.text "entity1_requirements"
    t.text "entity2_requirements"
    t.boolean "has_fields", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "idx_17216_uniqueness_idx", unique: true
  end

  create_table "representative", force: :cascade do |t|
    t.string "bioguide_id", limit: 20
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_17227_entity_id_idx"
  end

  create_table "representative_district", force: :cascade do |t|
    t.bigint "representative_id", null: false
    t.bigint "district_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id"], name: "idx_17234_district_id_idx"
    t.index ["representative_id", "district_id"], name: "idx_17234_uniqueness_idx", unique: true
    t.index ["representative_id"], name: "idx_17234_representative_id_idx"
  end

  create_table "school", force: :cascade do |t|
    t.bigint "endowment"
    t.bigint "students"
    t.bigint "faculty"
    t.bigint "tuition"
    t.boolean "is_private"
    t.bigint "entity_id", null: false
    t.index ["entity_id"], name: "idx_17243_entity_id_idx"
  end

  create_table "social", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.index ["relationship_id"], name: "idx_17249_relationship_id_idx"
  end

  create_table "sphinx_index", id: false, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.datetime "updated_at", null: false
  end

  create_table "swamp_tips", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tag", force: :cascade do |t|
    t.string "name", limit: 100
    t.boolean "is_visible", default: true, null: false
    t.string "triple_namespace", limit: 30
    t.string "triple_predicate", limit: 30
    t.string "triple_value", limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "idx_17267_uniqueness_idx", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "tagable_class", limit: 255, null: false
    t.bigint "tagable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_user_id", default: 1, null: false
    t.index ["last_user_id"], name: "idx_17278_fk_rails_5607f02466"
    t.index ["tag_id"], name: "idx_17278_index_taggings_on_tag_id"
    t.index ["tagable_class"], name: "idx_17278_index_taggings_on_tagable_class"
    t.index ["tagable_id"], name: "idx_17278_index_taggings_on_tagable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.boolean "restricted", default: false
    t.string "name", limit: 255, null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_17285_index_tags_on_name", unique: true
  end

  create_table "toolkit_pages", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "title", limit: 255
    t.text "markdown"
    t.bigint "last_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_17295_index_toolkit_pages_on_name", unique: true
  end

  create_table "transaction", force: :cascade do |t|
    t.bigint "contact1_id"
    t.bigint "contact2_id"
    t.bigint "district_id"
    t.boolean "is_lobbying"
    t.bigint "relationship_id", null: false
    t.index ["contact1_id"], name: "idx_17305_contact1_id_idx"
    t.index ["contact2_id"], name: "idx_17305_contact2_id_idx"
    t.index ["relationship_id"], name: "idx_17305_relationship_id_idx"
  end

  create_table "unmatched_ny_filers", force: :cascade do |t|
    t.bigint "ny_filer_id", null: false
    t.bigint "disclosure_count", null: false
    t.index ["disclosure_count"], name: "idx_17311_index_unmatched_ny_filers_on_disclosure_count"
    t.index ["ny_filer_id"], name: "idx_17311_index_unmatched_ny_filers_on_ny_filer_id", unique: true
  end

  create_table "user_permissions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "resource_type", limit: 255, null: false
    t.text "access_rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "resource_type"], name: "idx_17336_index_user_permissions_on_user_id_and_resource_type"
  end

  create_table "user_profiles", primary_key: "user_id", force: :cascade do |t|
    t.bigint "id", null: false
    t.string "name_first", limit: 255
    t.string "name_last", limit: 255
    t.string "location", limit: 255
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "idx_17345_index_user_profiles_on_user_id", unique: true
  end

  create_table "user_requests", force: :cascade do |t|
    t.string "type", limit: 255, null: false
    t.bigint "user_id", null: false
    t.bigint "status", default: 0, null: false
    t.bigint "source_id"
    t.bigint "dest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reviewer_id"
    t.bigint "entity_id"
    t.text "justification"
    t.bigint "list_id"
    t.index ["user_id"], name: "idx_17357_index_user_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "default_network_id"
    t.string "username", limit: 255, null: false
    t.string "remember_token", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean "newsletter"
    t.boolean "is_restricted", default: false
    t.boolean "map_the_power"
    t.text "about_me"
    t.integer "role", limit: 2, default: 0, null: false
    t.text "abilities"
    t.text "settings"
    t.index ["confirmation_token"], name: "idx_17317_index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "idx_17317_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_17317_index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "idx_17317_index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.bigint "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.bigint "entity1_id"
    t.bigint "entity2_id"
    t.text "association_data"
    t.bigint "other_id"
    t.index ["created_at"], name: "idx_17367_index_versions_on_created_at"
    t.index ["entity1_id"], name: "idx_17367_index_versions_on_entity1_id"
    t.index ["entity2_id"], name: "idx_17367_index_versions_on_entity2_id"
    t.index ["item_type", "item_id"], name: "idx_17367_index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "idx_17367_index_versions_on_whodunnit"
  end

  create_table "web_requests", force: :cascade do |t|
    t.string "remote_address", limit: 255
    t.datetime "time"
    t.string "host", limit: 255
    t.string "http_method", limit: 255
    t.text "uri"
    t.integer "status", limit: 2
    t.bigint "body_bytes"
    t.float "request_time"
    t.text "referer"
    t.text "user_agent"
    t.string "request_id", limit: 255, null: false
    t.index ["request_id"], name: "idx_34500_index_web_requests_on_request_id", unique: true
    t.index ["time"], name: "idx_34500_idx_web_requests_time"
    t.index ["time"], name: "idx_34500_index_web_requests_on_time"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "address", "address_category", column: "category_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "address", "entity", name: "address_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "addresses", "locations", on_update: :restrict, on_delete: :restrict
  add_foreign_key "alias", "entity", name: "alias_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "article", "article_source", column: "source_id", name: "article_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "business", "entity", name: "business_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_industry", "entity", column: "business_id", name: "business_industry_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_industry", "industry", name: "business_industry_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "business_person", "entity", name: "business_person_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "candidate_district", "political_district", column: "district_id", name: "candidate_district_ibfk_1", on_update: :restrict, on_delete: :restrict
  add_foreign_key "cmp_entities", "entity", on_update: :restrict, on_delete: :restrict
  add_foreign_key "donation", "entity", column: "bundler_id", name: "donation_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "donation", "relationship", name: "donation_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "education", "degree", name: "education_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "education", "relationship", name: "education_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "elected_representative", "entity", name: "elected_representative_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "email", "entity", name: "email_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "entity", "entity", column: "parent_id", name: "entity_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "entity", "users", column: "last_user_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "extension_definition", "extension_definition", column: "parent_id", name: "extension_definition_ibfk_1", on_update: :cascade, on_delete: :restrict
  add_foreign_key "extension_record", "entity", name: "extension_record_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "extension_record", "extension_definition", column: "definition_id", name: "extension_record_ibfk_2", on_update: :cascade, on_delete: :restrict
  add_foreign_key "external_relationships", "external_data", on_update: :restrict, on_delete: :cascade
  add_foreign_key "family", "relationship", name: "family_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "government_body", "address_state", column: "state_id", name: "government_body_ibfk_1", on_update: :cascade, on_delete: :restrict
  add_foreign_key "government_body", "entity", name: "government_body_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "image", "entity", name: "image_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "link", "entity", column: "entity1_id", name: "link_ibfk_3", on_update: :restrict, on_delete: :restrict
  add_foreign_key "link", "entity", column: "entity2_id", name: "link_ibfk_2", on_update: :restrict, on_delete: :restrict
  add_foreign_key "link", "relationship", name: "link_ibfk_1", on_update: :restrict, on_delete: :restrict
  add_foreign_key "link", "relationship_category", column: "category_id", name: "link_ibfk_4", on_update: :restrict, on_delete: :restrict
  add_foreign_key "lobby_filing_lobby_issue", "lobby_filing", name: "lobby_filing_lobby_issue_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobby_issue", "lobby_issue", column: "issue_id", name: "lobby_filing_lobby_issue_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobbyist", "entity", column: "lobbyist_id", name: "lobby_filing_lobbyist_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_lobbyist", "lobby_filing", name: "lobby_filing_lobbyist_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "lobby_filing_relationship", "lobby_filing", name: "lobby_filing_relationship_ibfk_2", on_update: :restrict, on_delete: :restrict
  add_foreign_key "lobby_filing_relationship", "relationship", name: "lobby_filing_relationship_ibfk_1", on_update: :restrict, on_delete: :restrict
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
  add_foreign_key "political_district", "address_state", column: "state_id", name: "political_district_ibfk_1", on_update: :cascade, on_delete: :restrict
  add_foreign_key "political_fundraising", "address_state", column: "state_id", name: "political_fundraising_ibfk_2", on_update: :cascade, on_delete: :restrict
  add_foreign_key "political_fundraising", "entity", name: "political_fundraising_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "position", "entity", column: "boss_id", name: "position_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "position", "relationship", name: "position_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "professional", "relationship", name: "professional_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "public_company", "entity", name: "public_company_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "entity", column: "entity1_id", name: "relationship_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "entity", column: "entity2_id", name: "relationship_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "relationship", "relationship_category", column: "category_id", name: "relationship_ibfk_3", on_update: :cascade, on_delete: :restrict
  add_foreign_key "relationship", "users", column: "last_user_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "representative", "entity", name: "representative_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "elected_representative", column: "representative_id", name: "representative_district_ibfk_3", on_update: :cascade, on_delete: :cascade
  add_foreign_key "representative_district", "political_district", column: "district_id", name: "representative_district_ibfk_4", on_update: :cascade, on_delete: :cascade
  add_foreign_key "school", "entity", name: "school_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "social", "relationship", name: "social_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "taggings", "users", column: "last_user_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "transaction", "entity", column: "contact1_id", name: "transaction_ibfk_3", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "entity", column: "contact2_id", name: "transaction_ibfk_2", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transaction", "relationship", name: "transaction_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_requests", "users", on_update: :restrict, on_delete: :restrict
end
