--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Debian 13.1-1.pgdg100+1)
-- Dumped by pg_dump version 13.2 (Debian 13.2-1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: network_map_link(bigint, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.network_map_link(id bigint, title text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT CONCAT('<a target="_blank" href="/maps/',
                CAST(id as text),
                '-',
                LOWER(REPLACE(REPLACE(TRIM(title), ' ', '-'), '/', '_')),
                '">',
                TRIM(title),
                '</a>');
$$;


--
-- Name: recent_entity_edits(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recent_entity_edits(history_limit integer, user_id text) RETURNS json
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  version_record RECORD;
  json_results json[];
BEGIN

        json_results := array[]::json[];

        FOR version_record IN
          SELECT id, item_type, item_id, entity1_id, entity2_id, whodunnit, created_at
  	  FROM versions
          WHERE entity1_id IS NOT NULL AND (CASE WHEN user_id is NOT NULL THEN whodunnit = user_id ELSE TRUE END)
          ORDER BY created_at desc
          LIMIT history_limit
        LOOP

          json_results := array_append(json_results,
                                       json_build_object('entity_id', version_record.entity1_id,
                                                         'version_id', version_record.id,
                                                         'item_type', version_record.item_type,
                                                         'item_id', version_record.item_id,
                                                         'user_id', version_record.whodunnit::integer,
                                                         'created_at', to_char(version_record.created_at, 'YYYY-MM-DD HH24:MI:SS')));

         IF version_record.entity2_id IS NOT NULL THEN
           json_results := array_append(json_results,
                                       json_build_object('entity_id', version_record.entity2_id,
                                                         'version_id', version_record.id,
                                                         'item_type', version_record.item_type,
                                                         'item_id', version_record.item_id,
                                                         'user_id', version_record.whodunnit::integer,
                                                         'created_at', to_char(version_record.created_at, 'YYYY-MM-DD HH24:MI:SS')));
         END IF;

        END LOOP;


        RETURN array_to_json(json_results);
END;

$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    record_type character varying(255) NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    content_type character varying(255),
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    service_name character varying(255) NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying(255) NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.address (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    street1 character varying(100),
    street2 character varying(100),
    street3 character varying(100),
    city character varying(50) NOT NULL,
    county character varying(50),
    state_id bigint,
    country_id bigint,
    postal character varying(20),
    latitude character varying(20),
    longitude character varying(20),
    category_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    last_user_id bigint,
    accuracy character varying(30),
    country_name character varying(50) NOT NULL,
    state_name character varying(50)
);


--
-- Name: address_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.address_category (
    id integer NOT NULL,
    name character varying(20) NOT NULL
);


--
-- Name: address_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.address_country (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


--
-- Name: address_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.address_id_seq OWNED BY public.address.id;


--
-- Name: address_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.address_state (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    abbreviation character varying(2) NOT NULL,
    country_id bigint NOT NULL
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    street1 text,
    street2 text,
    street3 text,
    city text,
    state character varying(255),
    country character varying(255),
    normalized_address text,
    location_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alias (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    name character varying(200) NOT NULL,
    context character varying(50),
    is_primary bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: alias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alias_id_seq OWNED BY public.alias.id;


--
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_tokens (
    id integer NOT NULL,
    token character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_tokens_id_seq OWNED BY public.api_tokens.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: article; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article (
    id bigint NOT NULL,
    url text NOT NULL,
    title character varying(200) NOT NULL,
    authors character varying(200),
    body text NOT NULL,
    description text,
    source_id bigint,
    published_at timestamp without time zone,
    is_indexed boolean DEFAULT false NOT NULL,
    reviewed_at timestamp without time zone,
    reviewed_by_user_id bigint,
    is_featured boolean DEFAULT false NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    found_at timestamp without time zone NOT NULL
);


--
-- Name: article_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_entities (
    id integer NOT NULL,
    article_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: article_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_entities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_entities_id_seq OWNED BY public.article_entities.id;


--
-- Name: article_entity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_entity (
    id integer NOT NULL,
    article_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    original_name character varying(100) NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    reviewed_by_user_id bigint,
    reviewed_at timestamp without time zone
);


--
-- Name: article_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_entity_id_seq OWNED BY public.article_entity.id;


--
-- Name: article_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_id_seq OWNED BY public.article.id;


--
-- Name: article_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_source (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    abbreviation character varying(10) NOT NULL
);


--
-- Name: article_source_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_source_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_source_id_seq OWNED BY public.article_source.id;


--
-- Name: articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.articles (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    snippet character varying(255),
    published_at timestamp without time zone,
    created_by_user_id character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.articles_id_seq OWNED BY public.articles.id;


--
-- Name: business; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business (
    id bigint NOT NULL,
    annual_profit bigint,
    entity_id bigint NOT NULL,
    assets numeric,
    marketcap numeric,
    net_income bigint,
    aum bigint
);


--
-- Name: business_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_id_seq OWNED BY public.business.id;


--
-- Name: business_industry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_industry (
    id bigint NOT NULL,
    business_id bigint NOT NULL,
    industry_id bigint NOT NULL
);


--
-- Name: business_industry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_industry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_industry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_industry_id_seq OWNED BY public.business_industry.id;


--
-- Name: business_person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_person (
    id bigint NOT NULL,
    sec_cik bigint,
    entity_id bigint NOT NULL
);


--
-- Name: business_person_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_person_id_seq OWNED BY public.business_person.id;


--
-- Name: candidate_district; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.candidate_district (
    id bigint NOT NULL,
    candidate_id bigint NOT NULL,
    district_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: candidate_district_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.candidate_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidate_district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.candidate_district_id_seq OWNED BY public.candidate_district.id;


--
-- Name: cmp_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cmp_entities (
    id bigint NOT NULL,
    entity_id bigint,
    cmp_id bigint,
    entity_type smallint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    strata smallint
);


--
-- Name: cmp_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cmp_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cmp_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cmp_entities_id_seq OWNED BY public.cmp_entities.id;


--
-- Name: cmp_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cmp_relationships (
    id bigint NOT NULL,
    cmp_affiliation_id character varying(255) NOT NULL,
    cmp_org_id bigint NOT NULL,
    cmp_person_id bigint NOT NULL,
    relationship_id bigint,
    status19 smallint
);


--
-- Name: cmp_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cmp_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cmp_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cmp_relationships_id_seq OWNED BY public.cmp_relationships.id;


--
-- Name: common_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.common_names (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: common_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.common_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: common_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.common_names_id_seq OWNED BY public.common_names.id;


--
-- Name: couple; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.couple (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    partner1_id bigint,
    partner2_id bigint
);


--
-- Name: couple_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.couple_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: couple_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.couple_id_seq OWNED BY public.couple.id;


--
-- Name: custom_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_key (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    value text,
    description character varying(200),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    object_model character varying(50) NOT NULL,
    object_id bigint NOT NULL
);


--
-- Name: custom_key_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_key_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_key_id_seq OWNED BY public.custom_key.id;


--
-- Name: dashboard_bulletins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_bulletins (
    id bigint NOT NULL,
    markdown text,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    color character varying(255)
);


--
-- Name: dashboard_bulletins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_bulletins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_bulletins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_bulletins_id_seq OWNED BY public.dashboard_bulletins.id;


--
-- Name: degree; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.degree (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    abbreviation character varying(10)
);


--
-- Name: degree_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.degree_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: degree_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.degree_id_seq OWNED BY public.degree.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    priority bigint DEFAULT 0 NOT NULL,
    attempts bigint DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    name character varying(255),
    url text,
    url_hash character varying(40),
    publication_date character varying(10),
    ref_type bigint DEFAULT 1 NOT NULL,
    excerpt text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: donation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.donation (
    id bigint NOT NULL,
    bundler_id bigint,
    relationship_id bigint NOT NULL
);


--
-- Name: donation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.donation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.donation_id_seq OWNED BY public.donation.id;


--
-- Name: edited_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edited_entities (
    id bigint NOT NULL,
    user_id bigint,
    version_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: edited_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.edited_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edited_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.edited_entities_id_seq OWNED BY public.edited_entities.id;


--
-- Name: education; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.education (
    id bigint NOT NULL,
    degree_id bigint,
    field character varying(30),
    is_dropout boolean,
    relationship_id bigint NOT NULL
);


--
-- Name: education_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.education_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: education_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.education_id_seq OWNED BY public.education.id;


--
-- Name: elected_representative; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elected_representative (
    id bigint NOT NULL,
    bioguide_id character varying(20),
    govtrack_id character varying(20),
    crp_id character varying(20),
    pvs_id character varying(20),
    watchdog_id character varying(50),
    entity_id bigint NOT NULL,
    fec_ids text
);


--
-- Name: elected_representative_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.elected_representative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elected_representative_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.elected_representative_id_seq OWNED BY public.elected_representative.id;


--
-- Name: email; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    address character varying(60) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    last_user_id bigint
);


--
-- Name: email_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_id_seq OWNED BY public.email.id;


--
-- Name: entity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity (
    id bigint NOT NULL,
    name text,
    blurb text,
    summary text,
    notes text,
    website text,
    parent_id bigint,
    primary_ext character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    start_date character varying(10),
    end_date character varying(10),
    is_current boolean,
    is_deleted boolean DEFAULT false NOT NULL,
    last_user_id bigint,
    merged_id bigint,
    delta boolean DEFAULT true NOT NULL,
    link_count bigint DEFAULT 0 NOT NULL
);


--
-- Name: entity_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_fields (
    id bigint NOT NULL,
    entity_id bigint,
    field_id bigint,
    value text NOT NULL,
    is_admin boolean DEFAULT false
);


--
-- Name: entity_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_fields_id_seq OWNED BY public.entity_fields.id;


--
-- Name: entity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_id_seq OWNED BY public.entity.id;


--
-- Name: example; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.example (
    word character varying(100),
    year bigint,
    cand_id character varying(100)
);


--
-- Name: extension_definition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extension_definition (
    id bigint NOT NULL,
    name character varying(30) NOT NULL,
    display_name character varying(50) NOT NULL,
    has_fields boolean DEFAULT false NOT NULL,
    parent_id bigint,
    tier bigint
);


--
-- Name: extension_definition_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extension_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extension_definition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extension_definition_id_seq OWNED BY public.extension_definition.id;


--
-- Name: extension_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extension_record (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    definition_id bigint NOT NULL,
    last_user_id bigint
);


--
-- Name: extension_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extension_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extension_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extension_record_id_seq OWNED BY public.extension_record.id;


--
-- Name: external_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data (
    id bigint NOT NULL,
    dataset smallint NOT NULL,
    dataset_id character varying(255) NOT NULL,
    data text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_data_fec_candidates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_fec_candidates (
    id bigint NOT NULL,
    cand_id character varying(255) NOT NULL,
    cand_name text,
    cand_pty_affiliation character varying(255),
    cand_election_yr smallint,
    cand_office_st character varying(2),
    cand_office character varying(1),
    cand_office_district character varying(2),
    cand_ici character varying(1),
    cand_status character varying(1),
    cand_pcc text,
    cand_st1 text,
    cand_st2 text,
    cand_city text,
    cand_st character varying(2),
    cand_zip character varying(255),
    fec_year smallint NOT NULL
);


--
-- Name: external_data_fec_candidates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_data_fec_candidates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_data_fec_candidates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_data_fec_candidates_id_seq OWNED BY public.external_data_fec_candidates.id;


--
-- Name: external_data_fec_committees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_fec_committees (
    id bigint NOT NULL,
    cmte_id character varying(255) NOT NULL,
    cmte_nm text,
    tres_nm text,
    cmte_st1 text,
    cmte_st2 text,
    cmte_city text,
    cmte_st character varying(2),
    cmte_zip character varying(255),
    cmte_dsgn character varying(1),
    cmte_tp character varying(2),
    cmte_pty_affiliation text,
    cmte_filing_freq character varying(1),
    org_tp character varying(1),
    connected_org_nm text,
    cand_id character varying(255),
    fec_year smallint NOT NULL
);


--
-- Name: external_data_fec_committees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_data_fec_committees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_data_fec_committees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_data_fec_committees_id_seq OWNED BY public.external_data_fec_committees.id;


--
-- Name: external_data_fec_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_fec_contributions (
    sub_id bigint NOT NULL,
    cmte_id character varying(255) NOT NULL,
    amndt_ind text,
    rpt_tp text,
    transaction_pgi text,
    image_num character varying(255),
    transaction_tp character varying(255),
    entity_tp character varying(255),
    name text,
    city text,
    state text,
    zip_code text,
    employer text,
    occupation text,
    transaction_dt text,
    transaction_amt numeric(10,0),
    other_id character varying(255),
    tran_id character varying(255),
    file_num bigint,
    memo_cd text,
    memo_text text,
    fec_year smallint NOT NULL
);


--
-- Name: external_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_data_id_seq OWNED BY public.external_data.id;


--
-- Name: external_data_nycc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_nycc (
    district bigint NOT NULL,
    personid smallint NOT NULL,
    council_district text,
    last_name text,
    first_name text,
    full_name text,
    photo_url text,
    twitter text,
    email text,
    party text,
    website text,
    gender text,
    title text,
    district_office text,
    legislative_office text
);


--
-- Name: external_data_nys_disclosures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_nys_disclosures (
    filer_id bigint NOT NULL,
    filer_previous_id text,
    cand_comm_name text,
    election_year bigint,
    election_type text,
    county_desc text,
    filing_abbrev character varying(1),
    filing_desc text,
    filing_cat_desc text,
    filing_sched_abbrev text,
    filing_sched_desc text,
    loan_lib_number text,
    trans_number character varying(255) NOT NULL,
    trans_mapping text,
    sched_date timestamp without time zone,
    org_date timestamp without time zone,
    cntrbr_type_desc text,
    cntrbn_type_desc text,
    transfer_type_desc text,
    receipt_type_desc text,
    receipt_code_desc text,
    purpose_code_desc text,
    r_subcontractor text,
    flng_ent_name text,
    flng_ent_first_name text,
    flng_ent_middle_name text,
    flng_ent_last_name text,
    flng_ent_add1 text,
    flng_ent_city text,
    flng_ent_state text,
    flng_ent_zip text,
    flng_ent_country text,
    payment_type_desc text,
    pay_number text,
    owned_amt double precision,
    org_amt double precision,
    loan_other_desc text,
    trans_explntn text,
    r_itemized character varying(1),
    r_liability character varying(1),
    election_year_str text,
    office_desc text,
    district text,
    dist_off_cand_bal_prop text,
    r_amend character varying(1)
);


--
-- Name: external_data_nys_filers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_data_nys_filers (
    id bigint NOT NULL,
    filer_id bigint NOT NULL,
    filer_name text,
    compliance_type_desc text,
    filter_type_desc text,
    filter_status text,
    committee_type_desc text,
    office_desc text,
    district text,
    county_desc text,
    municipality_subdivision_desc text,
    treasurer_first_name text,
    treasurer_middle_name text,
    treasurer_last_name text,
    address text,
    city text,
    state text,
    zipcode text
);


--
-- Name: external_data_nys_filers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_data_nys_filers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_data_nys_filers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_data_nys_filers_id_seq OWNED BY public.external_data_nys_filers.id;


--
-- Name: external_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_entities (
    id bigint NOT NULL,
    dataset smallint NOT NULL,
    match_data text,
    external_data_id bigint,
    entity_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    primary_ext character varying(6)
);


--
-- Name: external_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_entities_id_seq OWNED BY public.external_entities.id;


--
-- Name: external_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_links (
    id bigint NOT NULL,
    link_type smallint NOT NULL,
    entity_id bigint NOT NULL,
    link_id text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_links_id_seq OWNED BY public.external_links.id;


--
-- Name: external_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_relationships (
    id bigint NOT NULL,
    external_data_id bigint NOT NULL,
    relationship_id bigint,
    dataset smallint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    entity1_id bigint,
    entity2_id bigint,
    category_id smallint NOT NULL
);


--
-- Name: external_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_relationships_id_seq OWNED BY public.external_relationships.id;


--
-- Name: family; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.family (
    id bigint NOT NULL,
    is_nonbiological boolean,
    relationship_id bigint NOT NULL
);


--
-- Name: family_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.family_id_seq OWNED BY public.family.id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    type character varying(255) DEFAULT 'string'::character varying NOT NULL
);


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fields_id_seq OWNED BY public.fields.id;


--
-- Name: generic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generic (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL
);


--
-- Name: generic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.generic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: generic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.generic_id_seq OWNED BY public.generic.id;


--
-- Name: government_body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_body (
    id bigint NOT NULL,
    is_federal boolean,
    state_id bigint,
    city character varying(50),
    county character varying(50),
    entity_id bigint NOT NULL
);


--
-- Name: government_body_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_body_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_body_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_body_id_seq OWNED BY public.government_body.id;


--
-- Name: help_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_pages (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    markdown text,
    last_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: help_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_pages_id_seq OWNED BY public.help_pages.id;


--
-- Name: hierarchy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hierarchy (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL
);


--
-- Name: hierarchy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hierarchy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hierarchy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hierarchy_id_seq OWNED BY public.hierarchy.id;


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    id bigint NOT NULL,
    entity_id bigint,
    filename character varying(100) NOT NULL,
    caption text,
    is_featured boolean DEFAULT false NOT NULL,
    is_free boolean,
    url character varying(400),
    width bigint,
    height bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    has_square boolean DEFAULT false NOT NULL,
    address_id bigint,
    raw_address character varying(200),
    has_face boolean DEFAULT false NOT NULL,
    user_id bigint
);


--
-- Name: image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_id_seq OWNED BY public.image.id;


--
-- Name: industries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.industries (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    industry_id character varying(255) NOT NULL,
    sector_name character varying(255) NOT NULL
);


--
-- Name: industries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.industries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: industries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.industries_id_seq OWNED BY public.industries.id;


--
-- Name: industry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.industry (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    context character varying(30),
    code character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: industry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.industry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: industry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.industry_id_seq OWNED BY public.industry.id;


--
-- Name: link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link (
    id bigint NOT NULL,
    entity1_id bigint NOT NULL,
    entity2_id bigint NOT NULL,
    category_id bigint NOT NULL,
    relationship_id bigint NOT NULL,
    is_reverse boolean NOT NULL
);


--
-- Name: link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_id_seq OWNED BY public.link.id;


--
-- Name: lobby_filing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_filing (
    id bigint NOT NULL,
    federal_filing_id character varying(50) NOT NULL,
    amount bigint,
    year bigint,
    period character varying(100),
    report_type character varying(100),
    start_date character varying(10),
    end_date character varying(10),
    is_current boolean
);


--
-- Name: lobby_filing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobby_filing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobby_filing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobby_filing_id_seq OWNED BY public.lobby_filing.id;


--
-- Name: lobby_filing_lobby_issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_filing_lobby_issue (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    lobby_filing_id bigint NOT NULL,
    specific_issue text
);


--
-- Name: lobby_filing_lobby_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobby_filing_lobby_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobby_filing_lobby_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobby_filing_lobby_issue_id_seq OWNED BY public.lobby_filing_lobby_issue.id;


--
-- Name: lobby_filing_lobbyist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_filing_lobbyist (
    id bigint NOT NULL,
    lobbyist_id bigint NOT NULL,
    lobby_filing_id bigint NOT NULL
);


--
-- Name: lobby_filing_lobbyist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobby_filing_lobbyist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobby_filing_lobbyist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobby_filing_lobbyist_id_seq OWNED BY public.lobby_filing_lobbyist.id;


--
-- Name: lobby_filing_relationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_filing_relationship (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL,
    lobby_filing_id bigint NOT NULL
);


--
-- Name: lobby_filing_relationship_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobby_filing_relationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobby_filing_relationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobby_filing_relationship_id_seq OWNED BY public.lobby_filing_relationship.id;


--
-- Name: lobby_issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_issue (
    id bigint NOT NULL,
    name character varying(50) NOT NULL
);


--
-- Name: lobby_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobby_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobby_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobby_issue_id_seq OWNED BY public.lobby_issue.id;


--
-- Name: lobbying; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobbying (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL
);


--
-- Name: lobbying_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobbying_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobbying_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobbying_id_seq OWNED BY public.lobbying.id;


--
-- Name: lobbyist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobbyist (
    id bigint NOT NULL,
    lda_registrant_id bigint,
    entity_id bigint NOT NULL
);


--
-- Name: lobbyist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lobbyist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lobbyist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lobbyist_id_seq OWNED BY public.lobbyist.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    city text,
    country text,
    subregion text,
    region smallint,
    lat numeric(10,0),
    lng numeric(10,0),
    entity_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: ls_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ls_list (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_ranked boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    display_name character varying(50),
    featured_list_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_user_id bigint,
    is_deleted boolean DEFAULT false NOT NULL,
    custom_field_name character varying(100),
    delta boolean DEFAULT true NOT NULL,
    creator_user_id bigint,
    short_description character varying(255),
    access smallint DEFAULT 0 NOT NULL,
    entity_count bigint DEFAULT 0,
    sort_by character varying(255)
);


--
-- Name: ls_list_entity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ls_list_entity (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    rank integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_user_id bigint,
    custom_field text
);


--
-- Name: ls_list_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ls_list_entity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ls_list_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ls_list_entity_id_seq OWNED BY public.ls_list_entity.id;


--
-- Name: ls_list_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ls_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ls_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ls_list_id_seq OWNED BY public.ls_list.id;


--
-- Name: map_annotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.map_annotations (
    id bigint NOT NULL,
    map_id bigint NOT NULL,
    "order" bigint NOT NULL,
    title character varying(255),
    description text,
    highlighted_entity_ids character varying(255),
    highlighted_rel_ids character varying(255),
    highlighted_text_ids character varying(255)
);


--
-- Name: map_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.map_annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: map_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.map_annotations_id_seq OWNED BY public.map_annotations.id;


--
-- Name: membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership (
    id bigint NOT NULL,
    dues bigint,
    relationship_id bigint NOT NULL,
    elected_term text
);


--
-- Name: membership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: membership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.membership_id_seq OWNED BY public.membership.id;


--
-- Name: network_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.network_map (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    entity_ids text,
    rel_ids text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    title text,
    description text,
    width bigint NOT NULL,
    height bigint NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    zoom character varying(255) DEFAULT '1'::character varying NOT NULL,
    is_private boolean DEFAULT false NOT NULL,
    thumbnail text,
    delta boolean DEFAULT true NOT NULL,
    index_data text,
    secret character varying(255),
    graph_data text,
    annotations_data text,
    annotations_count bigint DEFAULT 0 NOT NULL,
    list_sources boolean DEFAULT false NOT NULL,
    is_cloneable boolean DEFAULT true NOT NULL,
    oligrapher_version smallint DEFAULT 2 NOT NULL,
    editors text,
    settings text,
    screenshot text
);


--
-- Name: network_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.network_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: network_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.network_map_id_seq OWNED BY public.network_map.id;


--
-- Name: ny_disclosures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ny_disclosures (
    id bigint NOT NULL,
    filer_id character varying(10) NOT NULL,
    report_id character varying(255),
    transaction_code character varying(1) NOT NULL,
    e_year character varying(4) NOT NULL,
    transaction_id bigint NOT NULL,
    schedule_transaction_date date,
    original_date date,
    contrib_code character varying(4),
    contrib_type_code character varying(1),
    corp_name character varying(255),
    first_name character varying(255),
    mid_init character varying(255),
    last_name character varying(255),
    address character varying(255),
    city character varying(255),
    state character varying(2),
    zip character varying(5),
    check_number character varying(255),
    check_date character varying(255),
    amount1 double precision,
    amount2 double precision,
    description character varying(255),
    other_recpt_code character varying(255),
    purpose_code1 character varying(255),
    purpose_code2 character varying(255),
    explanation character varying(255),
    transfer_type character varying(1),
    bank_loan_check_box character varying(1),
    crerec_uid character varying(255),
    crerec_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    delta boolean DEFAULT true NOT NULL
);


--
-- Name: ny_disclosures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ny_disclosures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ny_disclosures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ny_disclosures_id_seq OWNED BY public.ny_disclosures.id;


--
-- Name: ny_filer_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ny_filer_entities (
    id bigint NOT NULL,
    ny_filer_id bigint,
    entity_id bigint,
    is_committee boolean,
    cmte_entity_id bigint,
    e_year character varying(4),
    filer_id character varying(255),
    office character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ny_filer_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ny_filer_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ny_filer_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ny_filer_entities_id_seq OWNED BY public.ny_filer_entities.id;


--
-- Name: ny_filers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ny_filers (
    id bigint NOT NULL,
    filer_id character varying(255) NOT NULL,
    name character varying(255),
    filer_type character varying(255),
    status character varying(255),
    committee_type character varying(255),
    office bigint,
    district bigint,
    treas_first_name character varying(255),
    treas_last_name character varying(255),
    address character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ny_filers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ny_filers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ny_filers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ny_filers_id_seq OWNED BY public.ny_filers.id;


--
-- Name: ny_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ny_matches (
    id bigint NOT NULL,
    ny_disclosure_id bigint,
    donor_id bigint,
    recip_id bigint,
    relationship_id bigint,
    matched_by bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ny_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ny_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ny_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ny_matches_id_seq OWNED BY public.ny_matches.id;


--
-- Name: object_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_tag (
    id bigint NOT NULL,
    tag_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    object_model character varying(50) NOT NULL,
    object_id bigint NOT NULL,
    last_user_id bigint
);


--
-- Name: object_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_tag_id_seq OWNED BY public.object_tag.id;


--
-- Name: org; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org (
    id bigint NOT NULL,
    name text NOT NULL,
    name_nick character varying(100),
    employees bigint,
    revenue bigint,
    fedspending_id character varying(10),
    lda_registrant_id character varying(10),
    entity_id bigint NOT NULL
);


--
-- Name: org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.org_id_seq OWNED BY public.org.id;


--
-- Name: os_candidates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_candidates (
    id bigint NOT NULL,
    cycle character varying(255) NOT NULL,
    feccandid character varying(255) NOT NULL,
    crp_id character varying(255) NOT NULL,
    name character varying(255),
    party character varying(1),
    distid_runfor character varying(255),
    distid_current character varying(255),
    currcand boolean,
    cyclecand boolean,
    crpico character varying(1),
    recipcode character varying(2),
    nopacs character varying(1),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: os_candidates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_candidates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_candidates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_candidates_id_seq OWNED BY public.os_candidates.id;


--
-- Name: os_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_category (
    id bigint NOT NULL,
    category_id character varying(10) NOT NULL,
    category_name character varying(100) NOT NULL,
    industry_id character varying(10) NOT NULL,
    industry_name character varying(100) NOT NULL,
    sector_name character varying(100) NOT NULL
);


--
-- Name: os_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_category_id_seq OWNED BY public.os_category.id;


--
-- Name: os_committees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_committees (
    id bigint NOT NULL,
    cycle character varying(4) NOT NULL,
    cmte_id character varying(255) NOT NULL,
    name character varying(255),
    affiliate character varying(255),
    ultorg character varying(255),
    recipid character varying(255),
    recipcode character varying(2),
    feccandid character varying(255),
    party character varying(1),
    primcode character varying(5),
    source character varying(255),
    sensitive boolean,
    "foreign" boolean,
    active_in_cycle boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: os_committees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_committees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_committees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_committees_id_seq OWNED BY public.os_committees.id;


--
-- Name: os_donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_donations (
    id bigint NOT NULL,
    cycle character varying(4) NOT NULL,
    fectransid character varying(19) NOT NULL,
    contribid character varying(12),
    contrib character varying(255),
    recipid character varying(9),
    orgname character varying(255),
    ultorg character varying(255),
    realcode character varying(5),
    date date,
    amount bigint,
    street character varying(255),
    city character varying(255),
    state character varying(2),
    zip character varying(5),
    recipcode character varying(2),
    transactiontype character varying(3),
    cmteid character varying(9),
    otherid character varying(9),
    gender character varying(1),
    microfilm character varying(30),
    occupation character varying(255),
    employer character varying(255),
    source character varying(5),
    fec_cycle_id character varying(24) NOT NULL,
    name_last character varying(255),
    name_first character varying(255),
    name_middle character varying(255),
    name_suffix character varying(255),
    name_prefix character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: os_donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_donations_id_seq OWNED BY public.os_donations.id;


--
-- Name: os_entity_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_entity_category (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    category_id character varying(10) NOT NULL,
    source character varying(200),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: os_entity_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_entity_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_entity_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_entity_category_id_seq OWNED BY public.os_entity_category.id;


--
-- Name: os_entity_donor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_entity_donor (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    donor_id character varying(12),
    match_code bigint,
    is_verified boolean DEFAULT false NOT NULL,
    reviewed_by_user_id bigint,
    is_processed boolean DEFAULT false NOT NULL,
    is_synced boolean DEFAULT true NOT NULL,
    reviewed_at timestamp without time zone,
    locked_by_user_id bigint,
    locked_at timestamp without time zone
);


--
-- Name: os_entity_donor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_entity_donor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_entity_donor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_entity_donor_id_seq OWNED BY public.os_entity_donor.id;


--
-- Name: os_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os_matches (
    id bigint NOT NULL,
    os_donation_id bigint NOT NULL,
    donation_id bigint,
    donor_id bigint NOT NULL,
    recip_id bigint,
    relationship_id bigint,
    matched_by bigint,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    cmte_id bigint
);


--
-- Name: os_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_matches_id_seq OWNED BY public.os_matches.id;


--
-- Name: ownership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ownership (
    id bigint NOT NULL,
    percent_stake bigint,
    shares bigint,
    relationship_id bigint NOT NULL
);


--
-- Name: ownership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ownership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ownership_id_seq OWNED BY public.ownership.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    markdown text,
    last_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: permission_passes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_passes (
    id bigint NOT NULL,
    event_name character varying(255),
    token character varying(255) NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    valid_to timestamp without time zone NOT NULL,
    abilities text NOT NULL,
    creator_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permission_passes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_passes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_passes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_passes_id_seq OWNED BY public.permission_passes.id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person (
    id bigint NOT NULL,
    name_last character varying(50) NOT NULL,
    name_first character varying(50) NOT NULL,
    name_middle character varying(50),
    name_prefix character varying(30),
    name_suffix character varying(30),
    name_nick character varying(30),
    birthplace character varying(50),
    gender_id bigint,
    party_id bigint,
    is_independent boolean,
    net_worth bigint,
    entity_id bigint NOT NULL,
    name_maiden character varying(50),
    nationality text
);


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: phone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phone (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    number character varying(20) NOT NULL,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    last_user_id bigint
);


--
-- Name: phone_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phone_id_seq OWNED BY public.phone.id;


--
-- Name: political_candidate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_candidate (
    id bigint NOT NULL,
    is_federal boolean,
    is_state boolean,
    is_local boolean,
    pres_fec_id character varying(20),
    senate_fec_id character varying(20),
    house_fec_id character varying(20),
    crp_id character varying(20),
    entity_id bigint NOT NULL
);


--
-- Name: political_candidate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_candidate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_candidate_id_seq OWNED BY public.political_candidate.id;


--
-- Name: political_district; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_district (
    id bigint NOT NULL,
    state_id bigint,
    federal_district character varying(2),
    state_district character varying(2),
    local_district character varying(2)
);


--
-- Name: political_district_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_district_id_seq OWNED BY public.political_district.id;


--
-- Name: political_fundraising; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_fundraising (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    fec_id character varying(20),
    type_id bigint,
    state_id bigint
);


--
-- Name: political_fundraising_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_fundraising_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_fundraising_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_fundraising_id_seq OWNED BY public.political_fundraising.id;


--
-- Name: political_fundraising_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.political_fundraising_type (
    id bigint NOT NULL,
    name character varying(50) NOT NULL
);


--
-- Name: political_fundraising_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.political_fundraising_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: political_fundraising_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.political_fundraising_type_id_seq OWNED BY public.political_fundraising_type.id;


--
-- Name: position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."position" (
    id bigint NOT NULL,
    is_board boolean,
    is_executive boolean,
    is_employee boolean,
    compensation bigint,
    boss_id bigint,
    relationship_id bigint NOT NULL
);


--
-- Name: position_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.position_id_seq OWNED BY public."position".id;


--
-- Name: professional; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professional (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL
);


--
-- Name: professional_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.professional_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: professional_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.professional_id_seq OWNED BY public.professional.id;


--
-- Name: public_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_company (
    id bigint NOT NULL,
    ticker character varying(10),
    sec_cik bigint,
    entity_id bigint NOT NULL
);


--
-- Name: public_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.public_company_id_seq OWNED BY public.public_company.id;


--
-- Name: references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."references" (
    id bigint NOT NULL,
    document_id bigint NOT NULL,
    referenceable_id bigint NOT NULL,
    referenceable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.references_id_seq OWNED BY public."references".id;


--
-- Name: relationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationship (
    id bigint NOT NULL,
    entity1_id bigint NOT NULL,
    entity2_id bigint NOT NULL,
    category_id bigint NOT NULL,
    description1 character varying(100),
    description2 character varying(100),
    amount bigint,
    currency character varying(255),
    goods text,
    filings bigint,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    start_date character varying(10),
    end_date character varying(10),
    is_current boolean,
    is_deleted boolean DEFAULT false NOT NULL,
    last_user_id bigint,
    amount2 bigint,
    is_gte boolean DEFAULT false NOT NULL
);


--
-- Name: relationship_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationship_category (
    id bigint NOT NULL,
    name character varying(30) NOT NULL,
    display_name character varying(30) NOT NULL,
    default_description character varying(50),
    entity1_requirements text,
    entity2_requirements text,
    has_fields boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: relationship_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relationship_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationship_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relationship_category_id_seq OWNED BY public.relationship_category.id;


--
-- Name: relationship_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relationship_id_seq OWNED BY public.relationship.id;


--
-- Name: representative; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representative (
    id bigint NOT NULL,
    bioguide_id character varying(20),
    entity_id bigint NOT NULL
);


--
-- Name: representative_district; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representative_district (
    id bigint NOT NULL,
    representative_id bigint NOT NULL,
    district_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: representative_district_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.representative_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representative_district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.representative_district_id_seq OWNED BY public.representative_district.id;


--
-- Name: representative_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.representative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representative_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.representative_id_seq OWNED BY public.representative.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: school; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school (
    id bigint NOT NULL,
    endowment bigint,
    students bigint,
    faculty bigint,
    tuition bigint,
    is_private boolean,
    entity_id bigint NOT NULL
);


--
-- Name: school_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.school_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: school_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.school_id_seq OWNED BY public.school.id;


--
-- Name: social; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.social (
    id bigint NOT NULL,
    relationship_id bigint NOT NULL
);


--
-- Name: social_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.social_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.social_id_seq OWNED BY public.social.id;


--
-- Name: sphinx_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sphinx_index (
    name character varying(50) NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: swamp_tips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.swamp_tips (
    id bigint NOT NULL,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: swamp_tips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.swamp_tips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: swamp_tips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.swamp_tips_id_seq OWNED BY public.swamp_tips.id;


--
-- Name: tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag (
    id bigint NOT NULL,
    name character varying(100),
    is_visible boolean DEFAULT true NOT NULL,
    triple_namespace character varying(30),
    triple_predicate character varying(30),
    triple_value character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id bigint NOT NULL,
    tag_id bigint NOT NULL,
    tagable_class character varying(255) NOT NULL,
    tagable_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_user_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    restricted boolean DEFAULT false,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: toolkit_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.toolkit_pages (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    markdown text,
    last_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: toolkit_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.toolkit_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: toolkit_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.toolkit_pages_id_seq OWNED BY public.toolkit_pages.id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction (
    id bigint NOT NULL,
    contact1_id bigint,
    contact2_id bigint,
    district_id bigint,
    is_lobbying boolean,
    relationship_id bigint NOT NULL
);


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: unmatched_ny_filers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unmatched_ny_filers (
    id bigint NOT NULL,
    ny_filer_id bigint NOT NULL,
    disclosure_count bigint NOT NULL
);


--
-- Name: unmatched_ny_filers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unmatched_ny_filers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unmatched_ny_filers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unmatched_ny_filers_id_seq OWNED BY public.unmatched_ny_filers.id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_permissions (
    id bigint NOT NULL,
    user_id bigint,
    resource_type character varying(255) NOT NULL,
    access_rules text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_permissions_id_seq OWNED BY public.user_permissions.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_profiles (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    name_first character varying(255),
    name_last character varying(255),
    location character varying(255),
    reason text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;


--
-- Name: user_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_requests (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    status bigint DEFAULT 0 NOT NULL,
    source_id bigint,
    dest_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reviewer_id bigint,
    entity_id bigint,
    justification text,
    list_id bigint
);


--
-- Name: user_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_requests_id_seq OWNED BY public.user_requests.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count bigint DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_network_id bigint,
    username character varying(255) NOT NULL,
    remember_token character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    newsletter boolean,
    is_restricted boolean DEFAULT false,
    map_the_power boolean,
    about_me text,
    role smallint DEFAULT 0 NOT NULL,
    abilities text,
    settings text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id bigint NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text,
    entity1_id bigint,
    entity2_id bigint,
    association_data text,
    other_id bigint
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: web_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_requests (
    id bigint NOT NULL,
    remote_address character varying(255),
    "time" timestamp without time zone,
    host character varying(255),
    http_method character varying(255),
    uri text,
    status smallint,
    body_bytes bigint,
    request_time double precision,
    referer text,
    user_agent text,
    request_id character varying(255) NOT NULL
);


--
-- Name: web_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_requests_id_seq OWNED BY public.web_requests.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: address id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address ALTER COLUMN id SET DEFAULT nextval('public.address_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: alias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alias ALTER COLUMN id SET DEFAULT nextval('public.alias_id_seq'::regclass);


--
-- Name: api_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens ALTER COLUMN id SET DEFAULT nextval('public.api_tokens_id_seq'::regclass);


--
-- Name: article id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article ALTER COLUMN id SET DEFAULT nextval('public.article_id_seq'::regclass);


--
-- Name: article_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_entities ALTER COLUMN id SET DEFAULT nextval('public.article_entities_id_seq'::regclass);


--
-- Name: article_entity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_entity ALTER COLUMN id SET DEFAULT nextval('public.article_entity_id_seq'::regclass);


--
-- Name: article_source id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_source ALTER COLUMN id SET DEFAULT nextval('public.article_source_id_seq'::regclass);


--
-- Name: articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles ALTER COLUMN id SET DEFAULT nextval('public.articles_id_seq'::regclass);


--
-- Name: business id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business ALTER COLUMN id SET DEFAULT nextval('public.business_id_seq'::regclass);


--
-- Name: business_industry id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_industry ALTER COLUMN id SET DEFAULT nextval('public.business_industry_id_seq'::regclass);


--
-- Name: business_person id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_person ALTER COLUMN id SET DEFAULT nextval('public.business_person_id_seq'::regclass);


--
-- Name: candidate_district id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_district ALTER COLUMN id SET DEFAULT nextval('public.candidate_district_id_seq'::regclass);


--
-- Name: cmp_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cmp_entities ALTER COLUMN id SET DEFAULT nextval('public.cmp_entities_id_seq'::regclass);


--
-- Name: cmp_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cmp_relationships ALTER COLUMN id SET DEFAULT nextval('public.cmp_relationships_id_seq'::regclass);


--
-- Name: common_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.common_names ALTER COLUMN id SET DEFAULT nextval('public.common_names_id_seq'::regclass);


--
-- Name: couple id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.couple ALTER COLUMN id SET DEFAULT nextval('public.couple_id_seq'::regclass);


--
-- Name: custom_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_key ALTER COLUMN id SET DEFAULT nextval('public.custom_key_id_seq'::regclass);


--
-- Name: dashboard_bulletins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_bulletins ALTER COLUMN id SET DEFAULT nextval('public.dashboard_bulletins_id_seq'::regclass);


--
-- Name: degree id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.degree ALTER COLUMN id SET DEFAULT nextval('public.degree_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: donation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donation ALTER COLUMN id SET DEFAULT nextval('public.donation_id_seq'::regclass);


--
-- Name: edited_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edited_entities ALTER COLUMN id SET DEFAULT nextval('public.edited_entities_id_seq'::regclass);


--
-- Name: education id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education ALTER COLUMN id SET DEFAULT nextval('public.education_id_seq'::regclass);


--
-- Name: elected_representative id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elected_representative ALTER COLUMN id SET DEFAULT nextval('public.elected_representative_id_seq'::regclass);


--
-- Name: email id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email ALTER COLUMN id SET DEFAULT nextval('public.email_id_seq'::regclass);


--
-- Name: entity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity ALTER COLUMN id SET DEFAULT nextval('public.entity_id_seq'::regclass);


--
-- Name: entity_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_fields ALTER COLUMN id SET DEFAULT nextval('public.entity_fields_id_seq'::regclass);


--
-- Name: extension_definition id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_definition ALTER COLUMN id SET DEFAULT nextval('public.extension_definition_id_seq'::regclass);


--
-- Name: extension_record id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_record ALTER COLUMN id SET DEFAULT nextval('public.extension_record_id_seq'::regclass);


--
-- Name: external_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data ALTER COLUMN id SET DEFAULT nextval('public.external_data_id_seq'::regclass);


--
-- Name: external_data_fec_candidates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_fec_candidates ALTER COLUMN id SET DEFAULT nextval('public.external_data_fec_candidates_id_seq'::regclass);


--
-- Name: external_data_fec_committees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_fec_committees ALTER COLUMN id SET DEFAULT nextval('public.external_data_fec_committees_id_seq'::regclass);


--
-- Name: external_data_nys_filers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_nys_filers ALTER COLUMN id SET DEFAULT nextval('public.external_data_nys_filers_id_seq'::regclass);


--
-- Name: external_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_entities ALTER COLUMN id SET DEFAULT nextval('public.external_entities_id_seq'::regclass);


--
-- Name: external_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_links ALTER COLUMN id SET DEFAULT nextval('public.external_links_id_seq'::regclass);


--
-- Name: external_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_relationships ALTER COLUMN id SET DEFAULT nextval('public.external_relationships_id_seq'::regclass);


--
-- Name: family id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family ALTER COLUMN id SET DEFAULT nextval('public.family_id_seq'::regclass);


--
-- Name: fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields ALTER COLUMN id SET DEFAULT nextval('public.fields_id_seq'::regclass);


--
-- Name: generic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generic ALTER COLUMN id SET DEFAULT nextval('public.generic_id_seq'::regclass);


--
-- Name: government_body id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_body ALTER COLUMN id SET DEFAULT nextval('public.government_body_id_seq'::regclass);


--
-- Name: help_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_pages ALTER COLUMN id SET DEFAULT nextval('public.help_pages_id_seq'::regclass);


--
-- Name: hierarchy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchy ALTER COLUMN id SET DEFAULT nextval('public.hierarchy_id_seq'::regclass);


--
-- Name: image id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image ALTER COLUMN id SET DEFAULT nextval('public.image_id_seq'::regclass);


--
-- Name: industries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries ALTER COLUMN id SET DEFAULT nextval('public.industries_id_seq'::regclass);


--
-- Name: industry id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industry ALTER COLUMN id SET DEFAULT nextval('public.industry_id_seq'::regclass);


--
-- Name: link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link ALTER COLUMN id SET DEFAULT nextval('public.link_id_seq'::regclass);


--
-- Name: lobby_filing id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing ALTER COLUMN id SET DEFAULT nextval('public.lobby_filing_id_seq'::regclass);


--
-- Name: lobby_filing_lobby_issue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobby_issue ALTER COLUMN id SET DEFAULT nextval('public.lobby_filing_lobby_issue_id_seq'::regclass);


--
-- Name: lobby_filing_lobbyist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobbyist ALTER COLUMN id SET DEFAULT nextval('public.lobby_filing_lobbyist_id_seq'::regclass);


--
-- Name: lobby_filing_relationship id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_relationship ALTER COLUMN id SET DEFAULT nextval('public.lobby_filing_relationship_id_seq'::regclass);


--
-- Name: lobby_issue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_issue ALTER COLUMN id SET DEFAULT nextval('public.lobby_issue_id_seq'::regclass);


--
-- Name: lobbying id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbying ALTER COLUMN id SET DEFAULT nextval('public.lobbying_id_seq'::regclass);


--
-- Name: lobbyist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbyist ALTER COLUMN id SET DEFAULT nextval('public.lobbyist_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: ls_list id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list ALTER COLUMN id SET DEFAULT nextval('public.ls_list_id_seq'::regclass);


--
-- Name: ls_list_entity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list_entity ALTER COLUMN id SET DEFAULT nextval('public.ls_list_entity_id_seq'::regclass);


--
-- Name: map_annotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_annotations ALTER COLUMN id SET DEFAULT nextval('public.map_annotations_id_seq'::regclass);


--
-- Name: membership id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership ALTER COLUMN id SET DEFAULT nextval('public.membership_id_seq'::regclass);


--
-- Name: network_map id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_map ALTER COLUMN id SET DEFAULT nextval('public.network_map_id_seq'::regclass);


--
-- Name: ny_disclosures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_disclosures ALTER COLUMN id SET DEFAULT nextval('public.ny_disclosures_id_seq'::regclass);


--
-- Name: ny_filer_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_filer_entities ALTER COLUMN id SET DEFAULT nextval('public.ny_filer_entities_id_seq'::regclass);


--
-- Name: ny_filers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_filers ALTER COLUMN id SET DEFAULT nextval('public.ny_filers_id_seq'::regclass);


--
-- Name: ny_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_matches ALTER COLUMN id SET DEFAULT nextval('public.ny_matches_id_seq'::regclass);


--
-- Name: object_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_tag ALTER COLUMN id SET DEFAULT nextval('public.object_tag_id_seq'::regclass);


--
-- Name: org id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org ALTER COLUMN id SET DEFAULT nextval('public.org_id_seq'::regclass);


--
-- Name: os_candidates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_candidates ALTER COLUMN id SET DEFAULT nextval('public.os_candidates_id_seq'::regclass);


--
-- Name: os_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_category ALTER COLUMN id SET DEFAULT nextval('public.os_category_id_seq'::regclass);


--
-- Name: os_committees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_committees ALTER COLUMN id SET DEFAULT nextval('public.os_committees_id_seq'::regclass);


--
-- Name: os_donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_donations ALTER COLUMN id SET DEFAULT nextval('public.os_donations_id_seq'::regclass);


--
-- Name: os_entity_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_entity_category ALTER COLUMN id SET DEFAULT nextval('public.os_entity_category_id_seq'::regclass);


--
-- Name: os_entity_donor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_entity_donor ALTER COLUMN id SET DEFAULT nextval('public.os_entity_donor_id_seq'::regclass);


--
-- Name: os_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_matches ALTER COLUMN id SET DEFAULT nextval('public.os_matches_id_seq'::regclass);


--
-- Name: ownership id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownership ALTER COLUMN id SET DEFAULT nextval('public.ownership_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: permission_passes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_passes ALTER COLUMN id SET DEFAULT nextval('public.permission_passes_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: phone id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone ALTER COLUMN id SET DEFAULT nextval('public.phone_id_seq'::regclass);


--
-- Name: political_candidate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_candidate ALTER COLUMN id SET DEFAULT nextval('public.political_candidate_id_seq'::regclass);


--
-- Name: political_district id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_district ALTER COLUMN id SET DEFAULT nextval('public.political_district_id_seq'::regclass);


--
-- Name: political_fundraising id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising ALTER COLUMN id SET DEFAULT nextval('public.political_fundraising_id_seq'::regclass);


--
-- Name: political_fundraising_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising_type ALTER COLUMN id SET DEFAULT nextval('public.political_fundraising_type_id_seq'::regclass);


--
-- Name: position id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."position" ALTER COLUMN id SET DEFAULT nextval('public.position_id_seq'::regclass);


--
-- Name: professional id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional ALTER COLUMN id SET DEFAULT nextval('public.professional_id_seq'::regclass);


--
-- Name: public_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_company ALTER COLUMN id SET DEFAULT nextval('public.public_company_id_seq'::regclass);


--
-- Name: references id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."references" ALTER COLUMN id SET DEFAULT nextval('public.references_id_seq'::regclass);


--
-- Name: relationship id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship ALTER COLUMN id SET DEFAULT nextval('public.relationship_id_seq'::regclass);


--
-- Name: relationship_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship_category ALTER COLUMN id SET DEFAULT nextval('public.relationship_category_id_seq'::regclass);


--
-- Name: representative id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative ALTER COLUMN id SET DEFAULT nextval('public.representative_id_seq'::regclass);


--
-- Name: representative_district id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative_district ALTER COLUMN id SET DEFAULT nextval('public.representative_district_id_seq'::regclass);


--
-- Name: school id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school ALTER COLUMN id SET DEFAULT nextval('public.school_id_seq'::regclass);


--
-- Name: social id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social ALTER COLUMN id SET DEFAULT nextval('public.social_id_seq'::regclass);


--
-- Name: swamp_tips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swamp_tips ALTER COLUMN id SET DEFAULT nextval('public.swamp_tips_id_seq'::regclass);


--
-- Name: tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag ALTER COLUMN id SET DEFAULT nextval('public.tag_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: toolkit_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.toolkit_pages ALTER COLUMN id SET DEFAULT nextval('public.toolkit_pages_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Name: unmatched_ny_filers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unmatched_ny_filers ALTER COLUMN id SET DEFAULT nextval('public.unmatched_ny_filers_id_seq'::regclass);


--
-- Name: user_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions ALTER COLUMN id SET DEFAULT nextval('public.user_permissions_id_seq'::regclass);


--
-- Name: user_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles ALTER COLUMN id SET DEFAULT nextval('public.user_profiles_id_seq'::regclass);


--
-- Name: user_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_requests ALTER COLUMN id SET DEFAULT nextval('public.user_requests_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: web_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_requests ALTER COLUMN id SET DEFAULT nextval('public.web_requests_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: address_category address_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address_category
    ADD CONSTRAINT address_category_pkey PRIMARY KEY (id);


--
-- Name: address_country address_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address_country
    ADD CONSTRAINT address_country_pkey PRIMARY KEY (id);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);


--
-- Name: address_state address_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address_state
    ADD CONSTRAINT address_state_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: alias alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alias
    ADD CONSTRAINT alias_pkey PRIMARY KEY (id);


--
-- Name: api_tokens api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_tokens_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: article_entities article_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_entities
    ADD CONSTRAINT article_entities_pkey PRIMARY KEY (id);


--
-- Name: article_entity article_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_entity
    ADD CONSTRAINT article_entity_pkey PRIMARY KEY (id);


--
-- Name: article article_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article
    ADD CONSTRAINT article_pkey PRIMARY KEY (id);


--
-- Name: article_source article_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_source
    ADD CONSTRAINT article_source_pkey PRIMARY KEY (id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: business_industry business_industry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_industry
    ADD CONSTRAINT business_industry_pkey PRIMARY KEY (id);


--
-- Name: business_person business_person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_person
    ADD CONSTRAINT business_person_pkey PRIMARY KEY (id);


--
-- Name: business business_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business
    ADD CONSTRAINT business_pkey PRIMARY KEY (id);


--
-- Name: candidate_district candidate_district_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_district
    ADD CONSTRAINT candidate_district_pkey PRIMARY KEY (id);


--
-- Name: cmp_entities cmp_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cmp_entities
    ADD CONSTRAINT cmp_entities_pkey PRIMARY KEY (id);


--
-- Name: cmp_relationships cmp_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cmp_relationships
    ADD CONSTRAINT cmp_relationships_pkey PRIMARY KEY (id);


--
-- Name: common_names common_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.common_names
    ADD CONSTRAINT common_names_pkey PRIMARY KEY (id);


--
-- Name: couple couple_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.couple
    ADD CONSTRAINT couple_pkey PRIMARY KEY (id);


--
-- Name: custom_key custom_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_key
    ADD CONSTRAINT custom_key_pkey PRIMARY KEY (id);


--
-- Name: dashboard_bulletins dashboard_bulletins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_bulletins
    ADD CONSTRAINT dashboard_bulletins_pkey PRIMARY KEY (id);


--
-- Name: degree degree_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.degree
    ADD CONSTRAINT degree_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: donation donation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donation
    ADD CONSTRAINT donation_pkey PRIMARY KEY (id);


--
-- Name: edited_entities edited_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edited_entities
    ADD CONSTRAINT edited_entities_pkey PRIMARY KEY (id);


--
-- Name: education education_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_pkey PRIMARY KEY (id);


--
-- Name: elected_representative elected_representative_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elected_representative
    ADD CONSTRAINT elected_representative_pkey PRIMARY KEY (id);


--
-- Name: email email_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_pkey PRIMARY KEY (id);


--
-- Name: entity_fields entity_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_fields
    ADD CONSTRAINT entity_fields_pkey PRIMARY KEY (id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (id);


--
-- Name: extension_definition extension_definition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_definition
    ADD CONSTRAINT extension_definition_pkey PRIMARY KEY (id);


--
-- Name: extension_record extension_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_record
    ADD CONSTRAINT extension_record_pkey PRIMARY KEY (id);


--
-- Name: external_data_fec_candidates external_data_fec_candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_fec_candidates
    ADD CONSTRAINT external_data_fec_candidates_pkey PRIMARY KEY (id);


--
-- Name: external_data_fec_committees external_data_fec_committees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_fec_committees
    ADD CONSTRAINT external_data_fec_committees_pkey PRIMARY KEY (id);


--
-- Name: external_data_nys_filers external_data_nys_filers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data_nys_filers
    ADD CONSTRAINT external_data_nys_filers_pkey PRIMARY KEY (id);


--
-- Name: external_data external_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_data
    ADD CONSTRAINT external_data_pkey PRIMARY KEY (id);


--
-- Name: external_entities external_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_entities
    ADD CONSTRAINT external_entities_pkey PRIMARY KEY (id);


--
-- Name: external_links external_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_links
    ADD CONSTRAINT external_links_pkey PRIMARY KEY (id);


--
-- Name: external_relationships external_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_relationships
    ADD CONSTRAINT external_relationships_pkey PRIMARY KEY (id);


--
-- Name: family family_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family
    ADD CONSTRAINT family_pkey PRIMARY KEY (id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: generic generic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generic
    ADD CONSTRAINT generic_pkey PRIMARY KEY (id);


--
-- Name: government_body government_body_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_body
    ADD CONSTRAINT government_body_pkey PRIMARY KEY (id);


--
-- Name: help_pages help_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_pages
    ADD CONSTRAINT help_pages_pkey PRIMARY KEY (id);


--
-- Name: hierarchy hierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchy
    ADD CONSTRAINT hierarchy_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: industries industries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_pkey PRIMARY KEY (id);


--
-- Name: industry industry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industry
    ADD CONSTRAINT industry_pkey PRIMARY KEY (id);


--
-- Name: link link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (id);


--
-- Name: lobby_filing_lobby_issue lobby_filing_lobby_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobby_issue
    ADD CONSTRAINT lobby_filing_lobby_issue_pkey PRIMARY KEY (id);


--
-- Name: lobby_filing_lobbyist lobby_filing_lobbyist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobbyist
    ADD CONSTRAINT lobby_filing_lobbyist_pkey PRIMARY KEY (id);


--
-- Name: lobby_filing lobby_filing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing
    ADD CONSTRAINT lobby_filing_pkey PRIMARY KEY (id);


--
-- Name: lobby_filing_relationship lobby_filing_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_relationship
    ADD CONSTRAINT lobby_filing_relationship_pkey PRIMARY KEY (id);


--
-- Name: lobby_issue lobby_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_issue
    ADD CONSTRAINT lobby_issue_pkey PRIMARY KEY (id);


--
-- Name: lobbying lobbying_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbying
    ADD CONSTRAINT lobbying_pkey PRIMARY KEY (id);


--
-- Name: lobbyist lobbyist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbyist
    ADD CONSTRAINT lobbyist_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: ls_list_entity ls_list_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list_entity
    ADD CONSTRAINT ls_list_entity_pkey PRIMARY KEY (id);


--
-- Name: ls_list ls_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list
    ADD CONSTRAINT ls_list_pkey PRIMARY KEY (id);


--
-- Name: map_annotations map_annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_annotations
    ADD CONSTRAINT map_annotations_pkey PRIMARY KEY (id);


--
-- Name: membership membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_pkey PRIMARY KEY (id);


--
-- Name: network_map network_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.network_map
    ADD CONSTRAINT network_map_pkey PRIMARY KEY (id);


--
-- Name: ny_disclosures ny_disclosures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_disclosures
    ADD CONSTRAINT ny_disclosures_pkey PRIMARY KEY (id);


--
-- Name: ny_filer_entities ny_filer_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_filer_entities
    ADD CONSTRAINT ny_filer_entities_pkey PRIMARY KEY (id);


--
-- Name: ny_filers ny_filers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_filers
    ADD CONSTRAINT ny_filers_pkey PRIMARY KEY (id);


--
-- Name: ny_matches ny_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ny_matches
    ADD CONSTRAINT ny_matches_pkey PRIMARY KEY (id);


--
-- Name: object_tag object_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_tag
    ADD CONSTRAINT object_tag_pkey PRIMARY KEY (id);


--
-- Name: org org_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT org_pkey PRIMARY KEY (id);


--
-- Name: os_candidates os_candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_candidates
    ADD CONSTRAINT os_candidates_pkey PRIMARY KEY (id);


--
-- Name: os_category os_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_category
    ADD CONSTRAINT os_category_pkey PRIMARY KEY (id);


--
-- Name: os_committees os_committees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_committees
    ADD CONSTRAINT os_committees_pkey PRIMARY KEY (id);


--
-- Name: os_donations os_donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_donations
    ADD CONSTRAINT os_donations_pkey PRIMARY KEY (id);


--
-- Name: os_entity_category os_entity_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_entity_category
    ADD CONSTRAINT os_entity_category_pkey PRIMARY KEY (id);


--
-- Name: os_entity_donor os_entity_donor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_entity_donor
    ADD CONSTRAINT os_entity_donor_pkey PRIMARY KEY (id);


--
-- Name: os_matches os_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os_matches
    ADD CONSTRAINT os_matches_pkey PRIMARY KEY (id);


--
-- Name: ownership ownership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownership
    ADD CONSTRAINT ownership_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: permission_passes permission_passes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_passes
    ADD CONSTRAINT permission_passes_pkey PRIMARY KEY (id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: phone phone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone
    ADD CONSTRAINT phone_pkey PRIMARY KEY (id);


--
-- Name: political_candidate political_candidate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_candidate
    ADD CONSTRAINT political_candidate_pkey PRIMARY KEY (id);


--
-- Name: political_district political_district_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_district
    ADD CONSTRAINT political_district_pkey PRIMARY KEY (id);


--
-- Name: political_fundraising political_fundraising_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising
    ADD CONSTRAINT political_fundraising_pkey PRIMARY KEY (id);


--
-- Name: political_fundraising_type political_fundraising_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising_type
    ADD CONSTRAINT political_fundraising_type_pkey PRIMARY KEY (id);


--
-- Name: position position_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (id);


--
-- Name: professional professional_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional
    ADD CONSTRAINT professional_pkey PRIMARY KEY (id);


--
-- Name: public_company public_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_company
    ADD CONSTRAINT public_company_pkey PRIMARY KEY (id);


--
-- Name: references references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."references"
    ADD CONSTRAINT references_pkey PRIMARY KEY (id);


--
-- Name: relationship_category relationship_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship_category
    ADD CONSTRAINT relationship_category_pkey PRIMARY KEY (id);


--
-- Name: relationship relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_pkey PRIMARY KEY (id);


--
-- Name: representative_district representative_district_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative_district
    ADD CONSTRAINT representative_district_pkey PRIMARY KEY (id);


--
-- Name: representative representative_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative
    ADD CONSTRAINT representative_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: school school_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_pkey PRIMARY KEY (id);


--
-- Name: social social_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social
    ADD CONSTRAINT social_pkey PRIMARY KEY (id);


--
-- Name: swamp_tips swamp_tips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swamp_tips
    ADD CONSTRAINT swamp_tips_pkey PRIMARY KEY (id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: toolkit_pages toolkit_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.toolkit_pages
    ADD CONSTRAINT toolkit_pages_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: unmatched_ny_filers unmatched_ny_filers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unmatched_ny_filers
    ADD CONSTRAINT unmatched_ny_filers_pkey PRIMARY KEY (id);


--
-- Name: user_permissions user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_requests user_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_requests
    ADD CONSTRAINT user_requests_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: web_requests web_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_requests
    ADD CONSTRAINT web_requests_pkey PRIMARY KEY (id);


--
-- Name: idx_16388_index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16388_index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: idx_16388_index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16388_index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: idx_16397_index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16397_index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: idx_16407_index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16407_index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: idx_16413_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16413_category_id_idx ON public.address USING btree (category_id);


--
-- Name: idx_16413_country_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16413_country_id_idx ON public.address USING btree (country_id);


--
-- Name: idx_16413_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16413_entity_id_idx ON public.address USING btree (entity_id);


--
-- Name: idx_16413_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16413_last_user_id_idx ON public.address USING btree (last_user_id);


--
-- Name: idx_16413_state_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16413_state_id_idx ON public.address USING btree (state_id);


--
-- Name: idx_16432_index_addresses_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16432_index_addresses_on_location_id ON public.addresses USING btree (location_id);


--
-- Name: idx_16446_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16446_uniqueness_idx ON public.address_country USING btree (name);


--
-- Name: idx_16452_country_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16452_country_id_idx ON public.address_state USING btree (country_id);


--
-- Name: idx_16452_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16452_uniqueness_idx ON public.address_state USING btree (name);


--
-- Name: idx_16458_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16458_entity_id_idx ON public.alias USING btree (entity_id);


--
-- Name: idx_16458_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16458_name_idx ON public.alias USING btree (name);


--
-- Name: idx_16458_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16458_uniqueness_idx ON public.alias USING btree (entity_id, name, context);


--
-- Name: idx_16466_index_api_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16466_index_api_tokens_on_token ON public.api_tokens USING btree (token);


--
-- Name: idx_16466_index_api_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16466_index_api_tokens_on_user_id ON public.api_tokens USING btree (user_id);


--
-- Name: idx_16472_source_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16472_source_id_idx ON public.article USING btree (source_id);


--
-- Name: idx_16495_index_article_entities_on_entity_id_and_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16495_index_article_entities_on_entity_id_and_article_id ON public.article_entities USING btree (entity_id, article_id);


--
-- Name: idx_16495_index_article_entities_on_is_featured; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16495_index_article_entities_on_is_featured ON public.article_entities USING btree (is_featured);


--
-- Name: idx_16502_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16502_article_id_idx ON public.article_entity USING btree (article_id);


--
-- Name: idx_16502_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16502_entity_id_idx ON public.article_entity USING btree (entity_id);


--
-- Name: idx_16522_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16522_entity_id_idx ON public.business USING btree (entity_id);


--
-- Name: idx_16531_business_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16531_business_id_idx ON public.business_industry USING btree (business_id);


--
-- Name: idx_16531_industry_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16531_industry_id_idx ON public.business_industry USING btree (industry_id);


--
-- Name: idx_16537_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16537_entity_id_idx ON public.business_person USING btree (entity_id);


--
-- Name: idx_16543_district_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16543_district_id_idx ON public.candidate_district USING btree (district_id);


--
-- Name: idx_16543_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16543_uniqueness_idx ON public.candidate_district USING btree (candidate_id, district_id);


--
-- Name: idx_16549_index_cmp_entities_on_cmp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16549_index_cmp_entities_on_cmp_id ON public.cmp_entities USING btree (cmp_id);


--
-- Name: idx_16549_index_cmp_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16549_index_cmp_entities_on_entity_id ON public.cmp_entities USING btree (entity_id);


--
-- Name: idx_16555_index_cmp_relationships_on_cmp_affiliation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16555_index_cmp_relationships_on_cmp_affiliation_id ON public.cmp_relationships USING btree (cmp_affiliation_id);


--
-- Name: idx_16561_index_common_names_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16561_index_common_names_on_name ON public.common_names USING btree (name);


--
-- Name: idx_16568_index_couple_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16568_index_couple_on_entity_id ON public.couple USING btree (entity_id);


--
-- Name: idx_16568_index_couple_on_partner1_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16568_index_couple_on_partner1_id ON public.couple USING btree (partner1_id);


--
-- Name: idx_16568_index_couple_on_partner2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16568_index_couple_on_partner2_id ON public.couple USING btree (partner2_id);


--
-- Name: idx_16574_object_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16574_object_idx ON public.custom_key USING btree (object_model, object_id);


--
-- Name: idx_16574_object_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16574_object_name_idx ON public.custom_key USING btree (object_model, object_id, name);


--
-- Name: idx_16574_object_name_value_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16574_object_name_value_idx ON public.custom_key USING btree (object_model, object_id, name, value);


--
-- Name: idx_16584_index_dashboard_bulletins_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16584_index_dashboard_bulletins_on_created_at ON public.dashboard_bulletins USING btree (created_at);


--
-- Name: idx_16602_delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16602_delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_16615_index_documents_on_url_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16615_index_documents_on_url_hash ON public.documents USING btree (url_hash);


--
-- Name: idx_16628_bundler_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16628_bundler_id_idx ON public.donation USING btree (bundler_id);


--
-- Name: idx_16628_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16628_relationship_id_idx ON public.donation USING btree (relationship_id);


--
-- Name: idx_16634_index_edited_entities_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16634_index_edited_entities_on_created_at ON public.edited_entities USING btree (created_at);


--
-- Name: idx_16634_index_edited_entities_on_entity_id_and_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16634_index_edited_entities_on_entity_id_and_version_id ON public.edited_entities USING btree (entity_id, version_id);


--
-- Name: idx_16634_index_edited_entities_on_entity_id_and_version_id_and; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16634_index_edited_entities_on_entity_id_and_version_id_and ON public.edited_entities USING btree (entity_id, version_id, user_id);


--
-- Name: idx_16640_degree_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16640_degree_id_idx ON public.education USING btree (degree_id);


--
-- Name: idx_16640_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16640_relationship_id_idx ON public.education USING btree (relationship_id);


--
-- Name: idx_16647_crp_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16647_crp_id_idx ON public.elected_representative USING btree (crp_id);


--
-- Name: idx_16647_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16647_entity_id_idx ON public.elected_representative USING btree (entity_id);


--
-- Name: idx_16661_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16661_entity_id_idx ON public.email USING btree (entity_id);


--
-- Name: idx_16661_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16661_last_user_id_idx ON public.email USING btree (last_user_id);


--
-- Name: idx_16668_blurb_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_blurb_idx ON public.entity USING btree (blurb);


--
-- Name: idx_16668_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_created_at_idx ON public.entity USING btree (created_at);


--
-- Name: idx_16668_index_entity_on_delta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_index_entity_on_delta ON public.entity USING btree (delta);


--
-- Name: idx_16668_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_last_user_id_idx ON public.entity USING btree (last_user_id);


--
-- Name: idx_16668_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_name_idx ON public.entity USING btree (name);


--
-- Name: idx_16668_parent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_parent_id_idx ON public.entity USING btree (parent_id);


--
-- Name: idx_16668_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_search_idx ON public.entity USING btree (name, blurb, website);


--
-- Name: idx_16668_updated_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_updated_at_idx ON public.entity USING btree (updated_at);


--
-- Name: idx_16668_website_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16668_website_idx ON public.entity USING btree (website);


--
-- Name: idx_16686_index_entity_fields_on_entity_id_and_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16686_index_entity_fields_on_entity_id_and_field_id ON public.entity_fields USING btree (entity_id, field_id);


--
-- Name: idx_16691_example_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16691_example_idx ON public.example USING btree (year, cand_id);


--
-- Name: idx_16698_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16698_name_idx ON public.extension_definition USING btree (name);


--
-- Name: idx_16698_parent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16698_parent_id_idx ON public.extension_definition USING btree (parent_id);


--
-- Name: idx_16698_tier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16698_tier_idx ON public.extension_definition USING btree (tier);


--
-- Name: idx_16705_definition_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16705_definition_id_idx ON public.extension_record USING btree (definition_id);


--
-- Name: idx_16705_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16705_entity_id_idx ON public.extension_record USING btree (entity_id);


--
-- Name: idx_16705_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16705_last_user_id_idx ON public.extension_record USING btree (last_user_id);


--
-- Name: idx_16711_index_external_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16711_index_external_entities_on_entity_id ON public.external_entities USING btree (entity_id);


--
-- Name: idx_16711_index_external_entities_on_external_data_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16711_index_external_entities_on_external_data_id ON public.external_entities USING btree (external_data_id);


--
-- Name: idx_16711_index_external_entities_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16711_index_external_entities_on_priority ON public.external_entities USING btree (priority);


--
-- Name: idx_16722_index_external_links_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16722_index_external_links_on_entity_id ON public.external_links USING btree (entity_id);


--
-- Name: idx_16722_index_external_links_on_link_type_and_link_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16722_index_external_links_on_link_type_and_link_id ON public.external_links USING btree (link_type, link_id);


--
-- Name: idx_16728_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16728_relationship_id_idx ON public.family USING btree (relationship_id);


--
-- Name: idx_16734_index_fields_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16734_index_fields_on_name ON public.fields USING btree (name);


--
-- Name: idx_16744_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16744_relationship_id_idx ON public.generic USING btree (relationship_id);


--
-- Name: idx_16750_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16750_entity_id_idx ON public.government_body USING btree (entity_id);


--
-- Name: idx_16750_state_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16750_state_id_idx ON public.government_body USING btree (state_id);


--
-- Name: idx_16758_index_help_pages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16758_index_help_pages_on_name ON public.help_pages USING btree (name);


--
-- Name: idx_16768_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16768_relationship_id_idx ON public.hierarchy USING btree (relationship_id);


--
-- Name: idx_16774_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16774_entity_id_idx ON public.image USING btree (entity_id);


--
-- Name: idx_16774_index_image_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16774_index_image_on_address_id ON public.image USING btree (address_id);


--
-- Name: idx_16789_index_industries_on_industry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16789_index_industries_on_industry_id ON public.industries USING btree (industry_id);


--
-- Name: idx_16806_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_category_id_idx ON public.link USING btree (category_id);


--
-- Name: idx_16806_entity1_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_entity1_id_idx ON public.link USING btree (entity1_id);


--
-- Name: idx_16806_entity2_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_entity2_id_idx ON public.link USING btree (entity2_id);


--
-- Name: idx_16806_index_link_on_entity1_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_index_link_on_entity1_id_and_category_id ON public.link USING btree (entity1_id, category_id);


--
-- Name: idx_16806_index_link_on_entity1_id_and_category_id_and_is_rever; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_index_link_on_entity1_id_and_category_id_and_is_rever ON public.link USING btree (entity1_id, category_id, is_reverse);


--
-- Name: idx_16806_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16806_relationship_id_idx ON public.link USING btree (relationship_id);


--
-- Name: idx_16812_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16812_relationship_id_idx ON public.lobbying USING btree (relationship_id);


--
-- Name: idx_16818_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16818_entity_id_idx ON public.lobbyist USING btree (entity_id);


--
-- Name: idx_16834_lobby_filing_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16834_lobby_filing_id_idx ON public.lobby_filing_lobbyist USING btree (lobby_filing_id);


--
-- Name: idx_16834_lobbyist_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16834_lobbyist_id_idx ON public.lobby_filing_lobbyist USING btree (lobbyist_id);


--
-- Name: idx_16840_issue_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16840_issue_id_idx ON public.lobby_filing_lobby_issue USING btree (issue_id);


--
-- Name: idx_16840_lobby_filing_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16840_lobby_filing_id_idx ON public.lobby_filing_lobby_issue USING btree (lobby_filing_id);


--
-- Name: idx_16849_lobby_filing_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16849_lobby_filing_id_idx ON public.lobby_filing_relationship USING btree (lobby_filing_id);


--
-- Name: idx_16849_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16849_relationship_id_idx ON public.lobby_filing_relationship USING btree (relationship_id);


--
-- Name: idx_16861_index_locations_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16861_index_locations_on_entity_id ON public.locations USING btree (entity_id);


--
-- Name: idx_16861_index_locations_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16861_index_locations_on_region ON public.locations USING btree (region);


--
-- Name: idx_16872_featured_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16872_featured_list_id ON public.ls_list USING btree (featured_list_id);


--
-- Name: idx_16872_index_ls_list_on_delta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16872_index_ls_list_on_delta ON public.ls_list USING btree (delta);


--
-- Name: idx_16872_index_ls_list_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16872_index_ls_list_on_name ON public.ls_list USING btree (name);


--
-- Name: idx_16872_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16872_last_user_id_idx ON public.ls_list USING btree (last_user_id);


--
-- Name: idx_16892_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16892_created_at_idx ON public.ls_list_entity USING btree (created_at);


--
-- Name: idx_16892_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16892_entity_id_idx ON public.ls_list_entity USING btree (entity_id);


--
-- Name: idx_16892_index_ls_list_entity_on_entity_id_and_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16892_index_ls_list_entity_on_entity_id_and_list_id ON public.ls_list_entity USING btree (entity_id, list_id);


--
-- Name: idx_16892_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16892_last_user_id_idx ON public.ls_list_entity USING btree (last_user_id);


--
-- Name: idx_16892_list_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16892_list_id_idx ON public.ls_list_entity USING btree (list_id);


--
-- Name: idx_16901_index_map_annotations_on_map_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16901_index_map_annotations_on_map_id ON public.map_annotations USING btree (map_id);


--
-- Name: idx_16914_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16914_relationship_id_idx ON public.membership USING btree (relationship_id);


--
-- Name: idx_16923_index_network_map_on_delta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16923_index_network_map_on_delta ON public.network_map USING btree (delta);


--
-- Name: idx_16923_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16923_user_id_idx ON public.network_map USING btree (user_id);


--
-- Name: idx_16946_index_filer_report_trans_date_e_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_filer_report_trans_date_e_year ON public.ny_disclosures USING btree (filer_id, report_id, transaction_id, schedule_transaction_date, e_year);


--
-- Name: idx_16946_index_ny_disclosures_on_contrib_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_ny_disclosures_on_contrib_code ON public.ny_disclosures USING btree (contrib_code);


--
-- Name: idx_16946_index_ny_disclosures_on_delta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_ny_disclosures_on_delta ON public.ny_disclosures USING btree (delta);


--
-- Name: idx_16946_index_ny_disclosures_on_e_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_ny_disclosures_on_e_year ON public.ny_disclosures USING btree (e_year);


--
-- Name: idx_16946_index_ny_disclosures_on_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_ny_disclosures_on_filer_id ON public.ny_disclosures USING btree (filer_id);


--
-- Name: idx_16946_index_ny_disclosures_on_original_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16946_index_ny_disclosures_on_original_date ON public.ny_disclosures USING btree (original_date);


--
-- Name: idx_16977_index_ny_filers_on_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_16977_index_ny_filers_on_filer_id ON public.ny_filers USING btree (filer_id);


--
-- Name: idx_16977_index_ny_filers_on_filer_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16977_index_ny_filers_on_filer_type ON public.ny_filers USING btree (filer_type);


--
-- Name: idx_16996_index_ny_filer_entities_on_cmte_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16996_index_ny_filer_entities_on_cmte_entity_id ON public.ny_filer_entities USING btree (cmte_entity_id);


--
-- Name: idx_16996_index_ny_filer_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16996_index_ny_filer_entities_on_entity_id ON public.ny_filer_entities USING btree (entity_id);


--
-- Name: idx_16996_index_ny_filer_entities_on_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16996_index_ny_filer_entities_on_filer_id ON public.ny_filer_entities USING btree (filer_id);


--
-- Name: idx_16996_index_ny_filer_entities_on_is_committee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16996_index_ny_filer_entities_on_is_committee ON public.ny_filer_entities USING btree (is_committee);


--
-- Name: idx_16996_index_ny_filer_entities_on_ny_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_16996_index_ny_filer_entities_on_ny_filer_id ON public.ny_filer_entities USING btree (ny_filer_id);


--
-- Name: idx_17008_index_ny_matches_on_donor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17008_index_ny_matches_on_donor_id ON public.ny_matches USING btree (donor_id);


--
-- Name: idx_17008_index_ny_matches_on_ny_disclosure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17008_index_ny_matches_on_ny_disclosure_id ON public.ny_matches USING btree (ny_disclosure_id);


--
-- Name: idx_17008_index_ny_matches_on_recip_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17008_index_ny_matches_on_recip_id ON public.ny_matches USING btree (recip_id);


--
-- Name: idx_17008_index_ny_matches_on_relationship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17008_index_ny_matches_on_relationship_id ON public.ny_matches USING btree (relationship_id);


--
-- Name: idx_17014_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17014_last_user_id_idx ON public.object_tag USING btree (last_user_id);


--
-- Name: idx_17014_object_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17014_object_idx ON public.object_tag USING btree (object_model, object_id);


--
-- Name: idx_17014_tag_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17014_tag_id_idx ON public.object_tag USING btree (tag_id);


--
-- Name: idx_17014_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17014_uniqueness_idx ON public.object_tag USING btree (object_model, object_id, tag_id);


--
-- Name: idx_17020_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17020_entity_id_idx ON public.org USING btree (entity_id);


--
-- Name: idx_17029_index_os_candidates_on_crp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17029_index_os_candidates_on_crp_id ON public.os_candidates USING btree (crp_id);


--
-- Name: idx_17029_index_os_candidates_on_cycle_and_crp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17029_index_os_candidates_on_cycle_and_crp_id ON public.os_candidates USING btree (cycle, crp_id);


--
-- Name: idx_17029_index_os_candidates_on_feccandid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17029_index_os_candidates_on_feccandid ON public.os_candidates USING btree (feccandid);


--
-- Name: idx_17045_unique_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17045_unique_id_idx ON public.os_category USING btree (category_id);


--
-- Name: idx_17045_unique_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17045_unique_name_idx ON public.os_category USING btree (category_name);


--
-- Name: idx_17051_index_os_committees_on_cmte_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17051_index_os_committees_on_cmte_id ON public.os_committees USING btree (cmte_id);


--
-- Name: idx_17051_index_os_committees_on_cmte_id_and_cycle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17051_index_os_committees_on_cmte_id_and_cycle ON public.os_committees USING btree (cmte_id, cycle);


--
-- Name: idx_17051_index_os_committees_on_recipid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17051_index_os_committees_on_recipid ON public.os_committees USING btree (recipid);


--
-- Name: idx_17069_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17069_category_id_idx ON public.os_entity_category USING btree (category_id);


--
-- Name: idx_17069_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17069_entity_id_idx ON public.os_entity_category USING btree (entity_id);


--
-- Name: idx_17069_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17069_uniqueness_idx ON public.os_entity_category USING btree (entity_id, category_id);


--
-- Name: idx_17076_entity_donor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17076_entity_donor_idx ON public.os_entity_donor USING btree (entity_id, donor_id);


--
-- Name: idx_17076_is_synced_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17076_is_synced_idx ON public.os_entity_donor USING btree (is_synced);


--
-- Name: idx_17076_locked_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17076_locked_at_idx ON public.os_entity_donor USING btree (locked_at);


--
-- Name: idx_17076_reviewed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17076_reviewed_at_idx ON public.os_entity_donor USING btree (reviewed_at);


--
-- Name: idx_17086_index_os_matches_on_cmte_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17086_index_os_matches_on_cmte_id ON public.os_matches USING btree (cmte_id);


--
-- Name: idx_17086_index_os_matches_on_donor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17086_index_os_matches_on_donor_id ON public.os_matches USING btree (donor_id);


--
-- Name: idx_17086_index_os_matches_on_os_donation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17086_index_os_matches_on_os_donation_id ON public.os_matches USING btree (os_donation_id);


--
-- Name: idx_17086_index_os_matches_on_recip_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17086_index_os_matches_on_recip_id ON public.os_matches USING btree (recip_id);


--
-- Name: idx_17086_index_os_matches_on_relationship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17086_index_os_matches_on_relationship_id ON public.os_matches USING btree (relationship_id);


--
-- Name: idx_17093_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17093_relationship_id_idx ON public.ownership USING btree (relationship_id);


--
-- Name: idx_17099_index_pages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17099_index_pages_on_name ON public.pages USING btree (name);


--
-- Name: idx_17119_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17119_entity_id_idx ON public.person USING btree (entity_id);


--
-- Name: idx_17119_gender_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17119_gender_id_idx ON public.person USING btree (gender_id);


--
-- Name: idx_17119_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17119_name_idx ON public.person USING btree (name_last, name_first, name_middle);


--
-- Name: idx_17119_party_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17119_party_id_idx ON public.person USING btree (party_id);


--
-- Name: idx_17134_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17134_entity_id_idx ON public.phone USING btree (entity_id);


--
-- Name: idx_17134_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17134_last_user_id_idx ON public.phone USING btree (last_user_id);


--
-- Name: idx_17142_crp_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17142_crp_id_idx ON public.political_candidate USING btree (crp_id);


--
-- Name: idx_17142_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17142_entity_id_idx ON public.political_candidate USING btree (entity_id);


--
-- Name: idx_17142_house_fec_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17142_house_fec_id_idx ON public.political_candidate USING btree (house_fec_id);


--
-- Name: idx_17142_pres_fec_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17142_pres_fec_id_idx ON public.political_candidate USING btree (pres_fec_id);


--
-- Name: idx_17142_senate_fec_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17142_senate_fec_id_idx ON public.political_candidate USING btree (senate_fec_id);


--
-- Name: idx_17152_state_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17152_state_id_idx ON public.political_district USING btree (state_id);


--
-- Name: idx_17161_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17161_entity_id_idx ON public.political_fundraising USING btree (entity_id);


--
-- Name: idx_17161_fec_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17161_fec_id_idx ON public.political_fundraising USING btree (fec_id);


--
-- Name: idx_17161_state_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17161_state_id_idx ON public.political_fundraising USING btree (state_id);


--
-- Name: idx_17161_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17161_type_id_idx ON public.political_fundraising USING btree (type_id);


--
-- Name: idx_17174_boss_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17174_boss_id_idx ON public."position" USING btree (boss_id);


--
-- Name: idx_17174_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17174_relationship_id_idx ON public."position" USING btree (relationship_id);


--
-- Name: idx_17180_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17180_relationship_id_idx ON public.professional USING btree (relationship_id);


--
-- Name: idx_17186_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17186_entity_id_idx ON public.public_company USING btree (entity_id);


--
-- Name: idx_17193_index_references_on_referenceable_id_and_referenceabl; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17193_index_references_on_referenceable_id_and_referenceabl ON public."references" USING btree (referenceable_id, referenceable_type);


--
-- Name: idx_17200_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_category_id_idx ON public.relationship USING btree (category_id);


--
-- Name: idx_17200_entity1_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_entity1_category_idx ON public.relationship USING btree (entity1_id, category_id);


--
-- Name: idx_17200_entity1_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_entity1_id_idx ON public.relationship USING btree (entity1_id);


--
-- Name: idx_17200_entity2_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_entity2_id_idx ON public.relationship USING btree (entity2_id);


--
-- Name: idx_17200_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_entity_idx ON public.relationship USING btree (entity1_id, entity2_id);


--
-- Name: idx_17200_index_relationship_is_d_e2_cat_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_index_relationship_is_d_e2_cat_amount ON public.relationship USING btree (is_deleted, entity2_id, category_id, amount);


--
-- Name: idx_17200_last_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17200_last_user_id_idx ON public.relationship USING btree (last_user_id);


--
-- Name: idx_17216_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17216_uniqueness_idx ON public.relationship_category USING btree (name);


--
-- Name: idx_17227_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17227_entity_id_idx ON public.representative USING btree (entity_id);


--
-- Name: idx_17234_district_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17234_district_id_idx ON public.representative_district USING btree (district_id);


--
-- Name: idx_17234_representative_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17234_representative_id_idx ON public.representative_district USING btree (representative_id);


--
-- Name: idx_17234_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17234_uniqueness_idx ON public.representative_district USING btree (representative_id, district_id);


--
-- Name: idx_17243_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17243_entity_id_idx ON public.school USING btree (entity_id);


--
-- Name: idx_17249_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17249_relationship_id_idx ON public.social USING btree (relationship_id);


--
-- Name: idx_17267_uniqueness_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17267_uniqueness_idx ON public.tag USING btree (name);


--
-- Name: idx_17278_fk_rails_5607f02466; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17278_fk_rails_5607f02466 ON public.taggings USING btree (last_user_id);


--
-- Name: idx_17278_index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17278_index_taggings_on_tag_id ON public.taggings USING btree (tag_id);


--
-- Name: idx_17278_index_taggings_on_tagable_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17278_index_taggings_on_tagable_class ON public.taggings USING btree (tagable_class);


--
-- Name: idx_17278_index_taggings_on_tagable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17278_index_taggings_on_tagable_id ON public.taggings USING btree (tagable_id);


--
-- Name: idx_17285_index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17285_index_tags_on_name ON public.tags USING btree (name);


--
-- Name: idx_17295_index_toolkit_pages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17295_index_toolkit_pages_on_name ON public.toolkit_pages USING btree (name);


--
-- Name: idx_17305_contact1_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17305_contact1_id_idx ON public.transaction USING btree (contact1_id);


--
-- Name: idx_17305_contact2_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17305_contact2_id_idx ON public.transaction USING btree (contact2_id);


--
-- Name: idx_17305_relationship_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17305_relationship_id_idx ON public.transaction USING btree (relationship_id);


--
-- Name: idx_17311_index_unmatched_ny_filers_on_disclosure_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17311_index_unmatched_ny_filers_on_disclosure_count ON public.unmatched_ny_filers USING btree (disclosure_count);


--
-- Name: idx_17311_index_unmatched_ny_filers_on_ny_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17311_index_unmatched_ny_filers_on_ny_filer_id ON public.unmatched_ny_filers USING btree (ny_filer_id);


--
-- Name: idx_17317_index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17317_index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: idx_17317_index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17317_index_users_on_email ON public.users USING btree (email);


--
-- Name: idx_17317_index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17317_index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: idx_17317_index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17317_index_users_on_username ON public.users USING btree (username);


--
-- Name: idx_17336_index_user_permissions_on_user_id_and_resource_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17336_index_user_permissions_on_user_id_and_resource_type ON public.user_permissions USING btree (user_id, resource_type);


--
-- Name: idx_17345_index_user_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_17345_index_user_profiles_on_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: idx_17357_index_user_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17357_index_user_requests_on_user_id ON public.user_requests USING btree (user_id);


--
-- Name: idx_17367_index_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17367_index_versions_on_created_at ON public.versions USING btree (created_at);


--
-- Name: idx_17367_index_versions_on_entity1_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17367_index_versions_on_entity1_id ON public.versions USING btree (entity1_id);


--
-- Name: idx_17367_index_versions_on_entity2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17367_index_versions_on_entity2_id ON public.versions USING btree (entity2_id);


--
-- Name: idx_17367_index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17367_index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: idx_17367_index_versions_on_whodunnit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_17367_index_versions_on_whodunnit ON public.versions USING btree (whodunnit);


--
-- Name: idx_34330_index_external_data_on_dataset; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34330_index_external_data_on_dataset ON public.external_data USING btree (dataset);


--
-- Name: idx_34330_index_external_data_on_dataset_and_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34330_index_external_data_on_dataset_and_dataset_id ON public.external_data USING btree (dataset, dataset_id);


--
-- Name: idx_34339_index_external_data_fec_candidates_on_cand_id_and_fec; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34339_index_external_data_fec_candidates_on_cand_id_and_fec ON public.external_data_fec_candidates USING btree (cand_id, fec_year);


--
-- Name: idx_34339_index_external_data_fec_candidates_on_cand_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34339_index_external_data_fec_candidates_on_cand_name ON public.external_data_fec_candidates USING gin (to_tsvector('simple'::regconfig, cand_name));


--
-- Name: idx_34339_index_external_data_fec_candidates_on_cand_pty_affili; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34339_index_external_data_fec_candidates_on_cand_pty_affili ON public.external_data_fec_candidates USING btree (cand_pty_affiliation);


--
-- Name: idx_34356_index_external_data_fec_committees_on_cmte_id_and_fec; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34356_index_external_data_fec_committees_on_cmte_id_and_fec ON public.external_data_fec_committees USING btree (cmte_id, fec_year);


--
-- Name: idx_34356_index_external_data_fec_committees_on_cmte_nm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34356_index_external_data_fec_committees_on_cmte_nm ON public.external_data_fec_committees USING gin (to_tsvector('simple'::regconfig, cmte_nm));


--
-- Name: idx_34356_index_external_data_fec_committees_on_cmte_pty_affili; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34356_index_external_data_fec_committees_on_cmte_pty_affili ON public.external_data_fec_committees USING btree (cmte_pty_affiliation);


--
-- Name: idx_34356_index_external_data_fec_committees_on_connected_org_n; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34356_index_external_data_fec_committees_on_connected_org_n ON public.external_data_fec_committees USING gin (to_tsvector('simple'::regconfig, connected_org_nm));


--
-- Name: idx_34370_index_external_data_fec_contributions_on_cmte_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34370_index_external_data_fec_contributions_on_cmte_id ON public.external_data_fec_contributions USING btree (cmte_id);


--
-- Name: idx_34370_index_external_data_fec_contributions_on_employer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34370_index_external_data_fec_contributions_on_employer ON public.external_data_fec_contributions USING gin (to_tsvector('simple'::regconfig, employer));


--
-- Name: idx_34370_index_external_data_fec_contributions_on_fec_year_and; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34370_index_external_data_fec_contributions_on_fec_year_and ON public.external_data_fec_contributions USING btree (fec_year, sub_id);


--
-- Name: idx_34370_index_external_data_fec_contributions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34370_index_external_data_fec_contributions_on_name ON public.external_data_fec_contributions USING gin (to_tsvector('simple'::regconfig, name));


--
-- Name: idx_34370_index_external_data_fec_contributions_on_transaction_; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34370_index_external_data_fec_contributions_on_transaction_ ON public.external_data_fec_contributions USING btree (transaction_amt);


--
-- Name: idx_34391_index_external_data_nys_disclosures_on_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34391_index_external_data_nys_disclosures_on_filer_id ON public.external_data_nys_disclosures USING btree (filer_id);


--
-- Name: idx_34391_index_external_data_nys_disclosures_on_flng_ent_last_; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34391_index_external_data_nys_disclosures_on_flng_ent_last_ ON public.external_data_nys_disclosures USING gin (to_tsvector('simple'::regconfig, flng_ent_last_name));


--
-- Name: idx_34391_index_external_data_nys_disclosures_on_flng_ent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34391_index_external_data_nys_disclosures_on_flng_ent_name ON public.external_data_nys_disclosures USING gin (to_tsvector('simple'::regconfig, flng_ent_name));


--
-- Name: idx_34391_index_external_data_nys_disclosures_on_org_amt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34391_index_external_data_nys_disclosures_on_org_amt ON public.external_data_nys_disclosures USING btree (org_amt);


--
-- Name: idx_34391_index_external_data_nys_disclosures_on_trans_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34391_index_external_data_nys_disclosures_on_trans_number ON public.external_data_nys_disclosures USING btree (trans_number);


--
-- Name: idx_34436_index_external_data_nys_filers_on_filer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34436_index_external_data_nys_filers_on_filer_id ON public.external_data_nys_filers USING btree (filer_id);


--
-- Name: idx_34436_index_external_data_nys_filers_on_filer_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34436_index_external_data_nys_filers_on_filer_name ON public.external_data_nys_filers USING gin (to_tsvector('simple'::regconfig, filer_name));


--
-- Name: idx_34461_fk_rails_5025111f98; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34461_fk_rails_5025111f98 ON public.external_relationships USING btree (external_data_id);


--
-- Name: idx_34461_fk_rails_632542e80c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34461_fk_rails_632542e80c ON public.external_relationships USING btree (relationship_id);


--
-- Name: idx_34467_index_os_donations_on_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_amount ON public.os_donations USING btree (amount);


--
-- Name: idx_34467_index_os_donations_on_contribid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_contribid ON public.os_donations USING btree (contribid);


--
-- Name: idx_34467_index_os_donations_on_cycle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_cycle ON public.os_donations USING btree (cycle);


--
-- Name: idx_34467_index_os_donations_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_date ON public.os_donations USING btree (date);


--
-- Name: idx_34467_index_os_donations_on_fec_cycle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34467_index_os_donations_on_fec_cycle_id ON public.os_donations USING btree (fec_cycle_id);


--
-- Name: idx_34467_index_os_donations_on_fectransid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_fectransid ON public.os_donations USING btree (fectransid);


--
-- Name: idx_34467_index_os_donations_on_fectransid_and_cycle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_fectransid_and_cycle ON public.os_donations USING btree (fectransid, cycle);


--
-- Name: idx_34467_index_os_donations_on_microfilm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_microfilm ON public.os_donations USING btree (microfilm);


--
-- Name: idx_34467_index_os_donations_on_name_last_and_name_first; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_name_last_and_name_first ON public.os_donations USING btree (name_last, name_first);


--
-- Name: idx_34467_index_os_donations_on_realcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_realcode ON public.os_donations USING btree (realcode);


--
-- Name: idx_34467_index_os_donations_on_realcode_and_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_realcode_and_amount ON public.os_donations USING btree (realcode, amount);


--
-- Name: idx_34467_index_os_donations_on_recipid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_recipid ON public.os_donations USING btree (recipid);


--
-- Name: idx_34467_index_os_donations_on_recipid_and_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_recipid_and_amount ON public.os_donations USING btree (recipid, amount);


--
-- Name: idx_34467_index_os_donations_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_state ON public.os_donations USING btree (state);


--
-- Name: idx_34467_index_os_donations_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34467_index_os_donations_on_zip ON public.os_donations USING btree (zip);


--
-- Name: idx_34500_idx_web_requests_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34500_idx_web_requests_time ON public.web_requests USING btree ("time");


--
-- Name: idx_34500_index_web_requests_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_34500_index_web_requests_on_request_id ON public.web_requests USING btree (request_id);


--
-- Name: idx_34500_index_web_requests_on_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_34500_index_web_requests_on_time ON public.web_requests USING btree ("time");


--
-- Name: address address_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_ibfk_2 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alias alias_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alias
    ADD CONSTRAINT alias_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: article article_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article
    ADD CONSTRAINT article_ibfk_1 FOREIGN KEY (source_id) REFERENCES public.article_source(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: business business_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business
    ADD CONSTRAINT business_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_industry business_industry_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_industry
    ADD CONSTRAINT business_industry_ibfk_1 FOREIGN KEY (industry_id) REFERENCES public.industry(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_industry business_industry_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_industry
    ADD CONSTRAINT business_industry_ibfk_2 FOREIGN KEY (business_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_person business_person_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_person
    ADD CONSTRAINT business_person_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: candidate_district candidate_district_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_district
    ADD CONSTRAINT candidate_district_ibfk_1 FOREIGN KEY (district_id) REFERENCES public.political_district(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: donation donation_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donation
    ADD CONSTRAINT donation_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: donation donation_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donation
    ADD CONSTRAINT donation_ibfk_2 FOREIGN KEY (bundler_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: education education_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: education education_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_ibfk_2 FOREIGN KEY (degree_id) REFERENCES public.degree(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: elected_representative elected_representative_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elected_representative
    ADD CONSTRAINT elected_representative_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: email email_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entity entity_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity
    ADD CONSTRAINT entity_ibfk_1 FOREIGN KEY (parent_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: extension_definition extension_definition_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_definition
    ADD CONSTRAINT extension_definition_ibfk_1 FOREIGN KEY (parent_id) REFERENCES public.extension_definition(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: extension_record extension_record_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_record
    ADD CONSTRAINT extension_record_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: extension_record extension_record_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extension_record
    ADD CONSTRAINT extension_record_ibfk_2 FOREIGN KEY (definition_id) REFERENCES public.extension_definition(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: family family_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family
    ADD CONSTRAINT family_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: address fk_rails_1bfe88c8a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT fk_rails_1bfe88c8a7 FOREIGN KEY (category_id) REFERENCES public.address_category(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cmp_entities fk_rails_216b4cd432; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cmp_entities
    ADD CONSTRAINT fk_rails_216b4cd432 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: external_relationships fk_rails_5025111f98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_relationships
    ADD CONSTRAINT fk_rails_5025111f98 FOREIGN KEY (external_data_id) REFERENCES public.external_data(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: taggings fk_rails_5607f02466; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT fk_rails_5607f02466 FOREIGN KEY (last_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: addresses fk_rails_85b742bdb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_85b742bdb1 FOREIGN KEY (location_id) REFERENCES public.locations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: relationship fk_rails_92c847cbfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT fk_rails_92c847cbfe FOREIGN KEY (last_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: entity fk_rails_d27e2518f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity
    ADD CONSTRAINT fk_rails_d27e2518f5 FOREIGN KEY (last_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_requests fk_rails_de8c07e72e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_requests
    ADD CONSTRAINT fk_rails_de8c07e72e FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: government_body government_body_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_body
    ADD CONSTRAINT government_body_ibfk_1 FOREIGN KEY (state_id) REFERENCES public.address_state(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: government_body government_body_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_body
    ADD CONSTRAINT government_body_ibfk_2 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: link link_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: link link_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_ibfk_2 FOREIGN KEY (entity2_id) REFERENCES public.entity(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: link link_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_ibfk_3 FOREIGN KEY (entity1_id) REFERENCES public.entity(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: link link_ibfk_4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_ibfk_4 FOREIGN KEY (category_id) REFERENCES public.relationship_category(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: lobby_filing_lobby_issue lobby_filing_lobby_issue_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobby_issue
    ADD CONSTRAINT lobby_filing_lobby_issue_ibfk_1 FOREIGN KEY (lobby_filing_id) REFERENCES public.lobby_filing(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lobby_filing_lobby_issue lobby_filing_lobby_issue_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobby_issue
    ADD CONSTRAINT lobby_filing_lobby_issue_ibfk_2 FOREIGN KEY (issue_id) REFERENCES public.lobby_issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lobby_filing_lobbyist lobby_filing_lobbyist_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobbyist
    ADD CONSTRAINT lobby_filing_lobbyist_ibfk_1 FOREIGN KEY (lobbyist_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lobby_filing_lobbyist lobby_filing_lobbyist_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_lobbyist
    ADD CONSTRAINT lobby_filing_lobbyist_ibfk_2 FOREIGN KEY (lobby_filing_id) REFERENCES public.lobby_filing(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lobby_filing_relationship lobby_filing_relationship_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_relationship
    ADD CONSTRAINT lobby_filing_relationship_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: lobby_filing_relationship lobby_filing_relationship_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_filing_relationship
    ADD CONSTRAINT lobby_filing_relationship_ibfk_2 FOREIGN KEY (lobby_filing_id) REFERENCES public.lobby_filing(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: lobbying lobbying_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbying
    ADD CONSTRAINT lobbying_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lobbyist lobbyist_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbyist
    ADD CONSTRAINT lobbyist_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ls_list_entity ls_list_entity_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list_entity
    ADD CONSTRAINT ls_list_entity_ibfk_1 FOREIGN KEY (list_id) REFERENCES public.ls_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ls_list_entity ls_list_entity_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list_entity
    ADD CONSTRAINT ls_list_entity_ibfk_2 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ls_list ls_list_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ls_list
    ADD CONSTRAINT ls_list_ibfk_2 FOREIGN KEY (featured_list_id) REFERENCES public.ls_list(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: membership membership_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org org_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT org_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ownership ownership_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownership
    ADD CONSTRAINT ownership_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person person_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_ibfk_1 FOREIGN KEY (party_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: person person_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_ibfk_3 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: phone phone_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone
    ADD CONSTRAINT phone_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: political_candidate political_candidate_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_candidate
    ADD CONSTRAINT political_candidate_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: political_district political_district_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_district
    ADD CONSTRAINT political_district_ibfk_1 FOREIGN KEY (state_id) REFERENCES public.address_state(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: political_fundraising political_fundraising_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising
    ADD CONSTRAINT political_fundraising_ibfk_2 FOREIGN KEY (state_id) REFERENCES public.address_state(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: political_fundraising political_fundraising_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.political_fundraising
    ADD CONSTRAINT political_fundraising_ibfk_3 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: position position_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: position position_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_ibfk_2 FOREIGN KEY (boss_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: professional professional_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional
    ADD CONSTRAINT professional_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public_company public_company_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_company
    ADD CONSTRAINT public_company_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relationship relationship_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_ibfk_1 FOREIGN KEY (entity2_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relationship relationship_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_ibfk_2 FOREIGN KEY (entity1_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relationship relationship_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_ibfk_3 FOREIGN KEY (category_id) REFERENCES public.relationship_category(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: representative_district representative_district_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative_district
    ADD CONSTRAINT representative_district_ibfk_3 FOREIGN KEY (representative_id) REFERENCES public.elected_representative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: representative_district representative_district_ibfk_4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative_district
    ADD CONSTRAINT representative_district_ibfk_4 FOREIGN KEY (district_id) REFERENCES public.political_district(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: representative representative_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representative
    ADD CONSTRAINT representative_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: school school_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_ibfk_1 FOREIGN KEY (entity_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: social social_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social
    ADD CONSTRAINT social_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_ibfk_1 FOREIGN KEY (relationship_id) REFERENCES public.relationship(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_ibfk_2 FOREIGN KEY (contact2_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: transaction transaction_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_ibfk_3 FOREIGN KEY (contact1_id) REFERENCES public.entity(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

