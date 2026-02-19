--
-- PostgreSQL database dump
--

-- Dumped from database version 17.7 (Debian 17.7-3.pgdg13+1)
-- Dumped by pg_dump version 17.0

-- Started on 2025-11-22 23:15:40

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
-- TOC entry 4271 (class 1262 OID 16384)
-- Name: keycloak; Type: DATABASE; Schema: -; Owner: keycloak
--



DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'mimdb') THEN
    CREATE DATABASE mimdb OWNER keycloak;
  END IF;
END
$$;

\connect mimdb


CREATE SCHEMA mim;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
ALTER DATABASE mimdb SET search_path = mim, public,areti_multiservizio;

--dipendenze per powa
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'btree_gist') THEN
    CREATE EXTENSION IF NOT EXISTS btree_gist;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_stat_statements') THEN
    CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_qualstats') THEN
    CREATE EXTENSION IF NOT EXISTS pg_qualstats;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'hypopg') THEN
    CREATE EXTENSION IF NOT EXISTS hypopg;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'powa') THEN
    CREATE EXTENSION IF NOT EXISTS powa CASCADE;
  END IF;
END
$$;
    
---
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 428 (class 1259 OID 18801)
-- Name: admin_event_entity; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.admin_event_entity (
    id character varying(36) NOT NULL,
    admin_event_time bigint,
    realm_id character varying(255),
    operation_type character varying(255),
    auth_realm_id character varying(255),
    auth_client_id character varying(255),
    auth_user_id character varying(255),
    ip_address character varying(255),
    resource_path character varying(2550),
    representation text,
    error character varying(255),
    resource_type character varying(64),
    details_json text
);


--
-- TOC entry 429 (class 1259 OID 18806)
-- Name: associated_policy; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.associated_policy (
    policy_id character varying(36) NOT NULL,
    associated_policy_id character varying(36) NOT NULL
);


--
-- TOC entry 430 (class 1259 OID 18809)
-- Name: authentication_execution; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.authentication_execution (
    id character varying(36) NOT NULL,
    alias character varying(255),
    authenticator character varying(36),
    realm_id character varying(36),
    flow_id character varying(36),
    requirement integer,
    priority integer,
    authenticator_flow boolean DEFAULT false NOT NULL,
    auth_flow_id character varying(36),
    auth_config character varying(36)
);


--
-- TOC entry 431 (class 1259 OID 18813)
-- Name: authentication_flow; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.authentication_flow (
    id character varying(36) NOT NULL,
    alias character varying(255),
    description character varying(255),
    realm_id character varying(36),
    provider_id character varying(36) DEFAULT 'basic-flow'::character varying NOT NULL,
    top_level boolean DEFAULT false NOT NULL,
    built_in boolean DEFAULT false NOT NULL
);


--
-- TOC entry 432 (class 1259 OID 18821)
-- Name: authenticator_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.authenticator_config (
    id character varying(36) NOT NULL,
    alias character varying(255),
    realm_id character varying(36)
);


--
-- TOC entry 433 (class 1259 OID 18824)
-- Name: authenticator_config_entry; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.authenticator_config_entry (
    authenticator_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 434 (class 1259 OID 18829)
-- Name: broker_link; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.broker_link (
    identity_provider character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL,
    broker_user_id character varying(255),
    broker_username character varying(255),
    token text,
    user_id character varying(255) NOT NULL
);


--
-- TOC entry 435 (class 1259 OID 18834)
-- Name: client; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client (
    id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    full_scope_allowed boolean DEFAULT false NOT NULL,
    client_id character varying(255),
    not_before integer,
    public_client boolean DEFAULT false NOT NULL,
    secret character varying(255),
    base_url character varying(255),
    bearer_only boolean DEFAULT false NOT NULL,
    management_url character varying(255),
    surrogate_auth_required boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    protocol character varying(255),
    node_rereg_timeout integer DEFAULT 0,
    frontchannel_logout boolean DEFAULT false NOT NULL,
    consent_required boolean DEFAULT false NOT NULL,
    name character varying(255),
    service_accounts_enabled boolean DEFAULT false NOT NULL,
    client_authenticator_type character varying(255),
    root_url character varying(255),
    description character varying(255),
    registration_token character varying(255),
    standard_flow_enabled boolean DEFAULT true NOT NULL,
    implicit_flow_enabled boolean DEFAULT false NOT NULL,
    direct_access_grants_enabled boolean DEFAULT false NOT NULL,
    always_display_in_console boolean DEFAULT false NOT NULL
);


--
-- TOC entry 436 (class 1259 OID 18852)
-- Name: client_attributes; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_attributes (
    client_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 437 (class 1259 OID 18857)
-- Name: client_auth_flow_bindings; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_auth_flow_bindings (
    client_id character varying(36) NOT NULL,
    flow_id character varying(36),
    binding_name character varying(255) NOT NULL
);


--
-- TOC entry 438 (class 1259 OID 18860)
-- Name: client_initial_access; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_initial_access (
    id character varying(36) NOT NULL,
    realm_id character varying(36) NOT NULL,
    "timestamp" integer,
    expiration integer,
    count integer,
    remaining_count integer
);


--
-- TOC entry 439 (class 1259 OID 18863)
-- Name: client_node_registrations; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_node_registrations (
    client_id character varying(36) NOT NULL,
    value integer,
    name character varying(255) NOT NULL
);


--
-- TOC entry 440 (class 1259 OID 18866)
-- Name: client_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_scope (
    id character varying(36) NOT NULL,
    name character varying(255),
    realm_id character varying(36),
    description character varying(255),
    protocol character varying(255)
);


--
-- TOC entry 441 (class 1259 OID 18871)
-- Name: client_scope_attributes; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_scope_attributes (
    scope_id character varying(36) NOT NULL,
    value character varying(2048),
    name character varying(255) NOT NULL
);


--
-- TOC entry 442 (class 1259 OID 18876)
-- Name: client_scope_client; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_scope_client (
    client_id character varying(255) NOT NULL,
    scope_id character varying(255) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


--
-- TOC entry 443 (class 1259 OID 18882)
-- Name: client_scope_role_mapping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.client_scope_role_mapping (
    scope_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


--
-- TOC entry 444 (class 1259 OID 18885)
-- Name: component; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.component (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_id character varying(36),
    provider_id character varying(36),
    provider_type character varying(255),
    realm_id character varying(36),
    sub_type character varying(255)
);


--
-- TOC entry 445 (class 1259 OID 18890)
-- Name: component_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.component_config (
    id character varying(36) NOT NULL,
    component_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 446 (class 1259 OID 18895)
-- Name: composite_role; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.composite_role (
    composite character varying(36) NOT NULL,
    child_role character varying(36) NOT NULL
);


--
-- TOC entry 447 (class 1259 OID 18898)
-- Name: credential; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    user_id character varying(36),
    created_date bigint,
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer,
    version integer DEFAULT 0
);


--
-- TOC entry 448 (class 1259 OID 18904)
-- Name: databasechangelog; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


--
-- TOC entry 449 (class 1259 OID 18909)
-- Name: databasechangeloglock; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


--
-- TOC entry 450 (class 1259 OID 18912)
-- Name: default_client_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.default_client_scope (
    realm_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


--
-- TOC entry 451 (class 1259 OID 18916)
-- Name: group_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.group_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 452 (class 1259 OID 18922)
-- Name: keycloak_group; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.keycloak_group (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_group character varying(36) NOT NULL,
    realm_id character varying(36),
    type integer DEFAULT 0 NOT NULL,
    description character varying(255)
);


--
-- TOC entry 453 (class 1259 OID 18928)
-- Name: distribution_company_view; Type: VIEW; Schema: mim; Owner: -
--

CREATE VIEW mim.distribution_company_view AS
 SELECT id AS group_id,
    name AS group_name,
    ( SELECT ga.value
           FROM mim.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'piva'::text))) AS piva,
    ( SELECT ga.value
           FROM mim.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'company_db_id'::text))) AS company_db_id,
    ( SELECT ga.value
           FROM mim.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'company_name'::text))) AS company_name
   FROM mim.keycloak_group k
  WHERE (NULLIF(TRIM(BOTH FROM parent_group), ''::text) IS NULL);


--
-- TOC entry 454 (class 1259 OID 18932)
-- Name: group_role_mapping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.group_role_mapping (
    role_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 455 (class 1259 OID 18935)
-- Name: keycloak_role; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.keycloak_role (
    id character varying(36) NOT NULL,
    client_realm_constraint character varying(255),
    client_role boolean DEFAULT false NOT NULL,
    description character varying(255),
    name character varying(255),
    realm_id character varying(255),
    client character varying(36),
    realm character varying(36)
);


--
-- TOC entry 456 (class 1259 OID 18941)
-- Name: distribution_to_keycloak_group_view; Type: VIEW; Schema: mim; Owner: -
--

CREATE VIEW mim.distribution_to_keycloak_group_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg_1.id,
            kg_1.name,
            NULLIF((kg_1.parent_group)::text, ' '::text) AS parent_group,
            kg_1.realm_id,
            kg_1.description,
            (kg_1.name)::text AS path
           FROM mim.keycloak_group kg_1
          WHERE ((kg_1.parent_group IS NULL) OR ((kg_1.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            NULLIF((child.parent_group)::text, ' '::text) AS parent_group,
            child.realm_id,
            child.description,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (mim.keycloak_group child
             JOIN group_path gp_1 ON ((NULLIF((child.parent_group)::text, ' '::text) = (gp_1.id)::text)))
        )
 SELECT row_number() OVER () AS id,
    kg.id AS keycloak_id,
    gp.path AS keycloak_group,
    kg.parent_group AS keycloak_parent,
    kg.realm_id,
    gp.description AS keycloak_group_description,
    gt.name AS attribute_name,
    gt.value AS attribute_value,
    k.id AS role_id,
    k.name AS role_name,
    k.description AS role_description
   FROM ((((mim.keycloak_group kg
     LEFT JOIN group_path gp ON (((gp.id)::text = (kg.id)::text)))
     LEFT JOIN mim.group_attribute gt ON (((kg.id)::text = (gt.group_id)::text)))
     LEFT JOIN mim.group_role_mapping g ON (((kg.id)::text = (g.group_id)::text)))
     LEFT JOIN mim.keycloak_role k ON (((g.role_id)::text = (k.id)::text)));


--
-- TOC entry 457 (class 1259 OID 18946)
-- Name: event_entity; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.event_entity (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    details_json character varying(2550),
    error character varying(255),
    ip_address character varying(255),
    realm_id character varying(255),
    session_id character varying(255),
    event_time bigint,
    type character varying(255),
    user_id character varying(255),
    details_json_long_value text
);


--
-- TOC entry 458 (class 1259 OID 18951)
-- Name: fed_user_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_attribute (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    value character varying(2024),
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


--
-- TOC entry 459 (class 1259 OID 18956)
-- Name: fed_user_consent; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


--
-- TOC entry 460 (class 1259 OID 18961)
-- Name: fed_user_consent_cl_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_consent_cl_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 461 (class 1259 OID 18964)
-- Name: fed_user_credential; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    created_date bigint,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


--
-- TOC entry 462 (class 1259 OID 18969)
-- Name: fed_user_group_membership; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 463 (class 1259 OID 18972)
-- Name: fed_user_required_action; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_required_action (
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 464 (class 1259 OID 18978)
-- Name: fed_user_role_mapping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.fed_user_role_mapping (
    role_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 465 (class 1259 OID 18981)
-- Name: federated_identity; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.federated_identity (
    identity_provider character varying(255) NOT NULL,
    realm_id character varying(36),
    federated_user_id character varying(255),
    federated_username character varying(255),
    token text,
    user_id character varying(36) NOT NULL
);


--
-- TOC entry 466 (class 1259 OID 18986)
-- Name: federated_user; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.federated_user (
    id character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 467 (class 1259 OID 18991)
-- Name: identity_provider; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.identity_provider (
    internal_id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    provider_alias character varying(255),
    provider_id character varying(255),
    store_token boolean DEFAULT false NOT NULL,
    authenticate_by_default boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    add_token_role boolean DEFAULT true NOT NULL,
    trust_email boolean DEFAULT false NOT NULL,
    first_broker_login_flow_id character varying(36),
    post_broker_login_flow_id character varying(36),
    provider_display_name character varying(255),
    link_only boolean DEFAULT false NOT NULL,
    organization_id character varying(255),
    hide_on_login boolean DEFAULT false
);


--
-- TOC entry 468 (class 1259 OID 19003)
-- Name: identity_provider_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.identity_provider_config (
    identity_provider_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 469 (class 1259 OID 19008)
-- Name: identity_provider_mapper; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.identity_provider_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    idp_alias character varying(255) NOT NULL,
    idp_mapper_name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 470 (class 1259 OID 19013)
-- Name: idp_mapper_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.idp_mapper_config (
    idp_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 471 (class 1259 OID 19018)
-- Name: jgroups_ping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.jgroups_ping (
    address character varying(200) NOT NULL,
    name character varying(200),
    cluster_name character varying(200) NOT NULL,
    ip character varying(200) NOT NULL,
    coord boolean
);


--
-- TOC entry 472 (class 1259 OID 19023)
-- Name: keycloak_group_role_summary_view; Type: VIEW; Schema: mim; Owner: -
--

CREATE VIEW mim.keycloak_group_role_summary_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg.id,
            kg.name,
            NULLIF((kg.parent_group)::text, ' '::text) AS parent_group,
            (kg.name)::text AS path
           FROM mim.keycloak_group kg
          WHERE ((kg.parent_group IS NULL) OR ((kg.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            NULLIF((child.parent_group)::text, ' '::text) AS parent_group,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (mim.keycloak_group child
             JOIN group_path gp_1 ON ((NULLIF((child.parent_group)::text, ' '::text) = (gp_1.id)::text)))
        ), group_hierarchy AS (
         SELECT kg.id AS main_group_id,
            kg.name AS main_group_name,
            kg.id AS current_group_id,
            kg.name AS current_group_name,
            0 AS level,
            kg.realm_id
           FROM mim.keycloak_group kg
          WHERE (((kg.parent_group)::text = ' '::text) OR (kg.parent_group IS NULL))
        UNION ALL
         SELECT gh_1.main_group_id,
            gh_1.main_group_name,
            kg.id AS current_group_id,
            kg.name AS current_group_name,
            (gh_1.level + 1) AS level,
            kg.realm_id
           FROM (mim.keycloak_group kg
             JOIN group_hierarchy gh_1 ON (((kg.parent_group)::text = (gh_1.current_group_id)::text)))
        ), roles_aggregated AS (
         SELECT grm.group_id,
            string_agg(DISTINCT (kr.name)::text, ','::text) AS roles,
            string_agg(DISTINCT (kr.id)::text, ','::text) AS role_ids
           FROM (mim.group_role_mapping grm
             JOIN mim.keycloak_role kr ON (((kr.id)::text = (grm.role_id)::text)))
          GROUP BY grm.group_id
        ), attrs_flat AS (
         SELECT gh_1.main_group_id,
            gh_1.current_group_id,
            gh_1.level,
            ga.name,
            ga.value
           FROM (group_hierarchy gh_1
             LEFT JOIN mim.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
          WHERE (ga.name IS NOT NULL)
        ), attrs_dedup_main AS (
         SELECT t.main_group_id,
            t.name,
            t.value
           FROM ( SELECT attrs_flat.main_group_id,
                    attrs_flat.name,
                    attrs_flat.value,
                    attrs_flat.level,
                    row_number() OVER (PARTITION BY attrs_flat.main_group_id, attrs_flat.name ORDER BY attrs_flat.level DESC) AS rn
                   FROM attrs_flat) t
          WHERE (t.rn = 1)
        ), attrs_all_by_main AS (
         SELECT gh_1.main_group_id,
            jsonb_agg(DISTINCT jsonb_build_object('id', ga.id, 'name', ga.name, 'value', ga.value)) FILTER (WHERE (ga.id IS NOT NULL)) AS attributes_all
           FROM (group_hierarchy gh_1
             LEFT JOIN mim.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
          GROUP BY gh_1.main_group_id
        ), attrs_by_group AS (
         SELECT gh_1.current_group_id AS group_id,
            jsonb_agg(jsonb_build_object('id', ga.id, 'name', ga.name, 'value', ga.value)) FILTER (WHERE (ga.id IS NOT NULL)) AS attributes_current
           FROM (group_hierarchy gh_1
             LEFT JOIN mim.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
          GROUP BY gh_1.current_group_id
        ), distribution_company_from_attrs AS (
         SELECT a.main_group_id,
            (elem.value ->> 'id'::text) AS distribution_company_id,
            (elem.value ->> 'value'::text) AS distribution_company_name
           FROM (attrs_all_by_main a
             CROSS JOIN LATERAL jsonb_array_elements(a.attributes_all) elem(value))
          WHERE ((elem.value ->> 'name'::text) = 'company_name'::text)
        )
 SELECT row_number() OVER () AS id,
        CASE
            WHEN (gh.level = 0) THEN gh.main_group_id
            ELSE gh.current_group_id
        END AS group_id,
    gh.main_group_name AS group_name,
        CASE
            WHEN (gh.level = 0) THEN NULL::character varying
            ELSE gh.current_group_name
        END AS sub_group_name,
        CASE
            WHEN (gh.level = 0) THEN (NULL::character varying)::text
            WHEN (gh.level = 1) THEN (gh.current_group_name)::text
            ELSE substr(gp.path, (length((gh.main_group_name)::text) + 2))
        END AS group_path,
    gh.level,
    gh.realm_id,
    ra.roles,
    dca.distribution_company_id,
    dca.distribution_company_name,
    ag.attributes_current,
    am.attributes_all
   FROM (((((group_hierarchy gh
     LEFT JOIN group_path gp ON (((gp.id)::text = (gh.current_group_id)::text)))
     LEFT JOIN roles_aggregated ra ON (((ra.group_id)::text = (gh.current_group_id)::text)))
     LEFT JOIN attrs_all_by_main am ON (((am.main_group_id)::text = (gh.main_group_id)::text)))
     LEFT JOIN attrs_by_group ag ON (((ag.group_id)::text = (gh.current_group_id)::text)))
     LEFT JOIN distribution_company_from_attrs dca ON (((dca.main_group_id)::text = (gh.main_group_id)::text)));


--
-- TOC entry 473 (class 1259 OID 19028)
-- Name: keycloak_role_group_summary_view; Type: VIEW; Schema: mim; Owner: -
--

CREATE VIEW mim.keycloak_role_group_summary_view AS
 SELECT kr.id AS roles_id,
    kr.name AS role_name,
    kr.description,
    kr.realm_id,
    string_agg((
        CASE
            WHEN (parent.name IS NOT NULL) THEN ((((parent.name)::text || '/'::text) || (kg.name)::text))::character varying
            ELSE kg.name
        END)::text, ','::text ORDER BY (
        CASE
            WHEN (parent.name IS NOT NULL) THEN ((((parent.name)::text || '/'::text) || (kg.name)::text))::character varying
            ELSE kg.name
        END)::text) AS group_name
   FROM (((mim.keycloak_group kg
     LEFT JOIN mim.keycloak_group parent ON (((kg.parent_group)::text = (parent.id)::text)))
     LEFT JOIN mim.group_role_mapping grm ON (((kg.id)::text = (grm.group_id)::text)))
     RIGHT JOIN mim.keycloak_role kr ON (((grm.role_id)::text = (kr.id)::text)))
  WHERE (kr.client_role IS FALSE)
  GROUP BY kr.id, kr.name, kr.description, kr.realm_id;


--
-- TOC entry 474 (class 1259 OID 19033)
-- Name: user_entity; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_entity (
    id character varying(36) NOT NULL,
    email character varying(255),
    email_constraint character varying(255),
    email_verified boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    federation_link character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    realm_id character varying(255),
    username character varying(255),
    created_timestamp bigint,
    service_account_client_link character varying(255),
    not_before integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 475 (class 1259 OID 19041)
-- Name: user_group_membership; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    membership_type character varying(255) NOT NULL
);


--
-- TOC entry 476 (class 1259 OID 19044)
-- Name: keycloak_user_group_view; Type: VIEW; Schema: mim; Owner: -
--

CREATE VIEW mim.keycloak_user_group_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg_1.id,
            kg_1.name,
            kg_1.parent_group,
            (kg_1.name)::text AS path
           FROM mim.keycloak_group kg_1
          WHERE ((kg_1.parent_group IS NULL) OR ((kg_1.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            child.parent_group,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (mim.keycloak_group child
             JOIN group_path gp_1 ON (((child.parent_group)::text = (gp_1.id)::text)))
        ), ancestors AS (
         SELECT kg_1.id,
            kg_1.parent_group,
            kg_1.id AS start_id,
            0 AS depth
           FROM mim.keycloak_group kg_1
        UNION ALL
         SELECT parent.id,
            parent.parent_group,
            a.start_id,
            (a.depth + 1)
           FROM (ancestors a
             JOIN mim.keycloak_group parent ON (((parent.id)::text = (a.parent_group)::text)))
        ), company_attr AS (
         SELECT DISTINCT ON (a.start_id) a.start_id,
            ga.value AS distribution_company,
            ga.id AS distribution_company_id,
            a.depth
           FROM (ancestors a
             JOIN mim.group_attribute ga ON ((((ga.group_id)::text = (a.id)::text) AND ((ga.name)::text = 'company_name'::text))))
          ORDER BY a.start_id, a.depth
        )
 SELECT row_number() OVER () AS id,
    ue.id AS user_id,
    ue.email,
    ue.username,
    ue.first_name,
    ue.last_name,
    ((c.secret_data)::json ->> 'value'::text) AS password,
    ue.enabled,
    ue.realm_id,
    ugm.group_id,
    f.identity_provider,
    gp.path AS group_name,
    ca.distribution_company,
    ca.distribution_company_id
   FROM ((((((mim.user_entity ue
     LEFT JOIN mim.credential c ON (((ue.id)::text = (c.user_id)::text)))
     LEFT JOIN mim.federated_identity f ON (((ue.id)::text = (f.user_id)::text)))
     LEFT JOIN mim.user_group_membership ugm ON (((ue.id)::text = (ugm.user_id)::text)))
     LEFT JOIN mim.keycloak_group kg ON (((ugm.group_id)::text = (kg.id)::text)))
     LEFT JOIN group_path gp ON (((gp.id)::text = (kg.id)::text)))
     LEFT JOIN company_attr ca ON (((ca.start_id)::text = (kg.id)::text)));


--
-- TOC entry 477 (class 1259 OID 19049)
-- Name: menu_items; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.menu_items (
    id bigint NOT NULL,
    description character varying(100),
    icon character varying(100),
    item character varying(50),
    label character varying(100) NOT NULL,
    uri character varying(300),
    visual_order integer DEFAULT 0 NOT NULL,
    parent_id bigint,
    role_id character varying(36) NOT NULL,
    visible boolean DEFAULT false
);


--
-- TOC entry 478 (class 1259 OID 19056)
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: mim; Owner: -
--

ALTER TABLE mim.menu_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME mim.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 479 (class 1259 OID 19057)
-- Name: migration_model; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.migration_model (
    id character varying(36) NOT NULL,
    version character varying(36),
    update_time bigint DEFAULT 0 NOT NULL
);


--
-- TOC entry 480 (class 1259 OID 19061)
-- Name: offline_client_session; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.offline_client_session (
    user_session_id character varying(36) NOT NULL,
    client_id character varying(255) NOT NULL,
    offline_flag character varying(4) NOT NULL,
    "timestamp" integer,
    data text,
    client_storage_provider character varying(36) DEFAULT 'local'::character varying NOT NULL,
    external_client_id character varying(255) DEFAULT 'local'::character varying NOT NULL,
    version integer DEFAULT 0
);


--
-- TOC entry 481 (class 1259 OID 19069)
-- Name: offline_user_session; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.offline_user_session (
    user_session_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    created_on integer NOT NULL,
    offline_flag character varying(4) NOT NULL,
    data text,
    last_session_refresh integer DEFAULT 0 NOT NULL,
    broker_session_id character varying(1024),
    version integer DEFAULT 0
);


--
-- TOC entry 482 (class 1259 OID 19076)
-- Name: org; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.org (
    id character varying(255) NOT NULL,
    enabled boolean NOT NULL,
    realm_id character varying(255) NOT NULL,
    group_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(4000),
    alias character varying(255) NOT NULL,
    redirect_url character varying(2048)
);


--
-- TOC entry 483 (class 1259 OID 19081)
-- Name: org_domain; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.org_domain (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    verified boolean NOT NULL,
    org_id character varying(255) NOT NULL
);


--
-- TOC entry 484 (class 1259 OID 19086)
-- Name: policy_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.policy_config (
    policy_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 485 (class 1259 OID 19091)
-- Name: protocol_mapper; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.protocol_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    protocol character varying(255) NOT NULL,
    protocol_mapper_name character varying(255) NOT NULL,
    client_id character varying(36),
    client_scope_id character varying(36)
);


--
-- TOC entry 486 (class 1259 OID 19096)
-- Name: protocol_mapper_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.protocol_mapper_config (
    protocol_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 487 (class 1259 OID 19101)
-- Name: realm; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm (
    id character varying(36) NOT NULL,
    access_code_lifespan integer,
    user_action_lifespan integer,
    access_token_lifespan integer,
    account_theme character varying(255),
    admin_theme character varying(255),
    email_theme character varying(255),
    enabled boolean DEFAULT false NOT NULL,
    events_enabled boolean DEFAULT false NOT NULL,
    events_expiration bigint,
    login_theme character varying(255),
    name character varying(255),
    not_before integer,
    password_policy character varying(2550),
    registration_allowed boolean DEFAULT false NOT NULL,
    remember_me boolean DEFAULT false NOT NULL,
    reset_password_allowed boolean DEFAULT false NOT NULL,
    social boolean DEFAULT false NOT NULL,
    ssl_required character varying(255),
    sso_idle_timeout integer,
    sso_max_lifespan integer,
    update_profile_on_soc_login boolean DEFAULT false NOT NULL,
    verify_email boolean DEFAULT false NOT NULL,
    master_admin_client character varying(36),
    login_lifespan integer,
    internationalization_enabled boolean DEFAULT false NOT NULL,
    default_locale character varying(255),
    reg_email_as_username boolean DEFAULT false NOT NULL,
    admin_events_enabled boolean DEFAULT false NOT NULL,
    admin_events_details_enabled boolean DEFAULT false NOT NULL,
    edit_username_allowed boolean DEFAULT false NOT NULL,
    otp_policy_counter integer DEFAULT 0,
    otp_policy_window integer DEFAULT 1,
    otp_policy_period integer DEFAULT 30,
    otp_policy_digits integer DEFAULT 6,
    otp_policy_alg character varying(36) DEFAULT 'HmacSHA1'::character varying,
    otp_policy_type character varying(36) DEFAULT 'totp'::character varying,
    browser_flow character varying(36),
    registration_flow character varying(36),
    direct_grant_flow character varying(36),
    reset_credentials_flow character varying(36),
    client_auth_flow character varying(36),
    offline_session_idle_timeout integer DEFAULT 0,
    revoke_refresh_token boolean DEFAULT false NOT NULL,
    access_token_life_implicit integer DEFAULT 0,
    login_with_email_allowed boolean DEFAULT true NOT NULL,
    duplicate_emails_allowed boolean DEFAULT false NOT NULL,
    docker_auth_flow character varying(36),
    refresh_token_max_reuse integer DEFAULT 0,
    allow_user_managed_access boolean DEFAULT false NOT NULL,
    sso_max_lifespan_remember_me integer DEFAULT 0 NOT NULL,
    sso_idle_timeout_remember_me integer DEFAULT 0 NOT NULL,
    default_role character varying(255)
);


--
-- TOC entry 488 (class 1259 OID 19134)
-- Name: realm_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_attribute (
    name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    value text
);


--
-- TOC entry 489 (class 1259 OID 19139)
-- Name: realm_default_groups; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_default_groups (
    realm_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 490 (class 1259 OID 19142)
-- Name: realm_enabled_event_types; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_enabled_event_types (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 491 (class 1259 OID 19145)
-- Name: realm_events_listeners; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_events_listeners (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 492 (class 1259 OID 19148)
-- Name: realm_localizations; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_localizations (
    realm_id character varying(255) NOT NULL,
    locale character varying(255) NOT NULL,
    texts text NOT NULL
);


--
-- TOC entry 493 (class 1259 OID 19153)
-- Name: realm_required_credential; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_required_credential (
    type character varying(255) NOT NULL,
    form_label character varying(255),
    input boolean DEFAULT false NOT NULL,
    secret boolean DEFAULT false NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 494 (class 1259 OID 19160)
-- Name: realm_smtp_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_smtp_config (
    realm_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 495 (class 1259 OID 19165)
-- Name: realm_supported_locales; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.realm_supported_locales (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 496 (class 1259 OID 19168)
-- Name: redirect_uris; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.redirect_uris (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 497 (class 1259 OID 19171)
-- Name: required_action_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.required_action_config (
    required_action_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 498 (class 1259 OID 19176)
-- Name: required_action_provider; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.required_action_provider (
    id character varying(36) NOT NULL,
    alias character varying(255),
    name character varying(255),
    realm_id character varying(36),
    enabled boolean DEFAULT false NOT NULL,
    default_action boolean DEFAULT false NOT NULL,
    provider_id character varying(255),
    priority integer
);


--
-- TOC entry 499 (class 1259 OID 19183)
-- Name: resource_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    resource_id character varying(36) NOT NULL
);


--
-- TOC entry 500 (class 1259 OID 19189)
-- Name: resource_policy; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_policy (
    resource_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


--
-- TOC entry 501 (class 1259 OID 19192)
-- Name: resource_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_scope (
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 502 (class 1259 OID 19195)
-- Name: resource_server; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_server (
    id character varying(36) NOT NULL,
    allow_rs_remote_mgmt boolean DEFAULT false NOT NULL,
    policy_enforce_mode smallint NOT NULL,
    decision_strategy smallint DEFAULT 1 NOT NULL
);


--
-- TOC entry 503 (class 1259 OID 19200)
-- Name: resource_server_perm_ticket; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_server_perm_ticket (
    id character varying(36) NOT NULL,
    owner character varying(255) NOT NULL,
    requester character varying(255) NOT NULL,
    created_timestamp bigint NOT NULL,
    granted_timestamp bigint,
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36),
    resource_server_id character varying(36) NOT NULL,
    policy_id character varying(36)
);


--
-- TOC entry 504 (class 1259 OID 19205)
-- Name: resource_server_policy; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_server_policy (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    type character varying(255) NOT NULL,
    decision_strategy smallint,
    logic smallint,
    resource_server_id character varying(36) NOT NULL,
    owner character varying(255)
);


--
-- TOC entry 505 (class 1259 OID 19210)
-- Name: resource_server_resource; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_server_resource (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255),
    icon_uri character varying(255),
    owner character varying(255) NOT NULL,
    resource_server_id character varying(36) NOT NULL,
    owner_managed_access boolean DEFAULT false NOT NULL,
    display_name character varying(255)
);


--
-- TOC entry 506 (class 1259 OID 19216)
-- Name: resource_server_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_server_scope (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon_uri character varying(255),
    resource_server_id character varying(36) NOT NULL,
    display_name character varying(255)
);


--
-- TOC entry 507 (class 1259 OID 19221)
-- Name: resource_uris; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.resource_uris (
    resource_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 508 (class 1259 OID 19224)
-- Name: revoked_token; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.revoked_token (
    id character varying(255) NOT NULL,
    expire bigint NOT NULL
);


--
-- TOC entry 509 (class 1259 OID 19227)
-- Name: role_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.role_attribute (
    id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255)
);


--
-- TOC entry 510 (class 1259 OID 19232)
-- Name: scope_mapping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.scope_mapping (
    client_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


--
-- TOC entry 511 (class 1259 OID 19235)
-- Name: scope_policy; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.scope_policy (
    scope_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


--
-- TOC entry 512 (class 1259 OID 19238)
-- Name: server_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.server_config (
    server_config_key character varying(255) NOT NULL,
    value text NOT NULL,
    version integer DEFAULT 0
);


--
-- TOC entry 513 (class 1259 OID 19244)
-- Name: user_attribute; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_attribute (
    name character varying(255) NOT NULL,
    value character varying(255),
    user_id character varying(36) NOT NULL,
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


--
-- TOC entry 514 (class 1259 OID 19250)
-- Name: user_consent; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(36) NOT NULL,
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


--
-- TOC entry 515 (class 1259 OID 19255)
-- Name: user_consent_client_scope; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_consent_client_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 516 (class 1259 OID 19258)
-- Name: user_federation_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_federation_config (
    user_federation_provider_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 517 (class 1259 OID 19263)
-- Name: user_federation_mapper; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_federation_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    federation_provider_id character varying(36) NOT NULL,
    federation_mapper_type character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 518 (class 1259 OID 19268)
-- Name: user_federation_mapper_config; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_federation_mapper_config (
    user_federation_mapper_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 519 (class 1259 OID 19273)
-- Name: user_federation_provider; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_federation_provider (
    id character varying(36) NOT NULL,
    changed_sync_period integer,
    display_name character varying(255),
    full_sync_period integer,
    last_sync integer,
    priority integer,
    provider_name character varying(255),
    realm_id character varying(36)
);


--
-- TOC entry 520 (class 1259 OID 19278)
-- Name: user_required_action; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_required_action (
    user_id character varying(36) NOT NULL,
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL
);


--
-- TOC entry 521 (class 1259 OID 19282)
-- Name: user_role_mapping; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.user_role_mapping (
    role_id character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL
);


--
-- TOC entry 522 (class 1259 OID 19285)
-- Name: web_origins; Type: TABLE; Schema: mim; Owner: -
--

CREATE TABLE mim.web_origins (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 5438 (class 0 OID 18801)
-- Dependencies: 428
-- Data for Name: admin_event_entity; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5439 (class 0 OID 18806)
-- Dependencies: 429
-- Data for Name: associated_policy; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5440 (class 0 OID 18809)
-- Dependencies: 430
-- Data for Name: authentication_execution; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.authentication_execution VALUES ('7924e8bd-b0e1-4fbd-8e30-4d22e897e00a', NULL, 'auth-cookie', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('d3576418-f5eb-4309-9e7b-95784e5f5cc0', NULL, 'auth-spnego', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 3, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('ed643239-e18f-4ac3-94c4-b86bf5348690', NULL, 'identity-provider-redirector', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 25, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('adbfe000-2d74-44f6-ac4e-db7a39c11be5', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 30, true, 'ed691b27-ac6c-49ec-954c-4a9223701987', NULL);
INSERT INTO mim.authentication_execution VALUES ('7b8b8659-89fc-41f5-9905-da339d34ac71', NULL, 'auth-username-password-form', '0c806647-a11c-403d-af39-092523465ca0', 'ed691b27-ac6c-49ec-954c-4a9223701987', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('87fec2b4-274b-40dc-a4d3-fd672e71af19', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'ed691b27-ac6c-49ec-954c-4a9223701987', 1, 20, true, '12a33a18-3d69-41eb-9091-9617d079590e', NULL);
INSERT INTO mim.authentication_execution VALUES ('748e94d8-3ff6-47ce-bb8a-7312a0058f37', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('50f672e2-ba9a-4d41-a825-e2ae3052af08', NULL, 'auth-otp-form', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('54f3f0fb-e1d1-40c0-923b-e4326ec72159', NULL, 'webauthn-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 3, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('714cc9bf-7e2c-4028-a56f-16b9522a2d0c', NULL, 'auth-recovery-authn-code-form', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 3, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('b2b71f13-1680-498c-95bf-6a00eaca879f', NULL, 'direct-grant-validate-username', '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('2f0a4a73-8cc3-4b7d-933a-686c5e427c72', NULL, 'direct-grant-validate-password', '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('bbe74c50-d35b-4470-8ef0-6012d5354883', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 1, 30, true, '29376f88-03f6-44ba-99f6-53158b056246', NULL);
INSERT INTO mim.authentication_execution VALUES ('b0b8074a-8def-4c48-9751-c738e43c7454', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '29376f88-03f6-44ba-99f6-53158b056246', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('b70b5a27-2701-4adc-b879-1cf36b0fade1', NULL, 'direct-grant-validate-otp', '0c806647-a11c-403d-af39-092523465ca0', '29376f88-03f6-44ba-99f6-53158b056246', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('c311abeb-fc54-46e4-80cc-44dd6a478b40', NULL, 'registration-page-form', '0c806647-a11c-403d-af39-092523465ca0', 'd5ca2242-a726-45ed-abc5-0ab031f68d89', 0, 10, true, '0b0950be-3030-44ce-9d85-4e1ff1801173', NULL);
INSERT INTO mim.authentication_execution VALUES ('52b1004a-6dd2-45a1-be78-804f2e57582c', NULL, 'registration-user-creation', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('27d28ad5-4490-4d96-aa89-ad3440b69da8', NULL, 'registration-password-action', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 0, 50, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('97ed2230-a268-423d-ae8f-8e25aa450858', NULL, 'registration-recaptcha-action', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 3, 60, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('4623917b-9980-4e2a-951d-32f7d3a888e8', NULL, 'registration-terms-and-conditions', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 3, 70, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('69d09f35-8c6c-4c8c-84a6-584f6fbb7284', NULL, 'reset-credentials-choose-user', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('916e1f9d-1955-41ca-a5ea-d7dbecb3818d', NULL, 'reset-credential-email', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('3e454d19-d18d-4c9c-b566-151fc867467f', NULL, 'reset-password', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('e9721799-9fda-4984-a51c-50f941a2c1ca', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 1, 40, true, '3b538c6b-78d0-4485-97a2-799a543e1d3c', NULL);
INSERT INTO mim.authentication_execution VALUES ('bd93dd80-6a5e-477d-be47-4b72c95ebfb8', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '3b538c6b-78d0-4485-97a2-799a543e1d3c', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('21b7f95b-087b-400e-82de-eea37b97a7ce', NULL, 'reset-otp', '0c806647-a11c-403d-af39-092523465ca0', '3b538c6b-78d0-4485-97a2-799a543e1d3c', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('ab7a5826-55df-4f8b-b00f-09b2f7ee8852', NULL, 'client-secret', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('718ed6ff-ecad-40bd-9198-d0a44a7d5517', NULL, 'client-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('89458be5-18ac-4266-834c-54e2325f081d', NULL, 'client-secret-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('82e3864a-9c6b-43c0-9012-4c78eb8ef8ef', NULL, 'client-x509', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('fb2d39bc-c1a6-43f4-9e83-a286add7e646', NULL, 'idp-review-profile', '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 0, 10, false, NULL, 'bb3ab7fc-2f26-415c-aa8c-305a853f5031');
INSERT INTO mim.authentication_execution VALUES ('cdef4ba6-4321-4e9a-b34d-f77ef2e86858', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 0, 20, true, '86316c79-d109-4492-b1ed-b769c9b67c56', NULL);
INSERT INTO mim.authentication_execution VALUES ('255fadda-69b8-4a4d-a908-c3725066eba2', NULL, 'idp-create-user-if-unique', '0c806647-a11c-403d-af39-092523465ca0', '86316c79-d109-4492-b1ed-b769c9b67c56', 2, 10, false, NULL, 'c6f54644-4ff0-42d6-bf2f-90c1782c94e0');
INSERT INTO mim.authentication_execution VALUES ('b4d7e253-8988-4735-b673-220fbefb6f36', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '86316c79-d109-4492-b1ed-b769c9b67c56', 2, 20, true, '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', NULL);
INSERT INTO mim.authentication_execution VALUES ('ba79324b-e15f-4694-a25e-367b2efea414', NULL, 'idp-confirm-link', '0c806647-a11c-403d-af39-092523465ca0', '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('91b181ba-447f-491e-bf0c-bfc0f2c240b6', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 0, 20, true, '0477b3bf-3c95-418d-9d60-330d0a110004', NULL);
INSERT INTO mim.authentication_execution VALUES ('bb0d5e92-27ab-4d3e-8310-6020715ea04e', NULL, 'idp-email-verification', '0c806647-a11c-403d-af39-092523465ca0', '0477b3bf-3c95-418d-9d60-330d0a110004', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('22606dc7-446f-46a6-895f-debd056bf9a7', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '0477b3bf-3c95-418d-9d60-330d0a110004', 2, 20, true, '827d3481-45aa-4f03-9b65-932142e852a8', NULL);
INSERT INTO mim.authentication_execution VALUES ('11b6e953-0b56-4f4b-b4be-185a74058b15', NULL, 'idp-username-password-form', '0c806647-a11c-403d-af39-092523465ca0', '827d3481-45aa-4f03-9b65-932142e852a8', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('442932c7-b5ea-4f5f-a91e-cb37d07c3d9a', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '827d3481-45aa-4f03-9b65-932142e852a8', 1, 20, true, '2ee08def-66d5-4485-8930-5f353401803e', NULL);
INSERT INTO mim.authentication_execution VALUES ('61248cc2-396e-48b6-82ff-b8cd3b3cc743', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('fbe1e72f-70e1-4a09-8b8a-a6eec9217100', NULL, 'auth-otp-form', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('0aa5631e-6f0b-4f37-9aad-0909f03a6dde', NULL, 'webauthn-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 3, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('fe64eae0-7ffc-4ae4-acd6-07bd20869607', NULL, 'auth-recovery-authn-code-form', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 3, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('c589e443-0576-4b75-9b6c-6cc5c0454fae', NULL, 'http-basic-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '8e26f438-ebb5-445c-a713-fffe62480957', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('45aeddec-b369-4abb-801f-9f92eaa10df5', NULL, 'docker-http-basic-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '5e51b971-b52e-4997-9c70-d0fd966312f6', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('e45082ba-aa9a-4996-b51d-b9f42634b96a', NULL, 'auth-cookie', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39ea369c-a110-499e-8fd3-722b8b3481c4', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('92202e02-21a3-4af9-8067-22c4117fb009', NULL, 'auth-spnego', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39ea369c-a110-499e-8fd3-722b8b3481c4', 3, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('66db6c23-bd4a-49f5-bc13-83e1635e88ce', NULL, 'identity-provider-redirector', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39ea369c-a110-499e-8fd3-722b8b3481c4', 2, 25, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('e1806bf6-6ba5-4083-9002-04b71b7fdf38', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39ea369c-a110-499e-8fd3-722b8b3481c4', 2, 30, true, '39f27ca9-c7b5-443e-bd5b-3eaa28ffa4e8', NULL);
INSERT INTO mim.authentication_execution VALUES ('09b9e732-e2f1-41c6-8c81-a37f1ff571ac', NULL, 'auth-username-password-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39f27ca9-c7b5-443e-bd5b-3eaa28ffa4e8', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('01ae33df-e6da-467b-8dcb-32c83ce6b983', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39f27ca9-c7b5-443e-bd5b-3eaa28ffa4e8', 1, 20, true, '691676b8-1b75-4120-abc3-57bcdb2d44e4', NULL);
INSERT INTO mim.authentication_execution VALUES ('7ff8ca56-799d-4cef-ba05-88f54cce6b10', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '691676b8-1b75-4120-abc3-57bcdb2d44e4', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('172707dc-53b0-4b31-aaa4-f916234780aa', NULL, 'auth-otp-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '691676b8-1b75-4120-abc3-57bcdb2d44e4', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('20decbf1-e39b-45f0-aa04-c821926e259a', NULL, 'webauthn-authenticator', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '691676b8-1b75-4120-abc3-57bcdb2d44e4', 3, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('74de6ccd-f4ef-4333-abc5-d693098c0950', NULL, 'auth-recovery-authn-code-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '691676b8-1b75-4120-abc3-57bcdb2d44e4', 3, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('d431b906-8776-4b47-ba9f-94b07c8bc6d4', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '39ea369c-a110-499e-8fd3-722b8b3481c4', 2, 26, true, '6670a368-0f71-43f5-8444-d4daa576e8fc', NULL);
INSERT INTO mim.authentication_execution VALUES ('4dd0ae80-d051-4306-97a9-f9c4abf08590', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '6670a368-0f71-43f5-8444-d4daa576e8fc', 1, 10, true, '5d8c7504-20f9-42cb-a37a-1e6e0025949f', NULL);
INSERT INTO mim.authentication_execution VALUES ('3262bcb7-926c-425e-9563-9eef6fa83b46', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5d8c7504-20f9-42cb-a37a-1e6e0025949f', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('bfb0187e-7b4d-4895-91e3-34babc4a5f43', NULL, 'organization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5d8c7504-20f9-42cb-a37a-1e6e0025949f', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('bbe012ba-dd56-4280-b983-fe46d0999cc1', NULL, 'direct-grant-validate-username', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '24bf60db-ab22-421b-8f12-7091e59c4837', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('d8c439b0-9b23-4708-88e6-4b8ae071183e', NULL, 'direct-grant-validate-password', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '24bf60db-ab22-421b-8f12-7091e59c4837', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('42ed5ea1-22c6-471c-b05a-b5db73843d2e', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '24bf60db-ab22-421b-8f12-7091e59c4837', 1, 30, true, 'a3414214-0307-4380-a5e1-5bd36058c0ed', NULL);
INSERT INTO mim.authentication_execution VALUES ('4048ef2f-1a3f-4abf-8c54-ff9b8cbc3b36', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'a3414214-0307-4380-a5e1-5bd36058c0ed', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('75358124-0ee1-4d87-9341-82fae28f3197', NULL, 'direct-grant-validate-otp', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'a3414214-0307-4380-a5e1-5bd36058c0ed', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('6fd11954-e081-496c-bb2c-1c66bead5b8d', NULL, 'registration-page-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5ba7f27f-4dc7-4d74-8510-d69c7b8ee289', 0, 10, true, '51f11764-bad7-4fdb-9551-c3de2d2eb092', NULL);
INSERT INTO mim.authentication_execution VALUES ('265f4a2b-3503-475a-bc2a-daba0bfa5481', NULL, 'registration-user-creation', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '51f11764-bad7-4fdb-9551-c3de2d2eb092', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('509feeae-9b14-451b-a3a1-f442e403888b', NULL, 'registration-password-action', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '51f11764-bad7-4fdb-9551-c3de2d2eb092', 0, 50, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('7bdb2867-6d4c-4e9c-9691-49d3ff002916', NULL, 'registration-recaptcha-action', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '51f11764-bad7-4fdb-9551-c3de2d2eb092', 3, 60, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('11e7746a-b02e-40a4-a2d7-629000bf767b', NULL, 'registration-terms-and-conditions', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '51f11764-bad7-4fdb-9551-c3de2d2eb092', 3, 70, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('6acafe8f-b79c-4161-9c86-df10e6f0cf3d', NULL, 'reset-credentials-choose-user', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('4db6bc54-f3a6-47c0-a577-4cb97778ba28', NULL, 'reset-credential-email', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('1e71121d-3f72-4fa5-95d6-4771c72ad9c9', NULL, 'reset-password', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 0, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('1bf2ce67-7478-4016-9fbb-7186fea800a5', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 1, 40, true, 'dd69189b-2211-4fca-aee2-72d91ccbc793', NULL);
INSERT INTO mim.authentication_execution VALUES ('266421f3-8eda-430a-9598-dd189fa235ba', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'dd69189b-2211-4fca-aee2-72d91ccbc793', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('ba6ab471-4ad0-4e49-a0ab-cedddff6187b', NULL, 'reset-otp', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'dd69189b-2211-4fca-aee2-72d91ccbc793', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('9bd565d3-1d9e-4069-a074-46579961f642', NULL, 'client-secret', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'd1b4fbbf-0cf1-4270-86e9-3aef615553b7', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('8b8db497-7001-4e05-b13e-919471d4f8f7', NULL, 'client-jwt', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'd1b4fbbf-0cf1-4270-86e9-3aef615553b7', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('e93dc2f0-e018-408a-a019-16fdb65d4ec7', NULL, 'client-secret-jwt', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'd1b4fbbf-0cf1-4270-86e9-3aef615553b7', 2, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('763e8890-e0d5-4453-9cc6-0e2b31006a0a', NULL, 'client-x509', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'd1b4fbbf-0cf1-4270-86e9-3aef615553b7', 2, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('374caf5c-afd1-4b00-92e2-4df1f661e2f4', NULL, 'idp-review-profile', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '9e3d118c-ff59-496b-97c0-ff2a4124b8dc', 0, 10, false, NULL, 'fcdd5bcd-25f9-4ad2-8c35-ecf10d2c8b2f');
INSERT INTO mim.authentication_execution VALUES ('f9f54a2a-df46-472d-8c53-045d058cb1d4', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '9e3d118c-ff59-496b-97c0-ff2a4124b8dc', 0, 20, true, '6428b503-f2de-4dbd-8d1a-9b8e811f0dbd', NULL);
INSERT INTO mim.authentication_execution VALUES ('4c7404c1-d94a-433d-a4df-b92aa2e9f433', NULL, 'idp-create-user-if-unique', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '6428b503-f2de-4dbd-8d1a-9b8e811f0dbd', 2, 10, false, NULL, 'b2d2d468-3e05-48e4-8fbe-f03d6347b756');
INSERT INTO mim.authentication_execution VALUES ('db627ced-4850-4f42-8eeb-ca0844f7d826', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '6428b503-f2de-4dbd-8d1a-9b8e811f0dbd', 2, 20, true, '60b6831d-0028-446a-b1ed-123e1f9a78a1', NULL);
INSERT INTO mim.authentication_execution VALUES ('3cd06a79-4ebb-48ef-9af3-f055ebfe4c9d', NULL, 'idp-confirm-link', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '60b6831d-0028-446a-b1ed-123e1f9a78a1', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('5ca5ecb3-4744-4322-99a0-95686e492671', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '60b6831d-0028-446a-b1ed-123e1f9a78a1', 0, 20, true, '6d134011-202b-44db-94ac-17af6d12dd5c', NULL);
INSERT INTO mim.authentication_execution VALUES ('f98ffc70-27e8-43d3-9101-c31c9fdde1ca', NULL, 'idp-email-verification', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '6d134011-202b-44db-94ac-17af6d12dd5c', 2, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('8400324e-7679-40e1-bfc5-6b0d95f59dbf', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '6d134011-202b-44db-94ac-17af6d12dd5c', 2, 20, true, 'b92a38df-43d3-417b-a177-29b6cbd25be4', NULL);
INSERT INTO mim.authentication_execution VALUES ('0f34e231-a7a2-4f1e-82f8-23904dfe205a', NULL, 'idp-username-password-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'b92a38df-43d3-417b-a177-29b6cbd25be4', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('f05ebde1-96bb-42ce-b4e7-7abebacec747', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'b92a38df-43d3-417b-a177-29b6cbd25be4', 1, 20, true, 'c00f0eb2-5f28-4e67-990b-e916434622cc', NULL);
INSERT INTO mim.authentication_execution VALUES ('5af8e486-157b-46d4-9670-cd27c030bce7', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'c00f0eb2-5f28-4e67-990b-e916434622cc', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('5aa80724-c552-4b16-a903-d3e891b1344e', NULL, 'auth-otp-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'c00f0eb2-5f28-4e67-990b-e916434622cc', 2, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('d9c54ba1-e86e-4ddf-8116-cad327d82542', NULL, 'webauthn-authenticator', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'c00f0eb2-5f28-4e67-990b-e916434622cc', 3, 30, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('da91e262-c0be-4827-9a38-5edcab8823d2', NULL, 'auth-recovery-authn-code-form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'c00f0eb2-5f28-4e67-990b-e916434622cc', 3, 40, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('6aed0a33-8973-4350-aa6f-9bb99a452241', NULL, NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', '9e3d118c-ff59-496b-97c0-ff2a4124b8dc', 1, 50, true, 'a0e47e7e-a8c2-4609-b182-8ba4b0480428', NULL);
INSERT INTO mim.authentication_execution VALUES ('facf725c-8af2-4e46-95e2-875a11103b08', NULL, 'conditional-user-configured', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'a0e47e7e-a8c2-4609-b182-8ba4b0480428', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('607d1c29-08e2-4654-8262-a47a6cfbd467', NULL, 'idp-add-organization-member', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'a0e47e7e-a8c2-4609-b182-8ba4b0480428', 0, 20, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('419c9c8e-f913-4cd4-8a66-969d9cb70b4b', NULL, 'http-basic-authenticator', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'beec69cd-cdb9-40ef-b1d1-5f612ee67682', 0, 10, false, NULL, NULL);
INSERT INTO mim.authentication_execution VALUES ('efc5b224-2c7e-42c6-9cfc-bacdb82996b9', NULL, 'docker-http-basic-authenticator', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '84b34ea5-41f9-4db1-88b9-1ffd1b4ceea1', 0, 10, false, NULL, NULL);


--
-- TOC entry 5441 (class 0 OID 18813)
-- Dependencies: 431
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.authentication_flow VALUES ('176b4f88-6b3d-44cb-beb4-9317f356d604', 'browser', 'Browser based authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('ed691b27-ac6c-49ec-954c-4a9223701987', 'forms', 'Username, password, otp and other auth forms.', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('12a33a18-3d69-41eb-9091-9617d079590e', 'Browser - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('a973adea-a8aa-4ce1-953e-8d759df4b2d9', 'direct grant', 'OpenID Connect Resource Owner Grant', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('29376f88-03f6-44ba-99f6-53158b056246', 'Direct Grant - Conditional OTP', 'Flow to determine if the OTP is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('d5ca2242-a726-45ed-abc5-0ab031f68d89', 'registration', 'Registration flow', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('0b0950be-3030-44ce-9d85-4e1ff1801173', 'registration form', 'Registration form', '0c806647-a11c-403d-af39-092523465ca0', 'form-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('80c8bca9-2b6e-472a-bcef-d5f38392de99', 'reset credentials', 'Reset credentials for a user if they forgot their password or something', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('3b538c6b-78d0-4485-97a2-799a543e1d3c', 'Reset - Conditional OTP', 'Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('bace0a66-45dc-406a-b4c9-89ad226d88ce', 'clients', 'Base authentication for clients', '0c806647-a11c-403d-af39-092523465ca0', 'client-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 'first broker login', 'Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('86316c79-d109-4492-b1ed-b769c9b67c56', 'User creation or linking', 'Flow for the existing/non-existing user alternatives', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 'Handle Existing Account', 'Handle what to do if there is existing account with same email/username like authenticated identity provider', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('0477b3bf-3c95-418d-9d60-330d0a110004', 'Account verification options', 'Method with which to verity the existing account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('827d3481-45aa-4f03-9b65-932142e852a8', 'Verify Existing Account by Re-authentication', 'Reauthentication of existing account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('2ee08def-66d5-4485-8930-5f353401803e', 'First broker login - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('8e26f438-ebb5-445c-a713-fffe62480957', 'saml ecp', 'SAML ECP Profile Authentication Flow', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('5e51b971-b52e-4997-9c70-d0fd966312f6', 'docker auth', 'Used by Docker clients to authenticate against the IDP', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('39ea369c-a110-499e-8fd3-722b8b3481c4', 'browser', 'Browser based authentication', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('39f27ca9-c7b5-443e-bd5b-3eaa28ffa4e8', 'forms', 'Username, password, otp and other auth forms.', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('691676b8-1b75-4120-abc3-57bcdb2d44e4', 'Browser - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('6670a368-0f71-43f5-8444-d4daa576e8fc', 'Organization', NULL, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('5d8c7504-20f9-42cb-a37a-1e6e0025949f', 'Browser - Conditional Organization', 'Flow to determine if the organization identity-first login is to be used', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('24bf60db-ab22-421b-8f12-7091e59c4837', 'direct grant', 'OpenID Connect Resource Owner Grant', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('a3414214-0307-4380-a5e1-5bd36058c0ed', 'Direct Grant - Conditional OTP', 'Flow to determine if the OTP is required for the authentication', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('5ba7f27f-4dc7-4d74-8510-d69c7b8ee289', 'registration', 'Registration flow', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('51f11764-bad7-4fdb-9551-c3de2d2eb092', 'registration form', 'Registration form', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'form-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 'reset credentials', 'Reset credentials for a user if they forgot their password or something', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('dd69189b-2211-4fca-aee2-72d91ccbc793', 'Reset - Conditional OTP', 'Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('d1b4fbbf-0cf1-4270-86e9-3aef615553b7', 'clients', 'Base authentication for clients', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'client-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('9e3d118c-ff59-496b-97c0-ff2a4124b8dc', 'first broker login', 'Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('6428b503-f2de-4dbd-8d1a-9b8e811f0dbd', 'User creation or linking', 'Flow for the existing/non-existing user alternatives', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('60b6831d-0028-446a-b1ed-123e1f9a78a1', 'Handle Existing Account', 'Handle what to do if there is existing account with same email/username like authenticated identity provider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('6d134011-202b-44db-94ac-17af6d12dd5c', 'Account verification options', 'Method with which to verity the existing account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('b92a38df-43d3-417b-a177-29b6cbd25be4', 'Verify Existing Account by Re-authentication', 'Reauthentication of existing account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('c00f0eb2-5f28-4e67-990b-e916434622cc', 'First broker login - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('a0e47e7e-a8c2-4609-b182-8ba4b0480428', 'First Broker Login - Conditional Organization', 'Flow to determine if the authenticator that adds organization members is to be used', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', false, true);
INSERT INTO mim.authentication_flow VALUES ('beec69cd-cdb9-40ef-b1d1-5f612ee67682', 'saml ecp', 'SAML ECP Profile Authentication Flow', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);
INSERT INTO mim.authentication_flow VALUES ('84b34ea5-41f9-4db1-88b9-1ffd1b4ceea1', 'docker auth', 'Used by Docker clients to authenticate against the IDP', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'basic-flow', true, true);


--
-- TOC entry 5442 (class 0 OID 18821)
-- Dependencies: 432
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.authenticator_config VALUES ('bb3ab7fc-2f26-415c-aa8c-305a853f5031', 'review profile config', '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO mim.authenticator_config VALUES ('c6f54644-4ff0-42d6-bf2f-90c1782c94e0', 'create unique user config', '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO mim.authenticator_config VALUES ('fcdd5bcd-25f9-4ad2-8c35-ecf10d2c8b2f', 'review profile config', '55a761d8-e85b-4c2b-a052-3486ea3375b6');
INSERT INTO mim.authenticator_config VALUES ('b2d2d468-3e05-48e4-8fbe-f03d6347b756', 'create unique user config', '55a761d8-e85b-4c2b-a052-3486ea3375b6');


--
-- TOC entry 5443 (class 0 OID 18824)
-- Dependencies: 433
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.authenticator_config_entry VALUES ('bb3ab7fc-2f26-415c-aa8c-305a853f5031', 'missing', 'update.profile.on.first.login');
INSERT INTO mim.authenticator_config_entry VALUES ('c6f54644-4ff0-42d6-bf2f-90c1782c94e0', 'false', 'require.password.update.after.registration');
INSERT INTO mim.authenticator_config_entry VALUES ('b2d2d468-3e05-48e4-8fbe-f03d6347b756', 'false', 'require.password.update.after.registration');
INSERT INTO mim.authenticator_config_entry VALUES ('fcdd5bcd-25f9-4ad2-8c35-ecf10d2c8b2f', 'missing', 'update.profile.on.first.login');


--
-- TOC entry 5444 (class 0 OID 18829)
-- Dependencies: 434
-- Data for Name: broker_link; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5445 (class 0 OID 18834)
-- Dependencies: 435
-- Data for Name: client; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', true, false, 'master-realm', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', NULL, 0, false, false, 'master Realm', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', true, false, 'account', 0, true, NULL, '/realms/master/account/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_account}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', true, false, 'account-console', 0, true, NULL, '/realms/master/account/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_account-console}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', true, false, 'broker', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_broker}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', true, true, 'security-admin-console', 0, true, NULL, '/admin/master/console/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_security-admin-console}', false, 'client-secret', '${authAdminUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', true, true, 'admin-cli', 0, true, NULL, NULL, false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_admin-cli}', false, 'client-secret', NULL, NULL, NULL, false, false, true, false);
INSERT INTO mim.client VALUES ('5d174780-837c-47b6-ae12-fba56b1bdc0a', true, false, 'atlantica-realm', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', NULL, 0, false, false, 'atlantica Realm', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, false, 'realm-management', 0, false, NULL, NULL, true, NULL, false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_realm-management}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', true, false, 'account', 0, true, NULL, '/realms/atlantica/account/', false, NULL, false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_account}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', true, false, 'account-console', 0, true, NULL, '/realms/atlantica/account/', false, NULL, false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_account-console}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', true, false, 'broker', 0, false, NULL, NULL, true, NULL, false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_broker}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', true, true, 'security-admin-console', 0, true, NULL, '/admin/atlantica/console/', false, NULL, false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_security-admin-console}', false, 'client-secret', '${authAdminUrl}', NULL, NULL, true, false, false, false);
INSERT INTO mim.client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', true, true, 'admin-cli', 0, true, NULL, '', false, '', false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', 0, false, false, '${client_admin-cli}', false, 'client-secret', '', '', NULL, false, false, true, false);
INSERT INTO mim.client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', true, true, 'login', 0, true, NULL, '', false, '', false, '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'openid-connect', -1, true, false, '', false, 'client-secret', '', '', NULL, true, false, true, false);


--
-- TOC entry 5446 (class 0 OID 18852)
-- Dependencies: 436
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client_attributes VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'pkce.code.challenge.method', 'S256');
INSERT INTO mim.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'pkce.code.challenge.method', 'S256');
INSERT INTO mim.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO mim.client_attributes VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO mim.client_attributes VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('183a8995-5173-4495-a4bf-4620abe38771', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('183a8995-5173-4495-a4bf-4620abe38771', 'pkce.code.challenge.method', 'S256');
INSERT INTO mim.client_attributes VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'post.logout.redirect.uris', '+');
INSERT INTO mim.client_attributes VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'pkce.code.challenge.method', 'S256');
INSERT INTO mim.client_attributes VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'standard.token.exchange.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'oauth2.device.authorization.grant.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'oidc.ciba.grant.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'backchannel.logout.session.required', 'true');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'backchannel.logout.revoke.offline.tokens', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'realm_client', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'display.on.consent.screen', 'false');
INSERT INTO mim.client_attributes VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'frontchannel.logout.session.required', 'true');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'realm_client', 'false');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'standard.token.exchange.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'oauth2.device.authorization.grant.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'oidc.ciba.grant.enabled', 'false');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'display.on.consent.screen', 'false');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'backchannel.logout.session.required', 'true');
INSERT INTO mim.client_attributes VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'backchannel.logout.revoke.offline.tokens', 'false');


--
-- TOC entry 5447 (class 0 OID 18857)
-- Dependencies: 437
-- Data for Name: client_auth_flow_bindings; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5448 (class 0 OID 18860)
-- Dependencies: 438
-- Data for Name: client_initial_access; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5449 (class 0 OID 18863)
-- Dependencies: 439
-- Data for Name: client_node_registrations; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5450 (class 0 OID 18866)
-- Dependencies: 440
-- Data for Name: client_scope; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client_scope VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'offline_access', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: offline_access', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', 'role_list', '0c806647-a11c-403d-af39-092523465ca0', 'SAML role list', 'saml');
INSERT INTO mim.client_scope VALUES ('cbbe8007-9274-488d-b7a6-e1efa971032b', 'saml_organization', '0c806647-a11c-403d-af39-092523465ca0', 'Organization Membership', 'saml');
INSERT INTO mim.client_scope VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'profile', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: profile', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'email', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: email', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'address', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: address', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'phone', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: phone', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'roles', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add user roles to the access token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'web-origins', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add allowed web origins to the access token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'microprofile-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'Microprofile - JWT built-in scope', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'acr', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add acr (authentication context class reference) to the token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'basic', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add all basic claims to the token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'service_account', '0c806647-a11c-403d-af39-092523465ca0', 'Specific scope for a client enabled for service accounts', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('05888153-059e-47e4-b37a-47236467549a', 'organization', '0c806647-a11c-403d-af39-092523465ca0', 'Additional claims about the organization a subject belongs to', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('9951cc8a-858b-4683-a600-97e7665ddb42', 'offline_access', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect built-in scope: offline_access', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('fd6c9d6d-6ab6-438b-b89c-c7ff57754b28', 'role_list', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'SAML role list', 'saml');
INSERT INTO mim.client_scope VALUES ('3ad19674-ce68-4a42-aced-44c4fa68be5d', 'saml_organization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'Organization Membership', 'saml');
INSERT INTO mim.client_scope VALUES ('a9c186d7-5920-470d-9814-4401c3d8e267', 'profile', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect built-in scope: profile', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('4fc0ef8c-b308-4273-a876-f9503b1d7901', 'email', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect built-in scope: email', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('cc5d4db3-5f9b-4347-b293-ed400f6ba426', 'address', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect built-in scope: address', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('45e120c8-9839-41b6-9c44-a0e75e42f709', 'phone', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect built-in scope: phone', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('170d9849-440b-40c4-9013-365f850cb7cb', 'roles', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect scope for add user roles to the access token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', 'web-origins', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect scope for add allowed web origins to the access token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('075465d3-4d72-4dde-b87e-34ff466b2741', 'microprofile-jwt', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'Microprofile - JWT built-in scope', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('95cb1f46-2e30-45b1-86ba-18f721866a94', 'acr', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect scope for add acr (authentication context class reference) to the token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('92feb0f4-3a22-4406-95a9-f745e65f4cf5', 'basic', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'OpenID Connect scope for add all basic claims to the token', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('4830bd61-5d2d-4f04-89e6-140184227e4c', 'service_account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'Specific scope for a client enabled for service accounts', 'openid-connect');
INSERT INTO mim.client_scope VALUES ('49517077-c810-4c8a-acc3-1a53aa4c9d81', 'organization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'Additional claims about the organization a subject belongs to', 'openid-connect');


--
-- TOC entry 5451 (class 0 OID 18871)
-- Dependencies: 441
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client_scope_attributes VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', '${offlineAccessScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', '${samlRoleListScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('cbbe8007-9274-488d-b7a6-e1efa971032b', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', '${profileScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', '${emailScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', '${addressScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', '${phoneScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', '${rolesScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', '', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', '${organizationScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('9951cc8a-858b-4683-a600-97e7665ddb42', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('9951cc8a-858b-4683-a600-97e7665ddb42', '${offlineAccessScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('fd6c9d6d-6ab6-438b-b89c-c7ff57754b28', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('fd6c9d6d-6ab6-438b-b89c-c7ff57754b28', '${samlRoleListScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('3ad19674-ce68-4a42-aced-44c4fa68be5d', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('a9c186d7-5920-470d-9814-4401c3d8e267', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('a9c186d7-5920-470d-9814-4401c3d8e267', '${profileScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('a9c186d7-5920-470d-9814-4401c3d8e267', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('4fc0ef8c-b308-4273-a876-f9503b1d7901', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('4fc0ef8c-b308-4273-a876-f9503b1d7901', '${emailScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('4fc0ef8c-b308-4273-a876-f9503b1d7901', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('cc5d4db3-5f9b-4347-b293-ed400f6ba426', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('cc5d4db3-5f9b-4347-b293-ed400f6ba426', '${addressScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('cc5d4db3-5f9b-4347-b293-ed400f6ba426', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('45e120c8-9839-41b6-9c44-a0e75e42f709', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('45e120c8-9839-41b6-9c44-a0e75e42f709', '${phoneScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('45e120c8-9839-41b6-9c44-a0e75e42f709', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('170d9849-440b-40c4-9013-365f850cb7cb', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('170d9849-440b-40c4-9013-365f850cb7cb', '${rolesScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('170d9849-440b-40c4-9013-365f850cb7cb', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', '', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('075465d3-4d72-4dde-b87e-34ff466b2741', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('075465d3-4d72-4dde-b87e-34ff466b2741', 'true', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('95cb1f46-2e30-45b1-86ba-18f721866a94', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('95cb1f46-2e30-45b1-86ba-18f721866a94', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('92feb0f4-3a22-4406-95a9-f745e65f4cf5', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('92feb0f4-3a22-4406-95a9-f745e65f4cf5', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('4830bd61-5d2d-4f04-89e6-140184227e4c', 'false', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('4830bd61-5d2d-4f04-89e6-140184227e4c', 'false', 'include.in.token.scope');
INSERT INTO mim.client_scope_attributes VALUES ('49517077-c810-4c8a-acc3-1a53aa4c9d81', 'true', 'display.on.consent.screen');
INSERT INTO mim.client_scope_attributes VALUES ('49517077-c810-4c8a-acc3-1a53aa4c9d81', '${organizationScopeConsentText}', 'consent.screen.text');
INSERT INTO mim.client_scope_attributes VALUES ('49517077-c810-4c8a-acc3-1a53aa4c9d81', 'true', 'include.in.token.scope');


--
-- TOC entry 5452 (class 0 OID 18876)
-- Dependencies: 442
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('97fbfc19-45f5-4115-8b01-e97a2307536f', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('f72baef0-f75a-4a7a-8427-e95bde52c523', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('ec6afc2a-b688-4a03-811d-3ea6b49f7a00', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.client_scope_client VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', '075465d3-4d72-4dde-b87e-34ff466b2741', false);


--
-- TOC entry 5453 (class 0 OID 18882)
-- Dependencies: 443
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.client_scope_role_mapping VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'a3f06c98-eaeb-4470-98d5-09268563e97f');
INSERT INTO mim.client_scope_role_mapping VALUES ('9951cc8a-858b-4683-a600-97e7665ddb42', 'cb0b8832-9032-47af-907d-c3d5d899d711');


--
-- TOC entry 5454 (class 0 OID 18885)
-- Dependencies: 444
-- Data for Name: component; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.component VALUES ('c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'Trusted Hosts', '0c806647-a11c-403d-af39-092523465ca0', 'trusted-hosts', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('f3338552-3e7e-4652-91a3-167bdaecefd2', 'Consent Required', '0c806647-a11c-403d-af39-092523465ca0', 'consent-required', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('a992c1a8-e4a3-4d12-a76d-beda405fec83', 'Full Scope Disabled', '0c806647-a11c-403d-af39-092523465ca0', 'scope', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('21493008-7827-4e6e-b553-33e3102803d5', 'Max Clients Limit', '0c806647-a11c-403d-af39-092523465ca0', 'max-clients', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'Allowed Protocol Mapper Types', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('bddc26b3-1dea-4c70-8d45-933f187c7e7e', 'Allowed Client Scopes', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO mim.component VALUES ('bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'Allowed Protocol Mapper Types', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'authenticated');
INSERT INTO mim.component VALUES ('ef868973-344f-4e2f-a479-25e5af78abf3', 'Allowed Client Scopes', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'authenticated');
INSERT INTO mim.component VALUES ('5b29625a-0714-47e0-b3d1-9394f9079396', 'rsa-generated', '0c806647-a11c-403d-af39-092523465ca0', 'rsa-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO mim.component VALUES ('e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'rsa-enc-generated', '0c806647-a11c-403d-af39-092523465ca0', 'rsa-enc-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO mim.component VALUES ('8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'hmac-generated-hs512', '0c806647-a11c-403d-af39-092523465ca0', 'hmac-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO mim.component VALUES ('7d6cd448-3ab6-4320-b557-379496304c27', 'aes-generated', '0c806647-a11c-403d-af39-092523465ca0', 'aes-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO mim.component VALUES ('1c271620-cac1-4759-a00b-fed590e6e414', NULL, '0c806647-a11c-403d-af39-092523465ca0', 'declarative-user-profile', 'org.keycloak.userprofile.UserProfileProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO mim.component VALUES ('41dc0dba-d6b9-49a9-9ce7-61bd41b2aa32', 'rsa-generated', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'rsa-generated', 'org.keycloak.keys.KeyProvider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL);
INSERT INTO mim.component VALUES ('b212a523-ad7b-4a45-a126-46c123992248', 'rsa-enc-generated', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'rsa-enc-generated', 'org.keycloak.keys.KeyProvider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL);
INSERT INTO mim.component VALUES ('c25805dd-a15b-4755-8dd3-053f0b9e7be9', 'hmac-generated-hs512', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'hmac-generated', 'org.keycloak.keys.KeyProvider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL);
INSERT INTO mim.component VALUES ('7b45c6e5-eb97-4b99-b346-ee02c55b6d87', 'aes-generated', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'aes-generated', 'org.keycloak.keys.KeyProvider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL);
INSERT INTO mim.component VALUES ('1a0eb176-a172-4f29-8518-21478250c4b2', 'Trusted Hosts', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'trusted-hosts', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('67b315f0-d9d5-4f8f-9965-d581fa43a260', 'Consent Required', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'consent-required', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('d6ef3bf3-3474-4c49-98c1-27809f334903', 'Full Scope Disabled', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'scope', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('ae994a91-31c6-4cc6-90ba-4bcb94cbd772', 'Max Clients Limit', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'max-clients', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'Allowed Protocol Mapper Types', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('86c5a7e9-40e2-4a51-81af-dac800eba2bb', 'Allowed Client Scopes', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'anonymous');
INSERT INTO mim.component VALUES ('6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'Allowed Protocol Mapper Types', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'authenticated');
INSERT INTO mim.component VALUES ('d041f6b2-fdcf-4b9d-ac57-a9f8d3e5a6a8', 'Allowed Client Scopes', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'authenticated');


--
-- TOC entry 5455 (class 0 OID 18890)
-- Dependencies: 445
-- Data for Name: component_config; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.component_config VALUES ('338b1d24-e3dc-4c89-9f67-183c82f1ef55', 'c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'host-sending-registration-request-must-match', 'true');
INSERT INTO mim.component_config VALUES ('45733e81-82bb-4c6a-bd95-c5e4eab42c03', 'c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'client-uris-must-match', 'true');
INSERT INTO mim.component_config VALUES ('3d4dccb7-0882-493e-8d40-c609d8e7ec83', 'bddc26b3-1dea-4c70-8d45-933f187c7e7e', 'allow-default-scopes', 'true');
INSERT INTO mim.component_config VALUES ('0cfe84dd-f90e-4c8f-aaf6-8be01b700674', 'ef868973-344f-4e2f-a479-25e5af78abf3', 'allow-default-scopes', 'true');
INSERT INTO mim.component_config VALUES ('aab5de04-5bff-49f7-854c-a644b0021927', '21493008-7827-4e6e-b553-33e3102803d5', 'max-clients', '200');
INSERT INTO mim.component_config VALUES ('3cf3df5a-09a2-4e10-83a1-4358188aa45b', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO mim.component_config VALUES ('4ddad8a7-ccdd-48fa-b867-a6eb2def2388', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO mim.component_config VALUES ('cdcbf94e-8e60-4f38-9d4e-cdebc4df4c75', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO mim.component_config VALUES ('a0e27522-a9ec-44bf-bb28-87a938cfc64f', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO mim.component_config VALUES ('271389d9-54a7-47fb-91f3-0a7b9f5ce98c', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO mim.component_config VALUES ('3d32aea4-8294-46e0-ba3b-b942c05cb877', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO mim.component_config VALUES ('280a4c5e-8fc7-44a9-b228-802e457aeb77', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO mim.component_config VALUES ('45e42fa3-d726-4ce8-9bed-a82422eb9434', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO mim.component_config VALUES ('c99a37bc-bf51-4793-b632-6d453852cf69', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO mim.component_config VALUES ('8eb20f19-7d7f-487c-8677-43eabb9242e8', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO mim.component_config VALUES ('a0e035ac-3623-415f-93d4-ab59e08edba3', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO mim.component_config VALUES ('53518747-bc3c-4cce-af01-629508fbf7d7', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO mim.component_config VALUES ('5b17ea99-3fb5-4894-afad-e9bc372a3fc4', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO mim.component_config VALUES ('33c1bb1b-429f-47f0-89fd-443135164d2d', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO mim.component_config VALUES ('622dc8f0-221b-45b8-acc9-7761dedfc16f', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO mim.component_config VALUES ('d6019d36-94a4-42d8-b977-c47a886c7533', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO mim.component_config VALUES ('dd1296cd-dba8-486d-ab90-5715e898277e', '7d6cd448-3ab6-4320-b557-379496304c27', 'secret', 'bbACbT_wP3LkuofyB0WDCQ');
INSERT INTO mim.component_config VALUES ('ec235973-a48f-4715-b085-601d629b9b4c', '7d6cd448-3ab6-4320-b557-379496304c27', 'priority', '100');
INSERT INTO mim.component_config VALUES ('3ca592b4-b195-44d7-86c6-372ddbf6a059', '7d6cd448-3ab6-4320-b557-379496304c27', 'kid', 'f8b92589-f9ed-46b9-a841-dff66b6d21a4');
INSERT INTO mim.component_config VALUES ('b87004fd-4bce-45b7-8326-88639262f8b1', '1c271620-cac1-4759-a00b-fed590e6e414', 'kc.user.profile.config', '{"attributes":[{"name":"username","displayName":"${username}","validations":{"length":{"min":3,"max":255},"username-prohibited-characters":{},"up-username-not-idn-homograph":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"email","displayName":"${email}","validations":{"email":{},"length":{"max":255}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"firstName","displayName":"${firstName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"lastName","displayName":"${lastName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false}],"groups":[{"name":"user-metadata","displayHeader":"User metadata","displayDescription":"Attributes, which refer to user metadata"}]}');
INSERT INTO mim.component_config VALUES ('5ed28cde-d2fa-498d-a7ad-4f4103722a83', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'privateKey', 'MIIEowIBAAKCAQEA7cAJzQ+IXsp4Am9ThiVRTSZjgtDpwDD88/wEJ7tZN7P1QOb8n4+VPfn1urkQUn+k1aULvk9NQcJ4aFxjJWjEi3rpa8Ejw6LScrJYn3o1vRb1ty6ARtmv7Orehz5BazX4oioLgZYvzjcvHjAsEAEF9FjEIZDFuh/KchrV6eo+0nEEwgE9DAoZbMzR9Vab/Npu2Pdp8jN2k+QZGOCxJTtoj1eN2hzkhokjGLyhrxBJRJN5ptEJQi7lJgQBtqP137ft0biyKSUF2Ev8I00HrhAIPSXxvcbF9wzWOkGJzVEoRgk+PFBCtghJBD/gGh4cIa/J5YnNbJrc+Tpnq4itMcJrWwIDAQABAoIBAA+UwU+uD+rebAUE1L163pwmwujE1jzhOQKoZoFQFuW+pnkNakrutwIryn3lOPufH+dcfKuJOO/xVcDJJTpDZnYZpQiJzNU6a35Wz9YLxU/SHGJX6tI52/yz28eTPehPzi6agMyKUjG6jhz1XT3jQ0ejNZ9ZhIvRH4xg09oTnvBdlW2fJGosBAVz0E6KFshE+W2IF6mIb8jK9zIBn0ggBI62hTYfaqGzYvtlh5XNa9CssgCIMKg5x5bCexXxEmwRh1Jx0B29Qi+oZbAJMx7/if26gH4yhCoJy1FpqkKHxv8qfpQuYSfkdQ8lDjrtJUlkee61pEgUuYamq5KJ3ECyh8ECgYEA/9VZ1CgP9Q+KWSd001hQhG6M5wxbgvhwffrgfG+1C47YFwdPTcTNsUvVPfMU5urqV6xYEtgxm9ilmMar/3MLs03kPNZZrf7//b9fBUOq69xkCcc6CLg+EFFz/rK6mwIg+XPUjdFwMXkSp3IoNhiWRKW2cZhyI+FZsS7E7xC706ECgYEA7eesPEmyIPBfZO9bHmRMx6Ljy1bY4ueFfOZIIYgWrxfMauyDwQJXkRsDs+HUi4fxVSo0OkdGEvh8/v7cOZcN5YVfH7Lp3W1CYHkYjrZKlm5v4KZSbL8jVIemKh2+sZFNyjJXvsVic3offXC+of6+IL7eFoaN1czTDNdllJx6nXsCgYBKk0a8MXF1XjJWCspjUTsnX5JzR4blhsZD8v29SFLeK6WSEO9tHBFZvWFLzbAqIBBvvi1uUNclNuIOxtsce8zNV8dQdKtvrQWyUjbAshkA6B3BO/IO2KY+23+Un0UGKniyPrGXJZYu1bw6U2ylWEV1fVjRhD7Bds9OdvOxPI+EAQKBgFdbp8ongYpI2a6Vmc7qI6t269Ch3lhLjZ/Ua44si6/VvFFS8fpworj8w3pNJZ/q1jpgmfcAbwHOTw/PhAx9pDOwqsJYDzoowaPtM5BL7c2ZVemXCVM3SIDkoqZ6b6iCY58op0G89y7SHDgSq12Ozj/19lUtKW3lnWXsvjc40ml7AoGBAPEdh+vOiP2d9+S2X3AvZ9TwmQylid0edJbEQniF0e1PQcFuNRbdYs6D/JCp0NQwSMiDSyTQYgeCwof9lrYnakKKErevcwc50C/lZQi2gcwKYY/SPQVguwfzQGgxBfOQ9Waz2Vt8FEYt9trg+9WiKZTZmO0JCUBihP5I4tZsbge7');
INSERT INTO mim.component_config VALUES ('99c66cc8-9aef-4508-818d-38a4b94d1c6f', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'keyUse', 'ENC');
INSERT INTO mim.component_config VALUES ('d5869e80-95bd-46f1-b045-bb1131497168', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'algorithm', 'RSA-OAEP');
INSERT INTO mim.component_config VALUES ('d21d0cc2-9349-41a8-b4c0-82cda11dfefe', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'priority', '100');
INSERT INTO mim.component_config VALUES ('6b056c38-4dc9-4daf-a118-3795d23ab0d1', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'certificate', 'MIICmzCCAYMCBgGaAWfPlTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjUxMDIwMTEzNDMxWhcNMzUxMDIwMTEzNjExWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDtwAnND4heyngCb1OGJVFNJmOC0OnAMPzz/AQnu1k3s/VA5vyfj5U9+fW6uRBSf6TVpQu+T01BwnhoXGMlaMSLeulrwSPDotJyslifejW9FvW3LoBG2a/s6t6HPkFrNfiiKguBli/ONy8eMCwQAQX0WMQhkMW6H8pyGtXp6j7ScQTCAT0MChlszNH1Vpv82m7Y92nyM3aT5BkY4LElO2iPV43aHOSGiSMYvKGvEElEk3mm0QlCLuUmBAG2o/Xft+3RuLIpJQXYS/wjTQeuEAg9JfG9xsX3DNY6QYnNUShGCT48UEK2CEkEP+AaHhwhr8nlic1smtz5OmeriK0xwmtbAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAG9y4JM4Im6NJfbHYCyfruz2qTOk4O4fz08hfdOgAqB6wml7xMNCHui8nRp0quVC3+gBNHXqTVdKxz48NXfAeuz+GjN9XD2fN95ZvD8If8+dRQ6xnxaMXEocebUWem8JxNdxXt0yjKxppQ/jBifEjHkObQZMIPu/bEDmg5FuQ4PZdQWSoCv/yewTBDKPGVabEk6stvqnqEFj/wowi93zV7fNaNB9aw80eRukKzAQ92BQNga1NkipMWwPobHHEyvmt75bGEgXbgWFF9Mke935AbLsv7L6r79HXiTXBO3t7egeT51JgmwxUVlPyisdja0E8qFJ+A8XFLGTG3TE6YJsDg0=');
INSERT INTO mim.component_config VALUES ('8862eef4-5bad-444a-9ba9-834ab334acaf', '5b29625a-0714-47e0-b3d1-9394f9079396', 'priority', '100');
INSERT INTO mim.component_config VALUES ('82bf993b-c350-46bf-b03f-364468a0db14', '5b29625a-0714-47e0-b3d1-9394f9079396', 'privateKey', 'MIIEpAIBAAKCAQEA3uymqwJlsIZPOmj8GrqKisfyYR75GjMxHCFCRkafiVRkgxvPk5zulgrNx8NFlnd56oIWWCg6lGaEG7Qi0fiCgqPi9HdSQ4CfusPSS2sDjKtpjk/OzD08HZOfFVGUO+8px7hYt7O5wTIVTWUt5MQz336Ikw8WW1EM1BWX6nNp4V5J00MkZl3Z5c/vTiv4/wKl6mJe2axiXy6AvD40JyqzbdNSDWuKDb2nOKn6IMWT9M95P/ATBDk/T3WYmA2RfPB8n7wE8B0ssXQ28Cjw6seIc04j+C3oDxXHwoXGOVH+9nlYVmogVvwcs1miRmmY2AF6uCAg2p9yR/b3ocwGiOWstQIDAQABAoIBACCZY0sVM+kzTuE4CovfFRTz5dwxgxSDgW4/Z9luiPR0cKlilwGbXKF47XxFsEavbJbwVJOqOFzMvAtwFXp2mKFBlZYR3+gKpnERo05PlSqMQ4ih35gq6UBa/tPHhQGZuRahfOnKQMMBj69seSBf18UaVB8LQQX0DYfzK27H12czFHLLptTGhpq2ErBqBTQ/r3ua+Q23m4D110pUtOFcIM3j1wwadfOq0/9nIgl0grQJ29zKpaZPkD+nRIaHBtDqVrKos+MiWSqLqHLiPqvcTpZAMLVyOVEaP75ihw3amwg8K/GdFjrJqjq1Uyr7Pvv38414ZE4kkLNU6gI0JtQuyyECgYEA+S/yYqmIPYsOXmwb9Dg5IXiPvTsbOTHf+fF9ArnKbXi2Jrq2A8XhPAGOTZmfXBNu0d8AzfLfQ/a/QkQ3xipbqK+pTlc8vdqWaqWcI1yOf+B3JJ4BYclOeVfsGsx16Mh4T9Tmm6YtQCiA52XLKyNkphFMS8a+xvSluIeReM+tfWECgYEA5QTkK2sgaEDarYMJQC7oB41YCGvzTRNwwEjlGf/Inm0/LNV09CnNe4KQ0FbrcqpNe+hggnx3lWvq6+SNUohyyz49zF1zJz9lClk1rIslEw50fDF5Nsal9Dam2oPH6mBgkEE3qSfdoEOC1aXcmD0Ll0bLBf4rxh0RtARoUtQHO9UCgYEA3GWQ/7ysuKo+OjtqehYkSbtlftxBVtQLIvl5NSj4ptyGVzj69dlWPomtwGrorTqu4MdZ4c43tNgQD99gaVBbo5ZCq/yyx8UHFyqFMC2UB/yTxHpQBJpVYzPlq0o923c8GnfWw8I18bIhWQkKqovyYIOaNMeDQ1ttHAokG3OsIeECgYB83ZHZ6mqc7N9NwygECo8PrwzUaqcY2wSakiP3bPJhDodnVmqRxUj3klSKgxmURy4/5I7aFirNGS3Yt6Al46dTEPh4uGrUd0gLwF/3V1Y7caIpJIBGUUCiSjnm4frZ2vpLLIPAgq/fdW+cNPZ1OrNbI4oGFnKfbbH9SHnozxmykQKBgQDeFStpit9U8okahwmEvkX4UA5H3ylEHHFhFiVOXBjsg5bmL/JOVNQV79DnlDkzUjsWPprHyvAP8wjK62rV3VzVLSyp/l16SZIZ0DLiCbjZ9qfMGHwOGyuXcwzTzKtBgTnTaV1GTylKUfBS3oZuzoO5wFByVTzlSQalSQ/5M7U0UQ==');
INSERT INTO mim.component_config VALUES ('802bba59-8343-44a9-8a5b-4cb8edef927e', '5b29625a-0714-47e0-b3d1-9394f9079396', 'keyUse', 'SIG');
INSERT INTO mim.component_config VALUES ('d2cefcfe-5878-4f28-858a-83c9ad3a4c59', '5b29625a-0714-47e0-b3d1-9394f9079396', 'certificate', 'MIICmzCCAYMCBgGaAWfOqDANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjUxMDIwMTEzNDMxWhcNMzUxMDIwMTEzNjExWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDe7KarAmWwhk86aPwauoqKx/JhHvkaMzEcIUJGRp+JVGSDG8+TnO6WCs3Hw0WWd3nqghZYKDqUZoQbtCLR+IKCo+L0d1JDgJ+6w9JLawOMq2mOT87MPTwdk58VUZQ77ynHuFi3s7nBMhVNZS3kxDPffoiTDxZbUQzUFZfqc2nhXknTQyRmXdnlz+9OK/j/AqXqYl7ZrGJfLoC8PjQnKrNt01INa4oNvac4qfogxZP0z3k/8BMEOT9PdZiYDZF88HyfvATwHSyxdDbwKPDqx4hzTiP4LegPFcfChcY5Uf72eVhWaiBW/ByzWaJGaZjYAXq4ICDan3JH9vehzAaI5ay1AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIc2wFNNWA2s86FQ4FV1L2rQVJb6i4V2giHdgKkY3YLQW4D9DpeWD7asE5cGOp7xw7HyrspBxfM0ElepePkK6se/6wf057u1ecvJzV8vgXxSN9hsEpm3GMIq4+/K5RGlvfeQ6lxY9L1tJlhqVshcLoIVY6yKUOOu9C9rsDsEDhvbmLPdJxnB8V9RQZDNwV6seKppwnz1Q1mQbIvs2fTpqmzUMIGSbI0Ir5KlMgdsWHK75X4vQXkioo0CRls9lntV1dSUruvLyZMf4TFyRwQb61cmlMLeyPVOAnB/vSmOowaqJux2XJkrMdNv8swjo6NTEdyfcL/H4tXzUTfY/FW7/MY=');
INSERT INTO mim.component_config VALUES ('48e60672-18e4-406b-a9b7-1dc2f27ea101', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'kid', 'e7a4c20c-fffb-40c4-88d3-d7377b9e37d2');
INSERT INTO mim.component_config VALUES ('0568e9a2-aed6-4cd1-9681-4500321e9527', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'algorithm', 'HS512');
INSERT INTO mim.component_config VALUES ('ef45cd3c-4a60-4023-aa68-a7f2a2215c1b', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'secret', 'Oh9SxukoDayxKE7jogP5qiPblpvjnmEyAMhMtrBO51nsS0Ty0WuWI65QBSmC2DE7VhF9BU3T-KmeSG1BBEKFiSmUroLCQNso3MV-HTJI_5hsjvyKUzY6kuMnqDwofJwT8PDQZA_-ivKLOojJh1YIeJbA4P6aXWZZBmmgqqUuQmA');
INSERT INTO mim.component_config VALUES ('c33aad96-3cac-4f8e-b492-845820b9b551', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'priority', '100');
INSERT INTO mim.component_config VALUES ('cd1a607b-4ca1-4834-b9e2-3d8d191275ab', 'b212a523-ad7b-4a45-a126-46c123992248', 'keyUse', 'ENC');
INSERT INTO mim.component_config VALUES ('7014538d-97b3-43b4-83c1-9fc894a44b63', 'b212a523-ad7b-4a45-a126-46c123992248', 'certificate', 'MIICoTCCAYkCBgGaAWkakDANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAlhdGxhbnRpY2EwHhcNMjUxMDIwMTEzNTU2WhcNMzUxMDIwMTEzNzM2WjAUMRIwEAYDVQQDDAlhdGxhbnRpY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDzxnBMb+U0Fg/ltmQLwFH0QmCU7+lyiNUMeyboW5qcjnQuZmg6u1VlRngJnohMt2Y0b3wuBwO6rZ4USfYBQ2SOrfLcKWwSNHHQFAH0vIHOtDdg+wqS09eOuky9fqnKGV8pkx7gY7Xb8xNbt+fyCdBDX3y52/DxCePyAVyEHbbKEYLZtSnPXr4TUDfcuBjMHKGVSCjVjnWpeQCZoI5uXpPRhK7dhXpONcuDka2s08ixa+Tnz90PyOlqxQud+NKM8ckk/+iPXyRMRpTyqrAu8yV8Dsspm8D7ZVWxMG1hXnYQnuU0f+gISo2x7YGMiC8CFJsPNNwtDlHNxGq9anF9xZdlAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAF38Y9A145Dm0YK6ULtBlHYS8zc6qiwW+XY09REhN7uwaNfe3Q2g9rVVq94NZmw9twTiOXMeoS7RLdB8v5n+aj/AqZrpMBafVZQtvQfASjVz5GVS/BYvYyrmdphsoJj1h3oon6BIv7GXmgqF1RK0UZpJ8MmuWTM+pLpjrkGLAafbS9QMM7CqvrhNIGfaRrIJRCyk5uFfPqUb7681P/NakMJ00zsz8bBSR8BbS9QFw1tJTYCLqyPbI5R37capjkGlPbZnooOLdeyrGkLzUvWMfCPT3kapOBTRP5ALS7Nh/5SiaAJhklxxyyOQtOe1lKUOpnUh3oudyBurI+fbqh9hzDM=');
INSERT INTO mim.component_config VALUES ('1cf73bb1-5cbf-4f9d-93f9-d8e444b5aac9', 'b212a523-ad7b-4a45-a126-46c123992248', 'priority', '100');
INSERT INTO mim.component_config VALUES ('46a054a9-1141-4cde-84f1-d228e4f56201', 'b212a523-ad7b-4a45-a126-46c123992248', 'privateKey', 'MIIEowIBAAKCAQEA88ZwTG/lNBYP5bZkC8BR9EJglO/pcojVDHsm6FuanI50LmZoOrtVZUZ4CZ6ITLdmNG98LgcDuq2eFEn2AUNkjq3y3ClsEjRx0BQB9LyBzrQ3YPsKktPXjrpMvX6pyhlfKZMe4GO12/MTW7fn8gnQQ198udvw8Qnj8gFchB22yhGC2bUpz16+E1A33LgYzByhlUgo1Y51qXkAmaCObl6T0YSu3YV6TjXLg5GtrNPIsWvk58/dD8jpasULnfjSjPHJJP/oj18kTEaU8qqwLvMlfA7LKZvA+2VVsTBtYV52EJ7lNH/oCEqNse2BjIgvAhSbDzTcLQ5RzcRqvWpxfcWXZQIDAQABAoIBAAIEHB2lt0GNBSijL4ShXIwmmGHi8g1OcGSgCBxX1ZmB3BgeJLKHphcmVAvQUdRAmAnK+j3vNOqwUOReEDjGc+hyK9YCSbCE2oQcBkAd5vzspKCasuWv9tJpXAUdLQ5M02qmmtTEPlbJVdmmVba8ugo0mfV3ijCUIlx4AmndTQuywT53GOIVSQk7/xzI7W6jFO+SLn4EDbpXlvQKZ8Iz9dFJslnR/4YVUhMuaSdDcyGLqPMKxHLvGRQE56Hs0akpA7laOpOtrrbsujjqBoBRiidUkkecx/zeb6vTo2BV9j3ixAuVP2m3xxYVvMIaYIPRnEMPQlnTbQhg3fGW2Mce0AECgYEA+xY6H8eLT9iOW5gNTByxAYIiRFpgoGs5Ur8Xcz81CUOG2ZZdZFpGoElIDH3PKu1bsJvq5ilGDYepaZoeLtgUpMAs0L1YX8VcljAkliiP4NMnivyrEKS90MEj8NYhtSDlB2FLWC8aj6izSHMdz6IVhzD9vklHqXQqemiiOo6y1gECgYEA+IuVzBIjMnidzMjmNb88mDWSf093ov1j6Ji2i09pxIiNlyjDUW1lLOFC2+fibCyLuDc+8lF4dkgxhjpuM02T/IuT1b0fJJguaayuDZUCsOIvOmu7CFstZ4eE1VptmkcaQNk1CUCJWq01GgBRhRGIA34WVRyPdmBC4QBVvRbxKWUCgYBRadma6FbRowQ1ys20+jCirpFx3GQsX9gMbo2p/rqxsEWPU+QgX+06l8hW1IxR/PiYAVZfHs7qICzcYu6afdHjwbRGUr7O/u2QfTe/wJM2cQEHXfoRwXkSsS14L9ZqJqpchD2r8EoKfsbzHPBznLiiR05fXt9voI0Nd9PybMasAQKBgQCfQYmddi25ZFHwavYfkEb6XLFfBANrm6NN4bRt9VeXR8w6BDOK1GbU6A3YLHAH0k9AnZ2m1Q8z8zRQhtYf52CgnKsAdKsk3qI2sh/gsg9EWdnbPDZet1WTleFGeCfsiAzJaqQyJnkccgmpfHS/qCkX283hgWhneGzCEV3eyHmEhQKBgGxZnXIsR8S0D/ckaVabZWkjzGGyL0y6onsV/1shP+ium122dr+xA8UsVo5mqSxecB5kkEF348O9tELB35MdAXcUIiAXQYqyI+MlrcZEPQU2I/HB0U8t6aTPlkLylG3ZnCjVlLDsF+hKw7nscy1jrC6QS45Vf5H37Se0LWMzS2yJ');
INSERT INTO mim.component_config VALUES ('70a7b4c9-96d4-4ea6-98ac-506136fee4c8', 'b212a523-ad7b-4a45-a126-46c123992248', 'algorithm', 'RSA-OAEP');
INSERT INTO mim.component_config VALUES ('ec8d0990-27e0-4232-8f25-34f0dbe64c09', '41dc0dba-d6b9-49a9-9ce7-61bd41b2aa32', 'priority', '100');
INSERT INTO mim.component_config VALUES ('05b9f2b9-0f10-461d-9045-4850f1436f60', '41dc0dba-d6b9-49a9-9ce7-61bd41b2aa32', 'certificate', 'MIICoTCCAYkCBgGaAWkZ0zANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAlhdGxhbnRpY2EwHhcNMjUxMDIwMTEzNTU2WhcNMzUxMDIwMTEzNzM2WjAUMRIwEAYDVQQDDAlhdGxhbnRpY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9Kgd0JJ2nUg3ePCI/yTsl1amxPGvHn0ejHS85Qa+E++CvFteba5WjF4gbt7VTwLN70m4zwVSPnmAJxF5oRCWx/hhIPm/8lYTfOdZ8QXWWlJH1RUrDC0ODLxaPjtb0pIY9wwsFJm3jBfadq+mfEd6mD+EY9ugWM06Ik7X8KdOHsNnJWLaS4TIAuqSQTatCfauWblnbpJJWUje4SbxDSJBkpR4FmEWla1D3QRx6wuBb0emi23OTYL3DB/HfefsPQcrtqcJ/pLtrxDLYQswtjJugsZNZWyGe5Ic9gDiJurF0ax64KDUImSRDP72AglucIco5Ml5Wst/+88IAEKOFH49LAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIzvfahq2FIm8Mj0uHDzDaQiqa1VCzVZpatUe3Qe64k2bFyFnaVIazGVYa/JqjDRXlHP2jCFYO7Et+fS8t0s0WMGFvL2NgwYv/AIzcuImJgBxY3XJxbftgAb2pIFZiwGCmnU3K4/qipwPKQ+quU2l7eVYwoHfx7wxejZqqdF3+nHLebfFHlxxu4NdjM7+L6A7taBOgSajE8lZNeFzUrBrlxsLffk2DYwwrtU6rTKUhWT2Thnwy2reL4BOWhOuLeRzugl95sQVTfQBk/3hWF2aFFGxEAGfZ0ckBpeisgJLodZ60vonoJeM08kLZmspFR+4/so1f2NhhiLB8tFAa+rgmU=');
INSERT INTO mim.component_config VALUES ('2e73bb0e-caab-42b1-ab47-691323044a1a', '41dc0dba-d6b9-49a9-9ce7-61bd41b2aa32', 'keyUse', 'SIG');
INSERT INTO mim.component_config VALUES ('e0a0e71f-59a8-46e7-9f1b-3080776b743f', '41dc0dba-d6b9-49a9-9ce7-61bd41b2aa32', 'privateKey', 'MIIEpAIBAAKCAQEAvSoHdCSdp1IN3jwiP8k7JdWpsTxrx59Hox0vOUGvhPvgrxbXm2uVoxeIG7e1U8Cze9JuM8FUj55gCcReaEQlsf4YSD5v/JWE3znWfEF1lpSR9UVKwwtDgy8Wj47W9KSGPcMLBSZt4wX2navpnxHepg/hGPboFjNOiJO1/CnTh7DZyVi2kuEyALqkkE2rQn2rlm5Z26SSVlI3uEm8Q0iQZKUeBZhFpWtQ90EcesLgW9Hpottzk2C9wwfx33n7D0HK7anCf6S7a8Qy2ELMLYyboLGTWVshnuSHPYA4ibqxdGseuCg1CJkkQz+9gIJbnCHKOTJeVrLf/vPCABCjhR+PSwIDAQABAoIBAE5RP9vEqycSsF4x3GY3TM9JymNwZhk0Z2bvltUoTmCLHgevt92HqeDnxbjgEulVj5n00h6IbRe3FQEGNaYKjObIEkqa2yeiyevX2OcB/Qq2gUWghicBm1aNYNRX6cRI97FLdt0Pf5BuMCAwhF2Q+vMbAPGijA1g+aNPMJnxwTvcdE9o1OKutT1ofqPlptc9XUsrGu629kiWLieGCiNF9ZwVzOnumdTIk3QW0leuqIvY7VfK64N1cseEEtiGCjURxUDckg54w3VXxLHX85y+CkPzecLJr3d3Hd5OEYDVmqQP2Y3pfm/IJbvDx+fvi0ThCJZsKGNbvbMmIp5rTcfIP5UCgYEA7fyXWG3ldRVkRaXRGrEyULLtF77PXAzbeX76B9CfnHyqAELhh8ijsGNghR7//yv02i5DpJEXs9MPDzFRvBnrh09w5yt5D3X4a4yVXWE4uLZ244DeTjOxfrlGrd6PLXpH+mbI5aynMcDUHzXKCWdy/cj/q33SGRtGC11167wNfmUCgYEAy3tqlCPOzikMZEyvr2Mwad7y55F40k0GnM75aFzKA3WF6rJ1HX2Axi7uc5+9PEaGtzk5//tHwhY2hRJbL+dvWSp8lxYU5/gpebd23et2EGGpmcx2olswCg4cV7nmxgnI96VsCzHSj+vHbVPo9eCT7ud06zS7/W2u85pAJEL34+8CgYEA2LbenvEcNT1wnRe9TeA0YFY/HxNrwngW2BFv3/PzlM3VBP3iYAKuRK6KM08icRx3EMN2Z4KUofU9Tmlr861q1EHcHzZwPEsCF/XiAjHJNDM8Gjm8tlvOcwaGvUfg+9nRd81nffZ2HhFpWK5jt6KTjVUetOyTiLdUVn8aJbuOUh0CgYAH85WxnkiZk88RKFIBN44PxQ+W7v9asHnerNPgOSgHxJLsHfcnpNzgYbsdt5NMhLEE/e5/S1F9iyKsRpBbqd6XDGr7+HfurKrqP7ocZ/QgJcDb6rqEE64n5m9DGlejS4SX8NXtBhBlYWBUrF/BI/qD7nWKL3BdMekRSejRwfAv7wKBgQDiBEq8V33gERRdnNjHo+pKXSg7whFJf0TY/5KlhKeg96aixUQvl3OTtJy4/gLD2grmNPNLMo1qYIGu8w/nHutZ3A0lVg/Je0OiR8RdcF5un2KBedGanaebQTAOn//fhWzArFZHO8Q7GAhD9/B4cicog9iq+h8oV5qWugJ30d7hnQ==');
INSERT INTO mim.component_config VALUES ('a9483bb3-34c2-4cd8-bff7-8f53f04ff988', 'c25805dd-a15b-4755-8dd3-053f0b9e7be9', 'priority', '100');
INSERT INTO mim.component_config VALUES ('cbbf8515-bcac-4bca-9809-6087fbe76389', 'c25805dd-a15b-4755-8dd3-053f0b9e7be9', 'algorithm', 'HS512');
INSERT INTO mim.component_config VALUES ('21f107f2-a494-48d5-92db-5bb1f4120589', 'c25805dd-a15b-4755-8dd3-053f0b9e7be9', 'kid', '6d2816eb-914e-4970-9e02-504a49648019');
INSERT INTO mim.component_config VALUES ('dc0d6c75-1665-4fd7-9c5d-7a6a0745995b', 'c25805dd-a15b-4755-8dd3-053f0b9e7be9', 'secret', 'pWhKMQnJ35MA7RrrSaUHwDtZa85PkKXo_AyO2F5JwJYh1BJmPZIuKESfgKipamrICZzU-bavcWaIW4lHueYKI__YXcs_zqIt8R9boYDT3E-4DEG8KgekwoyJVGaOORpiyJqlZXWrZbft0XnTPrvY37oVGEbVBAE3EsnsJOSoxk0');
INSERT INTO mim.component_config VALUES ('64762f2d-26bf-49fe-a438-c7dc503bd373', '7b45c6e5-eb97-4b99-b346-ee02c55b6d87', 'kid', 'f0410fa8-0bd3-4ac4-8bbc-947544fc73cc');
INSERT INTO mim.component_config VALUES ('e29d8e73-dfe0-4a22-8556-2a079c464d3a', '7b45c6e5-eb97-4b99-b346-ee02c55b6d87', 'secret', 'jel-GiEJ9MMINICaEH7j_A');
INSERT INTO mim.component_config VALUES ('56f7091e-af3c-47df-936f-113cb2978e04', '7b45c6e5-eb97-4b99-b346-ee02c55b6d87', 'priority', '100');
INSERT INTO mim.component_config VALUES ('1da87ccc-2f6d-4b56-b601-d2d84c0f2a75', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO mim.component_config VALUES ('d4dd8b0c-66f0-40c0-bcb7-607cd3789fca', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO mim.component_config VALUES ('71ae8501-b094-48a7-895d-490d67f7c9a4', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO mim.component_config VALUES ('ec0621c4-41aa-4189-96e6-93298fe195ce', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO mim.component_config VALUES ('db10512f-9e2e-4aa8-82b9-d793645d5741', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO mim.component_config VALUES ('ff16bb47-c466-4754-aad8-2f450f382d99', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO mim.component_config VALUES ('02d25514-7cf4-408c-aa2f-197b7ab279ad', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO mim.component_config VALUES ('7fa2ea55-2f22-4b66-88df-e7b66da715a5', '27b46ef7-27cf-455c-b568-cb2eb5f7723d', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO mim.component_config VALUES ('71695401-0fb0-44c0-83ae-7afc07edf260', '1a0eb176-a172-4f29-8518-21478250c4b2', 'host-sending-registration-request-must-match', 'true');
INSERT INTO mim.component_config VALUES ('05aaf1d9-e828-4780-8330-df7c6b9342f8', '1a0eb176-a172-4f29-8518-21478250c4b2', 'client-uris-must-match', 'true');
INSERT INTO mim.component_config VALUES ('198fc549-485b-47f2-b382-50b7330aabfd', 'ae994a91-31c6-4cc6-90ba-4bcb94cbd772', 'max-clients', '200');
INSERT INTO mim.component_config VALUES ('ad5f1516-765d-4be9-a9f9-e10a58566ca0', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO mim.component_config VALUES ('7e4faf4e-63d2-49ac-a63c-feb380cf251f', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO mim.component_config VALUES ('184fa710-1275-49c7-a771-30aff2524476', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO mim.component_config VALUES ('19b32bad-5c38-49c5-9413-65c205d2b958', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO mim.component_config VALUES ('88bed516-789c-450c-afd8-5dfacaae5a0d', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO mim.component_config VALUES ('39629d12-a99a-4e7c-b0c6-9911f700294f', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO mim.component_config VALUES ('2055cb95-ed15-412e-86ef-459c15f7ff8a', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO mim.component_config VALUES ('9c4098d9-8d72-4938-92c4-ea6a7019923b', '6eb3c3e1-3272-42ca-86b7-d933dcaffa04', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO mim.component_config VALUES ('ea097444-b19d-4edd-b150-9935e5cb2568', '86c5a7e9-40e2-4a51-81af-dac800eba2bb', 'allow-default-scopes', 'true');
INSERT INTO mim.component_config VALUES ('2cec5b43-f48a-4d8b-b63d-fe74bb798843', 'd041f6b2-fdcf-4b9d-ac57-a9f8d3e5a6a8', 'allow-default-scopes', 'true');


--
-- TOC entry 5456 (class 0 OID 18895)
-- Dependencies: 446
-- Data for Name: composite_role; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8e3d03e5-e70a-460f-8d22-bb11ecabcae3');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '1bf774c0-76b5-43d3-a6ab-580554987f88');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '90da9da7-9cbd-4e08-afe2-b657bdca5ac0');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'fe8410b4-6e80-4979-ad47-941c192ad518');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'dceb8aa5-57cb-4636-9e53-d4c22906571d');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '393c8228-dabe-4927-bec5-d62e0f372af9');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'bcf549e9-6de7-4ba3-a2d7-7864f460fe6a');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6c32a60e-78de-4b5a-b19c-69eb7e84ac9a');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'd5ff873d-5bc6-444c-89db-b2a7573008ca');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6d21a91c-7886-4b8c-8933-7e6f708606fe');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '966551e2-bdb1-4c42-a1f4-10c85d410db2');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '2c9a23ac-4921-404e-99df-1f5a7b85cd7f');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'c56c1682-22c0-4d14-b41f-af9641674de5');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '689bf969-bf06-440a-95a4-8429cc400d09');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '46d4c4c6-ab10-47b3-9665-43d3f44aaa63');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '325745f8-d041-4e42-8a89-466e404c775b');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '75bb763a-6fc1-4bfe-8432-da1fc12e5efd');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'dd58dfd2-861f-41eb-9dc8-d956324f9ccd');
INSERT INTO mim.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'c5fbb5ee-4707-425f-836d-3d833f7c294f');
INSERT INTO mim.composite_role VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', '325745f8-d041-4e42-8a89-466e404c775b');
INSERT INTO mim.composite_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', '46d4c4c6-ab10-47b3-9665-43d3f44aaa63');
INSERT INTO mim.composite_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', 'dd58dfd2-861f-41eb-9dc8-d956324f9ccd');
INSERT INTO mim.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');
INSERT INTO mim.composite_role VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', 'a471a901-48ee-443e-90b1-2c70abd516ea');
INSERT INTO mim.composite_role VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', 'd416a33e-2abf-4dc2-b9fa-94a23017e858');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '3a3b68f5-5620-44aa-974f-6b1cf9c2c12a');
INSERT INTO mim.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'a3f06c98-eaeb-4470-98d5-09268563e97f');
INSERT INTO mim.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'b83d7ede-d9b5-493d-bb43-8a5e641d5085');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'e793b400-1ba3-4b9c-b00e-85de01861d6c');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'cf7f6c67-c1ef-459e-83c5-c5a8caed6e4d');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6806d196-0d69-427e-b093-e76f9aed4f24');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'db3211e4-5b1e-4b1e-8bf9-68caf3f85b4c');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '73d1e89b-739f-490b-9c20-f6bfc06c629f');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '214f2782-211b-45cc-acb1-78dc440b10e0');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8acccd39-bfe1-4075-84d1-23ac852c4535');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '69cf759d-2a1d-4854-869f-813c20c139f2');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '1384f2ce-8f9b-463d-9282-f1779c5b9de9');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'c3c8df3d-a2a9-4e04-94d4-73977c885f2f');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'b20809cc-1123-48fc-9338-3dd52921b0da');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'a5fda10a-f896-4aaa-9478-0c27f050ab25');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '0dcf03c2-e7a1-4084-93f0-f4b7d794d193');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '92ea89b0-7a1a-4206-9145-ec4f9b63aac4');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '4402d0a7-3ad3-42f7-a4b0-6a026144a866');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8b4747ac-3706-4047-aa04-503b9f2e3840');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6d901d15-deaa-4571-bdf5-67f46236bcf1');
INSERT INTO mim.composite_role VALUES ('6806d196-0d69-427e-b093-e76f9aed4f24', '92ea89b0-7a1a-4206-9145-ec4f9b63aac4');
INSERT INTO mim.composite_role VALUES ('6806d196-0d69-427e-b093-e76f9aed4f24', '6d901d15-deaa-4571-bdf5-67f46236bcf1');
INSERT INTO mim.composite_role VALUES ('db3211e4-5b1e-4b1e-8bf9-68caf3f85b4c', '4402d0a7-3ad3-42f7-a4b0-6a026144a866');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'ff2f0fac-6b39-4b1f-abb6-0252669895cf');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '2b5aef57-58f4-43c6-84d0-3d2657eb7002');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '6f5e377f-9be5-4915-874c-da7284b6111a');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '42cf16eb-49a0-4793-999c-e78175462c6b');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '74e17fab-1b69-4738-b247-f7195ec4775a');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'c02820af-7da5-4d7e-a152-fa3c90ce554c');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'c75f97d9-a933-4bc8-8101-900df1277a32');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '50ea785c-717e-409b-936d-6440e102fbf9');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'c8743249-05ea-4178-888f-5933c41ada6c');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'c6cd383c-a00d-432b-b977-f422f07f1606');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'a1c9d20c-4d01-4ce4-855e-f61666c9f224');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '60cafdb3-3d6c-48c1-9e77-172daf242bea');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'ef0ea393-fde1-4c82-aaef-508782fb824f');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '88f5f86b-d637-4ba4-aaa0-e9cca63f08a7');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '1cee0901-37bd-4a6d-9803-77b75a697239');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '6f485a00-8e0c-4172-8b86-fe86925f6dd5');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'f521e451-2789-41a8-834c-a2ad8cf2dbe2');
INSERT INTO mim.composite_role VALUES ('42cf16eb-49a0-4793-999c-e78175462c6b', '1cee0901-37bd-4a6d-9803-77b75a697239');
INSERT INTO mim.composite_role VALUES ('6f5e377f-9be5-4915-874c-da7284b6111a', '88f5f86b-d637-4ba4-aaa0-e9cca63f08a7');
INSERT INTO mim.composite_role VALUES ('6f5e377f-9be5-4915-874c-da7284b6111a', 'f521e451-2789-41a8-834c-a2ad8cf2dbe2');
INSERT INTO mim.composite_role VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', 'b781240c-1437-41e2-9953-f973d3124a31');
INSERT INTO mim.composite_role VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', '53004a4e-b443-4cb9-af6f-a3d4725a933c');
INSERT INTO mim.composite_role VALUES ('53004a4e-b443-4cb9-af6f-a3d4725a933c', 'b287f985-f47a-4ca9-8e5a-ca8671801eba');
INSERT INTO mim.composite_role VALUES ('04389301-51df-49c0-acb5-e8e5edacb614', '4f3f02d4-5fa5-42e4-b343-662782da3788');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '3d9014ee-1b65-4abc-9066-a08b5ead2d8d');
INSERT INTO mim.composite_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '12b4b4c0-ceca-48ee-86f2-27fe90505a2c');
INSERT INTO mim.composite_role VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', 'cb0b8832-9032-47af-907d-c3d5d899d711');
INSERT INTO mim.composite_role VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', '803a5296-f69f-403a-aa65-a1168bff4666');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'd416a33e-2abf-4dc2-b9fa-94a23017e858');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'c5fbb5ee-4707-425f-836d-3d833f7c294f');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'bd5731c3-d8e2-4830-b512-a914de001373');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'a471a901-48ee-443e-90b1-2c70abd516ea');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8095b4ff-6f0d-414b-8057-22d5471ad338');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '5e45631a-17db-48f8-87dd-278459b02b54');
INSERT INTO mim.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');


--
-- TOC entry 5457 (class 0 OID 18898)
-- Dependencies: 447
-- Data for Name: credential; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.credential VALUES ('99d4eb04-f3c3-4679-9ffe-fc898658129e', NULL, 'password', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f', 1760963844931, 'My password', '{"value":"WDrz9WwLn/wcsw/4lkU6a/RAiVCh9Gqkyhxy5xnaoHg=","salt":"UVZ7YmF6Pa8ofrrtBzp9fw==","additionalParameters":{}}', '{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}', 10, 3);
INSERT INTO mim.credential VALUES ('78f9d1ac-2bf2-434d-b5d8-818e4e0ad381', NULL, 'password', 'b813f8c8-a0bf-4df9-af10-ceccc2733e43', 1760965828000, 'My password', '{"value":"g5Q91ISEneKzM8EKrAHm6/3Y6XZVYCtCWgRn6yPyeio=","salt":"fjZOyNTACgj5B7WICguHDA==","additionalParameters":{}}', '{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}', 10, 1);
INSERT INTO mim.credential VALUES ('9627f3fd-4d96-439c-bbdd-a042507b8ac0', NULL, 'password', '679d8ad7-2047-41eb-b88e-bad459ccdc81', 1760965852735, 'My password', '{"value":"P8+WO2V7N/1JWat0oPt3T51lPh/9nyAJpRpmJUUd7sk=","salt":"EaDlQfc5GQ662rulI7ereQ==","additionalParameters":{}}', '{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}', 10, 1);


--
-- TOC entry 5458 (class 0 OID 18904)
-- Dependencies: 448
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.databasechangelog VALUES ('1.0.0.Final-KEYCLOAK-5461', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.0.0.Final.xml', '2025-10-20 11:35:57.088317', 1, 'EXECUTED', '9:6f1016664e21e16d26517a4418f5e3df', 'createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.0.0.Final-KEYCLOAK-5461', 'sthorger@redhat.com', 'META-INF/db2-jpa-changelog-1.0.0.Final.xml', '2025-10-20 11:35:57.135871', 2, 'MARK_RAN', '9:828775b1596a07d1200ba1d49e5e3941', 'createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.1.0.Beta1', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.1.0.Beta1.xml', '2025-10-20 11:35:57.252943', 3, 'EXECUTED', '9:5f090e44a7d595883c1fb61f4b41fd38', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.1.0.Final', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.1.0.Final.xml', '2025-10-20 11:35:57.26601', 4, 'EXECUTED', '9:c07e577387a3d2c04d1adc9aaad8730e', 'renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.2.0.Beta1', 'psilva@redhat.com', 'META-INF/jpa-changelog-1.2.0.Beta1.xml', '2025-10-20 11:35:57.507733', 5, 'EXECUTED', '9:b68ce996c655922dbcd2fe6b6ae72686', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.2.0.Beta1', 'psilva@redhat.com', 'META-INF/db2-jpa-changelog-1.2.0.Beta1.xml', '2025-10-20 11:35:57.517902', 6, 'MARK_RAN', '9:543b5c9989f024fe35c6f6c5a97de88e', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.2.0.RC1', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.2.0.CR1.xml', '2025-10-20 11:35:57.71795', 7, 'EXECUTED', '9:765afebbe21cf5bbca048e632df38336', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.2.0.RC1', 'bburke@redhat.com', 'META-INF/db2-jpa-changelog-1.2.0.CR1.xml', '2025-10-20 11:35:57.729759', 8, 'MARK_RAN', '9:db4a145ba11a6fdaefb397f6dbf829a1', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.2.0.Final', 'keycloak', 'META-INF/jpa-changelog-1.2.0.Final.xml', '2025-10-20 11:35:57.746607', 9, 'EXECUTED', '9:9d05c7be10cdb873f8bcb41bc3a8ab23', 'update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.3.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.3.0.xml', '2025-10-20 11:35:57.931903', 10, 'EXECUTED', '9:18593702353128d53111f9b1ff0b82b8', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.4.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.4.0.xml', '2025-10-20 11:35:58.001572', 11, 'EXECUTED', '9:6122efe5f090e41a85c0f1c9e52cbb62', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.4.0', 'bburke@redhat.com', 'META-INF/db2-jpa-changelog-1.4.0.xml', '2025-10-20 11:35:58.006894', 12, 'MARK_RAN', '9:e1ff28bf7568451453f844c5d54bb0b5', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.5.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.5.0.xml', '2025-10-20 11:35:58.037502', 13, 'EXECUTED', '9:7af32cd8957fbc069f796b61217483fd', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.6.1_from15', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.085286', 14, 'EXECUTED', '9:6005e15e84714cd83226bf7879f54190', 'addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.6.1_from16-pre', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.088895', 15, 'MARK_RAN', '9:bf656f5a2b055d07f314431cae76f06c', 'delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.6.1_from16', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.092574', 16, 'MARK_RAN', '9:f8dadc9284440469dcf71e25ca6ab99b', 'dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.6.1', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.101644', 17, 'EXECUTED', '9:d41d8cd98f00b204e9800998ecf8427e', 'empty', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.7.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.7.0.xml', '2025-10-20 11:35:58.17846', 18, 'EXECUTED', '9:3368ff0be4c2855ee2dd9ca813b38d8e', 'createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.8.0', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.259787', 19, 'EXECUTED', '9:8ac2fb5dd030b24c0570a763ed75ed20', 'addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.8.0-2', 'keycloak', 'META-INF/jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.27536', 20, 'EXECUTED', '9:f91ddca9b19743db60e3057679810e6c', 'dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.8.0', 'mposolda@redhat.com', 'META-INF/db2-jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.281176', 21, 'MARK_RAN', '9:831e82914316dc8a57dc09d755f23c51', 'addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.8.0-2', 'keycloak', 'META-INF/db2-jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.290152', 22, 'MARK_RAN', '9:f91ddca9b19743db60e3057679810e6c', 'dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.9.0', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.9.0.xml', '2025-10-20 11:35:58.448005', 23, 'EXECUTED', '9:bc3d0f9e823a69dc21e23e94c7a94bb1', 'update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.9.1', 'keycloak', 'META-INF/jpa-changelog-1.9.1.xml', '2025-10-20 11:35:58.458567', 24, 'EXECUTED', '9:c9999da42f543575ab790e76439a2679', 'modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.9.1', 'keycloak', 'META-INF/db2-jpa-changelog-1.9.1.xml', '2025-10-20 11:35:58.466807', 25, 'MARK_RAN', '9:0d6c65c6f58732d81569e77b10ba301d', 'modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('1.9.2', 'keycloak', 'META-INF/jpa-changelog-1.9.2.xml', '2025-10-20 11:35:59.033821', 26, 'EXECUTED', '9:fc576660fc016ae53d2d4778d84d86d0', 'createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-2.0.0', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-2.0.0.xml', '2025-10-20 11:35:59.157909', 27, 'EXECUTED', '9:43ed6b0da89ff77206289e87eaa9c024', 'createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-2.5.1', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-2.5.1.xml', '2025-10-20 11:35:59.163137', 28, 'EXECUTED', '9:44bae577f551b3738740281eceb4ea70', 'update tableName=RESOURCE_SERVER_POLICY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.1.0-KEYCLOAK-5461', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.1.0.xml', '2025-10-20 11:35:59.266674', 29, 'EXECUTED', '9:bd88e1f833df0420b01e114533aee5e8', 'createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.2.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.2.0.xml', '2025-10-20 11:35:59.302597', 30, 'EXECUTED', '9:a7022af5267f019d020edfe316ef4371', 'addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.3.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.3.0.xml', '2025-10-20 11:35:59.334188', 31, 'EXECUTED', '9:fc155c394040654d6a79227e56f5e25a', 'createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.4.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.4.0.xml', '2025-10-20 11:35:59.34135', 32, 'EXECUTED', '9:eac4ffb2a14795e5dc7b426063e54d88', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.354777', 33, 'EXECUTED', '9:54937c05672568c4c64fc9524c1e9462', 'customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.0-unicode-oracle', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.359054', 34, 'MARK_RAN', '9:1f9da21e444f4a539619ea5df1a8e089', 'modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.0-unicode-other-dbs', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.420378', 35, 'EXECUTED', '9:33d72168746f81f98ae3a1e8e0ca3554', 'modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.0-duplicate-email-support', 'slawomir@dabek.name', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.429398', 36, 'EXECUTED', '9:61b6d3d7a4c0e0024b0c839da283da0c', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.0-unique-group-names', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.44047', 37, 'EXECUTED', '9:8dcac7bdf7378e7d823cdfddebf72fda', 'addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('2.5.1', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.5.1.xml', '2025-10-20 11:35:59.446618', 38, 'EXECUTED', '9:a2b870802540cb3faa72098db5388af3', 'addColumn tableName=FED_USER_CONSENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.0.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-3.0.0.xml', '2025-10-20 11:35:59.453139', 39, 'EXECUTED', '9:132a67499ba24bcc54fb5cbdcfe7e4c0', 'addColumn tableName=IDENTITY_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.2.0-fix', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.456188', 40, 'MARK_RAN', '9:938f894c032f5430f2b0fafb1a243462', 'addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.2.0-fix-with-keycloak-5416', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.460597', 41, 'MARK_RAN', '9:845c332ff1874dc5d35974b0babf3006', 'dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.2.0-fix-offline-sessions', 'hmlnarik', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.469983', 42, 'EXECUTED', '9:fc86359c079781adc577c5a217e4d04c', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.2.0-fixed', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:36:02.361426', 43, 'EXECUTED', '9:59a64800e3c0d09b825f8a3b444fa8f4', 'addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.3.0', 'keycloak', 'META-INF/jpa-changelog-3.3.0.xml', '2025-10-20 11:36:02.369445', 44, 'EXECUTED', '9:d48d6da5c6ccf667807f633fe489ce88', 'addColumn tableName=USER_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part1', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.378438', 45, 'EXECUTED', '9:dde36f7973e80d71fceee683bc5d2951', 'addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.387069', 46, 'EXECUTED', '9:b855e9b0a406b34fa323235a0cf4f640', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part3-fixed', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.389503', 47, 'MARK_RAN', '9:51abbacd7b416c50c4421a8cabf7927e', 'dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.590612', 48, 'EXECUTED', '9:bdc99e567b3398bac83263d375aad143', 'addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authn-3.4.0.CR1-refresh-token-max-reuse', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.597066', 49, 'EXECUTED', '9:d198654156881c46bfba39abd7769e69', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.4.0', 'keycloak', 'META-INF/jpa-changelog-3.4.0.xml', '2025-10-20 11:36:02.653944', 50, 'EXECUTED', '9:cfdd8736332ccdd72c5256ccb42335db', 'addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.4.0-KEYCLOAK-5230', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-3.4.0.xml', '2025-10-20 11:36:03.156192', 51, 'EXECUTED', '9:7c84de3d9bd84d7f077607c1a4dcb714', 'createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.4.1', 'psilva@redhat.com', 'META-INF/jpa-changelog-3.4.1.xml', '2025-10-20 11:36:03.160319', 52, 'EXECUTED', '9:5a6bb36cbefb6a9d6928452c0852af2d', 'modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.4.2', 'keycloak', 'META-INF/jpa-changelog-3.4.2.xml', '2025-10-20 11:36:03.163587', 53, 'EXECUTED', '9:8f23e334dbc59f82e0a328373ca6ced0', 'update tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('3.4.2-KEYCLOAK-5172', 'mkanis@redhat.com', 'META-INF/jpa-changelog-3.4.2.xml', '2025-10-20 11:36:03.166457', 54, 'EXECUTED', '9:9156214268f09d970cdf0e1564d866af', 'update tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.0.0-KEYCLOAK-6335', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.177532', 55, 'EXECUTED', '9:db806613b1ed154826c02610b7dbdf74', 'createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.0.0-CLEANUP-UNUSED-TABLE', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.181991', 56, 'EXECUTED', '9:229a041fb72d5beac76bb94a5fa709de', 'dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.0.0-KEYCLOAK-6228', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.242313', 57, 'EXECUTED', '9:079899dade9c1e683f26b2aa9ca6ff04', 'dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.0.0-KEYCLOAK-5579-fixed', 'mposolda@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.764045', 58, 'EXECUTED', '9:139b79bcbbfe903bb1c2d2a4dbf001d9', 'dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-4.0.0.CR1', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-4.0.0.CR1.xml', '2025-10-20 11:36:03.795287', 59, 'EXECUTED', '9:b55738ad889860c625ba2bf483495a04', 'createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-4.0.0.Beta3', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-4.0.0.Beta3.xml', '2025-10-20 11:36:03.802556', 60, 'EXECUTED', '9:e0057eac39aa8fc8e09ac6cfa4ae15fe', 'addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-4.2.0.Final', 'mhajas@redhat.com', 'META-INF/jpa-changelog-authz-4.2.0.Final.xml', '2025-10-20 11:36:03.810945', 61, 'EXECUTED', '9:42a33806f3a0443fe0e7feeec821326c', 'createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-4.2.0.Final-KEYCLOAK-9944', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-authz-4.2.0.Final.xml', '2025-10-20 11:36:03.818521', 62, 'EXECUTED', '9:9968206fca46eecc1f51db9c024bfe56', 'addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.2.0-KEYCLOAK-6313', 'wadahiro@gmail.com', 'META-INF/jpa-changelog-4.2.0.xml', '2025-10-20 11:36:03.824447', 63, 'EXECUTED', '9:92143a6daea0a3f3b8f598c97ce55c3d', 'addColumn tableName=REQUIRED_ACTION_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.3.0-KEYCLOAK-7984', 'wadahiro@gmail.com', 'META-INF/jpa-changelog-4.3.0.xml', '2025-10-20 11:36:03.828793', 64, 'EXECUTED', '9:82bab26a27195d889fb0429003b18f40', 'update tableName=REQUIRED_ACTION_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.6.0-KEYCLOAK-7950', 'psilva@redhat.com', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.832819', 65, 'EXECUTED', '9:e590c88ddc0b38b0ae4249bbfcb5abc3', 'update tableName=RESOURCE_SERVER_RESOURCE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.6.0-KEYCLOAK-8377', 'keycloak', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.891804', 66, 'EXECUTED', '9:5c1f475536118dbdc38d5d7977950cc0', 'createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.6.0-KEYCLOAK-8555', 'gideonray@gmail.com', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.944988', 67, 'EXECUTED', '9:e7c9f5f9c4d67ccbbcc215440c718a17', 'createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.7.0-KEYCLOAK-1267', 'sguilhen@redhat.com', 'META-INF/jpa-changelog-4.7.0.xml', '2025-10-20 11:36:03.949722', 68, 'EXECUTED', '9:88e0bfdda924690d6f4e430c53447dd5', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.7.0-KEYCLOAK-7275', 'keycloak', 'META-INF/jpa-changelog-4.7.0.xml', '2025-10-20 11:36:04.005829', 69, 'EXECUTED', '9:f53177f137e1c46b6a88c59ec1cb5218', 'renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('4.8.0-KEYCLOAK-8835', 'sguilhen@redhat.com', 'META-INF/jpa-changelog-4.8.0.xml', '2025-10-20 11:36:04.012828', 70, 'EXECUTED', '9:a74d33da4dc42a37ec27121580d1459f', 'addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('authz-7.0.0-KEYCLOAK-10443', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-7.0.0.xml', '2025-10-20 11:36:04.017373', 71, 'EXECUTED', '9:fd4ade7b90c3b67fae0bfcfcb42dfb5f', 'addColumn tableName=RESOURCE_SERVER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('8.0.0-adding-credential-columns', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.024877', 72, 'EXECUTED', '9:aa072ad090bbba210d8f18781b8cebf4', 'addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('8.0.0-updating-credential-data-not-oracle-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.033318', 73, 'EXECUTED', '9:1ae6be29bab7c2aa376f6983b932be37', 'update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('8.0.0-updating-credential-data-oracle-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.0366', 74, 'MARK_RAN', '9:14706f286953fc9a25286dbd8fb30d97', 'update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('8.0.0-credential-cleanup-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.062064', 75, 'EXECUTED', '9:2b9cc12779be32c5b40e2e67711a218b', 'dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('8.0.0-resource-tag-support', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.126971', 76, 'EXECUTED', '9:91fa186ce7a5af127a2d7a91ee083cc5', 'addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.0-always-display-client', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.13154', 77, 'EXECUTED', '9:6335e5c94e83a2639ccd68dd24e2e5ad', 'addColumn tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.0-drop-constraints-for-column-increase', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.134084', 78, 'MARK_RAN', '9:6bdb5658951e028bfe16fa0a8228b530', 'dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.0-increase-column-size-federated-fk', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.153756', 79, 'EXECUTED', '9:d5bc15a64117ccad481ce8792d4c608f', 'modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.0-recreate-constraints-after-column-increase', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.156246', 80, 'MARK_RAN', '9:077cba51999515f4d3e7ad5619ab592c', 'addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.1-add-index-to-client.client_id', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.204491', 81, 'EXECUTED', '9:be969f08a163bf47c6b9e9ead8ac2afb', 'createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-drop-constraints', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.206446', 82, 'MARK_RAN', '9:6d3bb4408ba5a72f39bd8a0b301ec6e3', 'dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-add-not-null-constraint', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.212479', 83, 'EXECUTED', '9:966bda61e46bebf3cc39518fbed52fa7', 'addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-recreate-constraints', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.214409', 84, 'MARK_RAN', '9:8dcac7bdf7378e7d823cdfddebf72fda', 'addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('9.0.1-add-index-to-events', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.261878', 85, 'EXECUTED', '9:7d93d602352a30c0c317e6a609b56599', 'createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('map-remove-ri', 'keycloak', 'META-INF/jpa-changelog-11.0.0.xml', '2025-10-20 11:36:04.266259', 86, 'EXECUTED', '9:71c5969e6cdd8d7b6f47cebc86d37627', 'dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('map-remove-ri', 'keycloak', 'META-INF/jpa-changelog-12.0.0.xml', '2025-10-20 11:36:04.273211', 87, 'EXECUTED', '9:a9ba7d47f065f041b7da856a81762021', 'dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('12.1.0-add-realm-localization-table', 'keycloak', 'META-INF/jpa-changelog-12.0.0.xml', '2025-10-20 11:36:04.286563', 88, 'EXECUTED', '9:fffabce2bc01e1a8f5110d5278500065', 'createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('default-roles', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.293633', 89, 'EXECUTED', '9:fa8a5b5445e3857f4b010bafb5009957', 'addColumn tableName=REALM; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('default-roles-cleanup', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.298807', 90, 'EXECUTED', '9:67ac3241df9a8582d591c5ed87125f39', 'dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('13.0.0-KEYCLOAK-16844', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.348622', 91, 'EXECUTED', '9:ad1194d66c937e3ffc82386c050ba089', 'createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('map-remove-ri-13.0.0', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.357297', 92, 'EXECUTED', '9:d9be619d94af5a2f5d07b9f003543b91', 'dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('13.0.0-KEYCLOAK-17992-drop-constraints', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.359041', 93, 'MARK_RAN', '9:544d201116a0fcc5a5da0925fbbc3bde', 'dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('13.0.0-increase-column-size-federated', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.36937', 94, 'EXECUTED', '9:43c0c1055b6761b4b3e89de76d612ccf', 'modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('13.0.0-KEYCLOAK-17992-recreate-constraints', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.372173', 95, 'MARK_RAN', '9:8bd711fd0330f4fe980494ca43ab1139', 'addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('json-string-accomodation-fixed', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.378993', 96, 'EXECUTED', '9:e07d2bc0970c348bb06fb63b1f82ddbf', 'addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('14.0.0-KEYCLOAK-11019', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.656722', 97, 'EXECUTED', '9:24fb8611e97f29989bea412aa38d12b7', 'createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.668906', 98, 'MARK_RAN', '9:259f89014ce2506ee84740cbf7163aa7', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-revert', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.698023', 99, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-supported-dbs', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.803801', 100, 'EXECUTED', '9:60ca84a0f8c94ec8c3504a5a3bc88ee8', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-unsupported-dbs', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.808783', 101, 'MARK_RAN', '9:d3d977031d431db16e2c181ce49d73e9', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('KEYCLOAK-17267-add-index-to-user-attributes', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.904924', 102, 'EXECUTED', '9:0b305d8d1277f3a89a0a53a659ad274c', 'createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('KEYCLOAK-18146-add-saml-art-binding-identifier', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.920843', 103, 'EXECUTED', '9:2c374ad2cdfe20e2905a84c8fac48460', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('15.0.0-KEYCLOAK-18467', 'keycloak', 'META-INF/jpa-changelog-15.0.0.xml', '2025-10-20 11:36:04.93639', 104, 'EXECUTED', '9:47a760639ac597360a8219f5b768b4de', 'addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('17.0.0-9562', 'keycloak', 'META-INF/jpa-changelog-17.0.0.xml', '2025-10-20 11:36:05.036253', 105, 'EXECUTED', '9:a6272f0576727dd8cad2522335f5d99e', 'createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('18.0.0-10625-IDX_ADMIN_EVENT_TIME', 'keycloak', 'META-INF/jpa-changelog-18.0.0.xml', '2025-10-20 11:36:05.112658', 106, 'EXECUTED', '9:015479dbd691d9cc8669282f4828c41d', 'createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('18.0.15-30992-index-consent', 'keycloak', 'META-INF/jpa-changelog-18.0.15.xml', '2025-10-20 11:36:05.192484', 107, 'EXECUTED', '9:80071ede7a05604b1f4906f3bf3b00f0', 'createIndex indexName=IDX_USCONSENT_SCOPE_ID, tableName=USER_CONSENT_CLIENT_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('19.0.0-10135', 'keycloak', 'META-INF/jpa-changelog-19.0.0.xml', '2025-10-20 11:36:05.201036', 108, 'EXECUTED', '9:9518e495fdd22f78ad6425cc30630221', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('20.0.0-12964-supported-dbs', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.258961', 109, 'EXECUTED', '9:e5f243877199fd96bcc842f27a1656ac', 'createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('20.0.0-12964-unsupported-dbs', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.261349', 110, 'MARK_RAN', '9:1a6fcaa85e20bdeae0a9ce49b41946a5', 'createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('client-attributes-string-accomodation-fixed', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.268913', 111, 'EXECUTED', '9:3f332e13e90739ed0c35b0b25b7822ca', 'addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('21.0.2-17277', 'keycloak', 'META-INF/jpa-changelog-21.0.2.xml', '2025-10-20 11:36:05.274268', 112, 'EXECUTED', '9:7ee1f7a3fb8f5588f171fb9a6ab623c0', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('21.1.0-19404', 'keycloak', 'META-INF/jpa-changelog-21.1.0.xml', '2025-10-20 11:36:05.310907', 113, 'EXECUTED', '9:3d7e830b52f33676b9d64f7f2b2ea634', 'modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('21.1.0-19404-2', 'keycloak', 'META-INF/jpa-changelog-21.1.0.xml', '2025-10-20 11:36:05.314629', 114, 'MARK_RAN', '9:627d032e3ef2c06c0e1f73d2ae25c26c', 'addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('22.0.0-17484-updated', 'keycloak', 'META-INF/jpa-changelog-22.0.0.xml', '2025-10-20 11:36:05.320438', 115, 'EXECUTED', '9:90af0bfd30cafc17b9f4d6eccd92b8b3', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('22.0.5-24031', 'keycloak', 'META-INF/jpa-changelog-22.0.0.xml', '2025-10-20 11:36:05.322522', 116, 'MARK_RAN', '9:a60d2d7b315ec2d3eba9e2f145f9df28', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('23.0.0-12062', 'keycloak', 'META-INF/jpa-changelog-23.0.0.xml', '2025-10-20 11:36:05.329836', 117, 'EXECUTED', '9:2168fbe728fec46ae9baf15bf80927b8', 'addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('23.0.0-17258', 'keycloak', 'META-INF/jpa-changelog-23.0.0.xml', '2025-10-20 11:36:05.334679', 118, 'EXECUTED', '9:36506d679a83bbfda85a27ea1864dca8', 'addColumn tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.0-9758', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.602784', 119, 'EXECUTED', '9:502c557a5189f600f0f445a9b49ebbce', 'addColumn tableName=USER_ATTRIBUTE; addColumn tableName=FED_USER_ATTRIBUTE; createIndex indexName=USER_ATTR_LONG_VALUES, tableName=USER_ATTRIBUTE; createIndex indexName=FED_USER_ATTR_LONG_VALUES, tableName=FED_USER_ATTRIBUTE; createIndex indexName...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.0-9758-2', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.614402', 120, 'EXECUTED', '9:bf0fdee10afdf597a987adbf291db7b2', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.0-26618-drop-index-if-present', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.625933', 121, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.0-26618-reindex', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.736813', 122, 'EXECUTED', '9:08707c0f0db1cef6b352db03a60edc7f', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.2-27228', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.748636', 123, 'EXECUTED', '9:eaee11f6b8aa25d2cc6a84fb86fc6238', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.2-27967-drop-index-if-present', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.75135', 124, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('24.0.2-27967-reindex', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.754972', 125, 'MARK_RAN', '9:d3d977031d431db16e2c181ce49d73e9', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-tables', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:05.769195', 126, 'EXECUTED', '9:deda2df035df23388af95bbd36c17cef', 'addColumn tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-creation', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:05.83231', 127, 'EXECUTED', '9:3e96709818458ae49f3c679ae58d263a', 'createIndex indexName=IDX_OFFLINE_USS_BY_LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-createdon', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.037673', 128, 'EXECUTED', '9:78ab4fc129ed5e8265dbcc3485fba92f', 'dropIndex indexName=IDX_OFFLINE_USS_CREATEDON, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-preload', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.250494', 129, 'EXECUTED', '9:de5f7c1f7e10994ed8b62e621d20eaab', 'dropIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-by-usersess', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.428897', 130, 'EXECUTED', '9:6eee220d024e38e89c799417ec33667f', 'dropIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-cleanup-css-preload', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.621494', 131, 'EXECUTED', '9:5411d2fb2891d3e8d63ddb55dfa3c0c9', 'dropIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-2-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.626868', 132, 'MARK_RAN', '9:b7ef76036d3126bb83c2423bf4d449d6', 'createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28265-index-2-not-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.722654', 133, 'EXECUTED', '9:23396cf51ab8bc1ae6f0cac7f9f6fcf7', 'createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-org', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.793495', 134, 'EXECUTED', '9:5c859965c2c9b9c72136c360649af157', 'createTable tableName=ORG; addUniqueConstraint constraintName=UK_ORG_NAME, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_GROUP, tableName=ORG; createTable tableName=ORG_DOMAIN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('unique-consentuser', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.853618', 135, 'EXECUTED', '9:5857626a2ea8767e9a6c66bf3a2cb32f', 'customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('unique-consentuser-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.862116', 136, 'MARK_RAN', '9:b79478aad5adaa1bc428e31563f55e8e', 'customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('25.0.0-28861-index-creation', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:07.024867', 137, 'EXECUTED', '9:b9acb58ac958d9ada0fe12a5d4794ab1', 'createIndex indexName=IDX_PERM_TICKET_REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; createIndex indexName=IDX_PERM_TICKET_OWNER, tableName=RESOURCE_SERVER_PERM_TICKET', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-org-alias', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.041765', 138, 'EXECUTED', '9:6ef7d63e4412b3c2d66ed179159886a4', 'addColumn tableName=ORG; update tableName=ORG; addNotNullConstraint columnName=ALIAS, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_ALIAS, tableName=ORG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-org-group', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.058717', 139, 'EXECUTED', '9:da8e8087d80ef2ace4f89d8c5b9ca223', 'addColumn tableName=KEYCLOAK_GROUP; update tableName=KEYCLOAK_GROUP; addNotNullConstraint columnName=TYPE, tableName=KEYCLOAK_GROUP; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-org-indexes', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.132752', 140, 'EXECUTED', '9:79b05dcd610a8c7f25ec05135eec0857', 'createIndex indexName=IDX_ORG_DOMAIN_ORG_ID, tableName=ORG_DOMAIN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-org-group-membership', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.141397', 141, 'EXECUTED', '9:a6ace2ce583a421d89b01ba2a28dc2d4', 'addColumn tableName=USER_GROUP_MEMBERSHIP; update tableName=USER_GROUP_MEMBERSHIP; addNotNullConstraint columnName=MEMBERSHIP_TYPE, tableName=USER_GROUP_MEMBERSHIP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('31296-persist-revoked-access-tokens', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.152331', 142, 'EXECUTED', '9:64ef94489d42a358e8304b0e245f0ed4', 'createTable tableName=REVOKED_TOKEN; addPrimaryKey constraintName=CONSTRAINT_RT, tableName=REVOKED_TOKEN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('31725-index-persist-revoked-access-tokens', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.213477', 143, 'EXECUTED', '9:b994246ec2bf7c94da881e1d28782c7b', 'createIndex indexName=IDX_REV_TOKEN_ON_EXPIRE, tableName=REVOKED_TOKEN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-idps-for-login', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.335814', 144, 'EXECUTED', '9:51f5fffadf986983d4bd59582c6c1604', 'addColumn tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_REALM_ORG, tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_FOR_LOGIN, tableName=IDENTITY_PROVIDER; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-32583-drop-redundant-index-on-client-session', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.557655', 145, 'EXECUTED', '9:24972d83bf27317a055d234187bb4af9', 'dropIndex indexName=IDX_US_SESS_ID_ON_CL_SESS, tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0.32582-remove-tables-user-session-user-session-note-and-client-session', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.589698', 146, 'EXECUTED', '9:febdc0f47f2ed241c59e60f58c3ceea5', 'dropTable tableName=CLIENT_SESSION_ROLE; dropTable tableName=CLIENT_SESSION_NOTE; dropTable tableName=CLIENT_SESSION_PROT_MAPPER; dropTable tableName=CLIENT_SESSION_AUTH_STATUS; dropTable tableName=CLIENT_USER_SESSION_NOTE; dropTable tableName=CLI...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.0.0-33201-org-redirect-url', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.608849', 147, 'EXECUTED', '9:4d0e22b0ac68ebe9794fa9cb752ea660', 'addColumn tableName=ORG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('29399-jdbc-ping-default', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.641863', 148, 'EXECUTED', '9:007dbe99d7203fca403b89d4edfdf21e', 'createTable tableName=JGROUPS_PING; addPrimaryKey constraintName=CONSTRAINT_JGROUPS_PING, tableName=JGROUPS_PING', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.1.0-34013', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.666123', 149, 'EXECUTED', '9:e6b686a15759aef99a6d758a5c4c6a26', 'addColumn tableName=ADMIN_EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.1.0-34380', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.678351', 150, 'EXECUTED', '9:ac8b9edb7c2b6c17a1c7a11fcf5ccf01', 'dropTable tableName=USERNAME_LOGIN_FAILURE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.0-36750', 'keycloak', 'META-INF/jpa-changelog-26.2.0.xml', '2025-10-20 11:36:07.702868', 151, 'EXECUTED', '9:b49ce951c22f7eb16480ff085640a33a', 'createTable tableName=SERVER_CONFIG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.0-26106', 'keycloak', 'META-INF/jpa-changelog-26.2.0.xml', '2025-10-20 11:36:07.709515', 152, 'EXECUTED', '9:b5877d5dab7d10ff3a9d209d7beb6680', 'addColumn tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.6-39866-duplicate', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.720547', 153, 'EXECUTED', '9:1dc67ccee24f30331db2cba4f372e40e', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.6-39866-uk', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.729406', 154, 'EXECUTED', '9:b70b76f47210cf0a5f4ef0e219eac7cd', 'addUniqueConstraint constraintName=UK_MIGRATION_VERSION, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.6-40088-duplicate', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.737196', 155, 'EXECUTED', '9:cc7e02ed69ab31979afb1982f9670e8f', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.2.6-40088-uk', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.745088', 156, 'EXECUTED', '9:5bb848128da7bc4595cc507383325241', 'addUniqueConstraint constraintName=UK_MIGRATION_UPDATE_TIME, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO mim.databasechangelog VALUES ('26.3.0-groups-description', 'keycloak', 'META-INF/jpa-changelog-26.3.0.xml', '2025-10-20 11:36:07.754934', 157, 'EXECUTED', '9:e1a3c05574326fb5b246b73b9a4c4d49', 'addColumn tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');


--
-- TOC entry 5459 (class 0 OID 18909)
-- Dependencies: 449
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.databasechangeloglock VALUES (1, false, NULL, NULL);
INSERT INTO mim.databasechangeloglock VALUES (1000, false, NULL, NULL);


--
-- TOC entry 5460 (class 0 OID 18912)
-- Dependencies: 450
-- Data for Name: default_client_scope; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '26186141-2832-4cc9-8b88-1a39757006ec', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'cbbe8007-9274-488d-b7a6-e1efa971032b', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO mim.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '9951cc8a-858b-4683-a600-97e7665ddb42', false);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'fd6c9d6d-6ab6-438b-b89c-c7ff57754b28', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '3ad19674-ce68-4a42-aced-44c4fa68be5d', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'a9c186d7-5920-470d-9814-4401c3d8e267', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '4fc0ef8c-b308-4273-a876-f9503b1d7901', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'cc5d4db3-5f9b-4347-b293-ed400f6ba426', false);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '45e120c8-9839-41b6-9c44-a0e75e42f709', false);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '170d9849-440b-40c4-9013-365f850cb7cb', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '075465d3-4d72-4dde-b87e-34ff466b2741', false);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '95cb1f46-2e30-45b1-86ba-18f721866a94', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '92feb0f4-3a22-4406-95a9-f745e65f4cf5', true);
INSERT INTO mim.default_client_scope VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', '49517077-c810-4c8a-acc3-1a53aa4c9d81', false);


--
-- TOC entry 5465 (class 0 OID 18946)
-- Dependencies: 457
-- Data for Name: event_entity; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5466 (class 0 OID 18951)
-- Dependencies: 458
-- Data for Name: fed_user_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5467 (class 0 OID 18956)
-- Dependencies: 459
-- Data for Name: fed_user_consent; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5468 (class 0 OID 18961)
-- Dependencies: 460
-- Data for Name: fed_user_consent_cl_scope; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5469 (class 0 OID 18964)
-- Dependencies: 461
-- Data for Name: fed_user_credential; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5470 (class 0 OID 18969)
-- Dependencies: 462
-- Data for Name: fed_user_group_membership; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5471 (class 0 OID 18972)
-- Dependencies: 463
-- Data for Name: fed_user_required_action; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5472 (class 0 OID 18978)
-- Dependencies: 464
-- Data for Name: fed_user_role_mapping; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5473 (class 0 OID 18981)
-- Dependencies: 465
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5474 (class 0 OID 18986)
-- Dependencies: 466
-- Data for Name: federated_user; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5461 (class 0 OID 18916)
-- Dependencies: 451
-- Data for Name: group_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.group_attribute VALUES ('6c6e7ab4-bfb8-438c-9485-38d0e7a5cb0f', 'piva', '123', 'fba16bae-1a39-4f7d-afb7-72dfecd4f8cd');
INSERT INTO mim.group_attribute VALUES ('8d0b608e-6651-40e0-99a4-fef727648a12', 'company_db_id', '1', 'fba16bae-1a39-4f7d-afb7-72dfecd4f8cd');
INSERT INTO mim.group_attribute VALUES ('1ee367f9-4b87-4af2-817e-b5b3fceba143', 'company_name', 'testing', 'fba16bae-1a39-4f7d-afb7-72dfecd4f8cd');


--
-- TOC entry 5463 (class 0 OID 18932)
-- Dependencies: 454
-- Data for Name: group_role_mapping; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.group_role_mapping VALUES ('7aa6b849-53af-4db6-937e-d8abdc29087c', '4bc1ba62-5d4f-4fb3-b1e4-df00192977c3');
INSERT INTO mim.group_role_mapping VALUES ('52ea1671-7561-4813-9651-d003f9d5cb6e', '4bc1ba62-5d4f-4fb3-b1e4-df00192977c3');


--
-- TOC entry 5475 (class 0 OID 18991)
-- Dependencies: 467
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5476 (class 0 OID 19003)
-- Dependencies: 468
-- Data for Name: identity_provider_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5477 (class 0 OID 19008)
-- Dependencies: 469
-- Data for Name: identity_provider_mapper; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5478 (class 0 OID 19013)
-- Dependencies: 470
-- Data for Name: idp_mapper_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5479 (class 0 OID 19018)
-- Dependencies: 471
-- Data for Name: jgroups_ping; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5462 (class 0 OID 18922)
-- Dependencies: 452
-- Data for Name: keycloak_group; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.keycloak_group VALUES ('fba16bae-1a39-4f7d-afb7-72dfecd4f8cd', 'societa', ' ', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 0, '');
INSERT INTO mim.keycloak_group VALUES ('4bc1ba62-5d4f-4fb3-b1e4-df00192977c3', 'admin', 'fba16bae-1a39-4f7d-afb7-72dfecd4f8cd', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 0, '');


--
-- TOC entry 5464 (class 0 OID 18935)
-- Dependencies: 455
-- Data for Name: keycloak_role; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.keycloak_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_default-roles}', 'default-roles-master', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_admin}', 'admin', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('8e3d03e5-e70a-460f-8d22-bb11ecabcae3', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_create-realm}', 'create-realm', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('1bf774c0-76b5-43d3-a6ab-580554987f88', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_create-client}', 'create-client', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('90da9da7-9cbd-4e08-afe2-b657bdca5ac0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-realm}', 'view-realm', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-users}', 'view-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-clients}', 'view-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('393c8228-dabe-4927-bec5-d62e0f372af9', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-events}', 'view-events', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('bcf549e9-6de7-4ba3-a2d7-7864f460fe6a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-identity-providers}', 'view-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('6c32a60e-78de-4b5a-b19c-69eb7e84ac9a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-authorization}', 'view-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('d5ff873d-5bc6-444c-89db-b2a7573008ca', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-realm}', 'manage-realm', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('6d21a91c-7886-4b8c-8933-7e6f708606fe', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-users}', 'manage-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('966551e2-bdb1-4c42-a1f4-10c85d410db2', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-clients}', 'manage-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('2c9a23ac-4921-404e-99df-1f5a7b85cd7f', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-events}', 'manage-events', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('c56c1682-22c0-4d14-b41f-af9641674de5', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-identity-providers}', 'manage-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('689bf969-bf06-440a-95a4-8429cc400d09', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-authorization}', 'manage-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('46d4c4c6-ab10-47b3-9665-43d3f44aaa63', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-users}', 'query-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('325745f8-d041-4e42-8a89-466e404c775b', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-clients}', 'query-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('75bb763a-6fc1-4bfe-8432-da1fc12e5efd', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-realms}', 'query-realms', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('dd58dfd2-861f-41eb-9dc8-d956324f9ccd', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-groups}', 'query-groups', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('c5fbb5ee-4707-425f-836d-3d833f7c294f', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-profile}', 'view-profile', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-account}', 'manage-account', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('a471a901-48ee-443e-90b1-2c70abd516ea', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-account-links}', 'manage-account-links', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('8095b4ff-6f0d-414b-8057-22d5471ad338', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-applications}', 'view-applications', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('d416a33e-2abf-4dc2-b9fa-94a23017e858', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-consent}', 'view-consent', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-consent}', 'manage-consent', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-groups}', 'view-groups', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('5e45631a-17db-48f8-87dd-278459b02b54', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_delete-account}', 'delete-account', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO mim.keycloak_role VALUES ('bd5731c3-d8e2-4830-b512-a914de001373', '42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', true, '${role_read-token}', 'read-token', '0c806647-a11c-403d-af39-092523465ca0', '42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', NULL);
INSERT INTO mim.keycloak_role VALUES ('3a3b68f5-5620-44aa-974f-6b1cf9c2c12a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_impersonation}', 'impersonation', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO mim.keycloak_role VALUES ('a3f06c98-eaeb-4470-98d5-09268563e97f', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_offline-access}', 'offline_access', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('b83d7ede-d9b5-493d-bb43-8a5e641d5085', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_uma_authorization}', 'uma_authorization', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, '${role_default-roles}', 'default-roles-atlantica', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('e793b400-1ba3-4b9c-b00e-85de01861d6c', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_create-client}', 'create-client', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('cf7f6c67-c1ef-459e-83c5-c5a8caed6e4d', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-realm}', 'view-realm', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('6806d196-0d69-427e-b093-e76f9aed4f24', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-users}', 'view-users', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('db3211e4-5b1e-4b1e-8bf9-68caf3f85b4c', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-clients}', 'view-clients', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('73d1e89b-739f-490b-9c20-f6bfc06c629f', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-events}', 'view-events', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('214f2782-211b-45cc-acb1-78dc440b10e0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-identity-providers}', 'view-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('8acccd39-bfe1-4075-84d1-23ac852c4535', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_view-authorization}', 'view-authorization', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('69cf759d-2a1d-4854-869f-813c20c139f2', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-realm}', 'manage-realm', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('1384f2ce-8f9b-463d-9282-f1779c5b9de9', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-users}', 'manage-users', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('c3c8df3d-a2a9-4e04-94d4-73977c885f2f', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-clients}', 'manage-clients', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('b20809cc-1123-48fc-9338-3dd52921b0da', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-events}', 'manage-events', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('a5fda10a-f896-4aaa-9478-0c27f050ab25', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-identity-providers}', 'manage-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('0dcf03c2-e7a1-4084-93f0-f4b7d794d193', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_manage-authorization}', 'manage-authorization', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('92ea89b0-7a1a-4206-9145-ec4f9b63aac4', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_query-users}', 'query-users', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('4402d0a7-3ad3-42f7-a4b0-6a026144a866', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_query-clients}', 'query-clients', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('8b4747ac-3706-4047-aa04-503b9f2e3840', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_query-realms}', 'query-realms', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('6d901d15-deaa-4571-bdf5-67f46236bcf1', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_query-groups}', 'query-groups', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_realm-admin}', 'realm-admin', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('ff2f0fac-6b39-4b1f-abb6-0252669895cf', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_create-client}', 'create-client', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('2b5aef57-58f4-43c6-84d0-3d2657eb7002', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-realm}', 'view-realm', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('6f5e377f-9be5-4915-874c-da7284b6111a', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-users}', 'view-users', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('42cf16eb-49a0-4793-999c-e78175462c6b', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-clients}', 'view-clients', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('74e17fab-1b69-4738-b247-f7195ec4775a', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-events}', 'view-events', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('c02820af-7da5-4d7e-a152-fa3c90ce554c', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-identity-providers}', 'view-identity-providers', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('c75f97d9-a933-4bc8-8101-900df1277a32', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_view-authorization}', 'view-authorization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('50ea785c-717e-409b-936d-6440e102fbf9', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-realm}', 'manage-realm', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('c8743249-05ea-4178-888f-5933c41ada6c', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-users}', 'manage-users', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('c6cd383c-a00d-432b-b977-f422f07f1606', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-clients}', 'manage-clients', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('a1c9d20c-4d01-4ce4-855e-f61666c9f224', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-events}', 'manage-events', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('60cafdb3-3d6c-48c1-9e77-172daf242bea', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-identity-providers}', 'manage-identity-providers', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('ef0ea393-fde1-4c82-aaef-508782fb824f', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_manage-authorization}', 'manage-authorization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('88f5f86b-d637-4ba4-aaa0-e9cca63f08a7', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_query-users}', 'query-users', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('1cee0901-37bd-4a6d-9803-77b75a697239', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_query-clients}', 'query-clients', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('6f485a00-8e0c-4172-8b86-fe86925f6dd5', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_query-realms}', 'query-realms', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('f521e451-2789-41a8-834c-a2ad8cf2dbe2', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_query-groups}', 'query-groups', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('b781240c-1437-41e2-9953-f973d3124a31', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_view-profile}', 'view-profile', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('53004a4e-b443-4cb9-af6f-a3d4725a933c', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_manage-account}', 'manage-account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('b287f985-f47a-4ca9-8e5a-ca8671801eba', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_manage-account-links}', 'manage-account-links', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('8989f5c3-bec9-41d0-bb64-18789690d0a4', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_view-applications}', 'view-applications', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('4f3f02d4-5fa5-42e4-b343-662782da3788', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_view-consent}', 'view-consent', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('04389301-51df-49c0-acb5-e8e5edacb614', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_manage-consent}', 'manage-consent', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('2c82bdc0-f988-446d-ac7a-7e5ae13d93c2', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_view-groups}', 'view-groups', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('6f343f84-6a72-435a-8a1b-fc870d7d55f7', '160d4371-67af-4845-946e-f81f48ba3e42', true, '${role_delete-account}', 'delete-account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '160d4371-67af-4845-946e-f81f48ba3e42', NULL);
INSERT INTO mim.keycloak_role VALUES ('3d9014ee-1b65-4abc-9066-a08b5ead2d8d', '5d174780-837c-47b6-ae12-fba56b1bdc0a', true, '${role_impersonation}', 'impersonation', '0c806647-a11c-403d-af39-092523465ca0', '5d174780-837c-47b6-ae12-fba56b1bdc0a', NULL);
INSERT INTO mim.keycloak_role VALUES ('12b4b4c0-ceca-48ee-86f2-27fe90505a2c', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', true, '${role_impersonation}', 'impersonation', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ec6afc2a-b688-4a03-811d-3ea6b49f7a00', NULL);
INSERT INTO mim.keycloak_role VALUES ('9d914d8b-c9de-429e-8044-3ded177122f9', 'f72baef0-f75a-4a7a-8427-e95bde52c523', true, '${role_read-token}', 'read-token', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'f72baef0-f75a-4a7a-8427-e95bde52c523', NULL);
INSERT INTO mim.keycloak_role VALUES ('cb0b8832-9032-47af-907d-c3d5d899d711', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, '${role_offline-access}', 'offline_access', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('803a5296-f69f-403a-aa65-a1168bff4666', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, '${role_uma_authorization}', 'uma_authorization', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('7aa6b849-53af-4db6-937e-d8abdc29087c', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, '', 'authority_admin', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL, NULL);
INSERT INTO mim.keycloak_role VALUES ('52ea1671-7561-4813-9651-d003f9d5cb6e', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, NULL, 'user', '55a761d8-e85b-4c2b-a052-3486ea3375b6', NULL, NULL);


--
-- TOC entry 5482 (class 0 OID 19049)
-- Dependencies: 477
-- Data for Name: menu_items; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.menu_items VALUES (4, 'utenti', 'pi pi-users', NULL, 'sidebar.users', '/users', 3, 1, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);
INSERT INTO mim.menu_items VALUES (3, 'gruppi', 'pi pi-share-alt', NULL, 'sidebar.groups', '/groups', 2, 1, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);
INSERT INTO mim.menu_items VALUES (2, 'ruoli', 'pi pi-key', NULL, 'sidebar.roles', '/roles', 1, 1, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);
INSERT INTO mim.menu_items VALUES (1, 'amministratore label', 'pi pi-home', NULL, 'sidebar.admin', NULL, 0, NULL, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);
INSERT INTO mim.menu_items VALUES (5, 'home label', 'pi pi-home', NULL, 'sidebar.home', NULL, 1, NULL, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);
INSERT INTO mim.menu_items VALUES (8, 'menu label', 'pi pi-bars', NULL, 'sidebar.menu', '/menus', 4, 1, '7aa6b849-53af-4db6-937e-d8abdc29087c', true);

--
-- TOC entry 5484 (class 0 OID 19057)
-- Dependencies: 479
-- Data for Name: migration_model; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.migration_model VALUES ('rp667', '26.3.0', 1760960169);


--
-- TOC entry 5485 (class 0 OID 19061)
-- Dependencies: 480
-- Data for Name: offline_client_session; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.offline_client_session VALUES ('6ce7ccf8-5426-4d6f-ad2b-87f562225fd8', '74d50ff9-7290-434c-a967-e7144a37e4a5', '0', 1763844157, '{"authMethod":"openid-connect","redirectUri":"http://localhost:4200/","notes":{"clientId":"74d50ff9-7290-434c-a967-e7144a37e4a5","iss":"http://localhost:8082/realms/atlantica","startedAt":"1763844157","response_type":"code","level-of-authentication":"-1","code_challenge_method":"S256","nonce":"22797182-9657-4474-9d53-2addce1081ea","response_mode":"fragment","scope":"openid","userSessionStartedAt":"1763844157","redirect_uri":"http://localhost:4200/","state":"e926b6bb-4a70-4ea8-957e-56e89fefdf8e","code_challenge":"NYUOZlthJkZRcU_bQDXZloPb4YowfXcPmi82XCY3la4"}}', 'local', 'local', 0);


--
-- TOC entry 5486 (class 0 OID 19069)
-- Dependencies: 481
-- Data for Name: offline_user_session; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.offline_user_session VALUES ('6ce7ccf8-5426-4d6f-ad2b-87f562225fd8', 'b813f8c8-a0bf-4df9-af10-ceccc2733e43', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 1763844157, '0', '{"ipAddress":"172.18.0.1","authMethod":"openid-connect","rememberMe":false,"started":0,"notes":{"KC_DEVICE_NOTE":"eyJpcEFkZHJlc3MiOiIxNzIuMTguMC4xIiwib3MiOiJXaW5kb3dzIiwib3NWZXJzaW9uIjoiMTAiLCJicm93c2VyIjoiQ2hyb21lLzE0Mi4wLjAiLCJkZXZpY2UiOiJPdGhlciIsImxhc3RBY2Nlc3MiOjAsIm1vYmlsZSI6ZmFsc2V9","AUTH_TIME":"1763844157","authenticators-completed":"{\"09b9e732-e2f1-41c6-8c81-a37f1ff571ac\":1763844157}"},"state":"LOGGED_IN"}', 1763844157, NULL, 0);


--
-- TOC entry 5487 (class 0 OID 19076)
-- Dependencies: 482
-- Data for Name: org; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5488 (class 0 OID 19081)
-- Dependencies: 483
-- Data for Name: org_domain; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5489 (class 0 OID 19086)
-- Dependencies: 484
-- Data for Name: policy_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5490 (class 0 OID 19091)
-- Dependencies: 485
-- Data for Name: protocol_mapper; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.protocol_mapper VALUES ('f29f8d6f-bc6f-44e0-87a5-ade4354e4a3a', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', '8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', NULL);
INSERT INTO mim.protocol_mapper VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', '3cd5708c-d0ed-458c-8786-c953920c8f37', NULL);
INSERT INTO mim.protocol_mapper VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'role list', 'saml', 'saml-role-list-mapper', NULL, '26186141-2832-4cc9-8b88-1a39757006ec');
INSERT INTO mim.protocol_mapper VALUES ('45ff4d65-464d-4827-b123-ad3ce1b22671', 'organization', 'saml', 'saml-organization-membership-mapper', NULL, 'cbbe8007-9274-488d-b7a6-e1efa971032b');
INSERT INTO mim.protocol_mapper VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'full name', 'openid-connect', 'oidc-full-name-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'family name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'given name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middle name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'username', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updated at', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO mim.protocol_mapper VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a6e2784f-5222-4d7c-a15c-ba88682028f4');
INSERT INTO mim.protocol_mapper VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'email verified', 'openid-connect', 'oidc-usermodel-property-mapper', NULL, 'a6e2784f-5222-4d7c-a15c-ba88682028f4');
INSERT INTO mim.protocol_mapper VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'address', 'openid-connect', 'oidc-address-mapper', NULL, '993ba957-fbd7-43f2-ae34-1f79b0230bf5');
INSERT INTO mim.protocol_mapper VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phone number', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'fb44034c-f05c-478a-a35e-5b48b2bea3f2');
INSERT INTO mim.protocol_mapper VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phone number verified', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'fb44034c-f05c-478a-a35e-5b48b2bea3f2');
INSERT INTO mim.protocol_mapper VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'realm roles', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO mim.protocol_mapper VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'client roles', 'openid-connect', 'oidc-usermodel-client-role-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO mim.protocol_mapper VALUES ('634e424a-411b-44ef-9539-a21815948394', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO mim.protocol_mapper VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'allowed web origins', 'openid-connect', 'oidc-allowed-origins-mapper', NULL, 'af89a443-1204-4c1a-bce8-57a80972cc03');
INSERT INTO mim.protocol_mapper VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'upn', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '528e12c3-909d-419d-ab0c-9867e433de88');
INSERT INTO mim.protocol_mapper VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'groups', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '528e12c3-909d-419d-ab0c-9867e433de88');
INSERT INTO mim.protocol_mapper VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'acr loa level', 'openid-connect', 'oidc-acr-mapper', NULL, 'd4425897-b36d-4b12-846e-61da27f50271');
INSERT INTO mim.protocol_mapper VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'auth_time', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '039b7573-e076-41be-a04a-ac06eee8285f');
INSERT INTO mim.protocol_mapper VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'sub', 'openid-connect', 'oidc-sub-mapper', NULL, '039b7573-e076-41be-a04a-ac06eee8285f');
INSERT INTO mim.protocol_mapper VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'Client ID', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO mim.protocol_mapper VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'Client Host', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO mim.protocol_mapper VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'Client IP Address', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO mim.protocol_mapper VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'organization', 'openid-connect', 'oidc-organization-membership-mapper', NULL, '05888153-059e-47e4-b37a-47236467549a');
INSERT INTO mim.protocol_mapper VALUES ('db9ccf05-77fc-4b65-bb92-7aec9f888850', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', '183a8995-5173-4495-a4bf-4620abe38771', NULL);
INSERT INTO mim.protocol_mapper VALUES ('dd2929a7-8960-4548-92b5-5f78e446aa54', 'role list', 'saml', 'saml-role-list-mapper', NULL, 'fd6c9d6d-6ab6-438b-b89c-c7ff57754b28');
INSERT INTO mim.protocol_mapper VALUES ('c3c4d462-8849-444c-b33a-c83fa363f313', 'organization', 'saml', 'saml-organization-membership-mapper', NULL, '3ad19674-ce68-4a42-aced-44c4fa68be5d');
INSERT INTO mim.protocol_mapper VALUES ('b2ecea1d-c3a9-4264-a426-2ab00ef5b498', 'full name', 'openid-connect', 'oidc-full-name-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'family name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'given name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'middle name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'nickname', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'username', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'profile', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'picture', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'website', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'gender', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'birthdate', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'zoneinfo', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'updated at', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a9c186d7-5920-470d-9814-4401c3d8e267');
INSERT INTO mim.protocol_mapper VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'email', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '4fc0ef8c-b308-4273-a876-f9503b1d7901');
INSERT INTO mim.protocol_mapper VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'email verified', 'openid-connect', 'oidc-usermodel-property-mapper', NULL, '4fc0ef8c-b308-4273-a876-f9503b1d7901');
INSERT INTO mim.protocol_mapper VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'address', 'openid-connect', 'oidc-address-mapper', NULL, 'cc5d4db3-5f9b-4347-b293-ed400f6ba426');
INSERT INTO mim.protocol_mapper VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'phone number', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '45e120c8-9839-41b6-9c44-a0e75e42f709');
INSERT INTO mim.protocol_mapper VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'phone number verified', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '45e120c8-9839-41b6-9c44-a0e75e42f709');
INSERT INTO mim.protocol_mapper VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'realm roles', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '170d9849-440b-40c4-9013-365f850cb7cb');
INSERT INTO mim.protocol_mapper VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'client roles', 'openid-connect', 'oidc-usermodel-client-role-mapper', NULL, '170d9849-440b-40c4-9013-365f850cb7cb');
INSERT INTO mim.protocol_mapper VALUES ('d0010149-a232-4639-b86a-b3823c380145', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', NULL, '170d9849-440b-40c4-9013-365f850cb7cb');
INSERT INTO mim.protocol_mapper VALUES ('ac0c96be-843d-4a80-8c7d-f237bf23c5d6', 'allowed web origins', 'openid-connect', 'oidc-allowed-origins-mapper', NULL, 'cd45bf50-3bea-4ee6-9e9b-85cda5cc3167');
INSERT INTO mim.protocol_mapper VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'upn', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '075465d3-4d72-4dde-b87e-34ff466b2741');
INSERT INTO mim.protocol_mapper VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'groups', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '075465d3-4d72-4dde-b87e-34ff466b2741');
INSERT INTO mim.protocol_mapper VALUES ('85ba86a9-9309-41f5-bf54-372122cd3995', 'acr loa level', 'openid-connect', 'oidc-acr-mapper', NULL, '95cb1f46-2e30-45b1-86ba-18f721866a94');
INSERT INTO mim.protocol_mapper VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'auth_time', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '92feb0f4-3a22-4406-95a9-f745e65f4cf5');
INSERT INTO mim.protocol_mapper VALUES ('9b3d4465-21ee-4cf8-ba02-1d25a554339c', 'sub', 'openid-connect', 'oidc-sub-mapper', NULL, '92feb0f4-3a22-4406-95a9-f745e65f4cf5');
INSERT INTO mim.protocol_mapper VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'Client ID', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '4830bd61-5d2d-4f04-89e6-140184227e4c');
INSERT INTO mim.protocol_mapper VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'Client Host', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '4830bd61-5d2d-4f04-89e6-140184227e4c');
INSERT INTO mim.protocol_mapper VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'Client IP Address', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '4830bd61-5d2d-4f04-89e6-140184227e4c');
INSERT INTO mim.protocol_mapper VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'organization', 'openid-connect', 'oidc-organization-membership-mapper', NULL, '49517077-c810-4c8a-acc3-1a53aa4c9d81');
INSERT INTO mim.protocol_mapper VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', 'e0745322-716b-4b72-8a49-6c0b93644318', NULL);
INSERT INTO mim.protocol_mapper VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'code', 'openid-connect', 'oidc-usermodel-attribute-mapper', '74d50ff9-7290-434c-a967-e7144a37e4a5', NULL);
INSERT INTO mim.protocol_mapper VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'piva', 'openid-connect', 'oidc-usermodel-attribute-mapper', '74d50ff9-7290-434c-a967-e7144a37e4a5', NULL);
INSERT INTO mim.protocol_mapper VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'company_name', 'openid-connect', 'oidc-usermodel-attribute-mapper', '74d50ff9-7290-434c-a967-e7144a37e4a5', NULL);
INSERT INTO mim.protocol_mapper VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'id', 'openid-connect', 'oidc-usermodel-property-mapper', '74d50ff9-7290-434c-a967-e7144a37e4a5', NULL);
INSERT INTO mim.protocol_mapper VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', '74d50ff9-7290-434c-a967-e7144a37e4a5', NULL);


--
-- TOC entry 5491 (class 0 OID 19096)
-- Dependencies: 486
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'false', 'single');
INSERT INTO mim.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'Basic', 'attribute.nameformat');
INSERT INTO mim.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'Role', 'attribute.name');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'firstName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'given_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'lastName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'family_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middleName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middle_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updatedAt', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updated_at', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'long', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'username', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'preferred_username', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'emailVerified', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'email_verified', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'boolean', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'formatted', 'user.attribute.formatted');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'country', 'user.attribute.country');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'postal_code', 'user.attribute.postal_code');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'street', 'user.attribute.street');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'region', 'user.attribute.region');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'locality', 'user.attribute.locality');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phoneNumber', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phone_number', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phoneNumberVerified', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phone_number_verified', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'boolean', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('634e424a-411b-44ef-9539-a21815948394', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('634e424a-411b-44ef-9539-a21815948394', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'resource_access.${client_id}.roles', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'realm_access.roles', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'username', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'upn', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'groups', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'AUTH_TIME', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'auth_time', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'long', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'clientHost', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'clientHost', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'client_id', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'client_id', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'clientAddress', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'clientAddress', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'organization', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('dd2929a7-8960-4548-92b5-5f78e446aa54', 'false', 'single');
INSERT INTO mim.protocol_mapper_config VALUES ('dd2929a7-8960-4548-92b5-5f78e446aa54', 'Basic', 'attribute.nameformat');
INSERT INTO mim.protocol_mapper_config VALUES ('dd2929a7-8960-4548-92b5-5f78e446aa54', 'Role', 'attribute.name');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'profile', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'profile', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('0612aeb5-4c66-436d-88fb-a1625ff261d7', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'firstName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'given_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('095842c9-faae-449c-97bb-357d837b9008', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'lastName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'family_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('0dbc0fba-faad-45e6-9507-37cf478783ed', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'birthdate', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'birthdate', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('1d5efed5-b7e0-4e9e-b577-52c3c17727bf', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'middleName', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'middle_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('26e1ba7e-9f9a-43fd-8161-a38c1e29a2ee', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'nickname', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'nickname', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('7364c529-a102-4f32-8644-2e9c6bcc7c09', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'gender', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'gender', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('7b33eee5-04e3-4d39-875c-5ba5549ff77a', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'zoneinfo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'zoneinfo', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('93c1ea0b-e864-4635-9899-6533fecb4e9d', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'updatedAt', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'updated_at', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('a4d4e250-2c5f-43ef-ad2b-1ac2f7cd51a2', 'long', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('b2ecea1d-c3a9-4264-a426-2ab00ef5b498', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b2ecea1d-c3a9-4264-a426-2ab00ef5b498', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b2ecea1d-c3a9-4264-a426-2ab00ef5b498', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b2ecea1d-c3a9-4264-a426-2ab00ef5b498', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'locale', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'locale', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('bcd0f52e-5882-456e-a1f1-aabd94919e4c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'username', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'preferred_username', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('efbaae0f-614e-4dae-9815-21e5bd07b17c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'website', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'website', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('f50c5ea6-db9d-4ef2-a618-6fc72035e950', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'picture', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'picture', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('fb3e17c6-cd0e-44f2-83b9-824e740df42c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'email', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'email', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('2d246382-ec09-4cde-9872-1a24ba8c22de', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'emailVerified', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'email_verified', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('69505e00-54a8-4042-b314-be9b7d180b7a', 'boolean', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'formatted', 'user.attribute.formatted');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'country', 'user.attribute.country');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'postal_code', 'user.attribute.postal_code');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'street', 'user.attribute.street');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'region', 'user.attribute.region');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('2f246b9b-83c8-48bb-bdc2-68755fe043c2', 'locality', 'user.attribute.locality');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'phoneNumberVerified', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'phone_number_verified', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('b44eac83-5838-4a4b-a5a6-2072fb792230', 'boolean', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'phoneNumber', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'phone_number', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('fc58d742-a009-4968-bb47-ef9880122c30', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'realm_access.roles', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('0b344415-09f6-4d88-845a-2508b4062041', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'resource_access.${client_id}.roles', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('279da20f-2dbe-4955-9758-2edda5c46742', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('d0010149-a232-4639-b86a-b3823c380145', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('d0010149-a232-4639-b86a-b3823c380145', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ac0c96be-843d-4a80-8c7d-f237bf23c5d6', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('ac0c96be-843d-4a80-8c7d-f237bf23c5d6', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'username', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'upn', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('7c3a6f75-45d6-47bf-81a6-f7ba2d946f16', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'foo', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'groups', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('e24a9cd3-29c6-4c59-8b06-9ebf13a47a95', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('85ba86a9-9309-41f5-bf54-372122cd3995', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('85ba86a9-9309-41f5-bf54-372122cd3995', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('85ba86a9-9309-41f5-bf54-372122cd3995', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9b3d4465-21ee-4cf8-ba02-1d25a554339c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9b3d4465-21ee-4cf8-ba02-1d25a554339c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'AUTH_TIME', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'auth_time', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('afe479c7-9e1f-40d7-8d35-a183dd94346f', 'long', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'client_id', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'client_id', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('6bbc10b3-4b7a-48b0-94f7-aefa39b2fc79', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'clientHost', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'clientHost', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('bc9a987f-6295-40ea-b73c-56c6385c401c', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'clientAddress', 'user.session.note');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'clientAddress', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('e8aef49f-3d15-46cd-9610-a3fc63059417', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'organization', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('aaa82d9c-7e8f-4b1f-b5d0-37709fb09a65', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'locale', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'locale', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('fb9ab46b-32f8-4812-b3dc-2e7c06185c1e', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'aggregate.attrs');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'code', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'false', 'lightweight.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'code', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('77dc7b03-4958-4e6f-b224-1b2dae074ac8', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'aggregate.attrs');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'piva', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'false', 'lightweight.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'piva', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('9f2d403a-168e-4d14-bb0a-68c61d93d8ff', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'aggregate.attrs');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'multivalued');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'company_name', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'false', 'lightweight.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'company_name', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('90aedc16-0c7a-42c9-be5b-4ef73c80886a', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'id', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'false', 'lightweight.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'id', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('04f62a19-a92f-400c-bd12-47b525925a52', 'String', 'jsonType.label');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'true', 'introspection.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'true', 'userinfo.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'locale', 'user.attribute');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'true', 'id.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'false', 'lightweight.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'true', 'access.token.claim');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'locale', 'claim.name');
INSERT INTO mim.protocol_mapper_config VALUES ('428b1656-ed4b-42c4-aac4-43a74b23d2ad', 'String', 'jsonType.label');


--
-- TOC entry 5492 (class 0 OID 19101)
-- Dependencies: 487
-- Data for Name: realm; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.realm VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 60, 300, 300, NULL, NULL, NULL, true, false, 0, NULL, 'atlantica', 0, NULL, false, false, false, false, 'EXTERNAL', 1800, 36000, false, false, '5d174780-837c-47b6-ae12-fba56b1bdc0a', 1800, true, 'it', false, false, false, false, 0, 1, 30, 6, 'HmacSHA1', 'totp', '39ea369c-a110-499e-8fd3-722b8b3481c4', '5ba7f27f-4dc7-4d74-8510-d69c7b8ee289', '24bf60db-ab22-421b-8f12-7091e59c4837', '5b00a237-aa02-40bb-88cd-f72f4fd1fdcc', 'd1b4fbbf-0cf1-4270-86e9-3aef615553b7', 2592000, false, 900, true, false, '84b34ea5-41f9-4db1-88b9-1ffd1b4ceea1', 0, false, 0, 0, 'db79ad00-8089-44bc-ab11-93f0a595bfb5');
INSERT INTO mim.realm VALUES ('0c806647-a11c-403d-af39-092523465ca0', 60, 300, 60, NULL, NULL, NULL, true, false, 0, NULL, 'master', 0, NULL, false, false, false, false, 'EXTERNAL', 1800, 36000, false, false, 'b44bd709-a47c-4200-9be6-48e57da7d91c', 1800, false, NULL, false, false, false, false, 0, 1, 30, 6, 'HmacSHA1', 'totp', '176b4f88-6b3d-44cb-beb4-9317f356d604', 'd5ca2242-a726-45ed-abc5-0ab031f68d89', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2592000, false, 900, true, false, '5e51b971-b52e-4997-9c70-d0fd966312f6', 0, false, 0, 0, 'c9dfe9d4-a8db-4004-9148-41cad23b2bfe');


--
-- TOC entry 5493 (class 0 OID 19134)
-- Dependencies: 488
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.realm_attribute VALUES ('_browser_header.contentSecurityPolicyReportOnly', '0c806647-a11c-403d-af39-092523465ca0', '');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xContentTypeOptions', '0c806647-a11c-403d-af39-092523465ca0', 'nosniff');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.referrerPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'no-referrer');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xRobotsTag', '0c806647-a11c-403d-af39-092523465ca0', 'none');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xFrameOptions', '0c806647-a11c-403d-af39-092523465ca0', 'SAMEORIGIN');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.contentSecurityPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'frame-src ''self''; frame-ancestors ''self''; object-src ''none'';');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.strictTransportSecurity', '0c806647-a11c-403d-af39-092523465ca0', 'max-age=31536000; includeSubDomains');
INSERT INTO mim.realm_attribute VALUES ('bruteForceProtected', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO mim.realm_attribute VALUES ('permanentLockout', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO mim.realm_attribute VALUES ('maxTemporaryLockouts', '0c806647-a11c-403d-af39-092523465ca0', '0');
INSERT INTO mim.realm_attribute VALUES ('bruteForceStrategy', '0c806647-a11c-403d-af39-092523465ca0', 'MULTIPLE');
INSERT INTO mim.realm_attribute VALUES ('maxFailureWaitSeconds', '0c806647-a11c-403d-af39-092523465ca0', '900');
INSERT INTO mim.realm_attribute VALUES ('minimumQuickLoginWaitSeconds', '0c806647-a11c-403d-af39-092523465ca0', '60');
INSERT INTO mim.realm_attribute VALUES ('waitIncrementSeconds', '0c806647-a11c-403d-af39-092523465ca0', '60');
INSERT INTO mim.realm_attribute VALUES ('quickLoginCheckMilliSeconds', '0c806647-a11c-403d-af39-092523465ca0', '1000');
INSERT INTO mim.realm_attribute VALUES ('maxDeltaTimeSeconds', '0c806647-a11c-403d-af39-092523465ca0', '43200');
INSERT INTO mim.realm_attribute VALUES ('failureFactor', '0c806647-a11c-403d-af39-092523465ca0', '30');
INSERT INTO mim.realm_attribute VALUES ('realmReusableOtpCode', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO mim.realm_attribute VALUES ('firstBrokerLoginFlowId', '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c');
INSERT INTO mim.realm_attribute VALUES ('displayName', '0c806647-a11c-403d-af39-092523465ca0', 'Keycloak');
INSERT INTO mim.realm_attribute VALUES ('displayNameHtml', '0c806647-a11c-403d-af39-092523465ca0', '<div class="kc-logo-text"><span>Keycloak</span></div>');
INSERT INTO mim.realm_attribute VALUES ('defaultSignatureAlgorithm', '0c806647-a11c-403d-af39-092523465ca0', 'RS256');
INSERT INTO mim.realm_attribute VALUES ('offlineSessionMaxLifespanEnabled', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO mim.realm_attribute VALUES ('offlineSessionMaxLifespan', '0c806647-a11c-403d-af39-092523465ca0', '5184000');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.contentSecurityPolicyReportOnly', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xContentTypeOptions', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'nosniff');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.referrerPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'no-referrer');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xRobotsTag', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'none');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.xFrameOptions', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'SAMEORIGIN');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.contentSecurityPolicy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'frame-src ''self''; frame-ancestors ''self''; object-src ''none'';');
INSERT INTO mim.realm_attribute VALUES ('_browser_header.strictTransportSecurity', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'max-age=31536000; includeSubDomains');
INSERT INTO mim.realm_attribute VALUES ('bruteForceProtected', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('permanentLockout', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('maxTemporaryLockouts', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('bruteForceStrategy', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'MULTIPLE');
INSERT INTO mim.realm_attribute VALUES ('maxFailureWaitSeconds', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '900');
INSERT INTO mim.realm_attribute VALUES ('minimumQuickLoginWaitSeconds', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '60');
INSERT INTO mim.realm_attribute VALUES ('waitIncrementSeconds', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '60');
INSERT INTO mim.realm_attribute VALUES ('quickLoginCheckMilliSeconds', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '1000');
INSERT INTO mim.realm_attribute VALUES ('maxDeltaTimeSeconds', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '43200');
INSERT INTO mim.realm_attribute VALUES ('failureFactor', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '30');
INSERT INTO mim.realm_attribute VALUES ('realmReusableOtpCode', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('defaultSignatureAlgorithm', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'RS256');
INSERT INTO mim.realm_attribute VALUES ('offlineSessionMaxLifespanEnabled', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('offlineSessionMaxLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5184000');
INSERT INTO mim.realm_attribute VALUES ('actionTokenGeneratedByAdminLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '43200');
INSERT INTO mim.realm_attribute VALUES ('actionTokenGeneratedByUserLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '300');
INSERT INTO mim.realm_attribute VALUES ('oauth2DeviceCodeLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '600');
INSERT INTO mim.realm_attribute VALUES ('oauth2DevicePollingInterval', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRpEntityName', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'keycloak');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicySignatureAlgorithms', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ES256,RS256');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRpId', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAttestationConveyancePreference', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAuthenticatorAttachment', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRequireResidentKey', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyUserVerificationRequirement', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyCreateTimeout', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAvoidSameAuthenticatorRegister', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRpEntityNamePasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'keycloak');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicySignatureAlgorithmsPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'ES256,RS256');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRpIdPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAttestationConveyancePreferencePasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAuthenticatorAttachmentPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyRequireResidentKeyPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyUserVerificationRequirementPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'not specified');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyCreateTimeoutPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('cibaBackchannelTokenDeliveryMode', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'poll');
INSERT INTO mim.realm_attribute VALUES ('cibaExpiresIn', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '120');
INSERT INTO mim.realm_attribute VALUES ('cibaInterval', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '5');
INSERT INTO mim.realm_attribute VALUES ('cibaAuthRequestedUserHint', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'login_hint');
INSERT INTO mim.realm_attribute VALUES ('parRequestUriLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '60');
INSERT INTO mim.realm_attribute VALUES ('firstBrokerLoginFlowId', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '9e3d118c-ff59-496b-97c0-ff2a4124b8dc');
INSERT INTO mim.realm_attribute VALUES ('organizationsEnabled', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('adminPermissionsEnabled', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('verifiableCredentialsEnabled', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'false');
INSERT INTO mim.realm_attribute VALUES ('clientSessionIdleTimeout', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('clientSessionMaxLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('clientOfflineSessionIdleTimeout', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('clientOfflineSessionMaxLifespan', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '0');
INSERT INTO mim.realm_attribute VALUES ('client-policies.profiles', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '{"profiles":[]}');
INSERT INTO mim.realm_attribute VALUES ('client-policies.policies', '55a761d8-e85b-4c2b-a052-3486ea3375b6', '{"policies":[]}');


--
-- TOC entry 5494 (class 0 OID 19139)
-- Dependencies: 489
-- Data for Name: realm_default_groups; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5495 (class 0 OID 19142)
-- Dependencies: 490
-- Data for Name: realm_enabled_event_types; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5496 (class 0 OID 19145)
-- Dependencies: 491
-- Data for Name: realm_events_listeners; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.realm_events_listeners VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'jboss-logging');
INSERT INTO mim.realm_events_listeners VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'jboss-logging');


--
-- TOC entry 5497 (class 0 OID 19148)
-- Dependencies: 492
-- Data for Name: realm_localizations; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5498 (class 0 OID 19153)
-- Dependencies: 493
-- Data for Name: realm_required_credential; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.realm_required_credential VALUES ('password', 'password', true, true, '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO mim.realm_required_credential VALUES ('password', 'password', true, true, '55a761d8-e85b-4c2b-a052-3486ea3375b6');


--
-- TOC entry 5499 (class 0 OID 19160)
-- Dependencies: 494
-- Data for Name: realm_smtp_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5500 (class 0 OID 19165)
-- Dependencies: 495
-- Data for Name: realm_supported_locales; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.realm_supported_locales VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'en');
INSERT INTO mim.realm_supported_locales VALUES ('55a761d8-e85b-4c2b-a052-3486ea3375b6', 'it');


--
-- TOC entry 5501 (class 0 OID 19168)
-- Dependencies: 496
-- Data for Name: redirect_uris; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.redirect_uris VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '/realms/master/account/*');
INSERT INTO mim.redirect_uris VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '/realms/master/account/*');
INSERT INTO mim.redirect_uris VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '/admin/master/console/*');
INSERT INTO mim.redirect_uris VALUES ('160d4371-67af-4845-946e-f81f48ba3e42', '/realms/atlantica/account/*');
INSERT INTO mim.redirect_uris VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '/realms/atlantica/account/*');
INSERT INTO mim.redirect_uris VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '/admin/atlantica/console/*');
INSERT INTO mim.redirect_uris VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'http://localhost:4200/*');


--
-- TOC entry 5502 (class 0 OID 19171)
-- Dependencies: 497
-- Data for Name: required_action_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5503 (class 0 OID 19176)
-- Dependencies: 498
-- Data for Name: required_action_provider; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.required_action_provider VALUES ('39a5c391-d663-4b2a-a75c-d49197b08a2f', 'VERIFY_EMAIL', 'Verify Email', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'VERIFY_EMAIL', 50);
INSERT INTO mim.required_action_provider VALUES ('1319da51-7ce1-4394-8827-67d2bca51e72', 'UPDATE_PROFILE', 'Update Profile', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_PROFILE', 40);
INSERT INTO mim.required_action_provider VALUES ('e5683f92-48c2-4406-8182-d4f742ebc3f1', 'CONFIGURE_TOTP', 'Configure OTP', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'CONFIGURE_TOTP', 10);
INSERT INTO mim.required_action_provider VALUES ('7734f807-fb74-449d-8c93-4ee189700e73', 'UPDATE_PASSWORD', 'Update Password', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_PASSWORD', 30);
INSERT INTO mim.required_action_provider VALUES ('e8e51948-9b9c-4917-955f-deb2cbe5a806', 'TERMS_AND_CONDITIONS', 'Terms and Conditions', '0c806647-a11c-403d-af39-092523465ca0', false, false, 'TERMS_AND_CONDITIONS', 20);
INSERT INTO mim.required_action_provider VALUES ('0e2649ed-2a8b-4c77-b880-959212429dc1', 'delete_account', 'Delete Account', '0c806647-a11c-403d-af39-092523465ca0', false, false, 'delete_account', 60);
INSERT INTO mim.required_action_provider VALUES ('2a9f3cdc-4262-4fa3-97e8-a80636ad5b22', 'delete_credential', 'Delete Credential', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'delete_credential', 100);
INSERT INTO mim.required_action_provider VALUES ('dba3aaa5-bc22-454a-9440-c7ba2d0c171a', 'update_user_locale', 'Update User Locale', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'update_user_locale', 1000);
INSERT INTO mim.required_action_provider VALUES ('4e4a7a9e-7599-4f7e-b25d-6ca2d18a3a2c', 'UPDATE_EMAIL', 'Update Email', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_EMAIL', 70);
INSERT INTO mim.required_action_provider VALUES ('db12f199-6bfa-4d14-95e5-b3e398f0f91d', 'CONFIGURE_RECOVERY_AUTHN_CODES', 'Recovery Authentication Codes', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'CONFIGURE_RECOVERY_AUTHN_CODES', 120);
INSERT INTO mim.required_action_provider VALUES ('f71ec915-ff49-4e0d-b525-f913e1adf6d3', 'webauthn-register', 'Webauthn Register', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'webauthn-register', 70);
INSERT INTO mim.required_action_provider VALUES ('5036b5d0-bb51-424c-bac7-46e8b1b4f5db', 'webauthn-register-passwordless', 'Webauthn Register Passwordless', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'webauthn-register-passwordless', 80);
INSERT INTO mim.required_action_provider VALUES ('3c669ec7-e014-4458-9472-38cbeb8c0b9a', 'VERIFY_PROFILE', 'Verify Profile', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'VERIFY_PROFILE', 90);
INSERT INTO mim.required_action_provider VALUES ('b4088556-16bc-47b9-8484-a764da1a6a3b', 'idp_link', 'Linking Identity Provider', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'idp_link', 110);
INSERT INTO mim.required_action_provider VALUES ('3e8421a1-ddd2-4237-8a32-671ad0cf0daa', 'VERIFY_EMAIL', 'Verify Email', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'VERIFY_EMAIL', 50);
INSERT INTO mim.required_action_provider VALUES ('d8455d11-118b-400e-97dd-9efdc4857a5a', 'UPDATE_PROFILE', 'Update Profile', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'UPDATE_PROFILE', 40);
INSERT INTO mim.required_action_provider VALUES ('e82dbdf1-f524-4c99-b502-a64173615b32', 'CONFIGURE_TOTP', 'Configure OTP', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'CONFIGURE_TOTP', 10);
INSERT INTO mim.required_action_provider VALUES ('996c5641-20cd-4314-88ec-281599cb333c', 'UPDATE_PASSWORD', 'Update Password', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'UPDATE_PASSWORD', 30);
INSERT INTO mim.required_action_provider VALUES ('5563dd18-e5a0-46bf-a3e3-08968efe79c9', 'TERMS_AND_CONDITIONS', 'Terms and Conditions', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, false, 'TERMS_AND_CONDITIONS', 20);
INSERT INTO mim.required_action_provider VALUES ('7491eaee-ddcb-40e8-9986-41abf58ab4a5', 'delete_account', 'Delete Account', '55a761d8-e85b-4c2b-a052-3486ea3375b6', false, false, 'delete_account', 60);
INSERT INTO mim.required_action_provider VALUES ('bf0bffef-bce7-4120-8e95-ec19091e4d4c', 'delete_credential', 'Delete Credential', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'delete_credential', 100);
INSERT INTO mim.required_action_provider VALUES ('217471d3-21f9-4a0c-a7a2-befbcbcdec7b', 'update_user_locale', 'Update User Locale', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'update_user_locale', 1000);
INSERT INTO mim.required_action_provider VALUES ('19d939bf-8f28-4233-9658-41446920e9c1', 'UPDATE_EMAIL', 'Update Email', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'UPDATE_EMAIL', 70);
INSERT INTO mim.required_action_provider VALUES ('d80b52f5-235d-4977-af7c-312d3b4b5221', 'CONFIGURE_RECOVERY_AUTHN_CODES', 'Recovery Authentication Codes', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'CONFIGURE_RECOVERY_AUTHN_CODES', 120);
INSERT INTO mim.required_action_provider VALUES ('82b6cc01-d5b2-4e6c-9183-6d30d9b81629', 'webauthn-register', 'Webauthn Register', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'webauthn-register', 70);
INSERT INTO mim.required_action_provider VALUES ('caa1b6e0-ced3-49a2-82bc-20274b083889', 'webauthn-register-passwordless', 'Webauthn Register Passwordless', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'webauthn-register-passwordless', 80);
INSERT INTO mim.required_action_provider VALUES ('96d5019e-e330-4f14-a842-2e21f21be181', 'VERIFY_PROFILE', 'Verify Profile', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'VERIFY_PROFILE', 90);
INSERT INTO mim.required_action_provider VALUES ('b8c5789d-f98f-460a-827f-addef72d8396', 'idp_link', 'Linking Identity Provider', '55a761d8-e85b-4c2b-a052-3486ea3375b6', true, false, 'idp_link', 110);


--
-- TOC entry 5504 (class 0 OID 19183)
-- Dependencies: 499
-- Data for Name: resource_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5505 (class 0 OID 19189)
-- Dependencies: 500
-- Data for Name: resource_policy; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5506 (class 0 OID 19192)
-- Dependencies: 501
-- Data for Name: resource_scope; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5507 (class 0 OID 19195)
-- Dependencies: 502
-- Data for Name: resource_server; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5508 (class 0 OID 19200)
-- Dependencies: 503
-- Data for Name: resource_server_perm_ticket; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5509 (class 0 OID 19205)
-- Dependencies: 504
-- Data for Name: resource_server_policy; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5510 (class 0 OID 19210)
-- Dependencies: 505
-- Data for Name: resource_server_resource; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5511 (class 0 OID 19216)
-- Dependencies: 506
-- Data for Name: resource_server_scope; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5512 (class 0 OID 19221)
-- Dependencies: 507
-- Data for Name: resource_uris; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5513 (class 0 OID 19224)
-- Dependencies: 508
-- Data for Name: revoked_token; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5514 (class 0 OID 19227)
-- Dependencies: 509
-- Data for Name: role_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5515 (class 0 OID 19232)
-- Dependencies: 510
-- Data for Name: scope_mapping; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.scope_mapping VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');
INSERT INTO mim.scope_mapping VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d');
INSERT INTO mim.scope_mapping VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '53004a4e-b443-4cb9-af6f-a3d4725a933c');
INSERT INTO mim.scope_mapping VALUES ('183a8995-5173-4495-a4bf-4620abe38771', '2c82bdc0-f988-446d-ac7a-7e5ae13d93c2');


--
-- TOC entry 5516 (class 0 OID 19235)
-- Dependencies: 511
-- Data for Name: scope_policy; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5517 (class 0 OID 19238)
-- Dependencies: 512
-- Data for Name: server_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5518 (class 0 OID 19244)
-- Dependencies: 513
-- Data for Name: user_attribute; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.user_attribute VALUES ('locale', 'it', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f', 'b41235ce-4348-4bb9-b833-5588440ec426', NULL, NULL, NULL);
INSERT INTO mim.user_attribute VALUES ('locale', 'it', 'b813f8c8-a0bf-4df9-af10-ceccc2733e43', '94030495-e5e4-4920-ae69-94dd57b71050', NULL, NULL, NULL);


--
-- TOC entry 5519 (class 0 OID 19250)
-- Dependencies: 514
-- Data for Name: user_consent; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5520 (class 0 OID 19255)
-- Dependencies: 515
-- Data for Name: user_consent_client_scope; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5480 (class 0 OID 19033)
-- Dependencies: 474
-- Data for Name: user_entity; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.user_entity VALUES ('679d8ad7-2047-41eb-b88e-bad459ccdc81', NULL, '18392ca1-be8f-4338-83ac-8747a92aba03', false, true, NULL, NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'admin', 1760965845490, NULL, 0);
INSERT INTO mim.user_entity VALUES ('06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f', NULL, 'a362a394-004d-4206-98ed-d4e2314c819a', false, true, NULL, 'admin', 'Non Cancellarmi', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'admin', 1760963192756, NULL, 0);
INSERT INTO mim.user_entity VALUES ('b813f8c8-a0bf-4df9-af10-ceccc2733e43', 'test@gmail.com', 'test@gmail.com', false, true, NULL, 'test', 'test', '55a761d8-e85b-4c2b-a052-3486ea3375b6', 'test', 1760965819307, NULL, 0);


--
-- TOC entry 5521 (class 0 OID 19258)
-- Dependencies: 516
-- Data for Name: user_federation_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5522 (class 0 OID 19263)
-- Dependencies: 517
-- Data for Name: user_federation_mapper; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5523 (class 0 OID 19268)
-- Dependencies: 518
-- Data for Name: user_federation_mapper_config; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5524 (class 0 OID 19273)
-- Dependencies: 519
-- Data for Name: user_federation_provider; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5481 (class 0 OID 19041)
-- Dependencies: 475
-- Data for Name: user_group_membership; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.user_group_membership VALUES ('4bc1ba62-5d4f-4fb3-b1e4-df00192977c3', 'b813f8c8-a0bf-4df9-af10-ceccc2733e43', 'UNMANAGED');


--
-- TOC entry 5525 (class 0 OID 19278)
-- Dependencies: 520
-- Data for Name: user_required_action; Type: TABLE DATA; Schema: mim; Owner: -
--



--
-- TOC entry 5526 (class 0 OID 19282)
-- Dependencies: 521
-- Data for Name: user_role_mapping; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.user_role_mapping VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('6f5e377f-9be5-4915-874c-da7284b6111a', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('c8743249-05ea-4178-888f-5933c41ada6c', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('12b4b4c0-ceca-48ee-86f2-27fe90505a2c', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('4f3f02d4-5fa5-42e4-b343-662782da3788', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('2b5aef57-58f4-43c6-84d0-3d2657eb7002', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('f521e451-2789-41a8-834c-a2ad8cf2dbe2', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('60cafdb3-3d6c-48c1-9e77-172daf242bea', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('b781240c-1437-41e2-9953-f973d3124a31', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('53004a4e-b443-4cb9-af6f-a3d4725a933c', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('db79ad00-8089-44bc-ab11-93f0a595bfb5', 'b813f8c8-a0bf-4df9-af10-ceccc2733e43');
INSERT INTO mim.user_role_mapping VALUES ('393c8228-dabe-4927-bec5-d62e0f372af9', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('46d4c4c6-ab10-47b3-9665-43d3f44aaa63', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('d5ff873d-5bc6-444c-89db-b2a7573008ca', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('bd5731c3-d8e2-4830-b512-a914de001373', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('8acccd39-bfe1-4075-84d1-23ac852c4535', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('69cf759d-2a1d-4854-869f-813c20c139f2', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('e793b400-1ba3-4b9c-b00e-85de01861d6c', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('a471a901-48ee-443e-90b1-2c70abd516ea', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('c02820af-7da5-4d7e-a152-fa3c90ce554c', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('1cee0901-37bd-4a6d-9803-77b75a697239', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('ef0ea393-fde1-4c82-aaef-508782fb824f', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('2c82bdc0-f988-446d-ac7a-7e5ae13d93c2', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('6f343f84-6a72-435a-8a1b-fc870d7d55f7', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('bcf549e9-6de7-4ba3-a2d7-7864f460fe6a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('dd58dfd2-861f-41eb-9dc8-d956324f9ccd', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('689bf969-bf06-440a-95a4-8429cc400d09', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('214f2782-211b-45cc-acb1-78dc440b10e0', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('4402d0a7-3ad3-42f7-a4b0-6a026144a866', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('0dcf03c2-e7a1-4084-93f0-f4b7d794d193', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('8095b4ff-6f0d-414b-8057-22d5471ad338', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('74e17fab-1b69-4738-b247-f7195ec4775a', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('de6db5ce-a9e9-4f96-94ce-9e234026589a', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('50ea785c-717e-409b-936d-6440e102fbf9', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('ff2f0fac-6b39-4b1f-abb6-0252669895cf', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('04389301-51df-49c0-acb5-e8e5edacb614', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('75bb763a-6fc1-4bfe-8432-da1fc12e5efd', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('c56c1682-22c0-4d14-b41f-af9641674de5', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('6806d196-0d69-427e-b093-e76f9aed4f24', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('92ea89b0-7a1a-4206-9145-ec4f9b63aac4', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('b20809cc-1123-48fc-9338-3dd52921b0da', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('5e45631a-17db-48f8-87dd-278459b02b54', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('42cf16eb-49a0-4793-999c-e78175462c6b', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('6f485a00-8e0c-4172-8b86-fe86925f6dd5', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('a1c9d20c-4d01-4ce4-855e-f61666c9f224', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('8989f5c3-bec9-41d0-bb64-18789690d0a4', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('90da9da7-9cbd-4e08-afe2-b657bdca5ac0', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('325745f8-d041-4e42-8a89-466e404c775b', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('2c9a23ac-4921-404e-99df-1f5a7b85cd7f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('1bf774c0-76b5-43d3-a6ab-580554987f88', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('db3211e4-5b1e-4b1e-8bf9-68caf3f85b4c', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('1384f2ce-8f9b-463d-9282-f1779c5b9de9', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('3d9014ee-1b65-4abc-9066-a08b5ead2d8d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('c75f97d9-a933-4bc8-8101-900df1277a32', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('88f5f86b-d637-4ba4-aaa0-e9cca63f08a7', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('c6cd383c-a00d-432b-b977-f422f07f1606', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('9d914d8b-c9de-429e-8044-3ded177122f9', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('b287f985-f47a-4ca9-8e5a-ca8671801eba', '06d4953c-4dd5-41bc-9a70-eeb42a1e8e4f');
INSERT INTO mim.user_role_mapping VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('6d21a91c-7886-4b8c-8933-7e6f708606fe', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('3a3b68f5-5620-44aa-974f-6b1cf9c2c12a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('73d1e89b-739f-490b-9c20-f6bfc06c629f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('6d901d15-deaa-4571-bdf5-67f46236bcf1', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('c3c8df3d-a2a9-4e04-94d4-73977c885f2f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('d416a33e-2abf-4dc2-b9fa-94a23017e858', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('6c32a60e-78de-4b5a-b19c-69eb7e84ac9a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('966551e2-bdb1-4c42-a1f4-10c85d410db2', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('cf7f6c67-c1ef-459e-83c5-c5a8caed6e4d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('8b4747ac-3706-4047-aa04-503b9f2e3840', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('a5fda10a-f896-4aaa-9478-0c27f050ab25', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('c5fbb5ee-4707-425f-836d-3d833f7c294f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO mim.user_role_mapping VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', '679d8ad7-2047-41eb-b88e-bad459ccdc81');


--
-- TOC entry 5527 (class 0 OID 19285)
-- Dependencies: 522
-- Data for Name: web_origins; Type: TABLE DATA; Schema: mim; Owner: -
--

INSERT INTO mim.web_origins VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '+');
INSERT INTO mim.web_origins VALUES ('e0745322-716b-4b72-8a49-6c0b93644318', '+');
INSERT INTO mim.web_origins VALUES ('74d50ff9-7290-434c-a967-e7144a37e4a5', 'http://localhost:4200');


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 478
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: mim; Owner: -
--

SELECT pg_catalog.setval('mim.menu_items_id_seq', 31, true);


--
-- TOC entry 5079 (class 2606 OID 19289)
-- Name: org_domain ORG_DOMAIN_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.org_domain
    ADD CONSTRAINT "ORG_DOMAIN_pkey" PRIMARY KEY (id, name);


--
-- TOC entry 5071 (class 2606 OID 19291)
-- Name: org ORG_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.org
    ADD CONSTRAINT "ORG_pkey" PRIMARY KEY (id);


--
-- TOC entry 5171 (class 2606 OID 19293)
-- Name: server_config SERVER_CONFIG_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.server_config
    ADD CONSTRAINT "SERVER_CONFIG_pkey" PRIMARY KEY (server_config_key);


--
-- TOC entry 4985 (class 2606 OID 19295)
-- Name: keycloak_role UK_J3RWUVD56ONTGSUHOGM184WW2-2; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.keycloak_role
    ADD CONSTRAINT "UK_J3RWUVD56ONTGSUHOGM184WW2-2" UNIQUE (name, client_realm_constraint);


--
-- TOC entry 4931 (class 2606 OID 19297)
-- Name: client_auth_flow_bindings c_cli_flow_bind; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_auth_flow_bindings
    ADD CONSTRAINT c_cli_flow_bind PRIMARY KEY (client_id, binding_name);


--
-- TOC entry 4946 (class 2606 OID 19299)
-- Name: client_scope_client c_cli_scope_bind; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope_client
    ADD CONSTRAINT c_cli_scope_bind PRIMARY KEY (client_id, scope_id);


--
-- TOC entry 4933 (class 2606 OID 19301)
-- Name: client_initial_access cnstr_client_init_acc_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_initial_access
    ADD CONSTRAINT cnstr_client_init_acc_pk PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 19303)
-- Name: realm_default_groups con_group_id_def_groups; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_default_groups
    ADD CONSTRAINT con_group_id_def_groups UNIQUE (group_id);


--
-- TOC entry 4921 (class 2606 OID 19305)
-- Name: broker_link constr_broker_link_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.broker_link
    ADD CONSTRAINT constr_broker_link_pk PRIMARY KEY (identity_provider, user_id);


--
-- TOC entry 4958 (class 2606 OID 19307)
-- Name: component_config constr_component_config_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.component_config
    ADD CONSTRAINT constr_component_config_pk PRIMARY KEY (id);


--
-- TOC entry 4954 (class 2606 OID 19309)
-- Name: component constr_component_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.component
    ADD CONSTRAINT constr_component_pk PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 19311)
-- Name: fed_user_required_action constr_fed_required_action; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_required_action
    ADD CONSTRAINT constr_fed_required_action PRIMARY KEY (required_action, user_id);


--
-- TOC entry 4994 (class 2606 OID 19313)
-- Name: fed_user_attribute constr_fed_user_attr_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_attribute
    ADD CONSTRAINT constr_fed_user_attr_pk PRIMARY KEY (id);


--
-- TOC entry 4999 (class 2606 OID 19315)
-- Name: fed_user_consent constr_fed_user_consent_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_consent
    ADD CONSTRAINT constr_fed_user_consent_pk PRIMARY KEY (id);


--
-- TOC entry 5006 (class 2606 OID 19317)
-- Name: fed_user_credential constr_fed_user_cred_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_credential
    ADD CONSTRAINT constr_fed_user_cred_pk PRIMARY KEY (id);


--
-- TOC entry 5010 (class 2606 OID 19319)
-- Name: fed_user_group_membership constr_fed_user_group; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_group_membership
    ADD CONSTRAINT constr_fed_user_group PRIMARY KEY (group_id, user_id);


--
-- TOC entry 5018 (class 2606 OID 19321)
-- Name: fed_user_role_mapping constr_fed_user_role; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_role_mapping
    ADD CONSTRAINT constr_fed_user_role PRIMARY KEY (role_id, user_id);


--
-- TOC entry 5026 (class 2606 OID 19323)
-- Name: federated_user constr_federated_user; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.federated_user
    ADD CONSTRAINT constr_federated_user PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 19325)
-- Name: realm_default_groups constr_realm_default_groups; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_default_groups
    ADD CONSTRAINT constr_realm_default_groups PRIMARY KEY (realm_id, group_id);


--
-- TOC entry 5103 (class 2606 OID 19327)
-- Name: realm_enabled_event_types constr_realm_enabl_event_types; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_enabled_event_types
    ADD CONSTRAINT constr_realm_enabl_event_types PRIMARY KEY (realm_id, value);


--
-- TOC entry 5106 (class 2606 OID 19329)
-- Name: realm_events_listeners constr_realm_events_listeners; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_events_listeners
    ADD CONSTRAINT constr_realm_events_listeners PRIMARY KEY (realm_id, value);


--
-- TOC entry 5115 (class 2606 OID 19331)
-- Name: realm_supported_locales constr_realm_supported_locales; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_supported_locales
    ADD CONSTRAINT constr_realm_supported_locales PRIMARY KEY (realm_id, value);


--
-- TOC entry 5028 (class 2606 OID 19333)
-- Name: identity_provider constraint_2b; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider
    ADD CONSTRAINT constraint_2b PRIMARY KEY (internal_id);


--
-- TOC entry 4928 (class 2606 OID 19335)
-- Name: client_attributes constraint_3c; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_attributes
    ADD CONSTRAINT constraint_3c PRIMARY KEY (client_id, name);


--
-- TOC entry 4991 (class 2606 OID 19337)
-- Name: event_entity constraint_4; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.event_entity
    ADD CONSTRAINT constraint_4 PRIMARY KEY (id);


--
-- TOC entry 5022 (class 2606 OID 19339)
-- Name: federated_identity constraint_40; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.federated_identity
    ADD CONSTRAINT constraint_40 PRIMARY KEY (identity_provider, user_id);


--
-- TOC entry 5090 (class 2606 OID 19341)
-- Name: realm constraint_4a; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm
    ADD CONSTRAINT constraint_4a PRIMARY KEY (id);


--
-- TOC entry 5198 (class 2606 OID 19343)
-- Name: user_federation_provider constraint_5c; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_provider
    ADD CONSTRAINT constraint_5c PRIMARY KEY (id);


--
-- TOC entry 4923 (class 2606 OID 19345)
-- Name: client constraint_7; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client
    ADD CONSTRAINT constraint_7 PRIMARY KEY (id);


--
-- TOC entry 5165 (class 2606 OID 19347)
-- Name: scope_mapping constraint_81; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.scope_mapping
    ADD CONSTRAINT constraint_81 PRIMARY KEY (client_id, role_id);


--
-- TOC entry 4936 (class 2606 OID 19349)
-- Name: client_node_registrations constraint_84; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_node_registrations
    ADD CONSTRAINT constraint_84 PRIMARY KEY (client_id, name);


--
-- TOC entry 5095 (class 2606 OID 19351)
-- Name: realm_attribute constraint_9; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_attribute
    ADD CONSTRAINT constraint_9 PRIMARY KEY (name, realm_id);


--
-- TOC entry 5111 (class 2606 OID 19353)
-- Name: realm_required_credential constraint_92; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_required_credential
    ADD CONSTRAINT constraint_92 PRIMARY KEY (realm_id, type);


--
-- TOC entry 4987 (class 2606 OID 19355)
-- Name: keycloak_role constraint_a; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.keycloak_role
    ADD CONSTRAINT constraint_a PRIMARY KEY (id);


--
-- TOC entry 4903 (class 2606 OID 19357)
-- Name: admin_event_entity constraint_admin_event_entity; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.admin_event_entity
    ADD CONSTRAINT constraint_admin_event_entity PRIMARY KEY (id);


--
-- TOC entry 4919 (class 2606 OID 19359)
-- Name: authenticator_config_entry constraint_auth_cfg_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authenticator_config_entry
    ADD CONSTRAINT constraint_auth_cfg_pk PRIMARY KEY (authenticator_id, name);


--
-- TOC entry 4909 (class 2606 OID 19361)
-- Name: authentication_execution constraint_auth_exec_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authentication_execution
    ADD CONSTRAINT constraint_auth_exec_pk PRIMARY KEY (id);


--
-- TOC entry 4913 (class 2606 OID 19363)
-- Name: authentication_flow constraint_auth_flow_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authentication_flow
    ADD CONSTRAINT constraint_auth_flow_pk PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 19365)
-- Name: authenticator_config constraint_auth_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authenticator_config
    ADD CONSTRAINT constraint_auth_pk PRIMARY KEY (id);


--
-- TOC entry 5204 (class 2606 OID 19367)
-- Name: user_role_mapping constraint_c; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_role_mapping
    ADD CONSTRAINT constraint_c PRIMARY KEY (role_id, user_id);


--
-- TOC entry 4961 (class 2606 OID 19369)
-- Name: composite_role constraint_composite_role; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.composite_role
    ADD CONSTRAINT constraint_composite_role PRIMARY KEY (composite, child_role);


--
-- TOC entry 5035 (class 2606 OID 19371)
-- Name: identity_provider_config constraint_d; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider_config
    ADD CONSTRAINT constraint_d PRIMARY KEY (identity_provider_id, name);


--
-- TOC entry 5082 (class 2606 OID 19373)
-- Name: policy_config constraint_dpc; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.policy_config
    ADD CONSTRAINT constraint_dpc PRIMARY KEY (policy_id, name);


--
-- TOC entry 5113 (class 2606 OID 19375)
-- Name: realm_smtp_config constraint_e; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_smtp_config
    ADD CONSTRAINT constraint_e PRIMARY KEY (realm_id, name);


--
-- TOC entry 4965 (class 2606 OID 19377)
-- Name: credential constraint_f; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.credential
    ADD CONSTRAINT constraint_f PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 19379)
-- Name: user_federation_config constraint_f9; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_config
    ADD CONSTRAINT constraint_f9 PRIMARY KEY (user_federation_provider_id, name);


--
-- TOC entry 5136 (class 2606 OID 19381)
-- Name: resource_server_perm_ticket constraint_fapmt; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT constraint_fapmt PRIMARY KEY (id);


--
-- TOC entry 5147 (class 2606 OID 19383)
-- Name: resource_server_resource constraint_farsr; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_resource
    ADD CONSTRAINT constraint_farsr PRIMARY KEY (id);


--
-- TOC entry 5142 (class 2606 OID 19385)
-- Name: resource_server_policy constraint_farsrp; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_policy
    ADD CONSTRAINT constraint_farsrp PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 19387)
-- Name: associated_policy constraint_farsrpap; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.associated_policy
    ADD CONSTRAINT constraint_farsrpap PRIMARY KEY (policy_id, associated_policy_id);


--
-- TOC entry 5128 (class 2606 OID 19389)
-- Name: resource_policy constraint_farsrpp; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_policy
    ADD CONSTRAINT constraint_farsrpp PRIMARY KEY (resource_id, policy_id);


--
-- TOC entry 5152 (class 2606 OID 19391)
-- Name: resource_server_scope constraint_farsrs; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_scope
    ADD CONSTRAINT constraint_farsrs PRIMARY KEY (id);


--
-- TOC entry 5131 (class 2606 OID 19393)
-- Name: resource_scope constraint_farsrsp; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_scope
    ADD CONSTRAINT constraint_farsrsp PRIMARY KEY (resource_id, scope_id);


--
-- TOC entry 5168 (class 2606 OID 19395)
-- Name: scope_policy constraint_farsrsps; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.scope_policy
    ADD CONSTRAINT constraint_farsrsps PRIMARY KEY (scope_id, policy_id);


--
-- TOC entry 5044 (class 2606 OID 19397)
-- Name: user_entity constraint_fb; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_entity
    ADD CONSTRAINT constraint_fb PRIMARY KEY (id);


--
-- TOC entry 5196 (class 2606 OID 19399)
-- Name: user_federation_mapper_config constraint_fedmapper_cfg_pm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_mapper_config
    ADD CONSTRAINT constraint_fedmapper_cfg_pm PRIMARY KEY (user_federation_mapper_id, name);


--
-- TOC entry 5192 (class 2606 OID 19401)
-- Name: user_federation_mapper constraint_fedmapperpm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_mapper
    ADD CONSTRAINT constraint_fedmapperpm PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 19403)
-- Name: fed_user_consent_cl_scope constraint_fgrntcsnt_clsc_pm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.fed_user_consent_cl_scope
    ADD CONSTRAINT constraint_fgrntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- TOC entry 5186 (class 2606 OID 19405)
-- Name: user_consent_client_scope constraint_grntcsnt_clsc_pm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent_client_scope
    ADD CONSTRAINT constraint_grntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- TOC entry 5179 (class 2606 OID 19407)
-- Name: user_consent constraint_grntcsnt_pm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent
    ADD CONSTRAINT constraint_grntcsnt_pm PRIMARY KEY (id);


--
-- TOC entry 4978 (class 2606 OID 19409)
-- Name: keycloak_group constraint_group; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.keycloak_group
    ADD CONSTRAINT constraint_group PRIMARY KEY (id);


--
-- TOC entry 4974 (class 2606 OID 19411)
-- Name: group_attribute constraint_group_attribute_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.group_attribute
    ADD CONSTRAINT constraint_group_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 4982 (class 2606 OID 19413)
-- Name: group_role_mapping constraint_group_role; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.group_role_mapping
    ADD CONSTRAINT constraint_group_role PRIMARY KEY (role_id, group_id);


--
-- TOC entry 5037 (class 2606 OID 19415)
-- Name: identity_provider_mapper constraint_idpm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider_mapper
    ADD CONSTRAINT constraint_idpm PRIMARY KEY (id);


--
-- TOC entry 5040 (class 2606 OID 19417)
-- Name: idp_mapper_config constraint_idpmconfig; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.idp_mapper_config
    ADD CONSTRAINT constraint_idpmconfig PRIMARY KEY (idp_mapper_id, name);


--
-- TOC entry 5042 (class 2606 OID 19419)
-- Name: jgroups_ping constraint_jgroups_ping; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.jgroups_ping
    ADD CONSTRAINT constraint_jgroups_ping PRIMARY KEY (address);


--
-- TOC entry 5057 (class 2606 OID 19421)
-- Name: migration_model constraint_migmod; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.migration_model
    ADD CONSTRAINT constraint_migmod PRIMARY KEY (id);


--
-- TOC entry 5064 (class 2606 OID 19423)
-- Name: offline_client_session constraint_offl_cl_ses_pk3; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.offline_client_session
    ADD CONSTRAINT constraint_offl_cl_ses_pk3 PRIMARY KEY (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag);


--
-- TOC entry 5066 (class 2606 OID 19425)
-- Name: offline_user_session constraint_offl_us_ses_pk2; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.offline_user_session
    ADD CONSTRAINT constraint_offl_us_ses_pk2 PRIMARY KEY (user_session_id, offline_flag);


--
-- TOC entry 5084 (class 2606 OID 19427)
-- Name: protocol_mapper constraint_pcm; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.protocol_mapper
    ADD CONSTRAINT constraint_pcm PRIMARY KEY (id);


--
-- TOC entry 5088 (class 2606 OID 19429)
-- Name: protocol_mapper_config constraint_pmconfig; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.protocol_mapper_config
    ADD CONSTRAINT constraint_pmconfig PRIMARY KEY (protocol_mapper_id, name);


--
-- TOC entry 5118 (class 2606 OID 19431)
-- Name: redirect_uris constraint_redirect_uris; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.redirect_uris
    ADD CONSTRAINT constraint_redirect_uris PRIMARY KEY (client_id, value);


--
-- TOC entry 5121 (class 2606 OID 19433)
-- Name: required_action_config constraint_req_act_cfg_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.required_action_config
    ADD CONSTRAINT constraint_req_act_cfg_pk PRIMARY KEY (required_action_id, name);


--
-- TOC entry 5123 (class 2606 OID 19435)
-- Name: required_action_provider constraint_req_act_prv_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.required_action_provider
    ADD CONSTRAINT constraint_req_act_prv_pk PRIMARY KEY (id);


--
-- TOC entry 5201 (class 2606 OID 19437)
-- Name: user_required_action constraint_required_action; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_required_action
    ADD CONSTRAINT constraint_required_action PRIMARY KEY (required_action, user_id);


--
-- TOC entry 5157 (class 2606 OID 19439)
-- Name: resource_uris constraint_resour_uris_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_uris
    ADD CONSTRAINT constraint_resour_uris_pk PRIMARY KEY (resource_id, value);


--
-- TOC entry 5162 (class 2606 OID 19441)
-- Name: role_attribute constraint_role_attribute_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.role_attribute
    ADD CONSTRAINT constraint_role_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 5159 (class 2606 OID 19443)
-- Name: revoked_token constraint_rt; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.revoked_token
    ADD CONSTRAINT constraint_rt PRIMARY KEY (id);


--
-- TOC entry 5173 (class 2606 OID 19445)
-- Name: user_attribute constraint_user_attribute_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_attribute
    ADD CONSTRAINT constraint_user_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 5052 (class 2606 OID 19447)
-- Name: user_group_membership constraint_user_group; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_group_membership
    ADD CONSTRAINT constraint_user_group PRIMARY KEY (group_id, user_id);


--
-- TOC entry 5207 (class 2606 OID 19449)
-- Name: web_origins constraint_web_origins; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.web_origins
    ADD CONSTRAINT constraint_web_origins PRIMARY KEY (client_id, value);


--
-- TOC entry 4968 (class 2606 OID 19451)
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- TOC entry 5055 (class 2606 OID 19453)
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 19455)
-- Name: client_scope_attributes pk_cl_tmpl_attr; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope_attributes
    ADD CONSTRAINT pk_cl_tmpl_attr PRIMARY KEY (scope_id, name);


--
-- TOC entry 4939 (class 2606 OID 19457)
-- Name: client_scope pk_cli_template; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope
    ADD CONSTRAINT pk_cli_template PRIMARY KEY (id);


--
-- TOC entry 5134 (class 2606 OID 19459)
-- Name: resource_server pk_resource_server; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server
    ADD CONSTRAINT pk_resource_server PRIMARY KEY (id);


--
-- TOC entry 4952 (class 2606 OID 19461)
-- Name: client_scope_role_mapping pk_template_scope; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope_role_mapping
    ADD CONSTRAINT pk_template_scope PRIMARY KEY (scope_id, role_id);


--
-- TOC entry 4972 (class 2606 OID 19463)
-- Name: default_client_scope r_def_cli_scope_bind; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.default_client_scope
    ADD CONSTRAINT r_def_cli_scope_bind PRIMARY KEY (realm_id, scope_id);


--
-- TOC entry 5109 (class 2606 OID 19465)
-- Name: realm_localizations realm_localizations_pkey; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_localizations
    ADD CONSTRAINT realm_localizations_pkey PRIMARY KEY (realm_id, locale);


--
-- TOC entry 5126 (class 2606 OID 19467)
-- Name: resource_attribute res_attr_pk; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_attribute
    ADD CONSTRAINT res_attr_pk PRIMARY KEY (id);


--
-- TOC entry 4980 (class 2606 OID 19469)
-- Name: keycloak_group sibling_names; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.keycloak_group
    ADD CONSTRAINT sibling_names UNIQUE (realm_id, parent_group, name);


--
-- TOC entry 5033 (class 2606 OID 19471)
-- Name: identity_provider uk_2daelwnibji49avxsrtuf6xj33; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider
    ADD CONSTRAINT uk_2daelwnibji49avxsrtuf6xj33 UNIQUE (provider_alias, realm_id);


--
-- TOC entry 4926 (class 2606 OID 19473)
-- Name: client uk_b71cjlbenv945rb6gcon438at; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client
    ADD CONSTRAINT uk_b71cjlbenv945rb6gcon438at UNIQUE (realm_id, client_id);


--
-- TOC entry 4941 (class 2606 OID 19475)
-- Name: client_scope uk_cli_scope; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope
    ADD CONSTRAINT uk_cli_scope UNIQUE (realm_id, name);


--
-- TOC entry 5048 (class 2606 OID 19477)
-- Name: user_entity uk_dykn684sl8up1crfei6eckhd7; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_entity
    ADD CONSTRAINT uk_dykn684sl8up1crfei6eckhd7 UNIQUE (realm_id, email_constraint);


--
-- TOC entry 5182 (class 2606 OID 19479)
-- Name: user_consent uk_external_consent; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent
    ADD CONSTRAINT uk_external_consent UNIQUE (client_storage_provider, external_client_id, user_id);


--
-- TOC entry 5150 (class 2606 OID 19481)
-- Name: resource_server_resource uk_frsr6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_resource
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5ha6 UNIQUE (name, owner, resource_server_id);


--
-- TOC entry 5140 (class 2606 OID 19483)
-- Name: resource_server_perm_ticket uk_frsr6t700s9v50bu18ws5pmt; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5pmt UNIQUE (owner, requester, resource_server_id, resource_id, scope_id);


--
-- TOC entry 5145 (class 2606 OID 19485)
-- Name: resource_server_policy uk_frsrpt700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_policy
    ADD CONSTRAINT uk_frsrpt700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- TOC entry 5155 (class 2606 OID 19487)
-- Name: resource_server_scope uk_frsrst700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_scope
    ADD CONSTRAINT uk_frsrst700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- TOC entry 5184 (class 2606 OID 19489)
-- Name: user_consent uk_local_consent; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent
    ADD CONSTRAINT uk_local_consent UNIQUE (client_id, user_id);


--
-- TOC entry 5060 (class 2606 OID 19491)
-- Name: migration_model uk_migration_update_time; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.migration_model
    ADD CONSTRAINT uk_migration_update_time UNIQUE (update_time);


--
-- TOC entry 5062 (class 2606 OID 19493)
-- Name: migration_model uk_migration_version; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.migration_model
    ADD CONSTRAINT uk_migration_version UNIQUE (version);


--
-- TOC entry 5073 (class 2606 OID 19495)
-- Name: org uk_org_alias; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.org
    ADD CONSTRAINT uk_org_alias UNIQUE (realm_id, alias);


--
-- TOC entry 5075 (class 2606 OID 19497)
-- Name: org uk_org_group; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.org
    ADD CONSTRAINT uk_org_group UNIQUE (group_id);


--
-- TOC entry 5077 (class 2606 OID 19499)
-- Name: org uk_org_name; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.org
    ADD CONSTRAINT uk_org_name UNIQUE (realm_id, name);


--
-- TOC entry 5093 (class 2606 OID 19501)
-- Name: realm uk_orvsdmla56612eaefiq6wl5oi; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm
    ADD CONSTRAINT uk_orvsdmla56612eaefiq6wl5oi UNIQUE (name);


--
-- TOC entry 5050 (class 2606 OID 19503)
-- Name: user_entity uk_ru8tt6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_entity
    ADD CONSTRAINT uk_ru8tt6t700s9v50bu18ws5ha6 UNIQUE (realm_id, username);


--
-- TOC entry 4995 (class 1259 OID 19504)
-- Name: fed_user_attr_long_values; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX fed_user_attr_long_values ON mim.fed_user_attribute USING btree (long_value_hash, name);


--
-- TOC entry 4996 (class 1259 OID 19505)
-- Name: fed_user_attr_long_values_lower_case; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX fed_user_attr_long_values_lower_case ON mim.fed_user_attribute USING btree (long_value_hash_lower_case, name);


--
-- TOC entry 4904 (class 1259 OID 19506)
-- Name: idx_admin_event_time; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_admin_event_time ON mim.admin_event_entity USING btree (realm_id, admin_event_time);


--
-- TOC entry 4907 (class 1259 OID 19507)
-- Name: idx_assoc_pol_assoc_pol_id; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_assoc_pol_assoc_pol_id ON mim.associated_policy USING btree (associated_policy_id);


--
-- TOC entry 4917 (class 1259 OID 19508)
-- Name: idx_auth_config_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_auth_config_realm ON mim.authenticator_config USING btree (realm_id);


--
-- TOC entry 4910 (class 1259 OID 19509)
-- Name: idx_auth_exec_flow; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_auth_exec_flow ON mim.authentication_execution USING btree (flow_id);


--
-- TOC entry 4911 (class 1259 OID 19510)
-- Name: idx_auth_exec_realm_flow; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_auth_exec_realm_flow ON mim.authentication_execution USING btree (realm_id, flow_id);


--
-- TOC entry 4914 (class 1259 OID 19511)
-- Name: idx_auth_flow_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_auth_flow_realm ON mim.authentication_flow USING btree (realm_id);


--
-- TOC entry 4947 (class 1259 OID 19512)
-- Name: idx_cl_clscope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_cl_clscope ON mim.client_scope_client USING btree (scope_id);


--
-- TOC entry 4929 (class 1259 OID 19513)
-- Name: idx_client_att_by_name_value; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_client_att_by_name_value ON mim.client_attributes USING btree (name, substr(value, 1, 255));


--
-- TOC entry 4924 (class 1259 OID 19514)
-- Name: idx_client_id; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_client_id ON mim.client USING btree (client_id);


--
-- TOC entry 4934 (class 1259 OID 19515)
-- Name: idx_client_init_acc_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_client_init_acc_realm ON mim.client_initial_access USING btree (realm_id);


--
-- TOC entry 4942 (class 1259 OID 19516)
-- Name: idx_clscope_attrs; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_clscope_attrs ON mim.client_scope_attributes USING btree (scope_id);


--
-- TOC entry 4948 (class 1259 OID 19517)
-- Name: idx_clscope_cl; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_clscope_cl ON mim.client_scope_client USING btree (client_id);


--
-- TOC entry 5085 (class 1259 OID 19518)
-- Name: idx_clscope_protmap; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_clscope_protmap ON mim.protocol_mapper USING btree (client_scope_id);


--
-- TOC entry 4949 (class 1259 OID 19519)
-- Name: idx_clscope_role; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_clscope_role ON mim.client_scope_role_mapping USING btree (scope_id);


--
-- TOC entry 4959 (class 1259 OID 19520)
-- Name: idx_compo_config_compo; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_compo_config_compo ON mim.component_config USING btree (component_id);


--
-- TOC entry 4955 (class 1259 OID 19521)
-- Name: idx_component_provider_type; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_component_provider_type ON mim.component USING btree (provider_type);


--
-- TOC entry 4956 (class 1259 OID 19522)
-- Name: idx_component_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_component_realm ON mim.component USING btree (realm_id);


--
-- TOC entry 4962 (class 1259 OID 19523)
-- Name: idx_composite; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_composite ON mim.composite_role USING btree (composite);


--
-- TOC entry 4963 (class 1259 OID 19524)
-- Name: idx_composite_child; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_composite_child ON mim.composite_role USING btree (child_role);


--
-- TOC entry 4969 (class 1259 OID 19525)
-- Name: idx_defcls_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_defcls_realm ON mim.default_client_scope USING btree (realm_id);


--
-- TOC entry 4970 (class 1259 OID 19526)
-- Name: idx_defcls_scope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_defcls_scope ON mim.default_client_scope USING btree (scope_id);


--
-- TOC entry 4992 (class 1259 OID 19527)
-- Name: idx_event_time; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_event_time ON mim.event_entity USING btree (realm_id, event_time);


--
-- TOC entry 5023 (class 1259 OID 19528)
-- Name: idx_fedidentity_feduser; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fedidentity_feduser ON mim.federated_identity USING btree (federated_user_id);


--
-- TOC entry 5024 (class 1259 OID 19529)
-- Name: idx_fedidentity_user; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fedidentity_user ON mim.federated_identity USING btree (user_id);


--
-- TOC entry 4997 (class 1259 OID 19530)
-- Name: idx_fu_attribute; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_attribute ON mim.fed_user_attribute USING btree (user_id, realm_id, name);


--
-- TOC entry 5000 (class 1259 OID 19531)
-- Name: idx_fu_cnsnt_ext; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_cnsnt_ext ON mim.fed_user_consent USING btree (user_id, client_storage_provider, external_client_id);


--
-- TOC entry 5001 (class 1259 OID 19532)
-- Name: idx_fu_consent; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_consent ON mim.fed_user_consent USING btree (user_id, client_id);


--
-- TOC entry 5002 (class 1259 OID 19533)
-- Name: idx_fu_consent_ru; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_consent_ru ON mim.fed_user_consent USING btree (realm_id, user_id);


--
-- TOC entry 5007 (class 1259 OID 19534)
-- Name: idx_fu_credential; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_credential ON mim.fed_user_credential USING btree (user_id, type);


--
-- TOC entry 5008 (class 1259 OID 19535)
-- Name: idx_fu_credential_ru; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_credential_ru ON mim.fed_user_credential USING btree (realm_id, user_id);


--
-- TOC entry 5011 (class 1259 OID 19536)
-- Name: idx_fu_group_membership; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_group_membership ON mim.fed_user_group_membership USING btree (user_id, group_id);


--
-- TOC entry 5012 (class 1259 OID 19537)
-- Name: idx_fu_group_membership_ru; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_group_membership_ru ON mim.fed_user_group_membership USING btree (realm_id, user_id);


--
-- TOC entry 5015 (class 1259 OID 19538)
-- Name: idx_fu_required_action; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_required_action ON mim.fed_user_required_action USING btree (user_id, required_action);


--
-- TOC entry 5016 (class 1259 OID 19539)
-- Name: idx_fu_required_action_ru; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_required_action_ru ON mim.fed_user_required_action USING btree (realm_id, user_id);


--
-- TOC entry 5019 (class 1259 OID 19540)
-- Name: idx_fu_role_mapping; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_role_mapping ON mim.fed_user_role_mapping USING btree (user_id, role_id);


--
-- TOC entry 5020 (class 1259 OID 19541)
-- Name: idx_fu_role_mapping_ru; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_fu_role_mapping_ru ON mim.fed_user_role_mapping USING btree (realm_id, user_id);


--
-- TOC entry 4975 (class 1259 OID 19542)
-- Name: idx_group_att_by_name_value; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_group_att_by_name_value ON mim.group_attribute USING btree (name, ((value)::character varying(250)));


--
-- TOC entry 4976 (class 1259 OID 19543)
-- Name: idx_group_attr_group; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_group_attr_group ON mim.group_attribute USING btree (group_id);


--
-- TOC entry 4983 (class 1259 OID 19544)
-- Name: idx_group_role_mapp_group; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_group_role_mapp_group ON mim.group_role_mapping USING btree (group_id);


--
-- TOC entry 5038 (class 1259 OID 19545)
-- Name: idx_id_prov_mapp_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_id_prov_mapp_realm ON mim.identity_provider_mapper USING btree (realm_id);


--
-- TOC entry 5029 (class 1259 OID 19546)
-- Name: idx_ident_prov_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_ident_prov_realm ON mim.identity_provider USING btree (realm_id);


--
-- TOC entry 5030 (class 1259 OID 19547)
-- Name: idx_idp_for_login; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_idp_for_login ON mim.identity_provider USING btree (realm_id, enabled, link_only, hide_on_login, organization_id);


--
-- TOC entry 5031 (class 1259 OID 19548)
-- Name: idx_idp_realm_org; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_idp_realm_org ON mim.identity_provider USING btree (realm_id, organization_id);


--
-- TOC entry 4988 (class 1259 OID 19549)
-- Name: idx_keycloak_role_client; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_keycloak_role_client ON mim.keycloak_role USING btree (client);


--
-- TOC entry 4989 (class 1259 OID 19550)
-- Name: idx_keycloak_role_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_keycloak_role_realm ON mim.keycloak_role USING btree (realm);


--
-- TOC entry 5067 (class 1259 OID 19551)
-- Name: idx_offline_uss_by_broker_session_id; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_offline_uss_by_broker_session_id ON mim.offline_user_session USING btree (broker_session_id, realm_id);


--
-- TOC entry 5068 (class 1259 OID 19552)
-- Name: idx_offline_uss_by_last_session_refresh; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_offline_uss_by_last_session_refresh ON mim.offline_user_session USING btree (realm_id, offline_flag, last_session_refresh);


--
-- TOC entry 5069 (class 1259 OID 19553)
-- Name: idx_offline_uss_by_user; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_offline_uss_by_user ON mim.offline_user_session USING btree (user_id, realm_id, offline_flag);


--
-- TOC entry 5080 (class 1259 OID 19554)
-- Name: idx_org_domain_org_id; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_org_domain_org_id ON mim.org_domain USING btree (org_id);


--
-- TOC entry 5137 (class 1259 OID 19555)
-- Name: idx_perm_ticket_owner; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_perm_ticket_owner ON mim.resource_server_perm_ticket USING btree (owner);


--
-- TOC entry 5138 (class 1259 OID 19556)
-- Name: idx_perm_ticket_requester; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_perm_ticket_requester ON mim.resource_server_perm_ticket USING btree (requester);


--
-- TOC entry 5086 (class 1259 OID 19557)
-- Name: idx_protocol_mapper_client; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_protocol_mapper_client ON mim.protocol_mapper USING btree (client_id);


--
-- TOC entry 5096 (class 1259 OID 19558)
-- Name: idx_realm_attr_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_attr_realm ON mim.realm_attribute USING btree (realm_id);


--
-- TOC entry 4937 (class 1259 OID 19559)
-- Name: idx_realm_clscope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_clscope ON mim.client_scope USING btree (realm_id);


--
-- TOC entry 5101 (class 1259 OID 19560)
-- Name: idx_realm_def_grp_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_def_grp_realm ON mim.realm_default_groups USING btree (realm_id);


--
-- TOC entry 5107 (class 1259 OID 19561)
-- Name: idx_realm_evt_list_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_evt_list_realm ON mim.realm_events_listeners USING btree (realm_id);


--
-- TOC entry 5104 (class 1259 OID 19562)
-- Name: idx_realm_evt_types_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_evt_types_realm ON mim.realm_enabled_event_types USING btree (realm_id);


--
-- TOC entry 5091 (class 1259 OID 19563)
-- Name: idx_realm_master_adm_cli; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_master_adm_cli ON mim.realm USING btree (master_admin_client);


--
-- TOC entry 5116 (class 1259 OID 19564)
-- Name: idx_realm_supp_local_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_realm_supp_local_realm ON mim.realm_supported_locales USING btree (realm_id);


--
-- TOC entry 5119 (class 1259 OID 19565)
-- Name: idx_redir_uri_client; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_redir_uri_client ON mim.redirect_uris USING btree (client_id);


--
-- TOC entry 5124 (class 1259 OID 19566)
-- Name: idx_req_act_prov_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_req_act_prov_realm ON mim.required_action_provider USING btree (realm_id);


--
-- TOC entry 5129 (class 1259 OID 19567)
-- Name: idx_res_policy_policy; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_res_policy_policy ON mim.resource_policy USING btree (policy_id);


--
-- TOC entry 5132 (class 1259 OID 19568)
-- Name: idx_res_scope_scope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_res_scope_scope ON mim.resource_scope USING btree (scope_id);


--
-- TOC entry 5143 (class 1259 OID 19569)
-- Name: idx_res_serv_pol_res_serv; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_res_serv_pol_res_serv ON mim.resource_server_policy USING btree (resource_server_id);


--
-- TOC entry 5148 (class 1259 OID 19570)
-- Name: idx_res_srv_res_res_srv; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_res_srv_res_res_srv ON mim.resource_server_resource USING btree (resource_server_id);


--
-- TOC entry 5153 (class 1259 OID 19571)
-- Name: idx_res_srv_scope_res_srv; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_res_srv_scope_res_srv ON mim.resource_server_scope USING btree (resource_server_id);


--
-- TOC entry 5160 (class 1259 OID 19572)
-- Name: idx_rev_token_on_expire; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_rev_token_on_expire ON mim.revoked_token USING btree (expire);


--
-- TOC entry 5163 (class 1259 OID 19573)
-- Name: idx_role_attribute; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_role_attribute ON mim.role_attribute USING btree (role_id);


--
-- TOC entry 4950 (class 1259 OID 19574)
-- Name: idx_role_clscope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_role_clscope ON mim.client_scope_role_mapping USING btree (role_id);


--
-- TOC entry 5166 (class 1259 OID 19575)
-- Name: idx_scope_mapping_role; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_scope_mapping_role ON mim.scope_mapping USING btree (role_id);


--
-- TOC entry 5169 (class 1259 OID 19576)
-- Name: idx_scope_policy_policy; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_scope_policy_policy ON mim.scope_policy USING btree (policy_id);


--
-- TOC entry 5058 (class 1259 OID 19577)
-- Name: idx_update_time; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_update_time ON mim.migration_model USING btree (update_time);


--
-- TOC entry 5187 (class 1259 OID 19578)
-- Name: idx_usconsent_clscope; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_usconsent_clscope ON mim.user_consent_client_scope USING btree (user_consent_id);


--
-- TOC entry 5188 (class 1259 OID 19579)
-- Name: idx_usconsent_scope_id; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_usconsent_scope_id ON mim.user_consent_client_scope USING btree (scope_id);


--
-- TOC entry 5174 (class 1259 OID 19580)
-- Name: idx_user_attribute; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_attribute ON mim.user_attribute USING btree (user_id);


--
-- TOC entry 5175 (class 1259 OID 19581)
-- Name: idx_user_attribute_name; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_attribute_name ON mim.user_attribute USING btree (name, value);


--
-- TOC entry 5180 (class 1259 OID 19582)
-- Name: idx_user_consent; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_consent ON mim.user_consent USING btree (user_id);


--
-- TOC entry 4966 (class 1259 OID 19583)
-- Name: idx_user_credential; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_credential ON mim.credential USING btree (user_id);


--
-- TOC entry 5045 (class 1259 OID 19584)
-- Name: idx_user_email; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_email ON mim.user_entity USING btree (email);


--
-- TOC entry 5053 (class 1259 OID 19585)
-- Name: idx_user_group_mapping; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_group_mapping ON mim.user_group_membership USING btree (user_id);


--
-- TOC entry 5202 (class 1259 OID 19586)
-- Name: idx_user_reqactions; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_reqactions ON mim.user_required_action USING btree (user_id);


--
-- TOC entry 5205 (class 1259 OID 19587)
-- Name: idx_user_role_mapping; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_role_mapping ON mim.user_role_mapping USING btree (user_id);


--
-- TOC entry 5046 (class 1259 OID 19588)
-- Name: idx_user_service_account; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_user_service_account ON mim.user_entity USING btree (realm_id, service_account_client_link);


--
-- TOC entry 5193 (class 1259 OID 19589)
-- Name: idx_usr_fed_map_fed_prv; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_usr_fed_map_fed_prv ON mim.user_federation_mapper USING btree (federation_provider_id);


--
-- TOC entry 5194 (class 1259 OID 19590)
-- Name: idx_usr_fed_map_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_usr_fed_map_realm ON mim.user_federation_mapper USING btree (realm_id);


--
-- TOC entry 5199 (class 1259 OID 19591)
-- Name: idx_usr_fed_prv_realm; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_usr_fed_prv_realm ON mim.user_federation_provider USING btree (realm_id);


--
-- TOC entry 5208 (class 1259 OID 19592)
-- Name: idx_web_orig_client; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX idx_web_orig_client ON mim.web_origins USING btree (client_id);


--
-- TOC entry 5176 (class 1259 OID 19593)
-- Name: user_attr_long_values; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX user_attr_long_values ON mim.user_attribute USING btree (long_value_hash, name);


--
-- TOC entry 5177 (class 1259 OID 19594)
-- Name: user_attr_long_values_lower_case; Type: INDEX; Schema: mim; Owner: -
--

CREATE INDEX user_attr_long_values_lower_case ON mim.user_attribute USING btree (long_value_hash_lower_case, name);


--
-- TOC entry 5230 (class 2606 OID 19595)
-- Name: identity_provider fk2b4ebc52ae5c3b34; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider
    ADD CONSTRAINT fk2b4ebc52ae5c3b34 FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5215 (class 2606 OID 19600)
-- Name: client_attributes fk3c47c64beacca966; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_attributes
    ADD CONSTRAINT fk3c47c64beacca966 FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5229 (class 2606 OID 19605)
-- Name: federated_identity fk404288b92ef007a6; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.federated_identity
    ADD CONSTRAINT fk404288b92ef007a6 FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5217 (class 2606 OID 19610)
-- Name: client_node_registrations fk4129723ba992f594; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_node_registrations
    ADD CONSTRAINT fk4129723ba992f594 FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5248 (class 2606 OID 19615)
-- Name: redirect_uris fk_1burs8pb4ouj97h5wuppahv9f; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.redirect_uris
    ADD CONSTRAINT fk_1burs8pb4ouj97h5wuppahv9f FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5274 (class 2606 OID 19620)
-- Name: user_federation_provider fk_1fj32f6ptolw2qy60cd8n01e8; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_provider
    ADD CONSTRAINT fk_1fj32f6ptolw2qy60cd8n01e8 FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5245 (class 2606 OID 19625)
-- Name: realm_required_credential fk_5hg65lybevavkqfki3kponh9v; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_required_credential
    ADD CONSTRAINT fk_5hg65lybevavkqfki3kponh9v FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5250 (class 2606 OID 19630)
-- Name: resource_attribute fk_5hrm2vlf9ql5fu022kqepovbr; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu022kqepovbr FOREIGN KEY (resource_id) REFERENCES mim.resource_server_resource(id);


--
-- TOC entry 5267 (class 2606 OID 19635)
-- Name: user_attribute fk_5hrm2vlf9ql5fu043kqepovbr; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu043kqepovbr FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5275 (class 2606 OID 19640)
-- Name: user_required_action fk_6qj3w1jw9cvafhe19bwsiuvmd; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_required_action
    ADD CONSTRAINT fk_6qj3w1jw9cvafhe19bwsiuvmd FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5228 (class 2606 OID 19645)
-- Name: keycloak_role fk_6vyqfe4cn4wlq8r6kt5vdsj5c; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.keycloak_role
    ADD CONSTRAINT fk_6vyqfe4cn4wlq8r6kt5vdsj5c FOREIGN KEY (realm) REFERENCES mim.realm(id);


--
-- TOC entry 5246 (class 2606 OID 19650)
-- Name: realm_smtp_config fk_70ej8xdxgxd0b9hh6180irr0o; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_smtp_config
    ADD CONSTRAINT fk_70ej8xdxgxd0b9hh6180irr0o FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5241 (class 2606 OID 19655)
-- Name: realm_attribute fk_8shxd6l3e9atqukacxgpffptw; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_attribute
    ADD CONSTRAINT fk_8shxd6l3e9atqukacxgpffptw FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5222 (class 2606 OID 19660)
-- Name: composite_role fk_a63wvekftu8jo1pnj81e7mce2; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.composite_role
    ADD CONSTRAINT fk_a63wvekftu8jo1pnj81e7mce2 FOREIGN KEY (composite) REFERENCES mim.keycloak_role(id);


--
-- TOC entry 5211 (class 2606 OID 19665)
-- Name: authentication_execution fk_auth_exec_flow; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authentication_execution
    ADD CONSTRAINT fk_auth_exec_flow FOREIGN KEY (flow_id) REFERENCES mim.authentication_flow(id);


--
-- TOC entry 5212 (class 2606 OID 19670)
-- Name: authentication_execution fk_auth_exec_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authentication_execution
    ADD CONSTRAINT fk_auth_exec_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5213 (class 2606 OID 19675)
-- Name: authentication_flow fk_auth_flow_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authentication_flow
    ADD CONSTRAINT fk_auth_flow_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5214 (class 2606 OID 19680)
-- Name: authenticator_config fk_auth_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.authenticator_config
    ADD CONSTRAINT fk_auth_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5276 (class 2606 OID 19685)
-- Name: user_role_mapping fk_c4fqv34p1mbylloxang7b1q3l; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_role_mapping
    ADD CONSTRAINT fk_c4fqv34p1mbylloxang7b1q3l FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5218 (class 2606 OID 19690)
-- Name: client_scope_attributes fk_cl_scope_attr_scope; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope_attributes
    ADD CONSTRAINT fk_cl_scope_attr_scope FOREIGN KEY (scope_id) REFERENCES mim.client_scope(id);


--
-- TOC entry 5219 (class 2606 OID 19695)
-- Name: client_scope_role_mapping fk_cl_scope_rm_scope; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_scope_role_mapping
    ADD CONSTRAINT fk_cl_scope_rm_scope FOREIGN KEY (scope_id) REFERENCES mim.client_scope(id);


--
-- TOC entry 5238 (class 2606 OID 19700)
-- Name: protocol_mapper fk_cli_scope_mapper; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.protocol_mapper
    ADD CONSTRAINT fk_cli_scope_mapper FOREIGN KEY (client_scope_id) REFERENCES mim.client_scope(id);


--
-- TOC entry 5216 (class 2606 OID 19705)
-- Name: client_initial_access fk_client_init_acc_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.client_initial_access
    ADD CONSTRAINT fk_client_init_acc_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5221 (class 2606 OID 19710)
-- Name: component_config fk_component_config; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.component_config
    ADD CONSTRAINT fk_component_config FOREIGN KEY (component_id) REFERENCES mim.component(id);


--
-- TOC entry 5220 (class 2606 OID 19715)
-- Name: component fk_component_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.component
    ADD CONSTRAINT fk_component_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5242 (class 2606 OID 19720)
-- Name: realm_default_groups fk_def_groups_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_default_groups
    ADD CONSTRAINT fk_def_groups_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5273 (class 2606 OID 19725)
-- Name: user_federation_mapper_config fk_fedmapper_cfg; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_mapper_config
    ADD CONSTRAINT fk_fedmapper_cfg FOREIGN KEY (user_federation_mapper_id) REFERENCES mim.user_federation_mapper(id);


--
-- TOC entry 5271 (class 2606 OID 19730)
-- Name: user_federation_mapper fk_fedmapperpm_fedprv; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_fedprv FOREIGN KEY (federation_provider_id) REFERENCES mim.user_federation_provider(id);


--
-- TOC entry 5272 (class 2606 OID 19735)
-- Name: user_federation_mapper fk_fedmapperpm_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5209 (class 2606 OID 19740)
-- Name: associated_policy fk_frsr5s213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.associated_policy
    ADD CONSTRAINT fk_frsr5s213xcx4wnkog82ssrfy FOREIGN KEY (associated_policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5265 (class 2606 OID 19745)
-- Name: scope_policy fk_frsrasp13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.scope_policy
    ADD CONSTRAINT fk_frsrasp13xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5255 (class 2606 OID 19750)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog82sspmt; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82sspmt FOREIGN KEY (resource_server_id) REFERENCES mim.resource_server(id);


--
-- TOC entry 5260 (class 2606 OID 19755)
-- Name: resource_server_resource fk_frsrho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_resource
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES mim.resource_server(id);


--
-- TOC entry 5256 (class 2606 OID 19760)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog83sspmt; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog83sspmt FOREIGN KEY (resource_id) REFERENCES mim.resource_server_resource(id);


--
-- TOC entry 5257 (class 2606 OID 19765)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog84sspmt; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog84sspmt FOREIGN KEY (scope_id) REFERENCES mim.resource_server_scope(id);


--
-- TOC entry 5210 (class 2606 OID 19770)
-- Name: associated_policy fk_frsrpas14xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.associated_policy
    ADD CONSTRAINT fk_frsrpas14xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5266 (class 2606 OID 19775)
-- Name: scope_policy fk_frsrpass3xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.scope_policy
    ADD CONSTRAINT fk_frsrpass3xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES mim.resource_server_scope(id);


--
-- TOC entry 5258 (class 2606 OID 19780)
-- Name: resource_server_perm_ticket fk_frsrpo2128cx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrpo2128cx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5259 (class 2606 OID 19785)
-- Name: resource_server_policy fk_frsrpo213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_policy
    ADD CONSTRAINT fk_frsrpo213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES mim.resource_server(id);


--
-- TOC entry 5253 (class 2606 OID 19790)
-- Name: resource_scope fk_frsrpos13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_scope
    ADD CONSTRAINT fk_frsrpos13xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES mim.resource_server_resource(id);


--
-- TOC entry 5251 (class 2606 OID 19795)
-- Name: resource_policy fk_frsrpos53xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_policy
    ADD CONSTRAINT fk_frsrpos53xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES mim.resource_server_resource(id);


--
-- TOC entry 5252 (class 2606 OID 19800)
-- Name: resource_policy fk_frsrpp213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_policy
    ADD CONSTRAINT fk_frsrpp213xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5254 (class 2606 OID 19805)
-- Name: resource_scope fk_frsrps213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_scope
    ADD CONSTRAINT fk_frsrps213xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES mim.resource_server_scope(id);


--
-- TOC entry 5261 (class 2606 OID 19810)
-- Name: resource_server_scope fk_frsrso213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_server_scope
    ADD CONSTRAINT fk_frsrso213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES mim.resource_server(id);


--
-- TOC entry 5223 (class 2606 OID 19815)
-- Name: composite_role fk_gr7thllb9lu8q4vqa4524jjy8; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.composite_role
    ADD CONSTRAINT fk_gr7thllb9lu8q4vqa4524jjy8 FOREIGN KEY (child_role) REFERENCES mim.keycloak_role(id);


--
-- TOC entry 5269 (class 2606 OID 19820)
-- Name: user_consent_client_scope fk_grntcsnt_clsc_usc; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent_client_scope
    ADD CONSTRAINT fk_grntcsnt_clsc_usc FOREIGN KEY (user_consent_id) REFERENCES mim.user_consent(id);


--
-- TOC entry 5268 (class 2606 OID 19825)
-- Name: user_consent fk_grntcsnt_user; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_consent
    ADD CONSTRAINT fk_grntcsnt_user FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5226 (class 2606 OID 19830)
-- Name: group_attribute fk_group_attribute_group; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.group_attribute
    ADD CONSTRAINT fk_group_attribute_group FOREIGN KEY (group_id) REFERENCES mim.keycloak_group(id);


--
-- TOC entry 5227 (class 2606 OID 19835)
-- Name: group_role_mapping fk_group_role_group; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.group_role_mapping
    ADD CONSTRAINT fk_group_role_group FOREIGN KEY (group_id) REFERENCES mim.keycloak_group(id);


--
-- TOC entry 5243 (class 2606 OID 19840)
-- Name: realm_enabled_event_types fk_h846o4h0w8epx5nwedrf5y69j; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_enabled_event_types
    ADD CONSTRAINT fk_h846o4h0w8epx5nwedrf5y69j FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5244 (class 2606 OID 19845)
-- Name: realm_events_listeners fk_h846o4h0w8epx5nxev9f5y69j; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_events_listeners
    ADD CONSTRAINT fk_h846o4h0w8epx5nxev9f5y69j FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5232 (class 2606 OID 19850)
-- Name: identity_provider_mapper fk_idpm_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider_mapper
    ADD CONSTRAINT fk_idpm_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5233 (class 2606 OID 19855)
-- Name: idp_mapper_config fk_idpmconfig; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.idp_mapper_config
    ADD CONSTRAINT fk_idpmconfig FOREIGN KEY (idp_mapper_id) REFERENCES mim.identity_provider_mapper(id);


--
-- TOC entry 5277 (class 2606 OID 19860)
-- Name: web_origins fk_lojpho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.web_origins
    ADD CONSTRAINT fk_lojpho213xcx4wnkog82ssrfy FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5264 (class 2606 OID 19865)
-- Name: scope_mapping fk_ouse064plmlr732lxjcn1q5f1; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.scope_mapping
    ADD CONSTRAINT fk_ouse064plmlr732lxjcn1q5f1 FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5239 (class 2606 OID 19870)
-- Name: protocol_mapper fk_pcm_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.protocol_mapper
    ADD CONSTRAINT fk_pcm_realm FOREIGN KEY (client_id) REFERENCES mim.client(id);


--
-- TOC entry 5224 (class 2606 OID 19875)
-- Name: credential fk_pfyr0glasqyl0dei3kl69r6v0; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.credential
    ADD CONSTRAINT fk_pfyr0glasqyl0dei3kl69r6v0 FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5240 (class 2606 OID 19880)
-- Name: protocol_mapper_config fk_pmconfig; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.protocol_mapper_config
    ADD CONSTRAINT fk_pmconfig FOREIGN KEY (protocol_mapper_id) REFERENCES mim.protocol_mapper(id);


--
-- TOC entry 5225 (class 2606 OID 19885)
-- Name: default_client_scope fk_r_def_cli_scope_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.default_client_scope
    ADD CONSTRAINT fk_r_def_cli_scope_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5249 (class 2606 OID 19890)
-- Name: required_action_provider fk_req_act_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.required_action_provider
    ADD CONSTRAINT fk_req_act_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5262 (class 2606 OID 19895)
-- Name: resource_uris fk_resource_server_uris; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.resource_uris
    ADD CONSTRAINT fk_resource_server_uris FOREIGN KEY (resource_id) REFERENCES mim.resource_server_resource(id);


--
-- TOC entry 5263 (class 2606 OID 19900)
-- Name: role_attribute fk_role_attribute_id; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.role_attribute
    ADD CONSTRAINT fk_role_attribute_id FOREIGN KEY (role_id) REFERENCES mim.keycloak_role(id);


--
-- TOC entry 5247 (class 2606 OID 19905)
-- Name: realm_supported_locales fk_supported_locales_realm; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.realm_supported_locales
    ADD CONSTRAINT fk_supported_locales_realm FOREIGN KEY (realm_id) REFERENCES mim.realm(id);


--
-- TOC entry 5270 (class 2606 OID 19910)
-- Name: user_federation_config fk_t13hpu1j94r2ebpekr39x5eu5; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_federation_config
    ADD CONSTRAINT fk_t13hpu1j94r2ebpekr39x5eu5 FOREIGN KEY (user_federation_provider_id) REFERENCES mim.user_federation_provider(id);


--
-- TOC entry 5234 (class 2606 OID 19915)
-- Name: user_group_membership fk_user_group_user; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.user_group_membership
    ADD CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES mim.user_entity(id);


--
-- TOC entry 5237 (class 2606 OID 19920)
-- Name: policy_config fkdc34197cf864c4e43; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.policy_config
    ADD CONSTRAINT fkdc34197cf864c4e43 FOREIGN KEY (policy_id) REFERENCES mim.resource_server_policy(id);


--
-- TOC entry 5231 (class 2606 OID 19925)
-- Name: identity_provider_config fkdc4897cf864c4e43; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.identity_provider_config
    ADD CONSTRAINT fkdc4897cf864c4e43 FOREIGN KEY (identity_provider_id) REFERENCES mim.identity_provider(internal_id);


--
-- TOC entry 5235 (class 2606 OID 19930)
-- Name: menu_items fkdv3wkrnc2guttkjxjbr4ykqke; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.menu_items
    ADD CONSTRAINT fkdv3wkrnc2guttkjxjbr4ykqke FOREIGN KEY (role_id) REFERENCES mim.keycloak_role(id);


--
-- TOC entry 5236 (class 2606 OID 19935)
-- Name: menu_items fkkcxk88u5djnbobanga7hj14q6; Type: FK CONSTRAINT; Schema: mim; Owner: -
--

ALTER TABLE ONLY mim.menu_items
    ADD CONSTRAINT fkkcxk88u5djnbobanga7hj14q6 FOREIGN KEY (parent_id) REFERENCES mim.menu_items(id);


-- Completed on 2025-11-22 23:15:40

--
-- PostgreSQL database dump complete
--

