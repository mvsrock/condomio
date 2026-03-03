--
-- PostgreSQL database dump
--

-- Dumped from database version 17.9 (Debian 17.9-1.pgdg13+1)
-- Dumped by pg_dump version 17.0

-- Started on 2026-03-03 14:36:37

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--DROP DATABASE condomio;
--
-- TOC entry 4349 (class 1262 OID 16384)
-- Name: condomio; Type: DATABASE; Schema: -; Owner: -
--

--CREATE DATABASE condomio WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


\connect condomio

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4350 (class 0 OID 0)
-- Name: condomio; Type: DATABASE PROPERTIES; Schema: -; Owner: -
--

ALTER DATABASE condomio SET search_path TO 'mim', 'public', 'areti_multiservizio';


\connect condomio

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16385)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16386)
-- Name: admin_event_entity; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.admin_event_entity (
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
-- TOC entry 219 (class 1259 OID 16391)
-- Name: associated_policy; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.associated_policy (
    policy_id character varying(36) NOT NULL,
    associated_policy_id character varying(36) NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 16394)
-- Name: authentication_execution; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.authentication_execution (
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
-- TOC entry 221 (class 1259 OID 16398)
-- Name: authentication_flow; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.authentication_flow (
    id character varying(36) NOT NULL,
    alias character varying(255),
    description character varying(255),
    realm_id character varying(36),
    provider_id character varying(36) DEFAULT 'basic-flow'::character varying NOT NULL,
    top_level boolean DEFAULT false NOT NULL,
    built_in boolean DEFAULT false NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 16406)
-- Name: authenticator_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.authenticator_config (
    id character varying(36) NOT NULL,
    alias character varying(255),
    realm_id character varying(36)
);


--
-- TOC entry 223 (class 1259 OID 16409)
-- Name: authenticator_config_entry; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.authenticator_config_entry (
    authenticator_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 16414)
-- Name: broker_link; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.broker_link (
    identity_provider character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL,
    broker_user_id character varying(255),
    broker_username character varying(255),
    token text,
    user_id character varying(255) NOT NULL
);


--
-- TOC entry 225 (class 1259 OID 16419)
-- Name: client; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client (
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
-- TOC entry 226 (class 1259 OID 16437)
-- Name: client_attributes; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_attributes (
    client_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 227 (class 1259 OID 16442)
-- Name: client_auth_flow_bindings; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_auth_flow_bindings (
    client_id character varying(36) NOT NULL,
    flow_id character varying(36),
    binding_name character varying(255) NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 16445)
-- Name: client_initial_access; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_initial_access (
    id character varying(36) NOT NULL,
    realm_id character varying(36) NOT NULL,
    "timestamp" integer,
    expiration integer,
    count integer,
    remaining_count integer
);


--
-- TOC entry 229 (class 1259 OID 16448)
-- Name: client_node_registrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_node_registrations (
    client_id character varying(36) NOT NULL,
    value integer,
    name character varying(255) NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 16451)
-- Name: client_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_scope (
    id character varying(36) NOT NULL,
    name character varying(255),
    realm_id character varying(36),
    description character varying(255),
    protocol character varying(255)
);


--
-- TOC entry 231 (class 1259 OID 16456)
-- Name: client_scope_attributes; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_scope_attributes (
    scope_id character varying(36) NOT NULL,
    value character varying(2048),
    name character varying(255) NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 16461)
-- Name: client_scope_client; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_scope_client (
    client_id character varying(255) NOT NULL,
    scope_id character varying(255) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 16467)
-- Name: client_scope_role_mapping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.client_scope_role_mapping (
    scope_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 16470)
-- Name: component; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.component (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_id character varying(36),
    provider_id character varying(36),
    provider_type character varying(255),
    realm_id character varying(36),
    sub_type character varying(255)
);


--
-- TOC entry 235 (class 1259 OID 16475)
-- Name: component_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.component_config (
    id character varying(36) NOT NULL,
    component_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 236 (class 1259 OID 16480)
-- Name: composite_role; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.composite_role (
    composite character varying(36) NOT NULL,
    child_role character varying(36) NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 16483)
-- Name: credential; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.credential (
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
-- TOC entry 238 (class 1259 OID 16489)
-- Name: databasechangelog; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.databasechangelog (
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
-- TOC entry 239 (class 1259 OID 16494)
-- Name: databasechangeloglock; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


--
-- TOC entry 240 (class 1259 OID 16497)
-- Name: default_client_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.default_client_scope (
    realm_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 16501)
-- Name: group_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.group_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 242 (class 1259 OID 16507)
-- Name: keycloak_group; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.keycloak_group (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_group character varying(36) NOT NULL,
    realm_id character varying(36),
    type integer DEFAULT 0 NOT NULL,
    description character varying(255)
);


--
-- TOC entry 243 (class 1259 OID 16513)
-- Name: distribution_company_view; Type: VIEW; Schema: auth; Owner: -
--

CREATE VIEW auth.distribution_company_view AS
 SELECT id AS group_id,
    name AS group_name,
    ( SELECT ga.value
           FROM auth.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'piva'::text))) AS piva,
    ( SELECT ga.value
           FROM auth.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'company_db_id'::text))) AS company_db_id,
    ( SELECT ga.value
           FROM auth.group_attribute ga
          WHERE (((ga.group_id)::text = (k.id)::text) AND ((ga.name)::text = 'company_name'::text))) AS company_name
   FROM auth.keycloak_group k
  WHERE (NULLIF(TRIM(BOTH FROM parent_group), ''::text) IS NULL);


--
-- TOC entry 244 (class 1259 OID 16517)
-- Name: group_role_mapping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.group_role_mapping (
    role_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 245 (class 1259 OID 16520)
-- Name: keycloak_role; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.keycloak_role (
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
-- TOC entry 246 (class 1259 OID 16526)
-- Name: distribution_to_keycloak_group_view; Type: VIEW; Schema: auth; Owner: -
--

CREATE VIEW auth.distribution_to_keycloak_group_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg_1.id,
            kg_1.name,
            NULLIF((kg_1.parent_group)::text, ' '::text) AS parent_group,
            kg_1.realm_id,
            kg_1.description,
            (kg_1.name)::text AS path
           FROM auth.keycloak_group kg_1
          WHERE ((kg_1.parent_group IS NULL) OR ((kg_1.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            NULLIF((child.parent_group)::text, ' '::text) AS parent_group,
            child.realm_id,
            child.description,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (auth.keycloak_group child
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
   FROM ((((auth.keycloak_group kg
     LEFT JOIN group_path gp ON (((gp.id)::text = (kg.id)::text)))
     LEFT JOIN auth.group_attribute gt ON (((kg.id)::text = (gt.group_id)::text)))
     LEFT JOIN auth.group_role_mapping g ON (((kg.id)::text = (g.group_id)::text)))
     LEFT JOIN auth.keycloak_role k ON (((g.role_id)::text = (k.id)::text)));


--
-- TOC entry 247 (class 1259 OID 16531)
-- Name: event_entity; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.event_entity (
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
-- TOC entry 248 (class 1259 OID 16536)
-- Name: fed_user_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_attribute (
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
-- TOC entry 249 (class 1259 OID 16541)
-- Name: fed_user_consent; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_consent (
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
-- TOC entry 250 (class 1259 OID 16546)
-- Name: fed_user_consent_cl_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_consent_cl_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 251 (class 1259 OID 16549)
-- Name: fed_user_credential; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_credential (
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
-- TOC entry 252 (class 1259 OID 16554)
-- Name: fed_user_group_membership; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 253 (class 1259 OID 16557)
-- Name: fed_user_required_action; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_required_action (
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 254 (class 1259 OID 16563)
-- Name: fed_user_role_mapping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.fed_user_role_mapping (
    role_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


--
-- TOC entry 255 (class 1259 OID 16566)
-- Name: federated_identity; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.federated_identity (
    identity_provider character varying(255) NOT NULL,
    realm_id character varying(36),
    federated_user_id character varying(255),
    federated_username character varying(255),
    token text,
    user_id character varying(36) NOT NULL
);


--
-- TOC entry 256 (class 1259 OID 16571)
-- Name: federated_user; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.federated_user (
    id character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 257 (class 1259 OID 16576)
-- Name: identity_provider; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identity_provider (
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
-- TOC entry 258 (class 1259 OID 16588)
-- Name: identity_provider_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identity_provider_config (
    identity_provider_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 259 (class 1259 OID 16593)
-- Name: identity_provider_mapper; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identity_provider_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    idp_alias character varying(255) NOT NULL,
    idp_mapper_name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 260 (class 1259 OID 16598)
-- Name: idp_mapper_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.idp_mapper_config (
    idp_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 16603)
-- Name: jgroups_ping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.jgroups_ping (
    address character varying(200) NOT NULL,
    name character varying(200),
    cluster_name character varying(200) NOT NULL,
    ip character varying(200) NOT NULL,
    coord boolean
);


--
-- TOC entry 262 (class 1259 OID 16608)
-- Name: keycloak_group_role_summary_view; Type: VIEW; Schema: auth; Owner: -
--

CREATE VIEW auth.keycloak_group_role_summary_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg.id,
            kg.name,
            NULLIF((kg.parent_group)::text, ' '::text) AS parent_group,
            (kg.name)::text AS path
           FROM auth.keycloak_group kg
          WHERE ((kg.parent_group IS NULL) OR ((kg.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            NULLIF((child.parent_group)::text, ' '::text) AS parent_group,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (auth.keycloak_group child
             JOIN group_path gp_1 ON ((NULLIF((child.parent_group)::text, ' '::text) = (gp_1.id)::text)))
        ), group_hierarchy AS (
         SELECT kg.id AS main_group_id,
            kg.name AS main_group_name,
            kg.id AS current_group_id,
            kg.name AS current_group_name,
            0 AS level,
            kg.realm_id
           FROM auth.keycloak_group kg
          WHERE (((kg.parent_group)::text = ' '::text) OR (kg.parent_group IS NULL))
        UNION ALL
         SELECT gh_1.main_group_id,
            gh_1.main_group_name,
            kg.id AS current_group_id,
            kg.name AS current_group_name,
            (gh_1.level + 1) AS level,
            kg.realm_id
           FROM (auth.keycloak_group kg
             JOIN group_hierarchy gh_1 ON (((kg.parent_group)::text = (gh_1.current_group_id)::text)))
        ), roles_aggregated AS (
         SELECT grm.group_id,
            string_agg(DISTINCT (kr.name)::text, ','::text) AS roles,
            string_agg(DISTINCT (kr.id)::text, ','::text) AS role_ids
           FROM (auth.group_role_mapping grm
             JOIN auth.keycloak_role kr ON (((kr.id)::text = (grm.role_id)::text)))
          GROUP BY grm.group_id
        ), attrs_flat AS (
         SELECT gh_1.main_group_id,
            gh_1.current_group_id,
            gh_1.level,
            ga.name,
            ga.value
           FROM (group_hierarchy gh_1
             LEFT JOIN auth.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
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
             LEFT JOIN auth.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
          GROUP BY gh_1.main_group_id
        ), attrs_by_group AS (
         SELECT gh_1.current_group_id AS group_id,
            jsonb_agg(jsonb_build_object('id', ga.id, 'name', ga.name, 'value', ga.value)) FILTER (WHERE (ga.id IS NOT NULL)) AS attributes_current
           FROM (group_hierarchy gh_1
             LEFT JOIN auth.group_attribute ga ON (((ga.group_id)::text = (gh_1.current_group_id)::text)))
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
-- TOC entry 263 (class 1259 OID 16613)
-- Name: keycloak_role_group_summary_view; Type: VIEW; Schema: auth; Owner: -
--

CREATE VIEW auth.keycloak_role_group_summary_view AS
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
   FROM (((auth.keycloak_group kg
     LEFT JOIN auth.keycloak_group parent ON (((kg.parent_group)::text = (parent.id)::text)))
     LEFT JOIN auth.group_role_mapping grm ON (((kg.id)::text = (grm.group_id)::text)))
     RIGHT JOIN auth.keycloak_role kr ON (((grm.role_id)::text = (kr.id)::text)))
  WHERE (kr.client_role IS FALSE)
  GROUP BY kr.id, kr.name, kr.description, kr.realm_id;


--
-- TOC entry 264 (class 1259 OID 16618)
-- Name: user_entity; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_entity (
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
-- TOC entry 265 (class 1259 OID 16626)
-- Name: user_group_membership; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    membership_type character varying(255) NOT NULL
);


--
-- TOC entry 266 (class 1259 OID 16629)
-- Name: keycloak_user_group_view; Type: VIEW; Schema: auth; Owner: -
--

CREATE VIEW auth.keycloak_user_group_view AS
 WITH RECURSIVE group_path AS (
         SELECT kg_1.id,
            kg_1.name,
            kg_1.parent_group,
            (kg_1.name)::text AS path
           FROM auth.keycloak_group kg_1
          WHERE ((kg_1.parent_group IS NULL) OR ((kg_1.parent_group)::text = ' '::text))
        UNION ALL
         SELECT child.id,
            child.name,
            child.parent_group,
            ((gp_1.path || '/'::text) || (child.name)::text) AS path
           FROM (auth.keycloak_group child
             JOIN group_path gp_1 ON (((child.parent_group)::text = (gp_1.id)::text)))
        ), ancestors AS (
         SELECT kg_1.id,
            kg_1.parent_group,
            kg_1.id AS start_id,
            0 AS depth
           FROM auth.keycloak_group kg_1
        UNION ALL
         SELECT parent.id,
            parent.parent_group,
            a.start_id,
            (a.depth + 1)
           FROM (ancestors a
             JOIN auth.keycloak_group parent ON (((parent.id)::text = (a.parent_group)::text)))
        ), company_attr AS (
         SELECT DISTINCT ON (a.start_id) a.start_id,
            ga.value AS distribution_company,
            ga.id AS distribution_company_id,
            a.depth
           FROM (ancestors a
             JOIN auth.group_attribute ga ON ((((ga.group_id)::text = (a.id)::text) AND ((ga.name)::text = 'company_name'::text))))
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
   FROM ((((((auth.user_entity ue
     LEFT JOIN auth.credential c ON (((ue.id)::text = (c.user_id)::text)))
     LEFT JOIN auth.federated_identity f ON (((ue.id)::text = (f.user_id)::text)))
     LEFT JOIN auth.user_group_membership ugm ON (((ue.id)::text = (ugm.user_id)::text)))
     LEFT JOIN auth.keycloak_group kg ON (((ugm.group_id)::text = (kg.id)::text)))
     LEFT JOIN group_path gp ON (((gp.id)::text = (kg.id)::text)))
     LEFT JOIN company_attr ca ON (((ca.start_id)::text = (kg.id)::text)));


--
-- TOC entry 267 (class 1259 OID 16634)
-- Name: menu_items; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.menu_items (
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
-- TOC entry 268 (class 1259 OID 16641)
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

ALTER TABLE auth.menu_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME auth.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 16642)
-- Name: migration_model; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.migration_model (
    id character varying(36) NOT NULL,
    version character varying(36),
    update_time bigint DEFAULT 0 NOT NULL
);


--
-- TOC entry 270 (class 1259 OID 16646)
-- Name: offline_client_session; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.offline_client_session (
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
-- TOC entry 271 (class 1259 OID 16654)
-- Name: offline_user_session; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.offline_user_session (
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
-- TOC entry 272 (class 1259 OID 16661)
-- Name: org; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.org (
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
-- TOC entry 273 (class 1259 OID 16666)
-- Name: org_domain; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.org_domain (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    verified boolean NOT NULL,
    org_id character varying(255) NOT NULL
);


--
-- TOC entry 274 (class 1259 OID 16671)
-- Name: policy_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.policy_config (
    policy_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 275 (class 1259 OID 16676)
-- Name: protocol_mapper; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.protocol_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    protocol character varying(255) NOT NULL,
    protocol_mapper_name character varying(255) NOT NULL,
    client_id character varying(36),
    client_scope_id character varying(36)
);


--
-- TOC entry 276 (class 1259 OID 16681)
-- Name: protocol_mapper_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.protocol_mapper_config (
    protocol_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 277 (class 1259 OID 16686)
-- Name: realm; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm (
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
-- TOC entry 278 (class 1259 OID 16719)
-- Name: realm_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_attribute (
    name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    value text
);


--
-- TOC entry 279 (class 1259 OID 16724)
-- Name: realm_default_groups; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_default_groups (
    realm_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


--
-- TOC entry 280 (class 1259 OID 16727)
-- Name: realm_enabled_event_types; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_enabled_event_types (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 281 (class 1259 OID 16730)
-- Name: realm_events_listeners; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_events_listeners (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 282 (class 1259 OID 16733)
-- Name: realm_localizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_localizations (
    realm_id character varying(255) NOT NULL,
    locale character varying(255) NOT NULL,
    texts text NOT NULL
);


--
-- TOC entry 283 (class 1259 OID 16738)
-- Name: realm_required_credential; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_required_credential (
    type character varying(255) NOT NULL,
    form_label character varying(255),
    input boolean DEFAULT false NOT NULL,
    secret boolean DEFAULT false NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 284 (class 1259 OID 16745)
-- Name: realm_smtp_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_smtp_config (
    realm_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 285 (class 1259 OID 16750)
-- Name: realm_supported_locales; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.realm_supported_locales (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 286 (class 1259 OID 16753)
-- Name: redirect_uris; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.redirect_uris (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 287 (class 1259 OID 16756)
-- Name: required_action_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.required_action_config (
    required_action_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


--
-- TOC entry 288 (class 1259 OID 16761)
-- Name: required_action_provider; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.required_action_provider (
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
-- TOC entry 289 (class 1259 OID 16768)
-- Name: resource_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    resource_id character varying(36) NOT NULL
);


--
-- TOC entry 290 (class 1259 OID 16774)
-- Name: resource_policy; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_policy (
    resource_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


--
-- TOC entry 291 (class 1259 OID 16777)
-- Name: resource_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_scope (
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 292 (class 1259 OID 16780)
-- Name: resource_server; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_server (
    id character varying(36) NOT NULL,
    allow_rs_remote_mgmt boolean DEFAULT false NOT NULL,
    policy_enforce_mode smallint NOT NULL,
    decision_strategy smallint DEFAULT 1 NOT NULL
);


--
-- TOC entry 293 (class 1259 OID 16785)
-- Name: resource_server_perm_ticket; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_server_perm_ticket (
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
-- TOC entry 294 (class 1259 OID 16790)
-- Name: resource_server_policy; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_server_policy (
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
-- TOC entry 295 (class 1259 OID 16795)
-- Name: resource_server_resource; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_server_resource (
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
-- TOC entry 296 (class 1259 OID 16801)
-- Name: resource_server_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_server_scope (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon_uri character varying(255),
    resource_server_id character varying(36) NOT NULL,
    display_name character varying(255)
);


--
-- TOC entry 297 (class 1259 OID 16806)
-- Name: resource_uris; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.resource_uris (
    resource_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 298 (class 1259 OID 16809)
-- Name: revoked_token; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.revoked_token (
    id character varying(255) NOT NULL,
    expire bigint NOT NULL
);


--
-- TOC entry 299 (class 1259 OID 16812)
-- Name: role_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.role_attribute (
    id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255)
);


--
-- TOC entry 300 (class 1259 OID 16817)
-- Name: scope_mapping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scope_mapping (
    client_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


--
-- TOC entry 301 (class 1259 OID 16820)
-- Name: scope_policy; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scope_policy (
    scope_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


--
-- TOC entry 302 (class 1259 OID 16823)
-- Name: server_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.server_config (
    server_config_key character varying(255) NOT NULL,
    value text NOT NULL,
    version integer DEFAULT 0
);


--
-- TOC entry 303 (class 1259 OID 16829)
-- Name: user_attribute; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_attribute (
    name character varying(255) NOT NULL,
    value character varying(255),
    user_id character varying(36) NOT NULL,
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


--
-- TOC entry 304 (class 1259 OID 16835)
-- Name: user_consent; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(36) NOT NULL,
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


--
-- TOC entry 305 (class 1259 OID 16840)
-- Name: user_consent_client_scope; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_consent_client_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


--
-- TOC entry 306 (class 1259 OID 16843)
-- Name: user_federation_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_federation_config (
    user_federation_provider_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 307 (class 1259 OID 16848)
-- Name: user_federation_mapper; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_federation_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    federation_provider_id character varying(36) NOT NULL,
    federation_mapper_type character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


--
-- TOC entry 308 (class 1259 OID 16853)
-- Name: user_federation_mapper_config; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_federation_mapper_config (
    user_federation_mapper_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 309 (class 1259 OID 16858)
-- Name: user_federation_provider; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_federation_provider (
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
-- TOC entry 310 (class 1259 OID 16863)
-- Name: user_required_action; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_required_action (
    user_id character varying(36) NOT NULL,
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL
);


--
-- TOC entry 311 (class 1259 OID 16867)
-- Name: user_role_mapping; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_role_mapping (
    role_id character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL
);


--
-- TOC entry 312 (class 1259 OID 16870)
-- Name: web_origins; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.web_origins (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


--
-- TOC entry 4254 (class 0 OID 16386)
-- Dependencies: 218
-- Data for Name: admin_event_entity; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4255 (class 0 OID 16391)
-- Dependencies: 219
-- Data for Name: associated_policy; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4256 (class 0 OID 16394)
-- Dependencies: 220
-- Data for Name: authentication_execution; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.authentication_execution VALUES ('7924e8bd-b0e1-4fbd-8e30-4d22e897e00a', NULL, 'auth-cookie', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('d3576418-f5eb-4309-9e7b-95784e5f5cc0', NULL, 'auth-spnego', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 3, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('ed643239-e18f-4ac3-94c4-b86bf5348690', NULL, 'identity-provider-redirector', '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 25, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('adbfe000-2d74-44f6-ac4e-db7a39c11be5', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '176b4f88-6b3d-44cb-beb4-9317f356d604', 2, 30, true, 'ed691b27-ac6c-49ec-954c-4a9223701987', NULL);
INSERT INTO auth.authentication_execution VALUES ('7b8b8659-89fc-41f5-9905-da339d34ac71', NULL, 'auth-username-password-form', '0c806647-a11c-403d-af39-092523465ca0', 'ed691b27-ac6c-49ec-954c-4a9223701987', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('87fec2b4-274b-40dc-a4d3-fd672e71af19', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'ed691b27-ac6c-49ec-954c-4a9223701987', 1, 20, true, '12a33a18-3d69-41eb-9091-9617d079590e', NULL);
INSERT INTO auth.authentication_execution VALUES ('748e94d8-3ff6-47ce-bb8a-7312a0058f37', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('50f672e2-ba9a-4d41-a825-e2ae3052af08', NULL, 'auth-otp-form', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('54f3f0fb-e1d1-40c0-923b-e4326ec72159', NULL, 'webauthn-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 3, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('714cc9bf-7e2c-4028-a56f-16b9522a2d0c', NULL, 'auth-recovery-authn-code-form', '0c806647-a11c-403d-af39-092523465ca0', '12a33a18-3d69-41eb-9091-9617d079590e', 3, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('b2b71f13-1680-498c-95bf-6a00eaca879f', NULL, 'direct-grant-validate-username', '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('2f0a4a73-8cc3-4b7d-933a-686c5e427c72', NULL, 'direct-grant-validate-password', '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('bbe74c50-d35b-4470-8ef0-6012d5354883', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', 1, 30, true, '29376f88-03f6-44ba-99f6-53158b056246', NULL);
INSERT INTO auth.authentication_execution VALUES ('b0b8074a-8def-4c48-9751-c738e43c7454', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '29376f88-03f6-44ba-99f6-53158b056246', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('b70b5a27-2701-4adc-b879-1cf36b0fade1', NULL, 'direct-grant-validate-otp', '0c806647-a11c-403d-af39-092523465ca0', '29376f88-03f6-44ba-99f6-53158b056246', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('c311abeb-fc54-46e4-80cc-44dd6a478b40', NULL, 'registration-page-form', '0c806647-a11c-403d-af39-092523465ca0', 'd5ca2242-a726-45ed-abc5-0ab031f68d89', 0, 10, true, '0b0950be-3030-44ce-9d85-4e1ff1801173', NULL);
INSERT INTO auth.authentication_execution VALUES ('52b1004a-6dd2-45a1-be78-804f2e57582c', NULL, 'registration-user-creation', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('27d28ad5-4490-4d96-aa89-ad3440b69da8', NULL, 'registration-password-action', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 0, 50, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('97ed2230-a268-423d-ae8f-8e25aa450858', NULL, 'registration-recaptcha-action', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 3, 60, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4623917b-9980-4e2a-951d-32f7d3a888e8', NULL, 'registration-terms-and-conditions', '0c806647-a11c-403d-af39-092523465ca0', '0b0950be-3030-44ce-9d85-4e1ff1801173', 3, 70, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('69d09f35-8c6c-4c8c-84a6-584f6fbb7284', NULL, 'reset-credentials-choose-user', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('916e1f9d-1955-41ca-a5ea-d7dbecb3818d', NULL, 'reset-credential-email', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('3e454d19-d18d-4c9c-b566-151fc867467f', NULL, 'reset-password', '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 0, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('e9721799-9fda-4984-a51c-50f941a2c1ca', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 1, 40, true, '3b538c6b-78d0-4485-97a2-799a543e1d3c', NULL);
INSERT INTO auth.authentication_execution VALUES ('bd93dd80-6a5e-477d-be47-4b72c95ebfb8', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '3b538c6b-78d0-4485-97a2-799a543e1d3c', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('21b7f95b-087b-400e-82de-eea37b97a7ce', NULL, 'reset-otp', '0c806647-a11c-403d-af39-092523465ca0', '3b538c6b-78d0-4485-97a2-799a543e1d3c', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('ab7a5826-55df-4f8b-b00f-09b2f7ee8852', NULL, 'client-secret', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('718ed6ff-ecad-40bd-9198-d0a44a7d5517', NULL, 'client-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('89458be5-18ac-4266-834c-54e2325f081d', NULL, 'client-secret-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('82e3864a-9c6b-43c0-9012-4c78eb8ef8ef', NULL, 'client-x509', '0c806647-a11c-403d-af39-092523465ca0', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('fb2d39bc-c1a6-43f4-9e83-a286add7e646', NULL, 'idp-review-profile', '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 0, 10, false, NULL, 'bb3ab7fc-2f26-415c-aa8c-305a853f5031');
INSERT INTO auth.authentication_execution VALUES ('cdef4ba6-4321-4e9a-b34d-f77ef2e86858', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 0, 20, true, '86316c79-d109-4492-b1ed-b769c9b67c56', NULL);
INSERT INTO auth.authentication_execution VALUES ('255fadda-69b8-4a4d-a908-c3725066eba2', NULL, 'idp-create-user-if-unique', '0c806647-a11c-403d-af39-092523465ca0', '86316c79-d109-4492-b1ed-b769c9b67c56', 2, 10, false, NULL, 'c6f54644-4ff0-42d6-bf2f-90c1782c94e0');
INSERT INTO auth.authentication_execution VALUES ('b4d7e253-8988-4735-b673-220fbefb6f36', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '86316c79-d109-4492-b1ed-b769c9b67c56', 2, 20, true, '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', NULL);
INSERT INTO auth.authentication_execution VALUES ('ba79324b-e15f-4694-a25e-367b2efea414', NULL, 'idp-confirm-link', '0c806647-a11c-403d-af39-092523465ca0', '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('91b181ba-447f-491e-bf0c-bfc0f2c240b6', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 0, 20, true, '0477b3bf-3c95-418d-9d60-330d0a110004', NULL);
INSERT INTO auth.authentication_execution VALUES ('bb0d5e92-27ab-4d3e-8310-6020715ea04e', NULL, 'idp-email-verification', '0c806647-a11c-403d-af39-092523465ca0', '0477b3bf-3c95-418d-9d60-330d0a110004', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('22606dc7-446f-46a6-895f-debd056bf9a7', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '0477b3bf-3c95-418d-9d60-330d0a110004', 2, 20, true, '827d3481-45aa-4f03-9b65-932142e852a8', NULL);
INSERT INTO auth.authentication_execution VALUES ('11b6e953-0b56-4f4b-b4be-185a74058b15', NULL, 'idp-username-password-form', '0c806647-a11c-403d-af39-092523465ca0', '827d3481-45aa-4f03-9b65-932142e852a8', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('442932c7-b5ea-4f5f-a91e-cb37d07c3d9a', NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', '827d3481-45aa-4f03-9b65-932142e852a8', 1, 20, true, '2ee08def-66d5-4485-8930-5f353401803e', NULL);
INSERT INTO auth.authentication_execution VALUES ('61248cc2-396e-48b6-82ff-b8cd3b3cc743', NULL, 'conditional-user-configured', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('fbe1e72f-70e1-4a09-8b8a-a6eec9217100', NULL, 'auth-otp-form', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('0aa5631e-6f0b-4f37-9aad-0909f03a6dde', NULL, 'webauthn-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 3, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('fe64eae0-7ffc-4ae4-acd6-07bd20869607', NULL, 'auth-recovery-authn-code-form', '0c806647-a11c-403d-af39-092523465ca0', '2ee08def-66d5-4485-8930-5f353401803e', 3, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('c589e443-0576-4b75-9b6c-6cc5c0454fae', NULL, 'http-basic-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '8e26f438-ebb5-445c-a713-fffe62480957', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('45aeddec-b369-4abb-801f-9f92eaa10df5', NULL, 'docker-http-basic-authenticator', '0c806647-a11c-403d-af39-092523465ca0', '5e51b971-b52e-4997-9c70-d0fd966312f6', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4525efef-235d-4b7c-8785-4596c884d0fc', NULL, 'auth-cookie', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '10ae742a-69e7-452f-a568-66130826e196', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('6f0e0f00-7ba4-47ea-95ee-e2d9aa652a82', NULL, 'auth-spnego', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '10ae742a-69e7-452f-a568-66130826e196', 3, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('ef4641e9-fefb-4166-9dd1-8c9d0a9953c3', NULL, 'identity-provider-redirector', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '10ae742a-69e7-452f-a568-66130826e196', 2, 25, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('394710f6-5154-44ae-bbba-bdc45e9cf334', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '10ae742a-69e7-452f-a568-66130826e196', 2, 30, true, 'cf6f0db4-6a50-414a-b9f0-9758c296e286', NULL);
INSERT INTO auth.authentication_execution VALUES ('9f945f24-5729-427a-a989-b145ea7d2383', NULL, 'auth-username-password-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cf6f0db4-6a50-414a-b9f0-9758c296e286', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('d5c3140d-48b4-4e35-98e4-a825cac102af', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cf6f0db4-6a50-414a-b9f0-9758c296e286', 1, 20, true, 'e87d0e7e-44e9-4c03-927f-2e36e6200b18', NULL);
INSERT INTO auth.authentication_execution VALUES ('1910505e-372e-4c41-a864-05fedba1b323', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'e87d0e7e-44e9-4c03-927f-2e36e6200b18', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('c697aee8-64ba-463f-ab95-bb5227edbbaf', NULL, 'auth-otp-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'e87d0e7e-44e9-4c03-927f-2e36e6200b18', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('de21b882-4aa1-4e98-81d5-8fbe4b4d65ed', NULL, 'webauthn-authenticator', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'e87d0e7e-44e9-4c03-927f-2e36e6200b18', 3, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('9be6cf36-491f-40eb-bbff-87e0a7459278', NULL, 'auth-recovery-authn-code-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'e87d0e7e-44e9-4c03-927f-2e36e6200b18', 3, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('38a22398-d9a9-4645-84bf-79fc98c2b7fe', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '10ae742a-69e7-452f-a568-66130826e196', 2, 26, true, 'e2a9073e-7c32-415b-8a65-96abce3252dd', NULL);
INSERT INTO auth.authentication_execution VALUES ('7ab584ee-092f-4c7f-8104-a64e35622669', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'e2a9073e-7c32-415b-8a65-96abce3252dd', 1, 10, true, '1201c288-8ee7-40e3-bd2e-fddf81c3abcd', NULL);
INSERT INTO auth.authentication_execution VALUES ('ab946eb4-8a14-465b-a567-2b0de98041c6', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1201c288-8ee7-40e3-bd2e-fddf81c3abcd', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('263828b3-46f3-4832-ae9e-deacb1e4682c', NULL, 'organization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1201c288-8ee7-40e3-bd2e-fddf81c3abcd', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('91a23062-05c0-4d5e-8b77-3228a78bf6f6', NULL, 'direct-grant-validate-username', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '91c6b076-6864-4b6f-8065-fa9b38a1922e', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('e47eb9c5-d426-41ed-a518-e72cab789f71', NULL, 'direct-grant-validate-password', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '91c6b076-6864-4b6f-8065-fa9b38a1922e', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4dfbf4f0-9a2d-409f-bde0-90d60b6a4146', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '91c6b076-6864-4b6f-8065-fa9b38a1922e', 1, 30, true, 'a18d9ba6-a28d-46bd-a800-be6b6b709893', NULL);
INSERT INTO auth.authentication_execution VALUES ('d8894eb8-6a79-44ba-9947-62253ac78860', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'a18d9ba6-a28d-46bd-a800-be6b6b709893', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('b1e4d6d2-58ea-460d-a1d8-7b341a7e8c0d', NULL, 'direct-grant-validate-otp', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'a18d9ba6-a28d-46bd-a800-be6b6b709893', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('fa642d65-fec5-4455-bba5-78a39446cf41', NULL, 'registration-page-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '6ceecd97-2f19-4979-89b4-8e44ed5d7d40', 0, 10, true, '7ac05a83-4137-4a69-920a-32188b1f2f8e', NULL);
INSERT INTO auth.authentication_execution VALUES ('8ecab6c8-25e9-4136-92da-a50e5abfed28', NULL, 'registration-user-creation', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ac05a83-4137-4a69-920a-32188b1f2f8e', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('a09a3c82-cc19-45bd-8f57-14cce577777c', NULL, 'registration-password-action', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ac05a83-4137-4a69-920a-32188b1f2f8e', 0, 50, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4969225b-4eb8-4658-93d5-638f2828dced', NULL, 'registration-recaptcha-action', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ac05a83-4137-4a69-920a-32188b1f2f8e', 3, 60, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('cf224d97-b530-427e-8b38-8e7c35cde219', NULL, 'registration-terms-and-conditions', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ac05a83-4137-4a69-920a-32188b1f2f8e', 3, 70, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('029749d0-8ee4-49de-9333-75ce3cb888dc', NULL, 'reset-credentials-choose-user', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1cbd9972-6fe9-40fb-b508-4f491187a252', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4afbf134-81ba-4afb-b9c0-a05e6d04a03e', NULL, 'reset-credential-email', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1cbd9972-6fe9-40fb-b508-4f491187a252', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('94d20fb9-79ce-4d7f-9fd9-87e2122fc1a5', NULL, 'reset-password', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1cbd9972-6fe9-40fb-b508-4f491187a252', 0, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('2f54a03c-323b-4697-9de9-1ce06a41b5d4', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1cbd9972-6fe9-40fb-b508-4f491187a252', 1, 40, true, 'd4e816d5-e177-448c-994d-b2ea8cea911f', NULL);
INSERT INTO auth.authentication_execution VALUES ('514dcb27-e76b-4e4c-b48b-f2c7dcf0ebdc', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'd4e816d5-e177-448c-994d-b2ea8cea911f', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('192d86a6-ce60-40d8-8a99-b8d40c166e00', NULL, 'reset-otp', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'd4e816d5-e177-448c-994d-b2ea8cea911f', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('af6ed3d0-ba0b-42c5-b754-579916982e75', NULL, 'client-secret', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('23a639ad-ae3a-402a-b1a7-146789b3bb38', NULL, 'client-jwt', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('935391c9-f924-4816-acb7-a4cafe566691', NULL, 'client-secret-jwt', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 2, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('3f72e209-4cd1-479b-a9ed-85d775a2f313', NULL, 'client-x509', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 2, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('83a80c49-8076-4b1a-94a2-2a9c2c6383f1', NULL, 'idp-review-profile', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '4003bde4-9625-4bb7-bd05-8f2d8b22fbe2', 0, 10, false, NULL, '785ca4c5-4776-4ed6-aa3e-97c59e0b6de3');
INSERT INTO auth.authentication_execution VALUES ('4743e63d-a242-4658-a70f-7b49f4461a0a', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '4003bde4-9625-4bb7-bd05-8f2d8b22fbe2', 0, 20, true, '7ab3f7b5-40d5-4cfb-aad3-4b6e0bda3ee8', NULL);
INSERT INTO auth.authentication_execution VALUES ('b77fcd0e-0c63-4360-ae3f-3909e18d3dce', NULL, 'idp-create-user-if-unique', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ab3f7b5-40d5-4cfb-aad3-4b6e0bda3ee8', 2, 10, false, NULL, 'b53e618d-f08b-47ed-a3af-9772c8c2311f');
INSERT INTO auth.authentication_execution VALUES ('10890da6-70e3-4cac-acc6-498cf36d5781', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7ab3f7b5-40d5-4cfb-aad3-4b6e0bda3ee8', 2, 20, true, 'd8b1fe97-d3ba-46a9-96c9-3723bceea789', NULL);
INSERT INTO auth.authentication_execution VALUES ('b23a7e93-b055-49f7-a91c-7e60dbd301b9', NULL, 'idp-confirm-link', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'd8b1fe97-d3ba-46a9-96c9-3723bceea789', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('66aade47-9d95-4969-adbe-91c56fbfaed1', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'd8b1fe97-d3ba-46a9-96c9-3723bceea789', 0, 20, true, 'b16ad4d2-979a-420c-9947-d8bb8dd75c31', NULL);
INSERT INTO auth.authentication_execution VALUES ('04b67cbe-d38f-4137-89f5-4316552fc5fa', NULL, 'idp-email-verification', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b16ad4d2-979a-420c-9947-d8bb8dd75c31', 2, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('1aaf5f2c-7f08-48c4-a9ce-7857187c2c15', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'b16ad4d2-979a-420c-9947-d8bb8dd75c31', 2, 20, true, 'fe609c83-c197-45e6-baf6-07da81354e1a', NULL);
INSERT INTO auth.authentication_execution VALUES ('ab4d7fd3-3161-4c32-a1c8-47d4db6e0612', NULL, 'idp-username-password-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'fe609c83-c197-45e6-baf6-07da81354e1a', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('e9027f8e-9d31-40e3-95b6-e21c06014e70', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'fe609c83-c197-45e6-baf6-07da81354e1a', 1, 20, true, '83bc319a-cbfe-4cb7-87ed-2ff77c58b093', NULL);
INSERT INTO auth.authentication_execution VALUES ('b6e1eb7f-0973-4c74-8713-83d182d1b131', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '83bc319a-cbfe-4cb7-87ed-2ff77c58b093', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('a26231d2-4588-4685-a9a7-09a801d30ece', NULL, 'auth-otp-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '83bc319a-cbfe-4cb7-87ed-2ff77c58b093', 2, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('b17b701f-d477-4931-964b-e030aaf3b2b7', NULL, 'webauthn-authenticator', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '83bc319a-cbfe-4cb7-87ed-2ff77c58b093', 3, 30, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('4a571367-aa6c-4904-9769-c0ac2732e850', NULL, 'auth-recovery-authn-code-form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '83bc319a-cbfe-4cb7-87ed-2ff77c58b093', 3, 40, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('c52dc95c-b654-4fbc-bce0-aa17fe0ae6b4', NULL, NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '4003bde4-9625-4bb7-bd05-8f2d8b22fbe2', 1, 50, true, 'f0f659d3-7409-41df-9edf-bd6b836d866a', NULL);
INSERT INTO auth.authentication_execution VALUES ('a44411b9-0e18-42d7-8370-5b5929883208', NULL, 'conditional-user-configured', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'f0f659d3-7409-41df-9edf-bd6b836d866a', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('f04ff509-eb26-464d-baff-4e700b1581ec', NULL, 'idp-add-organization-member', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'f0f659d3-7409-41df-9edf-bd6b836d866a', 0, 20, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('262df502-4a25-4d3d-9276-1fd7ff9f5c39', NULL, 'http-basic-authenticator', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'f2b2ee0a-efdf-496a-bf15-e84d3fee3b59', 0, 10, false, NULL, NULL);
INSERT INTO auth.authentication_execution VALUES ('ed4892b8-12bc-4753-8414-686d354ba21a', NULL, 'docker-http-basic-authenticator', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '63a48fc0-d641-4431-98c3-ba940d0d0867', 0, 10, false, NULL, NULL);


--
-- TOC entry 4257 (class 0 OID 16398)
-- Dependencies: 221
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.authentication_flow VALUES ('176b4f88-6b3d-44cb-beb4-9317f356d604', 'browser', 'Browser based authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('ed691b27-ac6c-49ec-954c-4a9223701987', 'forms', 'Username, password, otp and other auth forms.', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('12a33a18-3d69-41eb-9091-9617d079590e', 'Browser - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('a973adea-a8aa-4ce1-953e-8d759df4b2d9', 'direct grant', 'OpenID Connect Resource Owner Grant', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('29376f88-03f6-44ba-99f6-53158b056246', 'Direct Grant - Conditional OTP', 'Flow to determine if the OTP is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('d5ca2242-a726-45ed-abc5-0ab031f68d89', 'registration', 'Registration flow', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('0b0950be-3030-44ce-9d85-4e1ff1801173', 'registration form', 'Registration form', '0c806647-a11c-403d-af39-092523465ca0', 'form-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('80c8bca9-2b6e-472a-bcef-d5f38392de99', 'reset credentials', 'Reset credentials for a user if they forgot their password or something', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('3b538c6b-78d0-4485-97a2-799a543e1d3c', 'Reset - Conditional OTP', 'Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('bace0a66-45dc-406a-b4c9-89ad226d88ce', 'clients', 'Base authentication for clients', '0c806647-a11c-403d-af39-092523465ca0', 'client-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c', 'first broker login', 'Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('86316c79-d109-4492-b1ed-b769c9b67c56', 'User creation or linking', 'Flow for the existing/non-existing user alternatives', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('89a91c4a-a264-4746-b7b9-506b0e7a6fdf', 'Handle Existing Account', 'Handle what to do if there is existing account with same email/username like authenticated identity provider', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('0477b3bf-3c95-418d-9d60-330d0a110004', 'Account verification options', 'Method with which to verity the existing account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('827d3481-45aa-4f03-9b65-932142e852a8', 'Verify Existing Account by Re-authentication', 'Reauthentication of existing account', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('2ee08def-66d5-4485-8930-5f353401803e', 'First broker login - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('8e26f438-ebb5-445c-a713-fffe62480957', 'saml ecp', 'SAML ECP Profile Authentication Flow', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('5e51b971-b52e-4997-9c70-d0fd966312f6', 'docker auth', 'Used by Docker clients to authenticate against the IDP', '0c806647-a11c-403d-af39-092523465ca0', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('10ae742a-69e7-452f-a568-66130826e196', 'browser', 'Browser based authentication', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('cf6f0db4-6a50-414a-b9f0-9758c296e286', 'forms', 'Username, password, otp and other auth forms.', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('e87d0e7e-44e9-4c03-927f-2e36e6200b18', 'Browser - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('e2a9073e-7c32-415b-8a65-96abce3252dd', 'Organization', NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('1201c288-8ee7-40e3-bd2e-fddf81c3abcd', 'Browser - Conditional Organization', 'Flow to determine if the organization identity-first login is to be used', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('91c6b076-6864-4b6f-8065-fa9b38a1922e', 'direct grant', 'OpenID Connect Resource Owner Grant', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('a18d9ba6-a28d-46bd-a800-be6b6b709893', 'Direct Grant - Conditional OTP', 'Flow to determine if the OTP is required for the authentication', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('6ceecd97-2f19-4979-89b4-8e44ed5d7d40', 'registration', 'Registration flow', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('7ac05a83-4137-4a69-920a-32188b1f2f8e', 'registration form', 'Registration form', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'form-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('1cbd9972-6fe9-40fb-b508-4f491187a252', 'reset credentials', 'Reset credentials for a user if they forgot their password or something', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('d4e816d5-e177-448c-994d-b2ea8cea911f', 'Reset - Conditional OTP', 'Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 'clients', 'Base authentication for clients', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'client-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('4003bde4-9625-4bb7-bd05-8f2d8b22fbe2', 'first broker login', 'Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('7ab3f7b5-40d5-4cfb-aad3-4b6e0bda3ee8', 'User creation or linking', 'Flow for the existing/non-existing user alternatives', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('d8b1fe97-d3ba-46a9-96c9-3723bceea789', 'Handle Existing Account', 'Handle what to do if there is existing account with same email/username like authenticated identity provider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('b16ad4d2-979a-420c-9947-d8bb8dd75c31', 'Account verification options', 'Method with which to verity the existing account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('fe609c83-c197-45e6-baf6-07da81354e1a', 'Verify Existing Account by Re-authentication', 'Reauthentication of existing account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('83bc319a-cbfe-4cb7-87ed-2ff77c58b093', 'First broker login - Conditional 2FA', 'Flow to determine if any 2FA is required for the authentication', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('f0f659d3-7409-41df-9edf-bd6b836d866a', 'First Broker Login - Conditional Organization', 'Flow to determine if the authenticator that adds organization members is to be used', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', false, true);
INSERT INTO auth.authentication_flow VALUES ('f2b2ee0a-efdf-496a-bf15-e84d3fee3b59', 'saml ecp', 'SAML ECP Profile Authentication Flow', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);
INSERT INTO auth.authentication_flow VALUES ('63a48fc0-d641-4431-98c3-ba940d0d0867', 'docker auth', 'Used by Docker clients to authenticate against the IDP', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'basic-flow', true, true);


--
-- TOC entry 4258 (class 0 OID 16406)
-- Dependencies: 222
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.authenticator_config VALUES ('bb3ab7fc-2f26-415c-aa8c-305a853f5031', 'review profile config', '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO auth.authenticator_config VALUES ('c6f54644-4ff0-42d6-bf2f-90c1782c94e0', 'create unique user config', '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO auth.authenticator_config VALUES ('785ca4c5-4776-4ed6-aa3e-97c59e0b6de3', 'review profile config', '7404ff5e-f51a-4416-b45f-15d2d69cca5f');
INSERT INTO auth.authenticator_config VALUES ('b53e618d-f08b-47ed-a3af-9772c8c2311f', 'create unique user config', '7404ff5e-f51a-4416-b45f-15d2d69cca5f');


--
-- TOC entry 4259 (class 0 OID 16409)
-- Dependencies: 223
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.authenticator_config_entry VALUES ('bb3ab7fc-2f26-415c-aa8c-305a853f5031', 'missing', 'update.profile.on.first.login');
INSERT INTO auth.authenticator_config_entry VALUES ('c6f54644-4ff0-42d6-bf2f-90c1782c94e0', 'false', 'require.password.update.after.registration');
INSERT INTO auth.authenticator_config_entry VALUES ('785ca4c5-4776-4ed6-aa3e-97c59e0b6de3', 'missing', 'update.profile.on.first.login');
INSERT INTO auth.authenticator_config_entry VALUES ('b53e618d-f08b-47ed-a3af-9772c8c2311f', 'false', 'require.password.update.after.registration');


--
-- TOC entry 4260 (class 0 OID 16414)
-- Dependencies: 224
-- Data for Name: broker_link; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4261 (class 0 OID 16419)
-- Dependencies: 225
-- Data for Name: client; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', true, false, 'master-realm', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', NULL, 0, false, false, 'master Realm', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', true, false, 'account', 0, true, NULL, '/realms/master/account/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_account}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', true, false, 'account-console', 0, true, NULL, '/realms/master/account/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_account-console}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', true, false, 'broker', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_broker}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', true, true, 'security-admin-console', 0, true, NULL, '/admin/master/console/', false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_security-admin-console}', false, 'client-secret', '${authAdminUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', true, true, 'admin-cli', 0, true, NULL, NULL, false, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', 'openid-connect', 0, false, false, '${client_admin-cli}', false, 'client-secret', NULL, NULL, NULL, false, false, true, false);
INSERT INTO auth.client VALUES ('a12d00f9-ec24-4109-9127-358f4543feff', true, false, 'condominio-realm', 0, false, NULL, NULL, true, NULL, false, '0c806647-a11c-403d-af39-092523465ca0', NULL, 0, false, false, 'condominio Realm', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', true, false, 'realm-management', 0, false, NULL, NULL, true, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_realm-management}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', true, false, 'account', 0, true, NULL, '/realms/condominio/account/', false, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_account}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', true, false, 'account-console', 0, true, NULL, '/realms/condominio/account/', false, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_account-console}', false, 'client-secret', '${authBaseUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', true, false, 'broker', 0, false, NULL, NULL, true, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_broker}', false, 'client-secret', NULL, NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', true, true, 'security-admin-console', 0, true, NULL, '/admin/condominio/console/', false, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_security-admin-console}', false, 'client-secret', '${authAdminUrl}', NULL, NULL, true, false, false, false);
INSERT INTO auth.client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', true, true, 'admin-cli', 0, true, NULL, NULL, false, NULL, false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', 0, false, false, '${client_admin-cli}', false, 'client-secret', NULL, NULL, NULL, false, false, true, false);
INSERT INTO auth.client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', true, true, 'condominio', 0, true, NULL, '', false, '', false, '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'openid-connect', -1, true, false, 'Condominio', false, 'client-secret', '', 'client per realm di condominio', NULL, true, false, false, false);


--
-- TOC entry 4262 (class 0 OID 16437)
-- Dependencies: 226
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client_attributes VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'pkce.code.challenge.method', 'S256');
INSERT INTO auth.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'pkce.code.challenge.method', 'S256');
INSERT INTO auth.client_attributes VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO auth.client_attributes VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO auth.client_attributes VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'pkce.code.challenge.method', 'S256');
INSERT INTO auth.client_attributes VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'post.logout.redirect.uris', '+');
INSERT INTO auth.client_attributes VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'pkce.code.challenge.method', 'S256');
INSERT INTO auth.client_attributes VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO auth.client_attributes VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', 'client.use.lightweight.access.token.enabled', 'true');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'standard.token.exchange.enabled', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'oauth2.device.authorization.grant.enabled', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'oidc.ciba.grant.enabled', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'pkce.code.challenge.method', 'S256');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'backchannel.logout.session.required', 'true');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'backchannel.logout.revoke.offline.tokens', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'realm_client', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'login_theme', 'keycloak.v2');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'display.on.consent.screen', 'false');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'frontchannel.logout.session.required', 'true');
INSERT INTO auth.client_attributes VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'post.logout.redirect.uris', 'it.mvs.condominiouiflutter://login-callback');


--
-- TOC entry 4263 (class 0 OID 16442)
-- Dependencies: 227
-- Data for Name: client_auth_flow_bindings; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4264 (class 0 OID 16445)
-- Dependencies: 228
-- Data for Name: client_initial_access; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4265 (class 0 OID 16448)
-- Dependencies: 229
-- Data for Name: client_node_registrations; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4266 (class 0 OID 16451)
-- Dependencies: 230
-- Data for Name: client_scope; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client_scope VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'offline_access', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: offline_access', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', 'role_list', '0c806647-a11c-403d-af39-092523465ca0', 'SAML role list', 'saml');
INSERT INTO auth.client_scope VALUES ('cbbe8007-9274-488d-b7a6-e1efa971032b', 'saml_organization', '0c806647-a11c-403d-af39-092523465ca0', 'Organization Membership', 'saml');
INSERT INTO auth.client_scope VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'profile', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: profile', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'email', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: email', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'address', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: address', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'phone', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect built-in scope: phone', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'roles', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add user roles to the access token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'web-origins', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add allowed web origins to the access token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'microprofile-jwt', '0c806647-a11c-403d-af39-092523465ca0', 'Microprofile - JWT built-in scope', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'acr', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add acr (authentication context class reference) to the token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'basic', '0c806647-a11c-403d-af39-092523465ca0', 'OpenID Connect scope for add all basic claims to the token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'service_account', '0c806647-a11c-403d-af39-092523465ca0', 'Specific scope for a client enabled for service accounts', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('05888153-059e-47e4-b37a-47236467549a', 'organization', '0c806647-a11c-403d-af39-092523465ca0', 'Additional claims about the organization a subject belongs to', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', 'offline_access', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect built-in scope: offline_access', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('c3550f61-d509-40a4-904a-342af7980ecd', 'role_list', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'SAML role list', 'saml');
INSERT INTO auth.client_scope VALUES ('add1b692-0f4d-42e7-8620-9dc9c89039d0', 'saml_organization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'Organization Membership', 'saml');
INSERT INTO auth.client_scope VALUES ('0890c368-f43a-4825-a404-a2b2583e341d', 'profile', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect built-in scope: profile', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('89e456b7-ffac-4055-be76-32fb54b5ac72', 'email', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect built-in scope: email', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', 'address', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect built-in scope: address', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('07d4ed18-94fe-4306-8948-454720e0433c', 'phone', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect built-in scope: phone', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('92fca448-d98e-4989-8704-55a7cfec5b5c', 'roles', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect scope for add user roles to the access token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('8d404c72-37fa-4303-86ef-529092f0a904', 'web-origins', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect scope for add allowed web origins to the access token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('ce2b281f-a337-44fe-a9b7-e862ed20510b', 'microprofile-jwt', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'Microprofile - JWT built-in scope', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('57896332-b5ba-45da-87c9-04a1d23a9cf0', 'acr', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect scope for add acr (authentication context class reference) to the token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('f11b9ea4-f791-4a68-a2be-3809dc842a7e', 'basic', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'OpenID Connect scope for add all basic claims to the token', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('f79d8f96-2134-4bf0-913e-a67fbd836285', 'service_account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'Specific scope for a client enabled for service accounts', 'openid-connect');
INSERT INTO auth.client_scope VALUES ('fae553ba-26e5-4e37-9cc4-5e14f12ee564', 'organization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'Additional claims about the organization a subject belongs to', 'openid-connect');


--
-- TOC entry 4267 (class 0 OID 16456)
-- Dependencies: 231
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client_scope_attributes VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', '${offlineAccessScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('26186141-2832-4cc9-8b88-1a39757006ec', '${samlRoleListScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('cbbe8007-9274-488d-b7a6-e1efa971032b', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', '${profileScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('611958be-e756-45a6-9eb1-ad4af1a32f5b', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', '${emailScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('a6e2784f-5222-4d7c-a15c-ba88682028f4', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', '${addressScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('993ba957-fbd7-43f2-ae34-1f79b0230bf5', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', '${phoneScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('fb44034c-f05c-478a-a35e-5b48b2bea3f2', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', '${rolesScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('7d028e21-bf5d-4d13-bfc9-eea187b86b59', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', '', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('af89a443-1204-4c1a-bce8-57a80972cc03', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('528e12c3-909d-419d-ab0c-9867e433de88', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('d4425897-b36d-4b12-846e-61da27f50271', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('039b7573-e076-41be-a04a-ac06eee8285f', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('7921ab35-c79a-4ab6-8b01-4757c3b6db8c', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', '${organizationScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('05888153-059e-47e4-b37a-47236467549a', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', '${offlineAccessScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('c3550f61-d509-40a4-904a-342af7980ecd', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('c3550f61-d509-40a4-904a-342af7980ecd', '${samlRoleListScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('add1b692-0f4d-42e7-8620-9dc9c89039d0', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('0890c368-f43a-4825-a404-a2b2583e341d', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('0890c368-f43a-4825-a404-a2b2583e341d', '${profileScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('0890c368-f43a-4825-a404-a2b2583e341d', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('89e456b7-ffac-4055-be76-32fb54b5ac72', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('89e456b7-ffac-4055-be76-32fb54b5ac72', '${emailScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('89e456b7-ffac-4055-be76-32fb54b5ac72', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', '${addressScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('07d4ed18-94fe-4306-8948-454720e0433c', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('07d4ed18-94fe-4306-8948-454720e0433c', '${phoneScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('07d4ed18-94fe-4306-8948-454720e0433c', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('92fca448-d98e-4989-8704-55a7cfec5b5c', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('92fca448-d98e-4989-8704-55a7cfec5b5c', '${rolesScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('92fca448-d98e-4989-8704-55a7cfec5b5c', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('8d404c72-37fa-4303-86ef-529092f0a904', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('8d404c72-37fa-4303-86ef-529092f0a904', '', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('8d404c72-37fa-4303-86ef-529092f0a904', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('ce2b281f-a337-44fe-a9b7-e862ed20510b', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('ce2b281f-a337-44fe-a9b7-e862ed20510b', 'true', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('57896332-b5ba-45da-87c9-04a1d23a9cf0', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('57896332-b5ba-45da-87c9-04a1d23a9cf0', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('f11b9ea4-f791-4a68-a2be-3809dc842a7e', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('f11b9ea4-f791-4a68-a2be-3809dc842a7e', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('f79d8f96-2134-4bf0-913e-a67fbd836285', 'false', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('f79d8f96-2134-4bf0-913e-a67fbd836285', 'false', 'include.in.token.scope');
INSERT INTO auth.client_scope_attributes VALUES ('fae553ba-26e5-4e37-9cc4-5e14f12ee564', 'true', 'display.on.consent.screen');
INSERT INTO auth.client_scope_attributes VALUES ('fae553ba-26e5-4e37-9cc4-5e14f12ee564', '${organizationScopeConsentText}', 'consent.screen.text');
INSERT INTO auth.client_scope_attributes VALUES ('fae553ba-26e5-4e37-9cc4-5e14f12ee564', 'true', 'include.in.token.scope');


--
-- TOC entry 4268 (class 0 OID 16461)
-- Dependencies: 232
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('a68f7a60-23b0-44c7-b055-f83bfb024038', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('b44bd709-a47c-4200-9be6-48e57da7d91c', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.client_scope_client VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('4066bbcb-0c33-4a65-92bf-f44854d9b728', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('cab29a97-29d1-48f7-8558-c0b528039ebc', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.client_scope_client VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);


--
-- TOC entry 4269 (class 0 OID 16467)
-- Dependencies: 233
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.client_scope_role_mapping VALUES ('049a3409-76f1-4ebc-ae89-ad113353878d', 'a3f06c98-eaeb-4470-98d5-09268563e97f');
INSERT INTO auth.client_scope_role_mapping VALUES ('231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', '1ea38dc4-b1bd-4f5f-bd2b-cc4a119df8b2');


--
-- TOC entry 4270 (class 0 OID 16470)
-- Dependencies: 234
-- Data for Name: component; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.component VALUES ('c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'Trusted Hosts', '0c806647-a11c-403d-af39-092523465ca0', 'trusted-hosts', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('f3338552-3e7e-4652-91a3-167bdaecefd2', 'Consent Required', '0c806647-a11c-403d-af39-092523465ca0', 'consent-required', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('a992c1a8-e4a3-4d12-a76d-beda405fec83', 'Full Scope Disabled', '0c806647-a11c-403d-af39-092523465ca0', 'scope', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('21493008-7827-4e6e-b553-33e3102803d5', 'Max Clients Limit', '0c806647-a11c-403d-af39-092523465ca0', 'max-clients', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'Allowed Protocol Mapper Types', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('bddc26b3-1dea-4c70-8d45-933f187c7e7e', 'Allowed Client Scopes', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'anonymous');
INSERT INTO auth.component VALUES ('bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'Allowed Protocol Mapper Types', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'authenticated');
INSERT INTO auth.component VALUES ('ef868973-344f-4e2f-a479-25e5af78abf3', 'Allowed Client Scopes', '0c806647-a11c-403d-af39-092523465ca0', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'authenticated');
INSERT INTO auth.component VALUES ('5b29625a-0714-47e0-b3d1-9394f9079396', 'rsa-generated', '0c806647-a11c-403d-af39-092523465ca0', 'rsa-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO auth.component VALUES ('e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'rsa-enc-generated', '0c806647-a11c-403d-af39-092523465ca0', 'rsa-enc-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO auth.component VALUES ('8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'hmac-generated-hs512', '0c806647-a11c-403d-af39-092523465ca0', 'hmac-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO auth.component VALUES ('7d6cd448-3ab6-4320-b557-379496304c27', 'aes-generated', '0c806647-a11c-403d-af39-092523465ca0', 'aes-generated', 'org.keycloak.keys.KeyProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO auth.component VALUES ('1c271620-cac1-4759-a00b-fed590e6e414', NULL, '0c806647-a11c-403d-af39-092523465ca0', 'declarative-user-profile', 'org.keycloak.userprofile.UserProfileProvider', '0c806647-a11c-403d-af39-092523465ca0', NULL);
INSERT INTO auth.component VALUES ('e6dc40e4-7869-4df4-89f2-af26377118ba', 'rsa-generated', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'rsa-generated', 'org.keycloak.keys.KeyProvider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL);
INSERT INTO auth.component VALUES ('7b8c5368-49a3-4638-9315-53b298fdf344', 'rsa-enc-generated', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'rsa-enc-generated', 'org.keycloak.keys.KeyProvider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL);
INSERT INTO auth.component VALUES ('9a37dbaf-6d05-4863-b2c2-f959b556c9ce', 'hmac-generated-hs512', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'hmac-generated', 'org.keycloak.keys.KeyProvider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL);
INSERT INTO auth.component VALUES ('6c58138c-8a7b-48ba-97c5-d98a5e342e92', 'aes-generated', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'aes-generated', 'org.keycloak.keys.KeyProvider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL);
INSERT INTO auth.component VALUES ('ef346b2b-d54f-4465-96d6-1857668e8fe2', 'Trusted Hosts', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'trusted-hosts', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('c82f972e-d364-44f5-b0b8-744d85766d19', 'Consent Required', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'consent-required', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('99d03b8e-5d1d-4dfa-a4b0-481475a3e844', 'Full Scope Disabled', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'scope', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('2e7ff0d5-e5da-4d95-beec-e2089b404272', 'Max Clients Limit', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'max-clients', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'Allowed Protocol Mapper Types', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('61a9748a-f428-4b29-8975-5566a917904a', 'Allowed Client Scopes', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'anonymous');
INSERT INTO auth.component VALUES ('b8c59707-d356-4358-96f2-b3ec5d891de7', 'Allowed Protocol Mapper Types', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'allowed-protocol-mappers', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'authenticated');
INSERT INTO auth.component VALUES ('b95bd51f-20a0-4b38-9a91-09264df1c231', 'Allowed Client Scopes', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'allowed-client-templates', 'org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'authenticated');


--
-- TOC entry 4271 (class 0 OID 16475)
-- Dependencies: 235
-- Data for Name: component_config; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.component_config VALUES ('338b1d24-e3dc-4c89-9f67-183c82f1ef55', 'c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'host-sending-registration-request-must-match', 'true');
INSERT INTO auth.component_config VALUES ('45733e81-82bb-4c6a-bd95-c5e4eab42c03', 'c3eb141c-8003-4ff1-83ea-7a584fb052e7', 'client-uris-must-match', 'true');
INSERT INTO auth.component_config VALUES ('3d4dccb7-0882-493e-8d40-c609d8e7ec83', 'bddc26b3-1dea-4c70-8d45-933f187c7e7e', 'allow-default-scopes', 'true');
INSERT INTO auth.component_config VALUES ('0cfe84dd-f90e-4c8f-aaf6-8be01b700674', 'ef868973-344f-4e2f-a479-25e5af78abf3', 'allow-default-scopes', 'true');
INSERT INTO auth.component_config VALUES ('aab5de04-5bff-49f7-854c-a644b0021927', '21493008-7827-4e6e-b553-33e3102803d5', 'max-clients', '200');
INSERT INTO auth.component_config VALUES ('3cf3df5a-09a2-4e10-83a1-4358188aa45b', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO auth.component_config VALUES ('4ddad8a7-ccdd-48fa-b867-a6eb2def2388', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO auth.component_config VALUES ('cdcbf94e-8e60-4f38-9d4e-cdebc4df4c75', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO auth.component_config VALUES ('a0e27522-a9ec-44bf-bb28-87a938cfc64f', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO auth.component_config VALUES ('271389d9-54a7-47fb-91f3-0a7b9f5ce98c', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO auth.component_config VALUES ('3d32aea4-8294-46e0-ba3b-b942c05cb877', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO auth.component_config VALUES ('280a4c5e-8fc7-44a9-b228-802e457aeb77', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO auth.component_config VALUES ('45e42fa3-d726-4ce8-9bed-a82422eb9434', 'c8f317d7-0bf0-4a15-acb5-474bccdd3601', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO auth.component_config VALUES ('c99a37bc-bf51-4793-b632-6d453852cf69', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO auth.component_config VALUES ('8eb20f19-7d7f-487c-8677-43eabb9242e8', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO auth.component_config VALUES ('a0e035ac-3623-415f-93d4-ab59e08edba3', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO auth.component_config VALUES ('53518747-bc3c-4cce-af01-629508fbf7d7', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO auth.component_config VALUES ('5b17ea99-3fb5-4894-afad-e9bc372a3fc4', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO auth.component_config VALUES ('33c1bb1b-429f-47f0-89fd-443135164d2d', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO auth.component_config VALUES ('622dc8f0-221b-45b8-acc9-7761dedfc16f', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO auth.component_config VALUES ('d6019d36-94a4-42d8-b977-c47a886c7533', 'bd310d7b-bed9-48bd-b46d-c45b435f9bcb', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO auth.component_config VALUES ('dd1296cd-dba8-486d-ab90-5715e898277e', '7d6cd448-3ab6-4320-b557-379496304c27', 'secret', 'bbACbT_wP3LkuofyB0WDCQ');
INSERT INTO auth.component_config VALUES ('ec235973-a48f-4715-b085-601d629b9b4c', '7d6cd448-3ab6-4320-b557-379496304c27', 'priority', '100');
INSERT INTO auth.component_config VALUES ('3ca592b4-b195-44d7-86c6-372ddbf6a059', '7d6cd448-3ab6-4320-b557-379496304c27', 'kid', 'f8b92589-f9ed-46b9-a841-dff66b6d21a4');
INSERT INTO auth.component_config VALUES ('b87004fd-4bce-45b7-8326-88639262f8b1', '1c271620-cac1-4759-a00b-fed590e6e414', 'kc.user.profile.config', '{"attributes":[{"name":"username","displayName":"${username}","validations":{"length":{"min":3,"max":255},"username-prohibited-characters":{},"up-username-not-idn-homograph":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"email","displayName":"${email}","validations":{"email":{},"length":{"max":255}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"firstName","displayName":"${firstName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"lastName","displayName":"${lastName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false}],"groups":[{"name":"user-metadata","displayHeader":"User metadata","displayDescription":"Attributes, which refer to user metadata"}]}');
INSERT INTO auth.component_config VALUES ('5ed28cde-d2fa-498d-a7ad-4f4103722a83', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'privateKey', 'MIIEowIBAAKCAQEA7cAJzQ+IXsp4Am9ThiVRTSZjgtDpwDD88/wEJ7tZN7P1QOb8n4+VPfn1urkQUn+k1aULvk9NQcJ4aFxjJWjEi3rpa8Ejw6LScrJYn3o1vRb1ty6ARtmv7Orehz5BazX4oioLgZYvzjcvHjAsEAEF9FjEIZDFuh/KchrV6eo+0nEEwgE9DAoZbMzR9Vab/Npu2Pdp8jN2k+QZGOCxJTtoj1eN2hzkhokjGLyhrxBJRJN5ptEJQi7lJgQBtqP137ft0biyKSUF2Ev8I00HrhAIPSXxvcbF9wzWOkGJzVEoRgk+PFBCtghJBD/gGh4cIa/J5YnNbJrc+Tpnq4itMcJrWwIDAQABAoIBAA+UwU+uD+rebAUE1L163pwmwujE1jzhOQKoZoFQFuW+pnkNakrutwIryn3lOPufH+dcfKuJOO/xVcDJJTpDZnYZpQiJzNU6a35Wz9YLxU/SHGJX6tI52/yz28eTPehPzi6agMyKUjG6jhz1XT3jQ0ejNZ9ZhIvRH4xg09oTnvBdlW2fJGosBAVz0E6KFshE+W2IF6mIb8jK9zIBn0ggBI62hTYfaqGzYvtlh5XNa9CssgCIMKg5x5bCexXxEmwRh1Jx0B29Qi+oZbAJMx7/if26gH4yhCoJy1FpqkKHxv8qfpQuYSfkdQ8lDjrtJUlkee61pEgUuYamq5KJ3ECyh8ECgYEA/9VZ1CgP9Q+KWSd001hQhG6M5wxbgvhwffrgfG+1C47YFwdPTcTNsUvVPfMU5urqV6xYEtgxm9ilmMar/3MLs03kPNZZrf7//b9fBUOq69xkCcc6CLg+EFFz/rK6mwIg+XPUjdFwMXkSp3IoNhiWRKW2cZhyI+FZsS7E7xC706ECgYEA7eesPEmyIPBfZO9bHmRMx6Ljy1bY4ueFfOZIIYgWrxfMauyDwQJXkRsDs+HUi4fxVSo0OkdGEvh8/v7cOZcN5YVfH7Lp3W1CYHkYjrZKlm5v4KZSbL8jVIemKh2+sZFNyjJXvsVic3offXC+of6+IL7eFoaN1czTDNdllJx6nXsCgYBKk0a8MXF1XjJWCspjUTsnX5JzR4blhsZD8v29SFLeK6WSEO9tHBFZvWFLzbAqIBBvvi1uUNclNuIOxtsce8zNV8dQdKtvrQWyUjbAshkA6B3BO/IO2KY+23+Un0UGKniyPrGXJZYu1bw6U2ylWEV1fVjRhD7Bds9OdvOxPI+EAQKBgFdbp8ongYpI2a6Vmc7qI6t269Ch3lhLjZ/Ua44si6/VvFFS8fpworj8w3pNJZ/q1jpgmfcAbwHOTw/PhAx9pDOwqsJYDzoowaPtM5BL7c2ZVemXCVM3SIDkoqZ6b6iCY58op0G89y7SHDgSq12Ozj/19lUtKW3lnWXsvjc40ml7AoGBAPEdh+vOiP2d9+S2X3AvZ9TwmQylid0edJbEQniF0e1PQcFuNRbdYs6D/JCp0NQwSMiDSyTQYgeCwof9lrYnakKKErevcwc50C/lZQi2gcwKYY/SPQVguwfzQGgxBfOQ9Waz2Vt8FEYt9trg+9WiKZTZmO0JCUBihP5I4tZsbge7');
INSERT INTO auth.component_config VALUES ('99c66cc8-9aef-4508-818d-38a4b94d1c6f', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'keyUse', 'ENC');
INSERT INTO auth.component_config VALUES ('d5869e80-95bd-46f1-b045-bb1131497168', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'algorithm', 'RSA-OAEP');
INSERT INTO auth.component_config VALUES ('d21d0cc2-9349-41a8-b4c0-82cda11dfefe', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'priority', '100');
INSERT INTO auth.component_config VALUES ('6b056c38-4dc9-4daf-a118-3795d23ab0d1', 'e3b9d9e4-5d98-4342-b9ef-90c888be84cc', 'certificate', 'MIICmzCCAYMCBgGaAWfPlTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjUxMDIwMTEzNDMxWhcNMzUxMDIwMTEzNjExWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDtwAnND4heyngCb1OGJVFNJmOC0OnAMPzz/AQnu1k3s/VA5vyfj5U9+fW6uRBSf6TVpQu+T01BwnhoXGMlaMSLeulrwSPDotJyslifejW9FvW3LoBG2a/s6t6HPkFrNfiiKguBli/ONy8eMCwQAQX0WMQhkMW6H8pyGtXp6j7ScQTCAT0MChlszNH1Vpv82m7Y92nyM3aT5BkY4LElO2iPV43aHOSGiSMYvKGvEElEk3mm0QlCLuUmBAG2o/Xft+3RuLIpJQXYS/wjTQeuEAg9JfG9xsX3DNY6QYnNUShGCT48UEK2CEkEP+AaHhwhr8nlic1smtz5OmeriK0xwmtbAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAG9y4JM4Im6NJfbHYCyfruz2qTOk4O4fz08hfdOgAqB6wml7xMNCHui8nRp0quVC3+gBNHXqTVdKxz48NXfAeuz+GjN9XD2fN95ZvD8If8+dRQ6xnxaMXEocebUWem8JxNdxXt0yjKxppQ/jBifEjHkObQZMIPu/bEDmg5FuQ4PZdQWSoCv/yewTBDKPGVabEk6stvqnqEFj/wowi93zV7fNaNB9aw80eRukKzAQ92BQNga1NkipMWwPobHHEyvmt75bGEgXbgWFF9Mke935AbLsv7L6r79HXiTXBO3t7egeT51JgmwxUVlPyisdja0E8qFJ+A8XFLGTG3TE6YJsDg0=');
INSERT INTO auth.component_config VALUES ('8862eef4-5bad-444a-9ba9-834ab334acaf', '5b29625a-0714-47e0-b3d1-9394f9079396', 'priority', '100');
INSERT INTO auth.component_config VALUES ('937afaa8-6a72-4e26-95bb-f6cda4df09f0', 'b95bd51f-20a0-4b38-9a91-09264df1c231', 'allow-default-scopes', 'true');
INSERT INTO auth.component_config VALUES ('82bf993b-c350-46bf-b03f-364468a0db14', '5b29625a-0714-47e0-b3d1-9394f9079396', 'privateKey', 'MIIEpAIBAAKCAQEA3uymqwJlsIZPOmj8GrqKisfyYR75GjMxHCFCRkafiVRkgxvPk5zulgrNx8NFlnd56oIWWCg6lGaEG7Qi0fiCgqPi9HdSQ4CfusPSS2sDjKtpjk/OzD08HZOfFVGUO+8px7hYt7O5wTIVTWUt5MQz336Ikw8WW1EM1BWX6nNp4V5J00MkZl3Z5c/vTiv4/wKl6mJe2axiXy6AvD40JyqzbdNSDWuKDb2nOKn6IMWT9M95P/ATBDk/T3WYmA2RfPB8n7wE8B0ssXQ28Cjw6seIc04j+C3oDxXHwoXGOVH+9nlYVmogVvwcs1miRmmY2AF6uCAg2p9yR/b3ocwGiOWstQIDAQABAoIBACCZY0sVM+kzTuE4CovfFRTz5dwxgxSDgW4/Z9luiPR0cKlilwGbXKF47XxFsEavbJbwVJOqOFzMvAtwFXp2mKFBlZYR3+gKpnERo05PlSqMQ4ih35gq6UBa/tPHhQGZuRahfOnKQMMBj69seSBf18UaVB8LQQX0DYfzK27H12czFHLLptTGhpq2ErBqBTQ/r3ua+Q23m4D110pUtOFcIM3j1wwadfOq0/9nIgl0grQJ29zKpaZPkD+nRIaHBtDqVrKos+MiWSqLqHLiPqvcTpZAMLVyOVEaP75ihw3amwg8K/GdFjrJqjq1Uyr7Pvv38414ZE4kkLNU6gI0JtQuyyECgYEA+S/yYqmIPYsOXmwb9Dg5IXiPvTsbOTHf+fF9ArnKbXi2Jrq2A8XhPAGOTZmfXBNu0d8AzfLfQ/a/QkQ3xipbqK+pTlc8vdqWaqWcI1yOf+B3JJ4BYclOeVfsGsx16Mh4T9Tmm6YtQCiA52XLKyNkphFMS8a+xvSluIeReM+tfWECgYEA5QTkK2sgaEDarYMJQC7oB41YCGvzTRNwwEjlGf/Inm0/LNV09CnNe4KQ0FbrcqpNe+hggnx3lWvq6+SNUohyyz49zF1zJz9lClk1rIslEw50fDF5Nsal9Dam2oPH6mBgkEE3qSfdoEOC1aXcmD0Ll0bLBf4rxh0RtARoUtQHO9UCgYEA3GWQ/7ysuKo+OjtqehYkSbtlftxBVtQLIvl5NSj4ptyGVzj69dlWPomtwGrorTqu4MdZ4c43tNgQD99gaVBbo5ZCq/yyx8UHFyqFMC2UB/yTxHpQBJpVYzPlq0o923c8GnfWw8I18bIhWQkKqovyYIOaNMeDQ1ttHAokG3OsIeECgYB83ZHZ6mqc7N9NwygECo8PrwzUaqcY2wSakiP3bPJhDodnVmqRxUj3klSKgxmURy4/5I7aFirNGS3Yt6Al46dTEPh4uGrUd0gLwF/3V1Y7caIpJIBGUUCiSjnm4frZ2vpLLIPAgq/fdW+cNPZ1OrNbI4oGFnKfbbH9SHnozxmykQKBgQDeFStpit9U8okahwmEvkX4UA5H3ylEHHFhFiVOXBjsg5bmL/JOVNQV79DnlDkzUjsWPprHyvAP8wjK62rV3VzVLSyp/l16SZIZ0DLiCbjZ9qfMGHwOGyuXcwzTzKtBgTnTaV1GTylKUfBS3oZuzoO5wFByVTzlSQalSQ/5M7U0UQ==');
INSERT INTO auth.component_config VALUES ('802bba59-8343-44a9-8a5b-4cb8edef927e', '5b29625a-0714-47e0-b3d1-9394f9079396', 'keyUse', 'SIG');
INSERT INTO auth.component_config VALUES ('d2cefcfe-5878-4f28-858a-83c9ad3a4c59', '5b29625a-0714-47e0-b3d1-9394f9079396', 'certificate', 'MIICmzCCAYMCBgGaAWfOqDANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjUxMDIwMTEzNDMxWhcNMzUxMDIwMTEzNjExWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDe7KarAmWwhk86aPwauoqKx/JhHvkaMzEcIUJGRp+JVGSDG8+TnO6WCs3Hw0WWd3nqghZYKDqUZoQbtCLR+IKCo+L0d1JDgJ+6w9JLawOMq2mOT87MPTwdk58VUZQ77ynHuFi3s7nBMhVNZS3kxDPffoiTDxZbUQzUFZfqc2nhXknTQyRmXdnlz+9OK/j/AqXqYl7ZrGJfLoC8PjQnKrNt01INa4oNvac4qfogxZP0z3k/8BMEOT9PdZiYDZF88HyfvATwHSyxdDbwKPDqx4hzTiP4LegPFcfChcY5Uf72eVhWaiBW/ByzWaJGaZjYAXq4ICDan3JH9vehzAaI5ay1AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIc2wFNNWA2s86FQ4FV1L2rQVJb6i4V2giHdgKkY3YLQW4D9DpeWD7asE5cGOp7xw7HyrspBxfM0ElepePkK6se/6wf057u1ecvJzV8vgXxSN9hsEpm3GMIq4+/K5RGlvfeQ6lxY9L1tJlhqVshcLoIVY6yKUOOu9C9rsDsEDhvbmLPdJxnB8V9RQZDNwV6seKppwnz1Q1mQbIvs2fTpqmzUMIGSbI0Ir5KlMgdsWHK75X4vQXkioo0CRls9lntV1dSUruvLyZMf4TFyRwQb61cmlMLeyPVOAnB/vSmOowaqJux2XJkrMdNv8swjo6NTEdyfcL/H4tXzUTfY/FW7/MY=');
INSERT INTO auth.component_config VALUES ('48e60672-18e4-406b-a9b7-1dc2f27ea101', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'kid', 'e7a4c20c-fffb-40c4-88d3-d7377b9e37d2');
INSERT INTO auth.component_config VALUES ('0568e9a2-aed6-4cd1-9681-4500321e9527', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'algorithm', 'HS512');
INSERT INTO auth.component_config VALUES ('ef45cd3c-4a60-4023-aa68-a7f2a2215c1b', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'secret', 'Oh9SxukoDayxKE7jogP5qiPblpvjnmEyAMhMtrBO51nsS0Ty0WuWI65QBSmC2DE7VhF9BU3T-KmeSG1BBEKFiSmUroLCQNso3MV-HTJI_5hsjvyKUzY6kuMnqDwofJwT8PDQZA_-ivKLOojJh1YIeJbA4P6aXWZZBmmgqqUuQmA');
INSERT INTO auth.component_config VALUES ('c33aad96-3cac-4f8e-b492-845820b9b551', '8d1e663f-0b09-4b85-9dfb-a0abfbee40e1', 'priority', '100');
INSERT INTO auth.component_config VALUES ('f82ddf18-89cc-4ec6-a5a8-aa7f17cbd13c', '6c58138c-8a7b-48ba-97c5-d98a5e342e92', 'kid', '52e0ea85-4a36-4205-ae04-3a11647d15a4');
INSERT INTO auth.component_config VALUES ('d7c043fd-98c2-4151-9e42-56c8143f226c', '6c58138c-8a7b-48ba-97c5-d98a5e342e92', 'priority', '100');
INSERT INTO auth.component_config VALUES ('33958d0b-0ed0-4c48-a6a2-438b57db0201', '6c58138c-8a7b-48ba-97c5-d98a5e342e92', 'secret', 'n3Ry8Iu53OKuBpKORTQgaA');
INSERT INTO auth.component_config VALUES ('b13ed293-b084-4294-9509-5f07e7c0352e', '9a37dbaf-6d05-4863-b2c2-f959b556c9ce', 'secret', 'R-HqBnngVf_OFc2efuF6ZeIlr42Sm8Htr8dfTv1a4Bq1zOnCnanrKTk-Lzmsysv_ypSF-jck4vyjGwQzJpZdF-S79DvfamOefIF1H4WY3pcgCJAxS45sIcbNSYVvGLQbp9JL2XKY_M3kTmR8BXJTLRTWvzZNf4oEOv6-_xpxFAE');
INSERT INTO auth.component_config VALUES ('42f29d9a-c49d-462f-8a8f-9319ce0cd337', '9a37dbaf-6d05-4863-b2c2-f959b556c9ce', 'priority', '100');
INSERT INTO auth.component_config VALUES ('60eda84e-e5db-410d-a010-bc9ed24b370a', '9a37dbaf-6d05-4863-b2c2-f959b556c9ce', 'algorithm', 'HS512');
INSERT INTO auth.component_config VALUES ('9b8d752a-6122-4250-9c43-b924659b2136', '9a37dbaf-6d05-4863-b2c2-f959b556c9ce', 'kid', 'f2bd5ddc-3b32-476f-bd17-b67ba7218f99');
INSERT INTO auth.component_config VALUES ('311a95c4-4566-4ca5-9c29-50c57a74a067', 'e6dc40e4-7869-4df4-89f2-af26377118ba', 'certificate', 'MIICozCCAYsCBgGccAwx+jANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApjb25kb21pbmlvMB4XDTI2MDIxODA5MTc1M1oXDTM2MDIxODA5MTkzM1owFTETMBEGA1UEAwwKY29uZG9taW5pbzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIRvnCWHO5i4Yl1TExiFw9mGXw+6FHXixqFnEiokJmO3z7nW2oe/erdiogAJjcNJbLd2r6zKEG7IL05hKmc8x3KhE85y+sHkbRL+hkAwjZB+pI4khjRxWlqbFXHjLmoxVXnC4gO57Zbb5bJPrzV7fZRW52veVXzuSU6CYxMhMGo2NUIlWzYk5XxuwEe7nh3mwbcydwyzmaqm0G0jYwNP6yiJRy46WBdYTjV9AOvPvSPCMtqiDGwxwuepR/fYdHmpc/hU7sJNQSjOnH/jSOFTxig29kHlbYxW6cKQz63GLsearnDLhrJlGeJJX1vCjYAmToQaL9mlkLmrQ5jOZlNBh3sCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAHTXgYbmfpywP0pzulVHhYivDgDGdSh+qu19yHI/2WzZZZTd4pwE/yQCR5b0+d5Gy1DX/Qv6L0WLgMTGjIGAsgpCiKpmQxfG/iFGRy0LKoh67LZV5h0tZXiF4QZxfuXr5C9IKH1gkcwxGszVMdTKJW60YrFU/g34ieQsZf7ex+H5grHJv1TrliWtvlIZNgC6TLjhiFglHf5JnVkO3uIfimWcv+DuO0RXybpkt2S9Wfeou3Md+xKu3MR1t8RoQGOy0zbk3Cr7yWjRq41B7vF9O9rI0v2G7YleJUHzLKZFFtyoIbwTel48n+6IrLp2Yd2KCLXRMrdVyuvMGoV6meX3lWg==');
INSERT INTO auth.component_config VALUES ('f29c466a-43d4-4362-a58a-c34995c3804e', 'e6dc40e4-7869-4df4-89f2-af26377118ba', 'privateKey', 'MIIEowIBAAKCAQEAhG+cJYc7mLhiXVMTGIXD2YZfD7oUdeLGoWcSKiQmY7fPudbah796t2KiAAmNw0lst3avrMoQbsgvTmEqZzzHcqETznL6weRtEv6GQDCNkH6kjiSGNHFaWpsVceMuajFVecLiA7ntltvlsk+vNXt9lFbna95VfO5JToJjEyEwajY1QiVbNiTlfG7AR7ueHebBtzJ3DLOZqqbQbSNjA0/rKIlHLjpYF1hONX0A68+9I8Iy2qIMbDHC56lH99h0ealz+FTuwk1BKM6cf+NI4VPGKDb2QeVtjFbpwpDPrcYux5qucMuGsmUZ4klfW8KNgCZOhBov2aWQuatDmM5mU0GHewIDAQABAoIBABXSzIDUpYn3jGIDkAiA9nKQdXbCe5+ndILhWLlwBpF1FzpxAMbQ01iH3NkzudQd89fRq4ZGL+oJe94nHdUwS0+E4p4pDVBJI343Sgkm1xUiAVzZAPKAYVq/5otDXAEsywCLEDJ7/35WEyZMgjtGc72vimgYla7GF3dj/g6HcBJ4SqMxszqcflPKmJZMQ8yajewWZwFiplKcemPVABewiR0N4miio121Lao/IhlDlNKBr9I/+0jbrC+TMT8/dhhNXu12KqB8u+vLbe0C4Hh/8wcnQW5/f0CkX4T88B5RpfymYkX+ksL3aYZqfQD4/OuiffsqEWmBMvN/5H3tTqv/IkkCgYEAuknEE7/ZcbwPR2KEaWWOzrA/dD26RthilmGgt0pNgApDz215W4ImIn/ZCiBMtbdtQqP6V9eBNiwvLNc/gJvE4iSv56NlTAprcTuyJR1WsEN+KCBpn1iIG2b7jynazfKBE0djg1ohJAXbAvd6uhh4Tm0ZJ2hoDqu2ruOTf652yxMCgYEAtf7a8iQg7Vy4Qu8UkifaumSccFdwVBtpktj/g4/wFmIgW9oX2lVAUEy3SYDihZDxkmc7HOXI58bPjdwoIiHd/3ouNJU4VK8VxIHpfgxZc1vqLicml7at1zoEnVlc7ck0CezhNatMnOOgDE5UgqndlcIdsLWLAw0kKyGKxZ2gNvkCgYBTElwO1om37z38/lC/01sIjo3tXy13ND1ahDSwJ8FBrNIqaM4qYXJyBgMaQecTTbW6dvdHPsHPD4sF+wLFbjExC10p9bJRY4AgIZfCdz/WIHLcn/+Z4FfpqFXbtLVvC4pFt5sH0yReNQJCY2vmGs1jY8FI0oU8rZQsjy2STZGJ4wKBgFUWQebTXVGb98nTXRq351sdjsY3Gx03c7RkH5GyydytI9PNszkwglEIjOigiUdI7Kg1+z0XcUZrfL4mH91VWCUJSnDrEtsEwHiPBEsaGvgEEQhi5XgowD3PsjiefwPs/ZdmWCRvYfI3uawHMxujryVFC/yB4+wZSL+hfu/FMhKBAoGBAIBQ2/FyDXnWSi0tcjVt5U6KdRMcQfmMSQHnezVfogsxWGbMPB7litzjRqQN7xlIcOQwqEFGbbmfomEQV89LTe/MY5XILlvhYrMEFIzx/4nyfZpNcjrpDb+ibAomdAcwnB0n/qSFD0oBqJ1PSKJQPpyH26rehlyEuuzdufAhj0GF');
INSERT INTO auth.component_config VALUES ('d27e77e2-cc7f-4a82-bc25-9be7d7bcd79e', 'e6dc40e4-7869-4df4-89f2-af26377118ba', 'keyUse', 'SIG');
INSERT INTO auth.component_config VALUES ('11f87f75-906d-418e-9bef-7e4683a378bf', 'e6dc40e4-7869-4df4-89f2-af26377118ba', 'priority', '100');
INSERT INTO auth.component_config VALUES ('3f60636f-f837-4dbd-9acc-bd6b731782a9', '7b8c5368-49a3-4638-9315-53b298fdf344', 'priority', '100');
INSERT INTO auth.component_config VALUES ('eb1bb382-652f-4831-8648-467e7ccef96c', '7b8c5368-49a3-4638-9315-53b298fdf344', 'certificate', 'MIICozCCAYsCBgGccAwy5zANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApjb25kb21pbmlvMB4XDTI2MDIxODA5MTc1M1oXDTM2MDIxODA5MTkzM1owFTETMBEGA1UEAwwKY29uZG9taW5pbzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALFWtIFTtuOp2ZbWp3VdR8aU/h2IRM5NHzNhiJScJyPIDCcpPlx0tQC1fKQFgJ9hklYqYYjbTxyV17LDFxxrCenBESKidBPBjUFAXeIP0NQJydUu6DqbDmT7ZLJk4u90tdfUiOwojhLEe7hTdnMfZ4AjpVOoim5peNxPTcGEcA1d48pPUE9zVWDzMerz9p6UQd58EJvOLohrwKCByjBCQSFbGJYCqaDr7EzRDXTNTwFA9M+qZfUpzq2AMeVKYEhCkR8dSgUBIf5a4D13hhy1axZ5DJlSFBuG1JRXAgIIaUdauZW+OdaMd1fWVCZ8dqzIxYKCkIg2uEjKNvI9HYE/Zo0CAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAZ3gUGPF3DaczvXTTvSuoj3RH6Q9UY1o8o5HMWOVWxEZixAWTj3ByrcyoxHlsN4MV38eLh9V+Un1STAgOGVinpTfB1KlnpUyX38AXeM+hgMADzg7D92G0/wGvMSgzGSwMjXYN5xTI5aZ1AxVG9IxHuM4XhRqQ7NMXFIhwXurYcfM3DboFQXca4tn8mRB4uoa5dB3rIjIy7UkiNNR1JLArSLjNMdWcIbSMOWTH0OT5f0NXSMOhu4ICy7Jehuj/QIpjWGxAVnyyk4CyPJimw3PvAQR7giM5e7bC9RB4Nlz+G3zDZPnumrhF69hbtXCpdpeghz9h5zp45ikZskUaWeBSfQ==');
INSERT INTO auth.component_config VALUES ('dfc0f562-9b7b-4eeb-8768-ef7290f15d47', '7b8c5368-49a3-4638-9315-53b298fdf344', 'privateKey', 'MIIEpAIBAAKCAQEAsVa0gVO246nZltandV1HxpT+HYhEzk0fM2GIlJwnI8gMJyk+XHS1ALV8pAWAn2GSViphiNtPHJXXssMXHGsJ6cERIqJ0E8GNQUBd4g/Q1AnJ1S7oOpsOZPtksmTi73S119SI7CiOEsR7uFN2cx9ngCOlU6iKbml43E9NwYRwDV3jyk9QT3NVYPMx6vP2npRB3nwQm84uiGvAoIHKMEJBIVsYlgKpoOvsTNENdM1PAUD0z6pl9SnOrYAx5UpgSEKRHx1KBQEh/lrgPXeGHLVrFnkMmVIUG4bUlFcCAghpR1q5lb451ox3V9ZUJnx2rMjFgoKQiDa4SMo28j0dgT9mjQIDAQABAoIBADHcujYezq6mpDqIMl+KkdLhM64kEYycHKi6xMdcPJkP93LPYuxmGDqRzPDlZyvpKFc35WKwn0bfTt3Bgu8HnarvER1W5iJj6o6tRXh5j/L+qZRacwt/a4WzNbX/Ldu8SiDcbn9QS9o1CsBiH0zxSI27+BFUs0+mMkhnt+owjb0D75q226zxgmgyIHA3K/zFOi9MOA11Zb378wVN1NnEHLEhnZoFGt3UjxvqGoHF8NML75pyNCSNcynEbxZnEbtEXwTtBUjJamZCRWsq2vgnJoffk6tVA8gG4OjdSNZ29XnFs0YlBOn9PK1YTktTFBUqahUw2z/HOA8ayJkGA+Q/nnUCgYEA7woP/gbDY7zinxYoyzByYKJBEyuIvMnXCGauil2VGayMLjdt5OqMy4bvxjwpef3uUWeP1PTrtiUhrYVd2/CcE58YA9Ht+oOS5xeSb4JXpxHvr6yPfIIy0DFMGS0x9JlzR8LGemww56+WackhrlyGA8puNjO91RJZAcR+lsD/qXMCgYEAvevn0e6ztDYuJ/bSeXAzCbKBxKnrZzjwF3FQhGqmEACJTZiLnV6JSwchf4QZQidkN6Zfk7MTEwAaCs1lVuwwcLqFo7MkOcfgRqYpd09GWNl0NfiZ3wjOvunMd1T1aNGXhP+EdzOI/qpVdEEiKguDU4q4h7jsa9COP11cGRtAr/8CgYA1VfpxhNLOC1RJiOk7RSkQNMPuYhVVgnfPcRHa37yoCN8SZN3JaShXNVmE0uGyTZ2CXmgybR+2+ZwFGq/xpkM9AY+bMpk1/2uk0pai+ONT7OWdPhSaBHcQCx/esj3mROL7DRO6Ny/GUmBuZCl2vUBN0jo7L9pYk4p2oYBZZODmzwKBgQCH7WRQSxBQxYpJTg0bnyLYKOtZjueNTCICFTa0XwQVZdzfLXOXIQcQLL1b33aYc0r1zVyQgFUBf0wkORbznD2bINPu8pLVy+kHh3scCh/mDVRwIEo4Z7xYxUpyidrOt1tDdAEhsz+0TMK2XruN7gmC7EDf2olTLMPyM+ZrjabBjwKBgQCfmFgI0Y2F47yCzBGvwbvfkQAcXBC5ccAcoKySpIyK6mTyH4Ip54KTyjVPy0p8Q+euRp3PFkFW9Uwgxu2Ou8QpawzaOuN2bICAPPZD7+vDp+Xa9QsWVLMRWUQg+uS5ZI6COQl42LSZsQxi7OKPZzG374nmcSt/6BXJJuP4/mPOcA==');
INSERT INTO auth.component_config VALUES ('63f6dbe8-c36a-4f08-a0e3-1397906168cb', '7b8c5368-49a3-4638-9315-53b298fdf344', 'keyUse', 'ENC');
INSERT INTO auth.component_config VALUES ('68ef5806-37ca-4983-9a51-df4f4354c4c9', '7b8c5368-49a3-4638-9315-53b298fdf344', 'algorithm', 'RSA-OAEP');
INSERT INTO auth.component_config VALUES ('34f4bf6c-fef1-4a23-bc38-751a939aabe2', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO auth.component_config VALUES ('424445f2-f502-4c91-b29f-e7ab44596ad2', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO auth.component_config VALUES ('a273b42e-28ba-45ef-8900-d907b2e94c9c', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO auth.component_config VALUES ('01ea251f-d6d1-4b22-9032-c3c0cacbeec4', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO auth.component_config VALUES ('001363dd-00b9-4639-9122-83c05373e1aa', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO auth.component_config VALUES ('4617e8a8-3a62-4caf-9d5a-6ee336ff4a39', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO auth.component_config VALUES ('c45fe74b-0149-4a29-8ca2-2fa88d48bda1', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO auth.component_config VALUES ('2a6e2c34-6999-4f0c-a729-1c43a4e00a3e', 'b4255e5b-e3bf-4b60-97fb-a0d436a08acd', 'allowed-protocol-mapper-types', 'oidc-address-mapper');
INSERT INTO auth.component_config VALUES ('db158eda-a4a5-4832-9449-117f3e4c9b2a', 'ef346b2b-d54f-4465-96d6-1857668e8fe2', 'client-uris-must-match', 'true');
INSERT INTO auth.component_config VALUES ('f5576798-a6a4-42c5-834d-c270235cfc65', 'ef346b2b-d54f-4465-96d6-1857668e8fe2', 'host-sending-registration-request-must-match', 'true');
INSERT INTO auth.component_config VALUES ('8195c4ec-14d4-4595-b2d3-511d657e751d', '2e7ff0d5-e5da-4d95-beec-e2089b404272', 'max-clients', '200');
INSERT INTO auth.component_config VALUES ('f3764b86-a0f0-41ca-9d37-3be02dcf9404', '61a9748a-f428-4b29-8975-5566a917904a', 'allow-default-scopes', 'true');
INSERT INTO auth.component_config VALUES ('2dab993c-6620-4cbc-822d-1e1844e10ef3', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'saml-role-list-mapper');
INSERT INTO auth.component_config VALUES ('ae762525-ab9c-4cb5-b5d4-12a92a60690d', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'saml-user-attribute-mapper');
INSERT INTO auth.component_config VALUES ('d5fd4a26-41cc-4570-8831-ac3dae0e41bb', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'saml-user-property-mapper');
INSERT INTO auth.component_config VALUES ('9bf8015a-d9fc-47f6-868c-700c99c84b05', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'oidc-usermodel-attribute-mapper');
INSERT INTO auth.component_config VALUES ('38268136-16bb-4520-aa6b-d235dcfb180b', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'oidc-full-name-mapper');
INSERT INTO auth.component_config VALUES ('20d3fff8-a8e6-4c38-92dc-6f2522fcf949', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'oidc-usermodel-property-mapper');
INSERT INTO auth.component_config VALUES ('07556b2a-8395-4748-9d79-76ff7f006749', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'oidc-sha256-pairwise-sub-mapper');
INSERT INTO auth.component_config VALUES ('0fbed8d2-8579-4ccf-a652-fa31a2f8dbf8', 'b8c59707-d356-4358-96f2-b3ec5d891de7', 'allowed-protocol-mapper-types', 'oidc-address-mapper');


--
-- TOC entry 4272 (class 0 OID 16480)
-- Dependencies: 236
-- Data for Name: composite_role; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8e3d03e5-e70a-460f-8d22-bb11ecabcae3');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '1bf774c0-76b5-43d3-a6ab-580554987f88');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '90da9da7-9cbd-4e08-afe2-b657bdca5ac0');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'fe8410b4-6e80-4979-ad47-941c192ad518');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'dceb8aa5-57cb-4636-9e53-d4c22906571d');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '393c8228-dabe-4927-bec5-d62e0f372af9');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'bcf549e9-6de7-4ba3-a2d7-7864f460fe6a');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6c32a60e-78de-4b5a-b19c-69eb7e84ac9a');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'd5ff873d-5bc6-444c-89db-b2a7573008ca');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6d21a91c-7886-4b8c-8933-7e6f708606fe');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '966551e2-bdb1-4c42-a1f4-10c85d410db2');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '2c9a23ac-4921-404e-99df-1f5a7b85cd7f');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'c56c1682-22c0-4d14-b41f-af9641674de5');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '689bf969-bf06-440a-95a4-8429cc400d09');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '46d4c4c6-ab10-47b3-9665-43d3f44aaa63');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '325745f8-d041-4e42-8a89-466e404c775b');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '75bb763a-6fc1-4bfe-8432-da1fc12e5efd');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'dd58dfd2-861f-41eb-9dc8-d956324f9ccd');
INSERT INTO auth.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'c5fbb5ee-4707-425f-836d-3d833f7c294f');
INSERT INTO auth.composite_role VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', '325745f8-d041-4e42-8a89-466e404c775b');
INSERT INTO auth.composite_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', '46d4c4c6-ab10-47b3-9665-43d3f44aaa63');
INSERT INTO auth.composite_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', 'dd58dfd2-861f-41eb-9dc8-d956324f9ccd');
INSERT INTO auth.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');
INSERT INTO auth.composite_role VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', 'a471a901-48ee-443e-90b1-2c70abd516ea');
INSERT INTO auth.composite_role VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', 'd416a33e-2abf-4dc2-b9fa-94a23017e858');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '3a3b68f5-5620-44aa-974f-6b1cf9c2c12a');
INSERT INTO auth.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'a3f06c98-eaeb-4470-98d5-09268563e97f');
INSERT INTO auth.composite_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', 'b83d7ede-d9b5-493d-bb43-8a5e641d5085');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'd416a33e-2abf-4dc2-b9fa-94a23017e858');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'c5fbb5ee-4707-425f-836d-3d833f7c294f');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'bd5731c3-d8e2-4830-b512-a914de001373');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'a471a901-48ee-443e-90b1-2c70abd516ea');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '8095b4ff-6f0d-414b-8057-22d5471ad338');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '5e45631a-17db-48f8-87dd-278459b02b54');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '421c0b73-7158-4267-9c20-5574729807df');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '492be749-88d3-41b0-840a-e123476fe153');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '4d97730d-7083-4f63-9fdb-3572f2ff25bf');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'd0a07657-2f88-4f42-9f14-6bb26f4bb9af');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '6828aab4-b6b8-4479-8d49-2016f32d4738');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'cb3b8a3f-f8bb-41a5-b3dc-0a4b7cbb9920');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '324a1198-8182-4734-8c09-c5a9404ea00f');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '87373ef5-3d9c-4dfe-9a6e-657e391346f0');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '3fa51ad2-46dc-43d4-a4dd-0e6c7e9aef16');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '1af997e6-531d-429a-ab70-c072a047100f');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '2ac40628-0e24-4592-abe2-fc514fe4d4c9');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'e1e97732-6cf6-4ee9-90a5-8909dbb171ea');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'f58a7d9a-88e5-47f1-986d-d71fec912224');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '73d01fb5-b1ab-4f72-8c33-a29fe93c378b');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '74eeb0f0-1776-4d5b-b585-b00629a21170');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '2740f303-4323-4112-8646-85edc81139f2');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', 'aa5d18ba-9a50-40c6-858f-d9e18d8350f1');
INSERT INTO auth.composite_role VALUES ('4d97730d-7083-4f63-9fdb-3572f2ff25bf', '73d01fb5-b1ab-4f72-8c33-a29fe93c378b');
INSERT INTO auth.composite_role VALUES ('4d97730d-7083-4f63-9fdb-3572f2ff25bf', 'aa5d18ba-9a50-40c6-858f-d9e18d8350f1');
INSERT INTO auth.composite_role VALUES ('d0a07657-2f88-4f42-9f14-6bb26f4bb9af', '74eeb0f0-1776-4d5b-b585-b00629a21170');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '934863eb-19a3-43d8-a67b-f9b37920fbd2');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '8b338dad-a8bf-4763-a162-ee526b513c21');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '1d79d23b-665b-463c-a8da-739ed67041f8');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', 'c7db9779-ef41-46f8-ad5d-6cca47279246');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '94299728-d170-46e8-ac78-edd9239867a4');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '4d6c6704-bb2e-47cd-bfa8-5e54fea2045a');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '153043ef-4bcb-4a8b-814c-2d7faf6332b3');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '02ccc953-fe7e-4770-b402-2f3a750fdd00');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', 'a3fe7db6-f6d9-4db7-a909-d573f5905ceb');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '536f58f1-150e-40f9-bc33-4d59f912ba45');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '5bcd0748-e7a5-491d-9f86-e0d386bf08be');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', 'b5f90471-6f59-4ebb-91e3-7a5a622e98bc');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '2288496f-eea3-4b75-b2a1-5f917cb1a6cf');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '852c7e70-dc5c-4fc1-a153-683cd7a3b91f');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '9b47a50c-fb81-4258-a7c9-2da92d1919e9');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '12cc8e18-7edf-4a55-9382-efe5a246a6cc');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', '003409a2-f22d-420e-a493-c3e8e44cd711');
INSERT INTO auth.composite_role VALUES ('1d79d23b-665b-463c-a8da-739ed67041f8', '852c7e70-dc5c-4fc1-a153-683cd7a3b91f');
INSERT INTO auth.composite_role VALUES ('1d79d23b-665b-463c-a8da-739ed67041f8', '003409a2-f22d-420e-a493-c3e8e44cd711');
INSERT INTO auth.composite_role VALUES ('c7db9779-ef41-46f8-ad5d-6cca47279246', '9b47a50c-fb81-4258-a7c9-2da92d1919e9');
INSERT INTO auth.composite_role VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '208a0962-68c2-4167-b725-a1b9bd8506bd');
INSERT INTO auth.composite_role VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '23a43d84-86f5-4537-a4ce-bf0be37559c1');
INSERT INTO auth.composite_role VALUES ('23a43d84-86f5-4537-a4ce-bf0be37559c1', 'c8e6d0ea-215d-4e90-a1f4-91b21f6c7aac');
INSERT INTO auth.composite_role VALUES ('11498f02-8327-47df-9fff-3c6a52364b4a', '1bf0b636-8da4-43bd-ba77-98725a0dcc37');
INSERT INTO auth.composite_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '39af18c4-976f-4177-9883-d69e745b6173');
INSERT INTO auth.composite_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', 'f835b8be-a14e-42fc-b1fe-9d682a9966c4');
INSERT INTO auth.composite_role VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '1ea38dc4-b1bd-4f5f-bd2b-cc4a119df8b2');
INSERT INTO auth.composite_role VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '281f6695-40a4-4ba2-95b8-b30c5224f0f6');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '9b47a50c-fb81-4258-a7c9-2da92d1919e9');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '2288496f-eea3-4b75-b2a1-5f917cb1a6cf');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '536f58f1-150e-40f9-bc33-4d59f912ba45');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '934863eb-19a3-43d8-a67b-f9b37920fbd2');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '94299728-d170-46e8-ac78-edd9239867a4');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', 'a3fe7db6-f6d9-4db7-a909-d573f5905ceb');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '5bcd0748-e7a5-491d-9f86-e0d386bf08be');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '12cc8e18-7edf-4a55-9382-efe5a246a6cc');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', 'f835b8be-a14e-42fc-b1fe-9d682a9966c4');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '4d6c6704-bb2e-47cd-bfa8-5e54fea2045a');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', 'c7db9779-ef41-46f8-ad5d-6cca47279246');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '02ccc953-fe7e-4770-b402-2f3a750fdd00');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '852c7e70-dc5c-4fc1-a153-683cd7a3b91f');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '153043ef-4bcb-4a8b-814c-2d7faf6332b3');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '1d79d23b-665b-463c-a8da-739ed67041f8');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '8b338dad-a8bf-4763-a162-ee526b513c21');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '003409a2-f22d-420e-a493-c3e8e44cd711');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', 'dc5b5a9a-272c-41b3-bf80-4208f65b2dba');
INSERT INTO auth.composite_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', 'b5f90471-6f59-4ebb-91e3-7a5a622e98bc');


--
-- TOC entry 4273 (class 0 OID 16483)
-- Dependencies: 237
-- Data for Name: credential; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.credential VALUES ('9627f3fd-4d96-439c-bbdd-a042507b8ac0', NULL, 'password', '679d8ad7-2047-41eb-b88e-bad459ccdc81', 1760965852735, 'My password', '{"value":"P8+WO2V7N/1JWat0oPt3T51lPh/9nyAJpRpmJUUd7sk=","salt":"EaDlQfc5GQ662rulI7ereQ==","additionalParameters":{}}', '{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}', 10, 1);
INSERT INTO auth.credential VALUES ('f25ddc44-62d2-4686-9022-1809e6dd1771', NULL, 'password', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c', 1772537210969, 'My password', '{"value":"y4BgWMQnUUJYgkJcTDCWIZOB+PC/zEV99EszggO8sGg=","salt":"rAilLSFL+cFPcQZZQNph2g==","additionalParameters":{}}', '{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}', 10, 1);


--
-- TOC entry 4274 (class 0 OID 16489)
-- Dependencies: 238
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.databasechangelog VALUES ('1.0.0.Final-KEYCLOAK-5461', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.0.0.Final.xml', '2025-10-20 11:35:57.088317', 1, 'EXECUTED', '9:6f1016664e21e16d26517a4418f5e3df', 'createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.0.0.Final-KEYCLOAK-5461', 'sthorger@redhat.com', 'META-INF/db2-jpa-changelog-1.0.0.Final.xml', '2025-10-20 11:35:57.135871', 2, 'MARK_RAN', '9:828775b1596a07d1200ba1d49e5e3941', 'createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.1.0.Beta1', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.1.0.Beta1.xml', '2025-10-20 11:35:57.252943', 3, 'EXECUTED', '9:5f090e44a7d595883c1fb61f4b41fd38', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.1.0.Final', 'sthorger@redhat.com', 'META-INF/jpa-changelog-1.1.0.Final.xml', '2025-10-20 11:35:57.26601', 4, 'EXECUTED', '9:c07e577387a3d2c04d1adc9aaad8730e', 'renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.2.0.Beta1', 'psilva@redhat.com', 'META-INF/jpa-changelog-1.2.0.Beta1.xml', '2025-10-20 11:35:57.507733', 5, 'EXECUTED', '9:b68ce996c655922dbcd2fe6b6ae72686', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.2.0.Beta1', 'psilva@redhat.com', 'META-INF/db2-jpa-changelog-1.2.0.Beta1.xml', '2025-10-20 11:35:57.517902', 6, 'MARK_RAN', '9:543b5c9989f024fe35c6f6c5a97de88e', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.2.0.RC1', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.2.0.CR1.xml', '2025-10-20 11:35:57.71795', 7, 'EXECUTED', '9:765afebbe21cf5bbca048e632df38336', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.2.0.RC1', 'bburke@redhat.com', 'META-INF/db2-jpa-changelog-1.2.0.CR1.xml', '2025-10-20 11:35:57.729759', 8, 'MARK_RAN', '9:db4a145ba11a6fdaefb397f6dbf829a1', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.2.0.Final', 'keycloak', 'META-INF/jpa-changelog-1.2.0.Final.xml', '2025-10-20 11:35:57.746607', 9, 'EXECUTED', '9:9d05c7be10cdb873f8bcb41bc3a8ab23', 'update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.3.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.3.0.xml', '2025-10-20 11:35:57.931903', 10, 'EXECUTED', '9:18593702353128d53111f9b1ff0b82b8', 'delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.4.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.4.0.xml', '2025-10-20 11:35:58.001572', 11, 'EXECUTED', '9:6122efe5f090e41a85c0f1c9e52cbb62', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.4.0', 'bburke@redhat.com', 'META-INF/db2-jpa-changelog-1.4.0.xml', '2025-10-20 11:35:58.006894', 12, 'MARK_RAN', '9:e1ff28bf7568451453f844c5d54bb0b5', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.5.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.5.0.xml', '2025-10-20 11:35:58.037502', 13, 'EXECUTED', '9:7af32cd8957fbc069f796b61217483fd', 'delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.6.1_from15', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.085286', 14, 'EXECUTED', '9:6005e15e84714cd83226bf7879f54190', 'addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.6.1_from16-pre', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.088895', 15, 'MARK_RAN', '9:bf656f5a2b055d07f314431cae76f06c', 'delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.6.1_from16', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.092574', 16, 'MARK_RAN', '9:f8dadc9284440469dcf71e25ca6ab99b', 'dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.6.1', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.6.1.xml', '2025-10-20 11:35:58.101644', 17, 'EXECUTED', '9:d41d8cd98f00b204e9800998ecf8427e', 'empty', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.7.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-1.7.0.xml', '2025-10-20 11:35:58.17846', 18, 'EXECUTED', '9:3368ff0be4c2855ee2dd9ca813b38d8e', 'createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.8.0', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.259787', 19, 'EXECUTED', '9:8ac2fb5dd030b24c0570a763ed75ed20', 'addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.8.0-2', 'keycloak', 'META-INF/jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.27536', 20, 'EXECUTED', '9:f91ddca9b19743db60e3057679810e6c', 'dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.8.0', 'mposolda@redhat.com', 'META-INF/db2-jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.281176', 21, 'MARK_RAN', '9:831e82914316dc8a57dc09d755f23c51', 'addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.8.0-2', 'keycloak', 'META-INF/db2-jpa-changelog-1.8.0.xml', '2025-10-20 11:35:58.290152', 22, 'MARK_RAN', '9:f91ddca9b19743db60e3057679810e6c', 'dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.9.0', 'mposolda@redhat.com', 'META-INF/jpa-changelog-1.9.0.xml', '2025-10-20 11:35:58.448005', 23, 'EXECUTED', '9:bc3d0f9e823a69dc21e23e94c7a94bb1', 'update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.9.1', 'keycloak', 'META-INF/jpa-changelog-1.9.1.xml', '2025-10-20 11:35:58.458567', 24, 'EXECUTED', '9:c9999da42f543575ab790e76439a2679', 'modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.9.1', 'keycloak', 'META-INF/db2-jpa-changelog-1.9.1.xml', '2025-10-20 11:35:58.466807', 25, 'MARK_RAN', '9:0d6c65c6f58732d81569e77b10ba301d', 'modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('1.9.2', 'keycloak', 'META-INF/jpa-changelog-1.9.2.xml', '2025-10-20 11:35:59.033821', 26, 'EXECUTED', '9:fc576660fc016ae53d2d4778d84d86d0', 'createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-2.0.0', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-2.0.0.xml', '2025-10-20 11:35:59.157909', 27, 'EXECUTED', '9:43ed6b0da89ff77206289e87eaa9c024', 'createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-2.5.1', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-2.5.1.xml', '2025-10-20 11:35:59.163137', 28, 'EXECUTED', '9:44bae577f551b3738740281eceb4ea70', 'update tableName=RESOURCE_SERVER_POLICY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.1.0-KEYCLOAK-5461', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.1.0.xml', '2025-10-20 11:35:59.266674', 29, 'EXECUTED', '9:bd88e1f833df0420b01e114533aee5e8', 'createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.2.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.2.0.xml', '2025-10-20 11:35:59.302597', 30, 'EXECUTED', '9:a7022af5267f019d020edfe316ef4371', 'addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.3.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.3.0.xml', '2025-10-20 11:35:59.334188', 31, 'EXECUTED', '9:fc155c394040654d6a79227e56f5e25a', 'createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.4.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.4.0.xml', '2025-10-20 11:35:59.34135', 32, 'EXECUTED', '9:eac4ffb2a14795e5dc7b426063e54d88', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.354777', 33, 'EXECUTED', '9:54937c05672568c4c64fc9524c1e9462', 'customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.0-unicode-oracle', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.359054', 34, 'MARK_RAN', '9:1f9da21e444f4a539619ea5df1a8e089', 'modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.0-unicode-other-dbs', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.420378', 35, 'EXECUTED', '9:33d72168746f81f98ae3a1e8e0ca3554', 'modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.0-duplicate-email-support', 'slawomir@dabek.name', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.429398', 36, 'EXECUTED', '9:61b6d3d7a4c0e0024b0c839da283da0c', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.0-unique-group-names', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-2.5.0.xml', '2025-10-20 11:35:59.44047', 37, 'EXECUTED', '9:8dcac7bdf7378e7d823cdfddebf72fda', 'addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('2.5.1', 'bburke@redhat.com', 'META-INF/jpa-changelog-2.5.1.xml', '2025-10-20 11:35:59.446618', 38, 'EXECUTED', '9:a2b870802540cb3faa72098db5388af3', 'addColumn tableName=FED_USER_CONSENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.0.0', 'bburke@redhat.com', 'META-INF/jpa-changelog-3.0.0.xml', '2025-10-20 11:35:59.453139', 39, 'EXECUTED', '9:132a67499ba24bcc54fb5cbdcfe7e4c0', 'addColumn tableName=IDENTITY_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.2.0-fix', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.456188', 40, 'MARK_RAN', '9:938f894c032f5430f2b0fafb1a243462', 'addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.2.0-fix-with-keycloak-5416', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.460597', 41, 'MARK_RAN', '9:845c332ff1874dc5d35974b0babf3006', 'dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.2.0-fix-offline-sessions', 'hmlnarik', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:35:59.469983', 42, 'EXECUTED', '9:fc86359c079781adc577c5a217e4d04c', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.2.0-fixed', 'keycloak', 'META-INF/jpa-changelog-3.2.0.xml', '2025-10-20 11:36:02.361426', 43, 'EXECUTED', '9:59a64800e3c0d09b825f8a3b444fa8f4', 'addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.3.0', 'keycloak', 'META-INF/jpa-changelog-3.3.0.xml', '2025-10-20 11:36:02.369445', 44, 'EXECUTED', '9:d48d6da5c6ccf667807f633fe489ce88', 'addColumn tableName=USER_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part1', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.378438', 45, 'EXECUTED', '9:dde36f7973e80d71fceee683bc5d2951', 'addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.387069', 46, 'EXECUTED', '9:b855e9b0a406b34fa323235a0cf4f640', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part3-fixed', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.389503', 47, 'MARK_RAN', '9:51abbacd7b416c50c4421a8cabf7927e', 'dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.590612', 48, 'EXECUTED', '9:bdc99e567b3398bac83263d375aad143', 'addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authn-3.4.0.CR1-refresh-token-max-reuse', 'glavoie@gmail.com', 'META-INF/jpa-changelog-authz-3.4.0.CR1.xml', '2025-10-20 11:36:02.597066', 49, 'EXECUTED', '9:d198654156881c46bfba39abd7769e69', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.4.0', 'keycloak', 'META-INF/jpa-changelog-3.4.0.xml', '2025-10-20 11:36:02.653944', 50, 'EXECUTED', '9:cfdd8736332ccdd72c5256ccb42335db', 'addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.4.0-KEYCLOAK-5230', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-3.4.0.xml', '2025-10-20 11:36:03.156192', 51, 'EXECUTED', '9:7c84de3d9bd84d7f077607c1a4dcb714', 'createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.4.1', 'psilva@redhat.com', 'META-INF/jpa-changelog-3.4.1.xml', '2025-10-20 11:36:03.160319', 52, 'EXECUTED', '9:5a6bb36cbefb6a9d6928452c0852af2d', 'modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.4.2', 'keycloak', 'META-INF/jpa-changelog-3.4.2.xml', '2025-10-20 11:36:03.163587', 53, 'EXECUTED', '9:8f23e334dbc59f82e0a328373ca6ced0', 'update tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('3.4.2-KEYCLOAK-5172', 'mkanis@redhat.com', 'META-INF/jpa-changelog-3.4.2.xml', '2025-10-20 11:36:03.166457', 54, 'EXECUTED', '9:9156214268f09d970cdf0e1564d866af', 'update tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.0.0-KEYCLOAK-6335', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.177532', 55, 'EXECUTED', '9:db806613b1ed154826c02610b7dbdf74', 'createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.0.0-CLEANUP-UNUSED-TABLE', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.181991', 56, 'EXECUTED', '9:229a041fb72d5beac76bb94a5fa709de', 'dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.0.0-KEYCLOAK-6228', 'bburke@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.242313', 57, 'EXECUTED', '9:079899dade9c1e683f26b2aa9ca6ff04', 'dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.0.0-KEYCLOAK-5579-fixed', 'mposolda@redhat.com', 'META-INF/jpa-changelog-4.0.0.xml', '2025-10-20 11:36:03.764045', 58, 'EXECUTED', '9:139b79bcbbfe903bb1c2d2a4dbf001d9', 'dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-4.0.0.CR1', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-4.0.0.CR1.xml', '2025-10-20 11:36:03.795287', 59, 'EXECUTED', '9:b55738ad889860c625ba2bf483495a04', 'createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-4.0.0.Beta3', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-4.0.0.Beta3.xml', '2025-10-20 11:36:03.802556', 60, 'EXECUTED', '9:e0057eac39aa8fc8e09ac6cfa4ae15fe', 'addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-4.2.0.Final', 'mhajas@redhat.com', 'META-INF/jpa-changelog-authz-4.2.0.Final.xml', '2025-10-20 11:36:03.810945', 61, 'EXECUTED', '9:42a33806f3a0443fe0e7feeec821326c', 'createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-4.2.0.Final-KEYCLOAK-9944', 'hmlnarik@redhat.com', 'META-INF/jpa-changelog-authz-4.2.0.Final.xml', '2025-10-20 11:36:03.818521', 62, 'EXECUTED', '9:9968206fca46eecc1f51db9c024bfe56', 'addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.2.0-KEYCLOAK-6313', 'wadahiro@gmail.com', 'META-INF/jpa-changelog-4.2.0.xml', '2025-10-20 11:36:03.824447', 63, 'EXECUTED', '9:92143a6daea0a3f3b8f598c97ce55c3d', 'addColumn tableName=REQUIRED_ACTION_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.3.0-KEYCLOAK-7984', 'wadahiro@gmail.com', 'META-INF/jpa-changelog-4.3.0.xml', '2025-10-20 11:36:03.828793', 64, 'EXECUTED', '9:82bab26a27195d889fb0429003b18f40', 'update tableName=REQUIRED_ACTION_PROVIDER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.6.0-KEYCLOAK-7950', 'psilva@redhat.com', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.832819', 65, 'EXECUTED', '9:e590c88ddc0b38b0ae4249bbfcb5abc3', 'update tableName=RESOURCE_SERVER_RESOURCE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.6.0-KEYCLOAK-8377', 'keycloak', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.891804', 66, 'EXECUTED', '9:5c1f475536118dbdc38d5d7977950cc0', 'createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.6.0-KEYCLOAK-8555', 'gideonray@gmail.com', 'META-INF/jpa-changelog-4.6.0.xml', '2025-10-20 11:36:03.944988', 67, 'EXECUTED', '9:e7c9f5f9c4d67ccbbcc215440c718a17', 'createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.7.0-KEYCLOAK-1267', 'sguilhen@redhat.com', 'META-INF/jpa-changelog-4.7.0.xml', '2025-10-20 11:36:03.949722', 68, 'EXECUTED', '9:88e0bfdda924690d6f4e430c53447dd5', 'addColumn tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.7.0-KEYCLOAK-7275', 'keycloak', 'META-INF/jpa-changelog-4.7.0.xml', '2025-10-20 11:36:04.005829', 69, 'EXECUTED', '9:f53177f137e1c46b6a88c59ec1cb5218', 'renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('4.8.0-KEYCLOAK-8835', 'sguilhen@redhat.com', 'META-INF/jpa-changelog-4.8.0.xml', '2025-10-20 11:36:04.012828', 70, 'EXECUTED', '9:a74d33da4dc42a37ec27121580d1459f', 'addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('authz-7.0.0-KEYCLOAK-10443', 'psilva@redhat.com', 'META-INF/jpa-changelog-authz-7.0.0.xml', '2025-10-20 11:36:04.017373', 71, 'EXECUTED', '9:fd4ade7b90c3b67fae0bfcfcb42dfb5f', 'addColumn tableName=RESOURCE_SERVER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('8.0.0-adding-credential-columns', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.024877', 72, 'EXECUTED', '9:aa072ad090bbba210d8f18781b8cebf4', 'addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('8.0.0-updating-credential-data-not-oracle-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.033318', 73, 'EXECUTED', '9:1ae6be29bab7c2aa376f6983b932be37', 'update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('8.0.0-updating-credential-data-oracle-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.0366', 74, 'MARK_RAN', '9:14706f286953fc9a25286dbd8fb30d97', 'update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('8.0.0-credential-cleanup-fixed', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.062064', 75, 'EXECUTED', '9:2b9cc12779be32c5b40e2e67711a218b', 'dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('8.0.0-resource-tag-support', 'keycloak', 'META-INF/jpa-changelog-8.0.0.xml', '2025-10-20 11:36:04.126971', 76, 'EXECUTED', '9:91fa186ce7a5af127a2d7a91ee083cc5', 'addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.0-always-display-client', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.13154', 77, 'EXECUTED', '9:6335e5c94e83a2639ccd68dd24e2e5ad', 'addColumn tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.0-drop-constraints-for-column-increase', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.134084', 78, 'MARK_RAN', '9:6bdb5658951e028bfe16fa0a8228b530', 'dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.0-increase-column-size-federated-fk', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.153756', 79, 'EXECUTED', '9:d5bc15a64117ccad481ce8792d4c608f', 'modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.0-recreate-constraints-after-column-increase', 'keycloak', 'META-INF/jpa-changelog-9.0.0.xml', '2025-10-20 11:36:04.156246', 80, 'MARK_RAN', '9:077cba51999515f4d3e7ad5619ab592c', 'addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.1-add-index-to-client.client_id', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.204491', 81, 'EXECUTED', '9:be969f08a163bf47c6b9e9ead8ac2afb', 'createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-drop-constraints', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.206446', 82, 'MARK_RAN', '9:6d3bb4408ba5a72f39bd8a0b301ec6e3', 'dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-add-not-null-constraint', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.212479', 83, 'EXECUTED', '9:966bda61e46bebf3cc39518fbed52fa7', 'addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.1-KEYCLOAK-12579-recreate-constraints', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.214409', 84, 'MARK_RAN', '9:8dcac7bdf7378e7d823cdfddebf72fda', 'addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('9.0.1-add-index-to-events', 'keycloak', 'META-INF/jpa-changelog-9.0.1.xml', '2025-10-20 11:36:04.261878', 85, 'EXECUTED', '9:7d93d602352a30c0c317e6a609b56599', 'createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('map-remove-ri', 'keycloak', 'META-INF/jpa-changelog-11.0.0.xml', '2025-10-20 11:36:04.266259', 86, 'EXECUTED', '9:71c5969e6cdd8d7b6f47cebc86d37627', 'dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('map-remove-ri', 'keycloak', 'META-INF/jpa-changelog-12.0.0.xml', '2025-10-20 11:36:04.273211', 87, 'EXECUTED', '9:a9ba7d47f065f041b7da856a81762021', 'dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('12.1.0-add-realm-localization-table', 'keycloak', 'META-INF/jpa-changelog-12.0.0.xml', '2025-10-20 11:36:04.286563', 88, 'EXECUTED', '9:fffabce2bc01e1a8f5110d5278500065', 'createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('default-roles', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.293633', 89, 'EXECUTED', '9:fa8a5b5445e3857f4b010bafb5009957', 'addColumn tableName=REALM; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('default-roles-cleanup', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.298807', 90, 'EXECUTED', '9:67ac3241df9a8582d591c5ed87125f39', 'dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('13.0.0-KEYCLOAK-16844', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.348622', 91, 'EXECUTED', '9:ad1194d66c937e3ffc82386c050ba089', 'createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('map-remove-ri-13.0.0', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.357297', 92, 'EXECUTED', '9:d9be619d94af5a2f5d07b9f003543b91', 'dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('13.0.0-KEYCLOAK-17992-drop-constraints', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.359041', 93, 'MARK_RAN', '9:544d201116a0fcc5a5da0925fbbc3bde', 'dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('13.0.0-increase-column-size-federated', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.36937', 94, 'EXECUTED', '9:43c0c1055b6761b4b3e89de76d612ccf', 'modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('13.0.0-KEYCLOAK-17992-recreate-constraints', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.372173', 95, 'MARK_RAN', '9:8bd711fd0330f4fe980494ca43ab1139', 'addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('json-string-accomodation-fixed', 'keycloak', 'META-INF/jpa-changelog-13.0.0.xml', '2025-10-20 11:36:04.378993', 96, 'EXECUTED', '9:e07d2bc0970c348bb06fb63b1f82ddbf', 'addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('14.0.0-KEYCLOAK-11019', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.656722', 97, 'EXECUTED', '9:24fb8611e97f29989bea412aa38d12b7', 'createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.668906', 98, 'MARK_RAN', '9:259f89014ce2506ee84740cbf7163aa7', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-revert', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.698023', 99, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-supported-dbs', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.803801', 100, 'EXECUTED', '9:60ca84a0f8c94ec8c3504a5a3bc88ee8', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('14.0.0-KEYCLOAK-18286-unsupported-dbs', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.808783', 101, 'MARK_RAN', '9:d3d977031d431db16e2c181ce49d73e9', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('KEYCLOAK-17267-add-index-to-user-attributes', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.904924', 102, 'EXECUTED', '9:0b305d8d1277f3a89a0a53a659ad274c', 'createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('KEYCLOAK-18146-add-saml-art-binding-identifier', 'keycloak', 'META-INF/jpa-changelog-14.0.0.xml', '2025-10-20 11:36:04.920843', 103, 'EXECUTED', '9:2c374ad2cdfe20e2905a84c8fac48460', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('15.0.0-KEYCLOAK-18467', 'keycloak', 'META-INF/jpa-changelog-15.0.0.xml', '2025-10-20 11:36:04.93639', 104, 'EXECUTED', '9:47a760639ac597360a8219f5b768b4de', 'addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('17.0.0-9562', 'keycloak', 'META-INF/jpa-changelog-17.0.0.xml', '2025-10-20 11:36:05.036253', 105, 'EXECUTED', '9:a6272f0576727dd8cad2522335f5d99e', 'createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('18.0.0-10625-IDX_ADMIN_EVENT_TIME', 'keycloak', 'META-INF/jpa-changelog-18.0.0.xml', '2025-10-20 11:36:05.112658', 106, 'EXECUTED', '9:015479dbd691d9cc8669282f4828c41d', 'createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('18.0.15-30992-index-consent', 'keycloak', 'META-INF/jpa-changelog-18.0.15.xml', '2025-10-20 11:36:05.192484', 107, 'EXECUTED', '9:80071ede7a05604b1f4906f3bf3b00f0', 'createIndex indexName=IDX_USCONSENT_SCOPE_ID, tableName=USER_CONSENT_CLIENT_SCOPE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('19.0.0-10135', 'keycloak', 'META-INF/jpa-changelog-19.0.0.xml', '2025-10-20 11:36:05.201036', 108, 'EXECUTED', '9:9518e495fdd22f78ad6425cc30630221', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('20.0.0-12964-supported-dbs', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.258961', 109, 'EXECUTED', '9:e5f243877199fd96bcc842f27a1656ac', 'createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('20.0.0-12964-unsupported-dbs', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.261349', 110, 'MARK_RAN', '9:1a6fcaa85e20bdeae0a9ce49b41946a5', 'createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('client-attributes-string-accomodation-fixed', 'keycloak', 'META-INF/jpa-changelog-20.0.0.xml', '2025-10-20 11:36:05.268913', 111, 'EXECUTED', '9:3f332e13e90739ed0c35b0b25b7822ca', 'addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('21.0.2-17277', 'keycloak', 'META-INF/jpa-changelog-21.0.2.xml', '2025-10-20 11:36:05.274268', 112, 'EXECUTED', '9:7ee1f7a3fb8f5588f171fb9a6ab623c0', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('21.1.0-19404', 'keycloak', 'META-INF/jpa-changelog-21.1.0.xml', '2025-10-20 11:36:05.310907', 113, 'EXECUTED', '9:3d7e830b52f33676b9d64f7f2b2ea634', 'modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('21.1.0-19404-2', 'keycloak', 'META-INF/jpa-changelog-21.1.0.xml', '2025-10-20 11:36:05.314629', 114, 'MARK_RAN', '9:627d032e3ef2c06c0e1f73d2ae25c26c', 'addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('22.0.0-17484-updated', 'keycloak', 'META-INF/jpa-changelog-22.0.0.xml', '2025-10-20 11:36:05.320438', 115, 'EXECUTED', '9:90af0bfd30cafc17b9f4d6eccd92b8b3', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('22.0.5-24031', 'keycloak', 'META-INF/jpa-changelog-22.0.0.xml', '2025-10-20 11:36:05.322522', 116, 'MARK_RAN', '9:a60d2d7b315ec2d3eba9e2f145f9df28', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('23.0.0-12062', 'keycloak', 'META-INF/jpa-changelog-23.0.0.xml', '2025-10-20 11:36:05.329836', 117, 'EXECUTED', '9:2168fbe728fec46ae9baf15bf80927b8', 'addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('23.0.0-17258', 'keycloak', 'META-INF/jpa-changelog-23.0.0.xml', '2025-10-20 11:36:05.334679', 118, 'EXECUTED', '9:36506d679a83bbfda85a27ea1864dca8', 'addColumn tableName=EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.0-9758', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.602784', 119, 'EXECUTED', '9:502c557a5189f600f0f445a9b49ebbce', 'addColumn tableName=USER_ATTRIBUTE; addColumn tableName=FED_USER_ATTRIBUTE; createIndex indexName=USER_ATTR_LONG_VALUES, tableName=USER_ATTRIBUTE; createIndex indexName=FED_USER_ATTR_LONG_VALUES, tableName=FED_USER_ATTRIBUTE; createIndex indexName...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.0-9758-2', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.614402', 120, 'EXECUTED', '9:bf0fdee10afdf597a987adbf291db7b2', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.0-26618-drop-index-if-present', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.625933', 121, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.0-26618-reindex', 'keycloak', 'META-INF/jpa-changelog-24.0.0.xml', '2025-10-20 11:36:05.736813', 122, 'EXECUTED', '9:08707c0f0db1cef6b352db03a60edc7f', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.2-27228', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.748636', 123, 'EXECUTED', '9:eaee11f6b8aa25d2cc6a84fb86fc6238', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.2-27967-drop-index-if-present', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.75135', 124, 'MARK_RAN', '9:04baaf56c116ed19951cbc2cca584022', 'dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('24.0.2-27967-reindex', 'keycloak', 'META-INF/jpa-changelog-24.0.2.xml', '2025-10-20 11:36:05.754972', 125, 'MARK_RAN', '9:d3d977031d431db16e2c181ce49d73e9', 'createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-tables', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:05.769195', 126, 'EXECUTED', '9:deda2df035df23388af95bbd36c17cef', 'addColumn tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-creation', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:05.83231', 127, 'EXECUTED', '9:3e96709818458ae49f3c679ae58d263a', 'createIndex indexName=IDX_OFFLINE_USS_BY_LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-createdon', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.037673', 128, 'EXECUTED', '9:78ab4fc129ed5e8265dbcc3485fba92f', 'dropIndex indexName=IDX_OFFLINE_USS_CREATEDON, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-preload', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.250494', 129, 'EXECUTED', '9:de5f7c1f7e10994ed8b62e621d20eaab', 'dropIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-cleanup-uss-by-usersess', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.428897', 130, 'EXECUTED', '9:6eee220d024e38e89c799417ec33667f', 'dropIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-cleanup-css-preload', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.621494', 131, 'EXECUTED', '9:5411d2fb2891d3e8d63ddb55dfa3c0c9', 'dropIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-2-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.626868', 132, 'MARK_RAN', '9:b7ef76036d3126bb83c2423bf4d449d6', 'createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28265-index-2-not-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.722654', 133, 'EXECUTED', '9:23396cf51ab8bc1ae6f0cac7f9f6fcf7', 'createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-org', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.793495', 134, 'EXECUTED', '9:5c859965c2c9b9c72136c360649af157', 'createTable tableName=ORG; addUniqueConstraint constraintName=UK_ORG_NAME, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_GROUP, tableName=ORG; createTable tableName=ORG_DOMAIN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('unique-consentuser', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.853618', 135, 'EXECUTED', '9:5857626a2ea8767e9a6c66bf3a2cb32f', 'customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('unique-consentuser-mysql', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:06.862116', 136, 'MARK_RAN', '9:b79478aad5adaa1bc428e31563f55e8e', 'customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('25.0.0-28861-index-creation', 'keycloak', 'META-INF/jpa-changelog-25.0.0.xml', '2025-10-20 11:36:07.024867', 137, 'EXECUTED', '9:b9acb58ac958d9ada0fe12a5d4794ab1', 'createIndex indexName=IDX_PERM_TICKET_REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; createIndex indexName=IDX_PERM_TICKET_OWNER, tableName=RESOURCE_SERVER_PERM_TICKET', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-org-alias', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.041765', 138, 'EXECUTED', '9:6ef7d63e4412b3c2d66ed179159886a4', 'addColumn tableName=ORG; update tableName=ORG; addNotNullConstraint columnName=ALIAS, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_ALIAS, tableName=ORG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-org-group', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.058717', 139, 'EXECUTED', '9:da8e8087d80ef2ace4f89d8c5b9ca223', 'addColumn tableName=KEYCLOAK_GROUP; update tableName=KEYCLOAK_GROUP; addNotNullConstraint columnName=TYPE, tableName=KEYCLOAK_GROUP; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-org-indexes', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.132752', 140, 'EXECUTED', '9:79b05dcd610a8c7f25ec05135eec0857', 'createIndex indexName=IDX_ORG_DOMAIN_ORG_ID, tableName=ORG_DOMAIN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-org-group-membership', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.141397', 141, 'EXECUTED', '9:a6ace2ce583a421d89b01ba2a28dc2d4', 'addColumn tableName=USER_GROUP_MEMBERSHIP; update tableName=USER_GROUP_MEMBERSHIP; addNotNullConstraint columnName=MEMBERSHIP_TYPE, tableName=USER_GROUP_MEMBERSHIP', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('31296-persist-revoked-access-tokens', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.152331', 142, 'EXECUTED', '9:64ef94489d42a358e8304b0e245f0ed4', 'createTable tableName=REVOKED_TOKEN; addPrimaryKey constraintName=CONSTRAINT_RT, tableName=REVOKED_TOKEN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('31725-index-persist-revoked-access-tokens', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.213477', 143, 'EXECUTED', '9:b994246ec2bf7c94da881e1d28782c7b', 'createIndex indexName=IDX_REV_TOKEN_ON_EXPIRE, tableName=REVOKED_TOKEN', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-idps-for-login', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.335814', 144, 'EXECUTED', '9:51f5fffadf986983d4bd59582c6c1604', 'addColumn tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_REALM_ORG, tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_FOR_LOGIN, tableName=IDENTITY_PROVIDER; customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-32583-drop-redundant-index-on-client-session', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.557655', 145, 'EXECUTED', '9:24972d83bf27317a055d234187bb4af9', 'dropIndex indexName=IDX_US_SESS_ID_ON_CL_SESS, tableName=OFFLINE_CLIENT_SESSION', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0.32582-remove-tables-user-session-user-session-note-and-client-session', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.589698', 146, 'EXECUTED', '9:febdc0f47f2ed241c59e60f58c3ceea5', 'dropTable tableName=CLIENT_SESSION_ROLE; dropTable tableName=CLIENT_SESSION_NOTE; dropTable tableName=CLIENT_SESSION_PROT_MAPPER; dropTable tableName=CLIENT_SESSION_AUTH_STATUS; dropTable tableName=CLIENT_USER_SESSION_NOTE; dropTable tableName=CLI...', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.0.0-33201-org-redirect-url', 'keycloak', 'META-INF/jpa-changelog-26.0.0.xml', '2025-10-20 11:36:07.608849', 147, 'EXECUTED', '9:4d0e22b0ac68ebe9794fa9cb752ea660', 'addColumn tableName=ORG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('29399-jdbc-ping-default', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.641863', 148, 'EXECUTED', '9:007dbe99d7203fca403b89d4edfdf21e', 'createTable tableName=JGROUPS_PING; addPrimaryKey constraintName=CONSTRAINT_JGROUPS_PING, tableName=JGROUPS_PING', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.1.0-34013', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.666123', 149, 'EXECUTED', '9:e6b686a15759aef99a6d758a5c4c6a26', 'addColumn tableName=ADMIN_EVENT_ENTITY', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.1.0-34380', 'keycloak', 'META-INF/jpa-changelog-26.1.0.xml', '2025-10-20 11:36:07.678351', 150, 'EXECUTED', '9:ac8b9edb7c2b6c17a1c7a11fcf5ccf01', 'dropTable tableName=USERNAME_LOGIN_FAILURE', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.0-36750', 'keycloak', 'META-INF/jpa-changelog-26.2.0.xml', '2025-10-20 11:36:07.702868', 151, 'EXECUTED', '9:b49ce951c22f7eb16480ff085640a33a', 'createTable tableName=SERVER_CONFIG', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.0-26106', 'keycloak', 'META-INF/jpa-changelog-26.2.0.xml', '2025-10-20 11:36:07.709515', 152, 'EXECUTED', '9:b5877d5dab7d10ff3a9d209d7beb6680', 'addColumn tableName=CREDENTIAL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.6-39866-duplicate', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.720547', 153, 'EXECUTED', '9:1dc67ccee24f30331db2cba4f372e40e', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.6-39866-uk', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.729406', 154, 'EXECUTED', '9:b70b76f47210cf0a5f4ef0e219eac7cd', 'addUniqueConstraint constraintName=UK_MIGRATION_VERSION, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.6-40088-duplicate', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.737196', 155, 'EXECUTED', '9:cc7e02ed69ab31979afb1982f9670e8f', 'customChange', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.2.6-40088-uk', 'keycloak', 'META-INF/jpa-changelog-26.2.6.xml', '2025-10-20 11:36:07.745088', 156, 'EXECUTED', '9:5bb848128da7bc4595cc507383325241', 'addUniqueConstraint constraintName=UK_MIGRATION_UPDATE_TIME, tableName=MIGRATION_MODEL', '', NULL, '4.29.1', NULL, NULL, '0960155796');
INSERT INTO auth.databasechangelog VALUES ('26.3.0-groups-description', 'keycloak', 'META-INF/jpa-changelog-26.3.0.xml', '2025-10-20 11:36:07.754934', 157, 'EXECUTED', '9:e1a3c05574326fb5b246b73b9a4c4d49', 'addColumn tableName=KEYCLOAK_GROUP', '', NULL, '4.29.1', NULL, NULL, '0960155796');


--
-- TOC entry 4275 (class 0 OID 16494)
-- Dependencies: 239
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.databasechangeloglock VALUES (1, false, NULL, NULL);
INSERT INTO auth.databasechangeloglock VALUES (1000, false, NULL, NULL);


--
-- TOC entry 4276 (class 0 OID 16497)
-- Dependencies: 240
-- Data for Name: default_client_scope; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '049a3409-76f1-4ebc-ae89-ad113353878d', false);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '26186141-2832-4cc9-8b88-1a39757006ec', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'cbbe8007-9274-488d-b7a6-e1efa971032b', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '611958be-e756-45a6-9eb1-ad4af1a32f5b', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'a6e2784f-5222-4d7c-a15c-ba88682028f4', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '993ba957-fbd7-43f2-ae34-1f79b0230bf5', false);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'fb44034c-f05c-478a-a35e-5b48b2bea3f2', false);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '7d028e21-bf5d-4d13-bfc9-eea187b86b59', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'af89a443-1204-4c1a-bce8-57a80972cc03', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '528e12c3-909d-419d-ab0c-9867e433de88', false);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'd4425897-b36d-4b12-846e-61da27f50271', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '039b7573-e076-41be-a04a-ac06eee8285f', true);
INSERT INTO auth.default_client_scope VALUES ('0c806647-a11c-403d-af39-092523465ca0', '05888153-059e-47e4-b37a-47236467549a', false);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '231a9ae3-72f1-45aa-9cb1-1e1a82cd4627', false);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'c3550f61-d509-40a4-904a-342af7980ecd', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'add1b692-0f4d-42e7-8620-9dc9c89039d0', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '0890c368-f43a-4825-a404-a2b2583e341d', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '89e456b7-ffac-4055-be76-32fb54b5ac72', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c', false);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '07d4ed18-94fe-4306-8948-454720e0433c', false);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '92fca448-d98e-4989-8704-55a7cfec5b5c', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '8d404c72-37fa-4303-86ef-529092f0a904', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'ce2b281f-a337-44fe-a9b7-e862ed20510b', false);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', '57896332-b5ba-45da-87c9-04a1d23a9cf0', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'f11b9ea4-f791-4a68-a2be-3809dc842a7e', true);
INSERT INTO auth.default_client_scope VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'fae553ba-26e5-4e37-9cc4-5e14f12ee564', false);


--
-- TOC entry 4281 (class 0 OID 16531)
-- Dependencies: 247
-- Data for Name: event_entity; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4282 (class 0 OID 16536)
-- Dependencies: 248
-- Data for Name: fed_user_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4283 (class 0 OID 16541)
-- Dependencies: 249
-- Data for Name: fed_user_consent; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4284 (class 0 OID 16546)
-- Dependencies: 250
-- Data for Name: fed_user_consent_cl_scope; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4285 (class 0 OID 16549)
-- Dependencies: 251
-- Data for Name: fed_user_credential; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4286 (class 0 OID 16554)
-- Dependencies: 252
-- Data for Name: fed_user_group_membership; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4287 (class 0 OID 16557)
-- Dependencies: 253
-- Data for Name: fed_user_required_action; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4288 (class 0 OID 16563)
-- Dependencies: 254
-- Data for Name: fed_user_role_mapping; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4289 (class 0 OID 16566)
-- Dependencies: 255
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4290 (class 0 OID 16571)
-- Dependencies: 256
-- Data for Name: federated_user; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4277 (class 0 OID 16501)
-- Dependencies: 241
-- Data for Name: group_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4279 (class 0 OID 16517)
-- Dependencies: 244
-- Data for Name: group_role_mapping; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4291 (class 0 OID 16576)
-- Dependencies: 257
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4292 (class 0 OID 16588)
-- Dependencies: 258
-- Data for Name: identity_provider_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4293 (class 0 OID 16593)
-- Dependencies: 259
-- Data for Name: identity_provider_mapper; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4294 (class 0 OID 16598)
-- Dependencies: 260
-- Data for Name: idp_mapper_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4295 (class 0 OID 16603)
-- Dependencies: 261
-- Data for Name: jgroups_ping; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4278 (class 0 OID 16507)
-- Dependencies: 242
-- Data for Name: keycloak_group; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4280 (class 0 OID 16520)
-- Dependencies: 245
-- Data for Name: keycloak_role; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.keycloak_role VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_default-roles}', 'default-roles-master', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_admin}', 'admin', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('8e3d03e5-e70a-460f-8d22-bb11ecabcae3', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_create-realm}', 'create-realm', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('1bf774c0-76b5-43d3-a6ab-580554987f88', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_create-client}', 'create-client', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('90da9da7-9cbd-4e08-afe2-b657bdca5ac0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-realm}', 'view-realm', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-users}', 'view-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-clients}', 'view-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('393c8228-dabe-4927-bec5-d62e0f372af9', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-events}', 'view-events', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('bcf549e9-6de7-4ba3-a2d7-7864f460fe6a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-identity-providers}', 'view-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('6c32a60e-78de-4b5a-b19c-69eb7e84ac9a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_view-authorization}', 'view-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('d5ff873d-5bc6-444c-89db-b2a7573008ca', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-realm}', 'manage-realm', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('6d21a91c-7886-4b8c-8933-7e6f708606fe', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-users}', 'manage-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('966551e2-bdb1-4c42-a1f4-10c85d410db2', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-clients}', 'manage-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('2c9a23ac-4921-404e-99df-1f5a7b85cd7f', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-events}', 'manage-events', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('c56c1682-22c0-4d14-b41f-af9641674de5', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-identity-providers}', 'manage-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('689bf969-bf06-440a-95a4-8429cc400d09', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_manage-authorization}', 'manage-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('46d4c4c6-ab10-47b3-9665-43d3f44aaa63', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-users}', 'query-users', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('325745f8-d041-4e42-8a89-466e404c775b', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-clients}', 'query-clients', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('75bb763a-6fc1-4bfe-8432-da1fc12e5efd', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-realms}', 'query-realms', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('dd58dfd2-861f-41eb-9dc8-d956324f9ccd', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_query-groups}', 'query-groups', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('c5fbb5ee-4707-425f-836d-3d833f7c294f', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-profile}', 'view-profile', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-account}', 'manage-account', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('a471a901-48ee-443e-90b1-2c70abd516ea', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-account-links}', 'manage-account-links', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('8095b4ff-6f0d-414b-8057-22d5471ad338', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-applications}', 'view-applications', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('d416a33e-2abf-4dc2-b9fa-94a23017e858', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-consent}', 'view-consent', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_manage-consent}', 'manage-consent', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_view-groups}', 'view-groups', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('5e45631a-17db-48f8-87dd-278459b02b54', 'cb329b52-014b-4403-bea0-a5b73129e98e', true, '${role_delete-account}', 'delete-account', '0c806647-a11c-403d-af39-092523465ca0', 'cb329b52-014b-4403-bea0-a5b73129e98e', NULL);
INSERT INTO auth.keycloak_role VALUES ('bd5731c3-d8e2-4830-b512-a914de001373', '42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', true, '${role_read-token}', 'read-token', '0c806647-a11c-403d-af39-092523465ca0', '42f4de04-c1bc-4d5a-8492-bbe53f6fc81d', NULL);
INSERT INTO auth.keycloak_role VALUES ('3a3b68f5-5620-44aa-974f-6b1cf9c2c12a', 'b44bd709-a47c-4200-9be6-48e57da7d91c', true, '${role_impersonation}', 'impersonation', '0c806647-a11c-403d-af39-092523465ca0', 'b44bd709-a47c-4200-9be6-48e57da7d91c', NULL);
INSERT INTO auth.keycloak_role VALUES ('a3f06c98-eaeb-4470-98d5-09268563e97f', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_offline-access}', 'offline_access', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('b83d7ede-d9b5-493d-bb43-8a5e641d5085', '0c806647-a11c-403d-af39-092523465ca0', false, '${role_uma_authorization}', 'uma_authorization', '0c806647-a11c-403d-af39-092523465ca0', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, '${role_default-roles}', 'default-roles-condominio', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('421c0b73-7158-4267-9c20-5574729807df', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_create-client}', 'create-client', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('492be749-88d3-41b0-840a-e123476fe153', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-realm}', 'view-realm', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('4d97730d-7083-4f63-9fdb-3572f2ff25bf', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-users}', 'view-users', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('d0a07657-2f88-4f42-9f14-6bb26f4bb9af', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-clients}', 'view-clients', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('6828aab4-b6b8-4479-8d49-2016f32d4738', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-events}', 'view-events', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('cb3b8a3f-f8bb-41a5-b3dc-0a4b7cbb9920', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-identity-providers}', 'view-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('324a1198-8182-4734-8c09-c5a9404ea00f', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_view-authorization}', 'view-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('87373ef5-3d9c-4dfe-9a6e-657e391346f0', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-realm}', 'manage-realm', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('3fa51ad2-46dc-43d4-a4dd-0e6c7e9aef16', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-users}', 'manage-users', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('1af997e6-531d-429a-ab70-c072a047100f', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-clients}', 'manage-clients', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('2ac40628-0e24-4592-abe2-fc514fe4d4c9', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-events}', 'manage-events', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('e1e97732-6cf6-4ee9-90a5-8909dbb171ea', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-identity-providers}', 'manage-identity-providers', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('f58a7d9a-88e5-47f1-986d-d71fec912224', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_manage-authorization}', 'manage-authorization', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('73d01fb5-b1ab-4f72-8c33-a29fe93c378b', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_query-users}', 'query-users', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('74eeb0f0-1776-4d5b-b585-b00629a21170', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_query-clients}', 'query-clients', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('2740f303-4323-4112-8646-85edc81139f2', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_query-realms}', 'query-realms', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('aa5d18ba-9a50-40c6-858f-d9e18d8350f1', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_query-groups}', 'query-groups', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('dc5b5a9a-272c-41b3-bf80-4208f65b2dba', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_realm-admin}', 'realm-admin', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('934863eb-19a3-43d8-a67b-f9b37920fbd2', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_create-client}', 'create-client', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('8b338dad-a8bf-4763-a162-ee526b513c21', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-realm}', 'view-realm', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('1d79d23b-665b-463c-a8da-739ed67041f8', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-users}', 'view-users', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('c7db9779-ef41-46f8-ad5d-6cca47279246', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-clients}', 'view-clients', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('94299728-d170-46e8-ac78-edd9239867a4', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-events}', 'view-events', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('4d6c6704-bb2e-47cd-bfa8-5e54fea2045a', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-identity-providers}', 'view-identity-providers', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('153043ef-4bcb-4a8b-814c-2d7faf6332b3', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_view-authorization}', 'view-authorization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('02ccc953-fe7e-4770-b402-2f3a750fdd00', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-realm}', 'manage-realm', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('a3fe7db6-f6d9-4db7-a909-d573f5905ceb', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-users}', 'manage-users', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('536f58f1-150e-40f9-bc33-4d59f912ba45', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-clients}', 'manage-clients', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('5bcd0748-e7a5-491d-9f86-e0d386bf08be', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-events}', 'manage-events', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('b5f90471-6f59-4ebb-91e3-7a5a622e98bc', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-identity-providers}', 'manage-identity-providers', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('2288496f-eea3-4b75-b2a1-5f917cb1a6cf', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_manage-authorization}', 'manage-authorization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('852c7e70-dc5c-4fc1-a153-683cd7a3b91f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_query-users}', 'query-users', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('9b47a50c-fb81-4258-a7c9-2da92d1919e9', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_query-clients}', 'query-clients', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('12cc8e18-7edf-4a55-9382-efe5a246a6cc', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_query-realms}', 'query-realms', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('003409a2-f22d-420e-a493-c3e8e44cd711', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_query-groups}', 'query-groups', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('208a0962-68c2-4167-b725-a1b9bd8506bd', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_view-profile}', 'view-profile', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('23a43d84-86f5-4537-a4ce-bf0be37559c1', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_manage-account}', 'manage-account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('c8e6d0ea-215d-4e90-a1f4-91b21f6c7aac', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_manage-account-links}', 'manage-account-links', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('bf494f21-95d2-4977-8ec8-c7e26ab13c67', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_view-applications}', 'view-applications', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('1bf0b636-8da4-43bd-ba77-98725a0dcc37', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_view-consent}', 'view-consent', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('11498f02-8327-47df-9fff-3c6a52364b4a', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_manage-consent}', 'manage-consent', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('e595f950-21c6-4ab4-960d-b5023056f870', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_view-groups}', 'view-groups', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('be746ec3-246d-4a41-bc6f-073745a21e52', '7d9b13f0-2234-439a-a937-4060f4a485cf', true, '${role_delete-account}', 'delete-account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '7d9b13f0-2234-439a-a937-4060f4a485cf', NULL);
INSERT INTO auth.keycloak_role VALUES ('39af18c4-976f-4177-9883-d69e745b6173', 'a12d00f9-ec24-4109-9127-358f4543feff', true, '${role_impersonation}', 'impersonation', '0c806647-a11c-403d-af39-092523465ca0', 'a12d00f9-ec24-4109-9127-358f4543feff', NULL);
INSERT INTO auth.keycloak_role VALUES ('f835b8be-a14e-42fc-b1fe-9d682a9966c4', 'cab29a97-29d1-48f7-8558-c0b528039ebc', true, '${role_impersonation}', 'impersonation', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'cab29a97-29d1-48f7-8558-c0b528039ebc', NULL);
INSERT INTO auth.keycloak_role VALUES ('309ef1df-9bac-4cdf-824f-e6b6550d16e1', '4066bbcb-0c33-4a65-92bf-f44854d9b728', true, '${role_read-token}', 'read-token', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '4066bbcb-0c33-4a65-92bf-f44854d9b728', NULL);
INSERT INTO auth.keycloak_role VALUES ('1ea38dc4-b1bd-4f5f-bd2b-cc4a119df8b2', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, '${role_offline-access}', 'offline_access', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('281f6695-40a4-4ba2-95b8-b30c5224f0f6', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, '${role_uma_authorization}', 'uma_authorization', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, NULL);
INSERT INTO auth.keycloak_role VALUES ('6fefb22f-2020-60f7-ea88-24cb223a195c', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, NULL, 'user', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f');
INSERT INTO auth.keycloak_role VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, '', 'authority_admin', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, '7404ff5e-f51a-4416-b45f-15d2d69cca5f');
INSERT INTO auth.keycloak_role VALUES ('27af0f0b-5dd5-434f-a2e7-807776d4a813', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, 'Amministratore di condominio', 'amministratore', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', NULL, NULL);


--
-- TOC entry 4298 (class 0 OID 16634)
-- Dependencies: 267
-- Data for Name: menu_items; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.menu_items VALUES (8, 'menu label', 'pi pi-bars', NULL, 'sidebar.menu', '/menus', 4, 1, '5b557614-c20f-6f12-0325-de9631fe201d', true);
INSERT INTO auth.menu_items VALUES (5, 'home label', 'pi pi-home', NULL, 'sidebar.home', NULL, 1, NULL, '5b557614-c20f-6f12-0325-de9631fe201d', true);
INSERT INTO auth.menu_items VALUES (1, 'amministratore label', 'pi pi-home', NULL, 'sidebar.admin', NULL, 0, NULL, '5b557614-c20f-6f12-0325-de9631fe201d', true);
INSERT INTO auth.menu_items VALUES (2, 'ruoli', 'pi pi-key', NULL, 'sidebar.roles', '/roles', 1, 1, '5b557614-c20f-6f12-0325-de9631fe201d', true);
INSERT INTO auth.menu_items VALUES (3, 'gruppi', 'pi pi-share-alt', NULL, 'sidebar.groups', '/groups', 2, 1, '5b557614-c20f-6f12-0325-de9631fe201d', true);
INSERT INTO auth.menu_items VALUES (4, 'utenti', 'pi pi-users', NULL, 'sidebar.users', '/users', 3, 1, '5b557614-c20f-6f12-0325-de9631fe201d', true);


--
-- TOC entry 4300 (class 0 OID 16642)
-- Dependencies: 269
-- Data for Name: migration_model; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.migration_model VALUES ('rp667', '26.3.0', 1760960169);


--
-- TOC entry 4301 (class 0 OID 16646)
-- Dependencies: 270
-- Data for Name: offline_client_session; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.offline_client_session VALUES ('19dc75b3-a33b-471e-9096-363debc2fb8f', '6cc0d8f7-2bad-4320-9e69-d7ebb998594a', '0', 1772544943, '{"authMethod":"openid-connect","redirectUri":"http://localhost:8089/callback","notes":{"clientId":"6cc0d8f7-2bad-4320-9e69-d7ebb998594a","scope":"openid profile email","userSessionStartedAt":"1772544939","iss":"http://localhost:8082/realms/condominio","startedAt":"1772544939","response_type":"code","level-of-authentication":"-1","code_challenge_method":"S256","redirect_uri":"http://localhost:8089/callback","state":"L3ABzW1T2pKyBQuW5BNI1UFh507l2U5r","code_challenge":"Q-EkZHS0XkPO2K7U3cs6Acau_qMqHAUgIMj0T6R1c64"}}', 'local', 'local', 1);
INSERT INTO auth.offline_client_session VALUES ('11503d25-f3e1-4472-b14d-d63487251ecb', '3cd5708c-d0ed-458c-8786-c953920c8f37', '0', 1772544956, '{"authMethod":"openid-connect","redirectUri":"http://localhost:8082/admin/master/console/#/condominio/users/ace11e10-2926-4463-bb6f-e5d87b8099b8/role-mapping","notes":{"clientId":"3cd5708c-d0ed-458c-8786-c953920c8f37","iss":"http://localhost:8082/realms/master","startedAt":"1772543870","response_type":"code","level-of-authentication":"-1","code_challenge_method":"S256","nonce":"d77579eb-7d1d-4e0c-ade1-6bcc5b7fd832","response_mode":"query","scope":"openid","userSessionStartedAt":"1772543870","redirect_uri":"http://localhost:8082/admin/master/console/#/condominio/users/ace11e10-2926-4463-bb6f-e5d87b8099b8/role-mapping","state":"727a1304-eafd-487f-a277-537a976327ee","code_challenge":"hSPhTk0ddCTiFEIVoXIP5f_OJbUG0qfNXr9ZUeXfnsg","prompt":"none","SSO_AUTH":"true"}}', 'local', 'local', 6);
INSERT INTO auth.offline_client_session VALUES ('1096d143-b759-4247-b13d-aa86092ae784', 'c69481e1-87f7-4fa8-a2a9-c39fcb856a41', '0', 1772544507, '{"authMethod":"openid-connect","notes":{"clientId":"c69481e1-87f7-4fa8-a2a9-c39fcb856a41","userSessionStartedAt":"1772544507","iss":"http://localhost:8082/realms/condominio","startedAt":"1772544507","level-of-authentication":"-1"}}', 'local', 'local', 0);


--
-- TOC entry 4302 (class 0 OID 16654)
-- Dependencies: 271
-- Data for Name: offline_user_session; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.offline_user_session VALUES ('1096d143-b759-4247-b13d-aa86092ae784', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 1772544507, '0', '{"ipAddress":"172.18.0.1","authMethod":"openid-connect","rememberMe":false,"started":0,"notes":{"KC_DEVICE_NOTE":"eyJpcEFkZHJlc3MiOiIxNzIuMTguMC4xIiwib3MiOiJPdGhlciIsIm9zVmVyc2lvbiI6IlVua25vd24iLCJicm93c2VyIjoiQXBhY2hlLUh0dHBDbGllbnQvNC41LjMiLCJkZXZpY2UiOiJPdGhlciIsImxhc3RBY2Nlc3MiOjAsIm1vYmlsZSI6ZmFsc2V9","authenticators-completed":"{\"91a23062-05c0-4d5e-8b77-3228a78bf6f6\":1772544507,\"e47eb9c5-d426-41ed-a518-e72cab789f71\":1772544507}"},"state":"LOGGED_IN"}', 1772544507, NULL, 0);
INSERT INTO auth.offline_user_session VALUES ('19dc75b3-a33b-471e-9096-363debc2fb8f', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 1772544939, '0', '{"ipAddress":"172.18.0.1","authMethod":"openid-connect","rememberMe":false,"started":0,"notes":{"KC_DEVICE_NOTE":"eyJpcEFkZHJlc3MiOiIxNzIuMTguMC4xIiwib3MiOiJXaW5kb3dzIiwib3NWZXJzaW9uIjoiMTAiLCJicm93c2VyIjoiQ2hyb21lLzE0NS4wLjAiLCJkZXZpY2UiOiJPdGhlciIsImxhc3RBY2Nlc3MiOjAsIm1vYmlsZSI6ZmFsc2V9","AUTH_TIME":"1772544939","authenticators-completed":"{\"9f945f24-5729-427a-a989-b145ea7d2383\":1772544939}"},"state":"LOGGED_IN"}', 1772544943, NULL, 1);
INSERT INTO auth.offline_user_session VALUES ('11503d25-f3e1-4472-b14d-d63487251ecb', '679d8ad7-2047-41eb-b88e-bad459ccdc81', '0c806647-a11c-403d-af39-092523465ca0', 1772543870, '0', '{"ipAddress":"172.18.0.1","authMethod":"openid-connect","rememberMe":false,"started":0,"notes":{"KC_DEVICE_NOTE":"eyJpcEFkZHJlc3MiOiIxNzIuMTguMC4xIiwib3MiOiJXaW5kb3dzIiwib3NWZXJzaW9uIjoiMTAiLCJicm93c2VyIjoiQ2hyb21lLzE0NS4wLjAiLCJkZXZpY2UiOiJPdGhlciIsImxhc3RBY2Nlc3MiOjAsIm1vYmlsZSI6ZmFsc2V9","AUTH_TIME":"1772543870","authenticators-completed":"{\"7b8b8659-89fc-41f5-9905-da339d34ac71\":1772543870,\"7924e8bd-b0e1-4fbd-8e30-4d22e897e00a\":1772544523}"},"state":"LOGGED_IN"}', 1772544956, NULL, 6);


--
-- TOC entry 4303 (class 0 OID 16661)
-- Dependencies: 272
-- Data for Name: org; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4304 (class 0 OID 16666)
-- Dependencies: 273
-- Data for Name: org_domain; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4305 (class 0 OID 16671)
-- Dependencies: 274
-- Data for Name: policy_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4306 (class 0 OID 16676)
-- Dependencies: 275
-- Data for Name: protocol_mapper; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.protocol_mapper VALUES ('f29f8d6f-bc6f-44e0-87a5-ade4354e4a3a', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', '8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', NULL);
INSERT INTO auth.protocol_mapper VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', '3cd5708c-d0ed-458c-8786-c953920c8f37', NULL);
INSERT INTO auth.protocol_mapper VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'role list', 'saml', 'saml-role-list-mapper', NULL, '26186141-2832-4cc9-8b88-1a39757006ec');
INSERT INTO auth.protocol_mapper VALUES ('45ff4d65-464d-4827-b123-ad3ce1b22671', 'organization', 'saml', 'saml-organization-membership-mapper', NULL, 'cbbe8007-9274-488d-b7a6-e1efa971032b');
INSERT INTO auth.protocol_mapper VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'full name', 'openid-connect', 'oidc-full-name-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'family name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'given name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middle name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'username', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updated at', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '611958be-e756-45a6-9eb1-ad4af1a32f5b');
INSERT INTO auth.protocol_mapper VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'a6e2784f-5222-4d7c-a15c-ba88682028f4');
INSERT INTO auth.protocol_mapper VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'email verified', 'openid-connect', 'oidc-usermodel-property-mapper', NULL, 'a6e2784f-5222-4d7c-a15c-ba88682028f4');
INSERT INTO auth.protocol_mapper VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'address', 'openid-connect', 'oidc-address-mapper', NULL, '993ba957-fbd7-43f2-ae34-1f79b0230bf5');
INSERT INTO auth.protocol_mapper VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phone number', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'fb44034c-f05c-478a-a35e-5b48b2bea3f2');
INSERT INTO auth.protocol_mapper VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phone number verified', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'fb44034c-f05c-478a-a35e-5b48b2bea3f2');
INSERT INTO auth.protocol_mapper VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'realm roles', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO auth.protocol_mapper VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'client roles', 'openid-connect', 'oidc-usermodel-client-role-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO auth.protocol_mapper VALUES ('634e424a-411b-44ef-9539-a21815948394', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', NULL, '7d028e21-bf5d-4d13-bfc9-eea187b86b59');
INSERT INTO auth.protocol_mapper VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'allowed web origins', 'openid-connect', 'oidc-allowed-origins-mapper', NULL, 'af89a443-1204-4c1a-bce8-57a80972cc03');
INSERT INTO auth.protocol_mapper VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'upn', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '528e12c3-909d-419d-ab0c-9867e433de88');
INSERT INTO auth.protocol_mapper VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'groups', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '528e12c3-909d-419d-ab0c-9867e433de88');
INSERT INTO auth.protocol_mapper VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'acr loa level', 'openid-connect', 'oidc-acr-mapper', NULL, 'd4425897-b36d-4b12-846e-61da27f50271');
INSERT INTO auth.protocol_mapper VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'auth_time', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '039b7573-e076-41be-a04a-ac06eee8285f');
INSERT INTO auth.protocol_mapper VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'sub', 'openid-connect', 'oidc-sub-mapper', NULL, '039b7573-e076-41be-a04a-ac06eee8285f');
INSERT INTO auth.protocol_mapper VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'Client ID', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO auth.protocol_mapper VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'Client Host', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO auth.protocol_mapper VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'Client IP Address', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, '7921ab35-c79a-4ab6-8b01-4757c3b6db8c');
INSERT INTO auth.protocol_mapper VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'organization', 'openid-connect', 'oidc-organization-membership-mapper', NULL, '05888153-059e-47e4-b37a-47236467549a');
INSERT INTO auth.protocol_mapper VALUES ('ee55cd02-69f1-4980-93c1-651a11e557cf', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', '7fd7b484-d21f-4b3e-b90a-162ab060025e', NULL);
INSERT INTO auth.protocol_mapper VALUES ('87dd4ced-ce15-4f12-8874-f0393151b5ef', 'role list', 'saml', 'saml-role-list-mapper', NULL, 'c3550f61-d509-40a4-904a-342af7980ecd');
INSERT INTO auth.protocol_mapper VALUES ('684f7a0d-caa5-4585-a146-d169eb4bd8e1', 'organization', 'saml', 'saml-organization-membership-mapper', NULL, 'add1b692-0f4d-42e7-8620-9dc9c89039d0');
INSERT INTO auth.protocol_mapper VALUES ('31bb9756-d577-4e7e-a274-8c39d0635ad5', 'full name', 'openid-connect', 'oidc-full-name-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'family name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'given name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'middle name', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'nickname', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'username', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'profile', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'picture', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'website', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'gender', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'birthdate', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'zoneinfo', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'updated at', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '0890c368-f43a-4825-a404-a2b2583e341d');
INSERT INTO auth.protocol_mapper VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'email', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '89e456b7-ffac-4055-be76-32fb54b5ac72');
INSERT INTO auth.protocol_mapper VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'email verified', 'openid-connect', 'oidc-usermodel-property-mapper', NULL, '89e456b7-ffac-4055-be76-32fb54b5ac72');
INSERT INTO auth.protocol_mapper VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'address', 'openid-connect', 'oidc-address-mapper', NULL, '3c3ee25e-4d73-4285-b14e-fb09dbca1d0c');
INSERT INTO auth.protocol_mapper VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'phone number', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '07d4ed18-94fe-4306-8948-454720e0433c');
INSERT INTO auth.protocol_mapper VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'phone number verified', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, '07d4ed18-94fe-4306-8948-454720e0433c');
INSERT INTO auth.protocol_mapper VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'realm roles', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, '92fca448-d98e-4989-8704-55a7cfec5b5c');
INSERT INTO auth.protocol_mapper VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'client roles', 'openid-connect', 'oidc-usermodel-client-role-mapper', NULL, '92fca448-d98e-4989-8704-55a7cfec5b5c');
INSERT INTO auth.protocol_mapper VALUES ('3296dc2e-3b4e-415c-bf9b-b97031f8f7fe', 'audience resolve', 'openid-connect', 'oidc-audience-resolve-mapper', NULL, '92fca448-d98e-4989-8704-55a7cfec5b5c');
INSERT INTO auth.protocol_mapper VALUES ('97131056-5d65-40d4-8f53-d490b75aa9dc', 'allowed web origins', 'openid-connect', 'oidc-allowed-origins-mapper', NULL, '8d404c72-37fa-4303-86ef-529092f0a904');
INSERT INTO auth.protocol_mapper VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'upn', 'openid-connect', 'oidc-usermodel-attribute-mapper', NULL, 'ce2b281f-a337-44fe-a9b7-e862ed20510b');
INSERT INTO auth.protocol_mapper VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'groups', 'openid-connect', 'oidc-usermodel-realm-role-mapper', NULL, 'ce2b281f-a337-44fe-a9b7-e862ed20510b');
INSERT INTO auth.protocol_mapper VALUES ('3b56fde0-0b8b-4df7-bdf7-baa79d456588', 'acr loa level', 'openid-connect', 'oidc-acr-mapper', NULL, '57896332-b5ba-45da-87c9-04a1d23a9cf0');
INSERT INTO auth.protocol_mapper VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'auth_time', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, 'f11b9ea4-f791-4a68-a2be-3809dc842a7e');
INSERT INTO auth.protocol_mapper VALUES ('c3d08a6e-2506-4e6b-861c-217dfcc7a284', 'sub', 'openid-connect', 'oidc-sub-mapper', NULL, 'f11b9ea4-f791-4a68-a2be-3809dc842a7e');
INSERT INTO auth.protocol_mapper VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'Client ID', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, 'f79d8f96-2134-4bf0-913e-a67fbd836285');
INSERT INTO auth.protocol_mapper VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'Client Host', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, 'f79d8f96-2134-4bf0-913e-a67fbd836285');
INSERT INTO auth.protocol_mapper VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'Client IP Address', 'openid-connect', 'oidc-usersessionmodel-note-mapper', NULL, 'f79d8f96-2134-4bf0-913e-a67fbd836285');
INSERT INTO auth.protocol_mapper VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'organization', 'openid-connect', 'oidc-organization-membership-mapper', NULL, 'fae553ba-26e5-4e37-9cc4-5e14f12ee564');
INSERT INTO auth.protocol_mapper VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'locale', 'openid-connect', 'oidc-usermodel-attribute-mapper', '2ee548cd-26d4-4604-a004-44e3b2a529f7', NULL);


--
-- TOC entry 4307 (class 0 OID 16681)
-- Dependencies: 276
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'locale', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('d7131e53-c65c-4363-8d4e-153a1402ca3f', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'false', 'single');
INSERT INTO auth.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'Basic', 'attribute.nameformat');
INSERT INTO auth.protocol_mapper_config VALUES ('befbfb7f-4923-4ec2-a9c5-a118df8f4c0d', 'Role', 'attribute.name');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'firstName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'given_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('09ea1488-74b7-446a-a29a-ef1238b6fa81', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'lastName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'family_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('13aa237d-53ac-49d7-a903-ca915df23465', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'profile', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('15b2d224-68e7-4067-8c15-27f24234e04c', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'picture', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('3563d1db-aa53-4475-bc62-a7d07682e338', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middleName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'middle_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('46f3e794-15d4-4ade-8396-c9de447de199', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'nickname', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('4c451c23-237c-41e1-b581-a6964f17c183', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'website', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('57fb5f78-1443-4ce4-aa89-694743cfaf90', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updatedAt', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'updated_at', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8382af8a-e985-4786-a13b-628902cfeb47', 'long', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'birthdate', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('877cecce-b2da-45a7-966b-0fedbaf95992', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'zoneinfo', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('c3cf6c68-8e0e-488b-83fa-b748f45937e6', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'username', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'preferred_username', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('cef78d71-3dfc-488d-91a6-70e803acd530', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'gender', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('ed7d139c-1cef-4267-921c-4199e09790da', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'locale', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('f9f426dc-5f28-44ed-8a2f-c54062863c7b', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('ff628096-df1e-40e4-b9f4-9e539f56bc8f', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'email', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('b4d10ea7-153c-4433-b415-671858d905b2', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'emailVerified', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'email_verified', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('fecb598a-1cf0-4ca8-9642-3b3ca36829b3', 'boolean', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'formatted', 'user.attribute.formatted');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'country', 'user.attribute.country');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'postal_code', 'user.attribute.postal_code');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'street', 'user.attribute.street');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'region', 'user.attribute.region');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b6759c01-96b7-41af-ac92-3cc9de0f45ea', 'locality', 'user.attribute.locality');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phoneNumber', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'phone_number', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('087bd421-6b66-4d2d-bd29-c50d4cd9a971', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phoneNumberVerified', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'phone_number_verified', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('e9aa9ea1-cf57-475d-94c7-7cdf5380b8ab', 'boolean', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('634e424a-411b-44ef-9539-a21815948394', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('634e424a-411b-44ef-9539-a21815948394', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'resource_access.${client_id}.roles', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8db18e7f-7173-46cf-a5de-d172acda9344', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'realm_access.roles', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('e49c7ee6-3e37-4bdc-8cdf-846c892cb3c8', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('56fb575d-7b81-48dc-9a59-4af2b335ba29', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'username', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'upn', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('65c3facd-4073-463f-9a63-452ce236a16c', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'groups', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('715bf070-9a5f-46c3-82ac-2d207c7c783b', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('1bf40fd2-6b8c-4520-a8c7-5362c82f3ee2', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('562eaa79-009f-4329-a795-5994063dca02', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'AUTH_TIME', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'auth_time', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('a4fc9422-2bc2-46a8-8a94-5f81325a0662', 'long', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'clientHost', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'clientHost', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('24ad21cd-dd9a-41de-8903-b4ff7a6b913e', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'client_id', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'client_id', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('91996c7c-9f91-4461-adf0-705004826113', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'clientAddress', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'clientAddress', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('92e33d08-6fbe-4f98-bfcb-ce0abb749582', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'organization', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('410be29d-2e51-4920-89ae-c386b3ed413c', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('87dd4ced-ce15-4f12-8874-f0393151b5ef', 'false', 'single');
INSERT INTO auth.protocol_mapper_config VALUES ('87dd4ced-ce15-4f12-8874-f0393151b5ef', 'Basic', 'attribute.nameformat');
INSERT INTO auth.protocol_mapper_config VALUES ('87dd4ced-ce15-4f12-8874-f0393151b5ef', 'Role', 'attribute.name');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'gender', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'gender', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('0249dfe6-8fab-4751-bcce-af395e586786', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'locale', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'locale', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('251d53c1-0565-48fd-a8b3-15f26846248f', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('31bb9756-d577-4e7e-a274-8c39d0635ad5', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('31bb9756-d577-4e7e-a274-8c39d0635ad5', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('31bb9756-d577-4e7e-a274-8c39d0635ad5', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('31bb9756-d577-4e7e-a274-8c39d0635ad5', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'birthdate', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'birthdate', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('333f485b-b04e-4f00-bae5-3ac72ea10681', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'middleName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'middle_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('43484ac7-53ac-498d-bc93-c8a7783cb61b', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'website', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'website', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8a7aa4fe-ebcc-4135-ad10-67dc7ada78bc', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'username', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'preferred_username', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8da9d1f8-9064-47c7-a861-f825eb84d554', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'profile', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'profile', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8db6ead2-c79a-4dd9-aedc-575810716533', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'firstName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'given_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('a758974e-0a6b-4952-ba52-6a8324690d91', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'updatedAt', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'updated_at', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('afc046f7-77e1-4886-a257-66f373022fb3', 'long', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'lastName', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'family_name', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('c1739fb6-d99d-4ebf-ab41-0beaa8ef11a4', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'zoneinfo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'zoneinfo', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('cd73ae9a-f6f8-473f-953f-616109ba084e', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'nickname', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'nickname', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('eb9cd5ff-6b03-4578-add5-11965e126ef2', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'picture', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'picture', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('fe502546-d295-4f4c-9db8-0999984e8df3', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'emailVerified', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'email_verified', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('a8eb80ee-7849-47b0-a6f0-4ff8e622f632', 'boolean', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'email', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'email', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('fde92bd3-0a29-4d78-bb24-a57d9d0f7211', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'formatted', 'user.attribute.formatted');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'country', 'user.attribute.country');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'postal_code', 'user.attribute.postal_code');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'street', 'user.attribute.street');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'region', 'user.attribute.region');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a653744a-173d-4521-8bd4-fc56cd5096d2', 'locality', 'user.attribute.locality');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'phoneNumber', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'phone_number', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('8eaddaaa-cb0c-49b4-acbf-13b7541200b8', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'phoneNumberVerified', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'phone_number_verified', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('dc290b5a-3e75-48f2-8af5-a172d9dd3273', 'boolean', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('3296dc2e-3b4e-415c-bf9b-b97031f8f7fe', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3296dc2e-3b4e-415c-bf9b-b97031f8f7fe', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'realm_access.roles', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('81e1c15d-af74-4489-937d-64122cab679f', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'resource_access.${client_id}.roles', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('b17cf7e0-3dd9-4935-aaab-30b90d2a288c', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('97131056-5d65-40d4-8f53-d490b75aa9dc', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('97131056-5d65-40d4-8f53-d490b75aa9dc', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'foo', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'groups', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('54dd173a-bdcf-4d8d-9f52-a27a6d67521f', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'username', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'upn', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('b03434c7-cf06-42e6-acad-4eae87ad5ceb', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('3b56fde0-0b8b-4df7-bdf7-baa79d456588', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3b56fde0-0b8b-4df7-bdf7-baa79d456588', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('3b56fde0-0b8b-4df7-bdf7-baa79d456588', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'AUTH_TIME', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'auth_time', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('53c806f7-e8c0-4edb-97f5-290e7a370f50', 'long', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('c3d08a6e-2506-4e6b-861c-217dfcc7a284', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('c3d08a6e-2506-4e6b-861c-217dfcc7a284', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'clientHost', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'clientHost', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('15797d7c-1464-44ac-8c60-bd4b6b8bc7fa', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'client_id', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'client_id', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('741d1be5-b3d3-4025-ab53-0b76244d4916', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'clientAddress', 'user.session.note');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'clientAddress', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('a9a9d19b-44b5-41b3-af70-e7c8f19287a4', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'true', 'multivalued');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'organization', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('000b35c9-b75f-4a2c-a0e4-a3b77ec2f384', 'String', 'jsonType.label');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'true', 'introspection.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'true', 'userinfo.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'locale', 'user.attribute');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'true', 'id.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'true', 'access.token.claim');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'locale', 'claim.name');
INSERT INTO auth.protocol_mapper_config VALUES ('10b6626f-c9b9-4f6a-a451-f7c1f1982b05', 'String', 'jsonType.label');


--
-- TOC entry 4308 (class 0 OID 16686)
-- Dependencies: 277
-- Data for Name: realm; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.realm VALUES ('0c806647-a11c-403d-af39-092523465ca0', 60, 300, 60, NULL, NULL, NULL, true, false, 0, NULL, 'master', 0, NULL, false, false, false, false, 'EXTERNAL', 1800, 36000, false, false, 'b44bd709-a47c-4200-9be6-48e57da7d91c', 1800, false, NULL, false, false, false, false, 0, 1, 30, 6, 'HmacSHA1', 'totp', '176b4f88-6b3d-44cb-beb4-9317f356d604', 'd5ca2242-a726-45ed-abc5-0ab031f68d89', 'a973adea-a8aa-4ce1-953e-8d759df4b2d9', '80c8bca9-2b6e-472a-bcef-d5f38392de99', 'bace0a66-45dc-406a-b4c9-89ad226d88ce', 2592000, false, 900, true, false, '5e51b971-b52e-4997-9c70-d0fd966312f6', 0, false, 0, 0, 'c9dfe9d4-a8db-4004-9148-41cad23b2bfe');
INSERT INTO auth.realm VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 60, 300, 300, NULL, NULL, NULL, true, false, 0, NULL, 'condominio', 0, NULL, false, false, false, false, 'EXTERNAL', 1800, 36000, false, false, 'a12d00f9-ec24-4109-9127-358f4543feff', 1800, false, NULL, false, false, false, false, 0, 1, 30, 6, 'HmacSHA1', 'totp', '10ae742a-69e7-452f-a568-66130826e196', '6ceecd97-2f19-4979-89b4-8e44ed5d7d40', '91c6b076-6864-4b6f-8065-fa9b38a1922e', '1cbd9972-6fe9-40fb-b508-4f491187a252', 'b113e5e3-3f41-4a35-a895-1bc0ffc86b4f', 2592000, false, 900, true, false, '63a48fc0-d641-4431-98c3-ba940d0d0867', 0, false, 0, 0, 'e087d186-7b4a-406b-819f-315ea7e9ad76');


--
-- TOC entry 4309 (class 0 OID 16719)
-- Dependencies: 278
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.realm_attribute VALUES ('_browser_header.contentSecurityPolicyReportOnly', '0c806647-a11c-403d-af39-092523465ca0', '');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xContentTypeOptions', '0c806647-a11c-403d-af39-092523465ca0', 'nosniff');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.referrerPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'no-referrer');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xRobotsTag', '0c806647-a11c-403d-af39-092523465ca0', 'none');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xFrameOptions', '0c806647-a11c-403d-af39-092523465ca0', 'SAMEORIGIN');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.contentSecurityPolicy', '0c806647-a11c-403d-af39-092523465ca0', 'frame-src ''self''; frame-ancestors ''self''; object-src ''none'';');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.strictTransportSecurity', '0c806647-a11c-403d-af39-092523465ca0', 'max-age=31536000; includeSubDomains');
INSERT INTO auth.realm_attribute VALUES ('bruteForceProtected', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO auth.realm_attribute VALUES ('permanentLockout', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO auth.realm_attribute VALUES ('maxTemporaryLockouts', '0c806647-a11c-403d-af39-092523465ca0', '0');
INSERT INTO auth.realm_attribute VALUES ('bruteForceStrategy', '0c806647-a11c-403d-af39-092523465ca0', 'MULTIPLE');
INSERT INTO auth.realm_attribute VALUES ('maxFailureWaitSeconds', '0c806647-a11c-403d-af39-092523465ca0', '900');
INSERT INTO auth.realm_attribute VALUES ('minimumQuickLoginWaitSeconds', '0c806647-a11c-403d-af39-092523465ca0', '60');
INSERT INTO auth.realm_attribute VALUES ('waitIncrementSeconds', '0c806647-a11c-403d-af39-092523465ca0', '60');
INSERT INTO auth.realm_attribute VALUES ('quickLoginCheckMilliSeconds', '0c806647-a11c-403d-af39-092523465ca0', '1000');
INSERT INTO auth.realm_attribute VALUES ('maxDeltaTimeSeconds', '0c806647-a11c-403d-af39-092523465ca0', '43200');
INSERT INTO auth.realm_attribute VALUES ('failureFactor', '0c806647-a11c-403d-af39-092523465ca0', '30');
INSERT INTO auth.realm_attribute VALUES ('realmReusableOtpCode', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO auth.realm_attribute VALUES ('firstBrokerLoginFlowId', '0c806647-a11c-403d-af39-092523465ca0', 'a2e38ddc-ed5f-446d-bca6-f11e5b6eb71c');
INSERT INTO auth.realm_attribute VALUES ('displayName', '0c806647-a11c-403d-af39-092523465ca0', 'Keycloak');
INSERT INTO auth.realm_attribute VALUES ('displayNameHtml', '0c806647-a11c-403d-af39-092523465ca0', '<div class="kc-logo-text"><span>Keycloak</span></div>');
INSERT INTO auth.realm_attribute VALUES ('defaultSignatureAlgorithm', '0c806647-a11c-403d-af39-092523465ca0', 'RS256');
INSERT INTO auth.realm_attribute VALUES ('offlineSessionMaxLifespanEnabled', '0c806647-a11c-403d-af39-092523465ca0', 'false');
INSERT INTO auth.realm_attribute VALUES ('offlineSessionMaxLifespan', '0c806647-a11c-403d-af39-092523465ca0', '5184000');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.contentSecurityPolicyReportOnly', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xContentTypeOptions', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'nosniff');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.referrerPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'no-referrer');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xRobotsTag', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'none');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.xFrameOptions', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'SAMEORIGIN');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.contentSecurityPolicy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'frame-src ''self''; frame-ancestors ''self''; object-src ''none'';');
INSERT INTO auth.realm_attribute VALUES ('_browser_header.strictTransportSecurity', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'max-age=31536000; includeSubDomains');
INSERT INTO auth.realm_attribute VALUES ('bruteForceProtected', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('permanentLockout', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('maxTemporaryLockouts', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '0');
INSERT INTO auth.realm_attribute VALUES ('bruteForceStrategy', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'MULTIPLE');
INSERT INTO auth.realm_attribute VALUES ('maxFailureWaitSeconds', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '900');
INSERT INTO auth.realm_attribute VALUES ('minimumQuickLoginWaitSeconds', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '60');
INSERT INTO auth.realm_attribute VALUES ('waitIncrementSeconds', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '60');
INSERT INTO auth.realm_attribute VALUES ('quickLoginCheckMilliSeconds', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '1000');
INSERT INTO auth.realm_attribute VALUES ('maxDeltaTimeSeconds', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '43200');
INSERT INTO auth.realm_attribute VALUES ('failureFactor', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '30');
INSERT INTO auth.realm_attribute VALUES ('realmReusableOtpCode', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('defaultSignatureAlgorithm', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'RS256');
INSERT INTO auth.realm_attribute VALUES ('offlineSessionMaxLifespanEnabled', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('offlineSessionMaxLifespan', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '5184000');
INSERT INTO auth.realm_attribute VALUES ('actionTokenGeneratedByAdminLifespan', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '43200');
INSERT INTO auth.realm_attribute VALUES ('actionTokenGeneratedByUserLifespan', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '300');
INSERT INTO auth.realm_attribute VALUES ('oauth2DeviceCodeLifespan', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '600');
INSERT INTO auth.realm_attribute VALUES ('oauth2DevicePollingInterval', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '5');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRpEntityName', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'keycloak');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicySignatureAlgorithms', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'ES256,RS256');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRpId', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAttestationConveyancePreference', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAuthenticatorAttachment', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRequireResidentKey', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyUserVerificationRequirement', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyCreateTimeout', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '0');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAvoidSameAuthenticatorRegister', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRpEntityNamePasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'keycloak');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicySignatureAlgorithmsPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'ES256,RS256');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRpIdPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAttestationConveyancePreferencePasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAuthenticatorAttachmentPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyRequireResidentKeyPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyUserVerificationRequirementPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'not specified');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyCreateTimeoutPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '0');
INSERT INTO auth.realm_attribute VALUES ('webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'false');
INSERT INTO auth.realm_attribute VALUES ('cibaBackchannelTokenDeliveryMode', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'poll');
INSERT INTO auth.realm_attribute VALUES ('cibaExpiresIn', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '120');
INSERT INTO auth.realm_attribute VALUES ('cibaInterval', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '5');
INSERT INTO auth.realm_attribute VALUES ('cibaAuthRequestedUserHint', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'login_hint');
INSERT INTO auth.realm_attribute VALUES ('parRequestUriLifespan', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '60');
INSERT INTO auth.realm_attribute VALUES ('firstBrokerLoginFlowId', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', '4003bde4-9625-4bb7-bd05-8f2d8b22fbe2');


--
-- TOC entry 4310 (class 0 OID 16724)
-- Dependencies: 279
-- Data for Name: realm_default_groups; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4311 (class 0 OID 16727)
-- Dependencies: 280
-- Data for Name: realm_enabled_event_types; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4312 (class 0 OID 16730)
-- Dependencies: 281
-- Data for Name: realm_events_listeners; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.realm_events_listeners VALUES ('0c806647-a11c-403d-af39-092523465ca0', 'jboss-logging');
INSERT INTO auth.realm_events_listeners VALUES ('7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'jboss-logging');


--
-- TOC entry 4313 (class 0 OID 16733)
-- Dependencies: 282
-- Data for Name: realm_localizations; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4314 (class 0 OID 16738)
-- Dependencies: 283
-- Data for Name: realm_required_credential; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.realm_required_credential VALUES ('password', 'password', true, true, '0c806647-a11c-403d-af39-092523465ca0');
INSERT INTO auth.realm_required_credential VALUES ('password', 'password', true, true, '7404ff5e-f51a-4416-b45f-15d2d69cca5f');


--
-- TOC entry 4315 (class 0 OID 16745)
-- Dependencies: 284
-- Data for Name: realm_smtp_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4316 (class 0 OID 16750)
-- Dependencies: 285
-- Data for Name: realm_supported_locales; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4317 (class 0 OID 16753)
-- Dependencies: 286
-- Data for Name: redirect_uris; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.redirect_uris VALUES ('cb329b52-014b-4403-bea0-a5b73129e98e', '/realms/master/account/*');
INSERT INTO auth.redirect_uris VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '/realms/master/account/*');
INSERT INTO auth.redirect_uris VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '/admin/master/console/*');
INSERT INTO auth.redirect_uris VALUES ('7d9b13f0-2234-439a-a937-4060f4a485cf', '/realms/condominio/account/*');
INSERT INTO auth.redirect_uris VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '/realms/condominio/account/*');
INSERT INTO auth.redirect_uris VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '/admin/condominio/console/*');
INSERT INTO auth.redirect_uris VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'http://localhost:8089/callback');
INSERT INTO auth.redirect_uris VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'http://127.0.0.1:47899/callback');
INSERT INTO auth.redirect_uris VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'it.mvs.condominiouiflutter://login-callback');


--
-- TOC entry 4318 (class 0 OID 16756)
-- Dependencies: 287
-- Data for Name: required_action_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4319 (class 0 OID 16761)
-- Dependencies: 288
-- Data for Name: required_action_provider; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.required_action_provider VALUES ('39a5c391-d663-4b2a-a75c-d49197b08a2f', 'VERIFY_EMAIL', 'Verify Email', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'VERIFY_EMAIL', 50);
INSERT INTO auth.required_action_provider VALUES ('1319da51-7ce1-4394-8827-67d2bca51e72', 'UPDATE_PROFILE', 'Update Profile', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_PROFILE', 40);
INSERT INTO auth.required_action_provider VALUES ('e5683f92-48c2-4406-8182-d4f742ebc3f1', 'CONFIGURE_TOTP', 'Configure OTP', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'CONFIGURE_TOTP', 10);
INSERT INTO auth.required_action_provider VALUES ('7734f807-fb74-449d-8c93-4ee189700e73', 'UPDATE_PASSWORD', 'Update Password', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_PASSWORD', 30);
INSERT INTO auth.required_action_provider VALUES ('e8e51948-9b9c-4917-955f-deb2cbe5a806', 'TERMS_AND_CONDITIONS', 'Terms and Conditions', '0c806647-a11c-403d-af39-092523465ca0', false, false, 'TERMS_AND_CONDITIONS', 20);
INSERT INTO auth.required_action_provider VALUES ('0e2649ed-2a8b-4c77-b880-959212429dc1', 'delete_account', 'Delete Account', '0c806647-a11c-403d-af39-092523465ca0', false, false, 'delete_account', 60);
INSERT INTO auth.required_action_provider VALUES ('2a9f3cdc-4262-4fa3-97e8-a80636ad5b22', 'delete_credential', 'Delete Credential', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'delete_credential', 100);
INSERT INTO auth.required_action_provider VALUES ('dba3aaa5-bc22-454a-9440-c7ba2d0c171a', 'update_user_locale', 'Update User Locale', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'update_user_locale', 1000);
INSERT INTO auth.required_action_provider VALUES ('4e4a7a9e-7599-4f7e-b25d-6ca2d18a3a2c', 'UPDATE_EMAIL', 'Update Email', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'UPDATE_EMAIL', 70);
INSERT INTO auth.required_action_provider VALUES ('db12f199-6bfa-4d14-95e5-b3e398f0f91d', 'CONFIGURE_RECOVERY_AUTHN_CODES', 'Recovery Authentication Codes', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'CONFIGURE_RECOVERY_AUTHN_CODES', 120);
INSERT INTO auth.required_action_provider VALUES ('f71ec915-ff49-4e0d-b525-f913e1adf6d3', 'webauthn-register', 'Webauthn Register', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'webauthn-register', 70);
INSERT INTO auth.required_action_provider VALUES ('5036b5d0-bb51-424c-bac7-46e8b1b4f5db', 'webauthn-register-passwordless', 'Webauthn Register Passwordless', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'webauthn-register-passwordless', 80);
INSERT INTO auth.required_action_provider VALUES ('3c669ec7-e014-4458-9472-38cbeb8c0b9a', 'VERIFY_PROFILE', 'Verify Profile', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'VERIFY_PROFILE', 90);
INSERT INTO auth.required_action_provider VALUES ('b4088556-16bc-47b9-8484-a764da1a6a3b', 'idp_link', 'Linking Identity Provider', '0c806647-a11c-403d-af39-092523465ca0', true, false, 'idp_link', 110);
INSERT INTO auth.required_action_provider VALUES ('42c50d2d-3f06-4a56-ad14-ae9d70729cfb', 'VERIFY_EMAIL', 'Verify Email', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'VERIFY_EMAIL', 50);
INSERT INTO auth.required_action_provider VALUES ('d461c577-0182-4a6e-9915-7893630af67a', 'UPDATE_PROFILE', 'Update Profile', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'UPDATE_PROFILE', 40);
INSERT INTO auth.required_action_provider VALUES ('f488c632-93aa-4fa2-8451-98ddf75740a1', 'CONFIGURE_TOTP', 'Configure OTP', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'CONFIGURE_TOTP', 10);
INSERT INTO auth.required_action_provider VALUES ('0b239fa5-1824-445d-8b92-49a4223d2810', 'UPDATE_PASSWORD', 'Update Password', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'UPDATE_PASSWORD', 30);
INSERT INTO auth.required_action_provider VALUES ('018ad489-e0d9-498d-9eee-47a66d0c3ecf', 'TERMS_AND_CONDITIONS', 'Terms and Conditions', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, false, 'TERMS_AND_CONDITIONS', 20);
INSERT INTO auth.required_action_provider VALUES ('330e0be3-6222-4f52-ad93-1fca9461c1fb', 'delete_account', 'Delete Account', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', false, false, 'delete_account', 60);
INSERT INTO auth.required_action_provider VALUES ('abc14cf2-f0c4-4a16-a2c4-d87a56c21ddb', 'delete_credential', 'Delete Credential', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'delete_credential', 100);
INSERT INTO auth.required_action_provider VALUES ('1532c670-2e7e-4909-8745-f1f8d2e43738', 'update_user_locale', 'Update User Locale', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'update_user_locale', 1000);
INSERT INTO auth.required_action_provider VALUES ('11ffe470-f330-428e-ae57-c8eef22d0f89', 'UPDATE_EMAIL', 'Update Email', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'UPDATE_EMAIL', 70);
INSERT INTO auth.required_action_provider VALUES ('f966a0d1-e4ba-4085-b104-a63de85c6c79', 'CONFIGURE_RECOVERY_AUTHN_CODES', 'Recovery Authentication Codes', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'CONFIGURE_RECOVERY_AUTHN_CODES', 120);
INSERT INTO auth.required_action_provider VALUES ('c0da76cb-77ad-4bd9-9d19-0800143b335f', 'webauthn-register', 'Webauthn Register', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'webauthn-register', 70);
INSERT INTO auth.required_action_provider VALUES ('33949292-94a8-4301-99b6-e0582665b380', 'webauthn-register-passwordless', 'Webauthn Register Passwordless', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'webauthn-register-passwordless', 80);
INSERT INTO auth.required_action_provider VALUES ('3395a26f-343f-4f09-829d-cee429e72449', 'VERIFY_PROFILE', 'Verify Profile', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'VERIFY_PROFILE', 90);
INSERT INTO auth.required_action_provider VALUES ('648783ac-b412-4893-b9d3-6bf8742928ea', 'idp_link', 'Linking Identity Provider', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', true, false, 'idp_link', 110);


--
-- TOC entry 4320 (class 0 OID 16768)
-- Dependencies: 289
-- Data for Name: resource_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4321 (class 0 OID 16774)
-- Dependencies: 290
-- Data for Name: resource_policy; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4322 (class 0 OID 16777)
-- Dependencies: 291
-- Data for Name: resource_scope; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4323 (class 0 OID 16780)
-- Dependencies: 292
-- Data for Name: resource_server; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4324 (class 0 OID 16785)
-- Dependencies: 293
-- Data for Name: resource_server_perm_ticket; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4325 (class 0 OID 16790)
-- Dependencies: 294
-- Data for Name: resource_server_policy; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4326 (class 0 OID 16795)
-- Dependencies: 295
-- Data for Name: resource_server_resource; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4327 (class 0 OID 16801)
-- Dependencies: 296
-- Data for Name: resource_server_scope; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4328 (class 0 OID 16806)
-- Dependencies: 297
-- Data for Name: resource_uris; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4329 (class 0 OID 16809)
-- Dependencies: 298
-- Data for Name: revoked_token; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4330 (class 0 OID 16812)
-- Dependencies: 299
-- Data for Name: role_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4331 (class 0 OID 16817)
-- Dependencies: 300
-- Data for Name: scope_mapping; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.scope_mapping VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '34601634-cb47-4e05-8bb9-20cb5dfd0b50');
INSERT INTO auth.scope_mapping VALUES ('8f0c7fef-41a4-4566-84c3-8f1dcab5bd0c', '7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d');
INSERT INTO auth.scope_mapping VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', 'e595f950-21c6-4ab4-960d-b5023056f870');
INSERT INTO auth.scope_mapping VALUES ('7fd7b484-d21f-4b3e-b90a-162ab060025e', '23a43d84-86f5-4537-a4ce-bf0be37559c1');


--
-- TOC entry 4332 (class 0 OID 16820)
-- Dependencies: 301
-- Data for Name: scope_policy; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4333 (class 0 OID 16823)
-- Dependencies: 302
-- Data for Name: server_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4334 (class 0 OID 16829)
-- Dependencies: 303
-- Data for Name: user_attribute; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4335 (class 0 OID 16835)
-- Dependencies: 304
-- Data for Name: user_consent; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4336 (class 0 OID 16840)
-- Dependencies: 305
-- Data for Name: user_consent_client_scope; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4296 (class 0 OID 16618)
-- Dependencies: 264
-- Data for Name: user_entity; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.user_entity VALUES ('679d8ad7-2047-41eb-b88e-bad459ccdc81', NULL, '18392ca1-be8f-4338-83ac-8747a92aba03', false, true, NULL, NULL, NULL, '0c806647-a11c-403d-af39-092523465ca0', 'admin', 1760965845490, NULL, 0);
INSERT INTO auth.user_entity VALUES ('534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c', NULL, '766ffc3e-e517-4d13-9eed-69973fdfc8db', true, true, NULL, 'svc-admin', 'svc-admin', '7404ff5e-f51a-4416-b45f-15d2d69cca5f', 'svc-admin', 1772537204682, NULL, 0);


--
-- TOC entry 4337 (class 0 OID 16843)
-- Dependencies: 306
-- Data for Name: user_federation_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4338 (class 0 OID 16848)
-- Dependencies: 307
-- Data for Name: user_federation_mapper; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4339 (class 0 OID 16853)
-- Dependencies: 308
-- Data for Name: user_federation_mapper_config; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4340 (class 0 OID 16858)
-- Dependencies: 309
-- Data for Name: user_federation_provider; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4297 (class 0 OID 16626)
-- Dependencies: 265
-- Data for Name: user_group_membership; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4341 (class 0 OID 16863)
-- Dependencies: 310
-- Data for Name: user_required_action; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- TOC entry 4342 (class 0 OID 16867)
-- Dependencies: 311
-- Data for Name: user_role_mapping; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.user_role_mapping VALUES ('393c8228-dabe-4927-bec5-d62e0f372af9', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('46d4c4c6-ab10-47b3-9665-43d3f44aaa63', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('d5ff873d-5bc6-444c-89db-b2a7573008ca', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('bd5731c3-d8e2-4830-b512-a914de001373', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('a471a901-48ee-443e-90b1-2c70abd516ea', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('c9dfe9d4-a8db-4004-9148-41cad23b2bfe', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('bcf549e9-6de7-4ba3-a2d7-7864f460fe6a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('dd58dfd2-861f-41eb-9dc8-d956324f9ccd', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('689bf969-bf06-440a-95a4-8429cc400d09', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('8095b4ff-6f0d-414b-8057-22d5471ad338', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('fe8410b4-6e80-4979-ad47-941c192ad518', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('75bb763a-6fc1-4bfe-8432-da1fc12e5efd', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('c56c1682-22c0-4d14-b41f-af9641674de5', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('7e8e4d4a-63fb-42a7-96db-8a6f602a5c9d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('5e45631a-17db-48f8-87dd-278459b02b54', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('3b88fb4b-5e87-4d3e-844f-505f2df71c23', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('90da9da7-9cbd-4e08-afe2-b657bdca5ac0', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('325745f8-d041-4e42-8a89-466e404c775b', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('2c9a23ac-4921-404e-99df-1f5a7b85cd7f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('1bf774c0-76b5-43d3-a6ab-580554987f88', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('a1c70d0f-9a93-41c0-b0d3-3f1a31d78d5c', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('dceb8aa5-57cb-4636-9e53-d4c22906571d', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('6d21a91c-7886-4b8c-8933-7e6f708606fe', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('3a3b68f5-5620-44aa-974f-6b1cf9c2c12a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('d416a33e-2abf-4dc2-b9fa-94a23017e858', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('6c32a60e-78de-4b5a-b19c-69eb7e84ac9a', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('966551e2-bdb1-4c42-a1f4-10c85d410db2', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('c5fbb5ee-4707-425f-836d-3d833f7c294f', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('34601634-cb47-4e05-8bb9-20cb5dfd0b50', '679d8ad7-2047-41eb-b88e-bad459ccdc81');
INSERT INTO auth.user_role_mapping VALUES ('e087d186-7b4a-406b-819f-315ea7e9ad76', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c');
INSERT INTO auth.user_role_mapping VALUES ('5b557614-c20f-6f12-0325-de9631fe201d', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c');
INSERT INTO auth.user_role_mapping VALUES ('27af0f0b-5dd5-434f-a2e7-807776d4a813', '534dd7bc-f0f8-48e9-8b94-0e5d9d5f722c');


--
-- TOC entry 4343 (class 0 OID 16870)
-- Dependencies: 312
-- Data for Name: web_origins; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.web_origins VALUES ('3cd5708c-d0ed-458c-8786-c953920c8f37', '+');
INSERT INTO auth.web_origins VALUES ('2ee548cd-26d4-4604-a004-44e3b2a529f7', '+');
INSERT INTO auth.web_origins VALUES ('6cc0d8f7-2bad-4320-9e69-d7ebb998594a', 'http://localhost:8089');


--
-- TOC entry 4351 (class 0 OID 0)
-- Dependencies: 268
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.menu_items_id_seq', 31, true);


--
-- TOC entry 3905 (class 2606 OID 16874)
-- Name: org_domain ORG_DOMAIN_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.org_domain
    ADD CONSTRAINT "ORG_DOMAIN_pkey" PRIMARY KEY (id, name);


--
-- TOC entry 3897 (class 2606 OID 16876)
-- Name: org ORG_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.org
    ADD CONSTRAINT "ORG_pkey" PRIMARY KEY (id);


--
-- TOC entry 3997 (class 2606 OID 16878)
-- Name: server_config SERVER_CONFIG_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.server_config
    ADD CONSTRAINT "SERVER_CONFIG_pkey" PRIMARY KEY (server_config_key);


--
-- TOC entry 3811 (class 2606 OID 16880)
-- Name: keycloak_role UK_J3RWUVD56ONTGSUHOGM184WW2-2; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.keycloak_role
    ADD CONSTRAINT "UK_J3RWUVD56ONTGSUHOGM184WW2-2" UNIQUE (name, client_realm_constraint);


--
-- TOC entry 3757 (class 2606 OID 16882)
-- Name: client_auth_flow_bindings c_cli_flow_bind; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_auth_flow_bindings
    ADD CONSTRAINT c_cli_flow_bind PRIMARY KEY (client_id, binding_name);


--
-- TOC entry 3772 (class 2606 OID 16884)
-- Name: client_scope_client c_cli_scope_bind; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope_client
    ADD CONSTRAINT c_cli_scope_bind PRIMARY KEY (client_id, scope_id);


--
-- TOC entry 3759 (class 2606 OID 16886)
-- Name: client_initial_access cnstr_client_init_acc_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_initial_access
    ADD CONSTRAINT cnstr_client_init_acc_pk PRIMARY KEY (id);


--
-- TOC entry 3924 (class 2606 OID 16888)
-- Name: realm_default_groups con_group_id_def_groups; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_default_groups
    ADD CONSTRAINT con_group_id_def_groups UNIQUE (group_id);


--
-- TOC entry 3747 (class 2606 OID 16890)
-- Name: broker_link constr_broker_link_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.broker_link
    ADD CONSTRAINT constr_broker_link_pk PRIMARY KEY (identity_provider, user_id);


--
-- TOC entry 3784 (class 2606 OID 16892)
-- Name: component_config constr_component_config_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.component_config
    ADD CONSTRAINT constr_component_config_pk PRIMARY KEY (id);


--
-- TOC entry 3780 (class 2606 OID 16894)
-- Name: component constr_component_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.component
    ADD CONSTRAINT constr_component_pk PRIMARY KEY (id);


--
-- TOC entry 3840 (class 2606 OID 16896)
-- Name: fed_user_required_action constr_fed_required_action; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_required_action
    ADD CONSTRAINT constr_fed_required_action PRIMARY KEY (required_action, user_id);


--
-- TOC entry 3820 (class 2606 OID 16898)
-- Name: fed_user_attribute constr_fed_user_attr_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_attribute
    ADD CONSTRAINT constr_fed_user_attr_pk PRIMARY KEY (id);


--
-- TOC entry 3825 (class 2606 OID 16900)
-- Name: fed_user_consent constr_fed_user_consent_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_consent
    ADD CONSTRAINT constr_fed_user_consent_pk PRIMARY KEY (id);


--
-- TOC entry 3832 (class 2606 OID 16902)
-- Name: fed_user_credential constr_fed_user_cred_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_credential
    ADD CONSTRAINT constr_fed_user_cred_pk PRIMARY KEY (id);


--
-- TOC entry 3836 (class 2606 OID 16904)
-- Name: fed_user_group_membership constr_fed_user_group; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_group_membership
    ADD CONSTRAINT constr_fed_user_group PRIMARY KEY (group_id, user_id);


--
-- TOC entry 3844 (class 2606 OID 16906)
-- Name: fed_user_role_mapping constr_fed_user_role; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_role_mapping
    ADD CONSTRAINT constr_fed_user_role PRIMARY KEY (role_id, user_id);


--
-- TOC entry 3852 (class 2606 OID 16908)
-- Name: federated_user constr_federated_user; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.federated_user
    ADD CONSTRAINT constr_federated_user PRIMARY KEY (id);


--
-- TOC entry 3926 (class 2606 OID 16910)
-- Name: realm_default_groups constr_realm_default_groups; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_default_groups
    ADD CONSTRAINT constr_realm_default_groups PRIMARY KEY (realm_id, group_id);


--
-- TOC entry 3929 (class 2606 OID 16912)
-- Name: realm_enabled_event_types constr_realm_enabl_event_types; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_enabled_event_types
    ADD CONSTRAINT constr_realm_enabl_event_types PRIMARY KEY (realm_id, value);


--
-- TOC entry 3932 (class 2606 OID 16914)
-- Name: realm_events_listeners constr_realm_events_listeners; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_events_listeners
    ADD CONSTRAINT constr_realm_events_listeners PRIMARY KEY (realm_id, value);


--
-- TOC entry 3941 (class 2606 OID 16916)
-- Name: realm_supported_locales constr_realm_supported_locales; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_supported_locales
    ADD CONSTRAINT constr_realm_supported_locales PRIMARY KEY (realm_id, value);


--
-- TOC entry 3854 (class 2606 OID 16918)
-- Name: identity_provider constraint_2b; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider
    ADD CONSTRAINT constraint_2b PRIMARY KEY (internal_id);


--
-- TOC entry 3754 (class 2606 OID 16920)
-- Name: client_attributes constraint_3c; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_attributes
    ADD CONSTRAINT constraint_3c PRIMARY KEY (client_id, name);


--
-- TOC entry 3817 (class 2606 OID 16922)
-- Name: event_entity constraint_4; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.event_entity
    ADD CONSTRAINT constraint_4 PRIMARY KEY (id);


--
-- TOC entry 3848 (class 2606 OID 16924)
-- Name: federated_identity constraint_40; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.federated_identity
    ADD CONSTRAINT constraint_40 PRIMARY KEY (identity_provider, user_id);


--
-- TOC entry 3916 (class 2606 OID 16926)
-- Name: realm constraint_4a; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm
    ADD CONSTRAINT constraint_4a PRIMARY KEY (id);


--
-- TOC entry 4024 (class 2606 OID 16928)
-- Name: user_federation_provider constraint_5c; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_provider
    ADD CONSTRAINT constraint_5c PRIMARY KEY (id);


--
-- TOC entry 3749 (class 2606 OID 16930)
-- Name: client constraint_7; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client
    ADD CONSTRAINT constraint_7 PRIMARY KEY (id);


--
-- TOC entry 3991 (class 2606 OID 16932)
-- Name: scope_mapping constraint_81; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scope_mapping
    ADD CONSTRAINT constraint_81 PRIMARY KEY (client_id, role_id);


--
-- TOC entry 3762 (class 2606 OID 16934)
-- Name: client_node_registrations constraint_84; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_node_registrations
    ADD CONSTRAINT constraint_84 PRIMARY KEY (client_id, name);


--
-- TOC entry 3921 (class 2606 OID 16936)
-- Name: realm_attribute constraint_9; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_attribute
    ADD CONSTRAINT constraint_9 PRIMARY KEY (name, realm_id);


--
-- TOC entry 3937 (class 2606 OID 16938)
-- Name: realm_required_credential constraint_92; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_required_credential
    ADD CONSTRAINT constraint_92 PRIMARY KEY (realm_id, type);


--
-- TOC entry 3813 (class 2606 OID 16940)
-- Name: keycloak_role constraint_a; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.keycloak_role
    ADD CONSTRAINT constraint_a PRIMARY KEY (id);


--
-- TOC entry 3729 (class 2606 OID 16942)
-- Name: admin_event_entity constraint_admin_event_entity; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.admin_event_entity
    ADD CONSTRAINT constraint_admin_event_entity PRIMARY KEY (id);


--
-- TOC entry 3745 (class 2606 OID 16944)
-- Name: authenticator_config_entry constraint_auth_cfg_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authenticator_config_entry
    ADD CONSTRAINT constraint_auth_cfg_pk PRIMARY KEY (authenticator_id, name);


--
-- TOC entry 3735 (class 2606 OID 16946)
-- Name: authentication_execution constraint_auth_exec_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authentication_execution
    ADD CONSTRAINT constraint_auth_exec_pk PRIMARY KEY (id);


--
-- TOC entry 3739 (class 2606 OID 16948)
-- Name: authentication_flow constraint_auth_flow_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authentication_flow
    ADD CONSTRAINT constraint_auth_flow_pk PRIMARY KEY (id);


--
-- TOC entry 3742 (class 2606 OID 16950)
-- Name: authenticator_config constraint_auth_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authenticator_config
    ADD CONSTRAINT constraint_auth_pk PRIMARY KEY (id);


--
-- TOC entry 4030 (class 2606 OID 16952)
-- Name: user_role_mapping constraint_c; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_role_mapping
    ADD CONSTRAINT constraint_c PRIMARY KEY (role_id, user_id);


--
-- TOC entry 3787 (class 2606 OID 16954)
-- Name: composite_role constraint_composite_role; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.composite_role
    ADD CONSTRAINT constraint_composite_role PRIMARY KEY (composite, child_role);


--
-- TOC entry 3861 (class 2606 OID 16956)
-- Name: identity_provider_config constraint_d; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider_config
    ADD CONSTRAINT constraint_d PRIMARY KEY (identity_provider_id, name);


--
-- TOC entry 3908 (class 2606 OID 16958)
-- Name: policy_config constraint_dpc; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.policy_config
    ADD CONSTRAINT constraint_dpc PRIMARY KEY (policy_id, name);


--
-- TOC entry 3939 (class 2606 OID 16960)
-- Name: realm_smtp_config constraint_e; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_smtp_config
    ADD CONSTRAINT constraint_e PRIMARY KEY (realm_id, name);


--
-- TOC entry 3791 (class 2606 OID 16962)
-- Name: credential constraint_f; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.credential
    ADD CONSTRAINT constraint_f PRIMARY KEY (id);


--
-- TOC entry 4016 (class 2606 OID 16964)
-- Name: user_federation_config constraint_f9; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_config
    ADD CONSTRAINT constraint_f9 PRIMARY KEY (user_federation_provider_id, name);


--
-- TOC entry 3962 (class 2606 OID 16966)
-- Name: resource_server_perm_ticket constraint_fapmt; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT constraint_fapmt PRIMARY KEY (id);


--
-- TOC entry 3973 (class 2606 OID 16968)
-- Name: resource_server_resource constraint_farsr; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_resource
    ADD CONSTRAINT constraint_farsr PRIMARY KEY (id);


--
-- TOC entry 3968 (class 2606 OID 16970)
-- Name: resource_server_policy constraint_farsrp; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_policy
    ADD CONSTRAINT constraint_farsrp PRIMARY KEY (id);


--
-- TOC entry 3732 (class 2606 OID 16972)
-- Name: associated_policy constraint_farsrpap; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.associated_policy
    ADD CONSTRAINT constraint_farsrpap PRIMARY KEY (policy_id, associated_policy_id);


--
-- TOC entry 3954 (class 2606 OID 16974)
-- Name: resource_policy constraint_farsrpp; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_policy
    ADD CONSTRAINT constraint_farsrpp PRIMARY KEY (resource_id, policy_id);


--
-- TOC entry 3978 (class 2606 OID 16976)
-- Name: resource_server_scope constraint_farsrs; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_scope
    ADD CONSTRAINT constraint_farsrs PRIMARY KEY (id);


--
-- TOC entry 3957 (class 2606 OID 16978)
-- Name: resource_scope constraint_farsrsp; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_scope
    ADD CONSTRAINT constraint_farsrsp PRIMARY KEY (resource_id, scope_id);


--
-- TOC entry 3994 (class 2606 OID 16980)
-- Name: scope_policy constraint_farsrsps; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scope_policy
    ADD CONSTRAINT constraint_farsrsps PRIMARY KEY (scope_id, policy_id);


--
-- TOC entry 3870 (class 2606 OID 16982)
-- Name: user_entity constraint_fb; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_entity
    ADD CONSTRAINT constraint_fb PRIMARY KEY (id);


--
-- TOC entry 4022 (class 2606 OID 16984)
-- Name: user_federation_mapper_config constraint_fedmapper_cfg_pm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_mapper_config
    ADD CONSTRAINT constraint_fedmapper_cfg_pm PRIMARY KEY (user_federation_mapper_id, name);


--
-- TOC entry 4018 (class 2606 OID 16986)
-- Name: user_federation_mapper constraint_fedmapperpm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_mapper
    ADD CONSTRAINT constraint_fedmapperpm PRIMARY KEY (id);


--
-- TOC entry 3830 (class 2606 OID 16988)
-- Name: fed_user_consent_cl_scope constraint_fgrntcsnt_clsc_pm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.fed_user_consent_cl_scope
    ADD CONSTRAINT constraint_fgrntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- TOC entry 4012 (class 2606 OID 16990)
-- Name: user_consent_client_scope constraint_grntcsnt_clsc_pm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent_client_scope
    ADD CONSTRAINT constraint_grntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- TOC entry 4005 (class 2606 OID 16992)
-- Name: user_consent constraint_grntcsnt_pm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent
    ADD CONSTRAINT constraint_grntcsnt_pm PRIMARY KEY (id);


--
-- TOC entry 3804 (class 2606 OID 16994)
-- Name: keycloak_group constraint_group; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.keycloak_group
    ADD CONSTRAINT constraint_group PRIMARY KEY (id);


--
-- TOC entry 3800 (class 2606 OID 16996)
-- Name: group_attribute constraint_group_attribute_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.group_attribute
    ADD CONSTRAINT constraint_group_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 3808 (class 2606 OID 16998)
-- Name: group_role_mapping constraint_group_role; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.group_role_mapping
    ADD CONSTRAINT constraint_group_role PRIMARY KEY (role_id, group_id);


--
-- TOC entry 3863 (class 2606 OID 17000)
-- Name: identity_provider_mapper constraint_idpm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider_mapper
    ADD CONSTRAINT constraint_idpm PRIMARY KEY (id);


--
-- TOC entry 3866 (class 2606 OID 17002)
-- Name: idp_mapper_config constraint_idpmconfig; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.idp_mapper_config
    ADD CONSTRAINT constraint_idpmconfig PRIMARY KEY (idp_mapper_id, name);


--
-- TOC entry 3868 (class 2606 OID 17004)
-- Name: jgroups_ping constraint_jgroups_ping; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.jgroups_ping
    ADD CONSTRAINT constraint_jgroups_ping PRIMARY KEY (address);


--
-- TOC entry 3883 (class 2606 OID 17006)
-- Name: migration_model constraint_migmod; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.migration_model
    ADD CONSTRAINT constraint_migmod PRIMARY KEY (id);


--
-- TOC entry 3890 (class 2606 OID 17008)
-- Name: offline_client_session constraint_offl_cl_ses_pk3; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.offline_client_session
    ADD CONSTRAINT constraint_offl_cl_ses_pk3 PRIMARY KEY (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag);


--
-- TOC entry 3892 (class 2606 OID 17010)
-- Name: offline_user_session constraint_offl_us_ses_pk2; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.offline_user_session
    ADD CONSTRAINT constraint_offl_us_ses_pk2 PRIMARY KEY (user_session_id, offline_flag);


--
-- TOC entry 3910 (class 2606 OID 17012)
-- Name: protocol_mapper constraint_pcm; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.protocol_mapper
    ADD CONSTRAINT constraint_pcm PRIMARY KEY (id);


--
-- TOC entry 3914 (class 2606 OID 17014)
-- Name: protocol_mapper_config constraint_pmconfig; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.protocol_mapper_config
    ADD CONSTRAINT constraint_pmconfig PRIMARY KEY (protocol_mapper_id, name);


--
-- TOC entry 3944 (class 2606 OID 17016)
-- Name: redirect_uris constraint_redirect_uris; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.redirect_uris
    ADD CONSTRAINT constraint_redirect_uris PRIMARY KEY (client_id, value);


--
-- TOC entry 3947 (class 2606 OID 17018)
-- Name: required_action_config constraint_req_act_cfg_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.required_action_config
    ADD CONSTRAINT constraint_req_act_cfg_pk PRIMARY KEY (required_action_id, name);


--
-- TOC entry 3949 (class 2606 OID 17020)
-- Name: required_action_provider constraint_req_act_prv_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.required_action_provider
    ADD CONSTRAINT constraint_req_act_prv_pk PRIMARY KEY (id);


--
-- TOC entry 4027 (class 2606 OID 17022)
-- Name: user_required_action constraint_required_action; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_required_action
    ADD CONSTRAINT constraint_required_action PRIMARY KEY (required_action, user_id);


--
-- TOC entry 3983 (class 2606 OID 17024)
-- Name: resource_uris constraint_resour_uris_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_uris
    ADD CONSTRAINT constraint_resour_uris_pk PRIMARY KEY (resource_id, value);


--
-- TOC entry 3988 (class 2606 OID 17026)
-- Name: role_attribute constraint_role_attribute_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role_attribute
    ADD CONSTRAINT constraint_role_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 3985 (class 2606 OID 17028)
-- Name: revoked_token constraint_rt; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.revoked_token
    ADD CONSTRAINT constraint_rt PRIMARY KEY (id);


--
-- TOC entry 3999 (class 2606 OID 17030)
-- Name: user_attribute constraint_user_attribute_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_attribute
    ADD CONSTRAINT constraint_user_attribute_pk PRIMARY KEY (id);


--
-- TOC entry 3878 (class 2606 OID 17032)
-- Name: user_group_membership constraint_user_group; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_group_membership
    ADD CONSTRAINT constraint_user_group PRIMARY KEY (group_id, user_id);


--
-- TOC entry 4033 (class 2606 OID 17034)
-- Name: web_origins constraint_web_origins; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.web_origins
    ADD CONSTRAINT constraint_web_origins PRIMARY KEY (client_id, value);


--
-- TOC entry 3794 (class 2606 OID 17036)
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- TOC entry 3881 (class 2606 OID 17038)
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3770 (class 2606 OID 17040)
-- Name: client_scope_attributes pk_cl_tmpl_attr; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope_attributes
    ADD CONSTRAINT pk_cl_tmpl_attr PRIMARY KEY (scope_id, name);


--
-- TOC entry 3765 (class 2606 OID 17042)
-- Name: client_scope pk_cli_template; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope
    ADD CONSTRAINT pk_cli_template PRIMARY KEY (id);


--
-- TOC entry 3960 (class 2606 OID 17044)
-- Name: resource_server pk_resource_server; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server
    ADD CONSTRAINT pk_resource_server PRIMARY KEY (id);


--
-- TOC entry 3778 (class 2606 OID 17046)
-- Name: client_scope_role_mapping pk_template_scope; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope_role_mapping
    ADD CONSTRAINT pk_template_scope PRIMARY KEY (scope_id, role_id);


--
-- TOC entry 3798 (class 2606 OID 17048)
-- Name: default_client_scope r_def_cli_scope_bind; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.default_client_scope
    ADD CONSTRAINT r_def_cli_scope_bind PRIMARY KEY (realm_id, scope_id);


--
-- TOC entry 3935 (class 2606 OID 17050)
-- Name: realm_localizations realm_localizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_localizations
    ADD CONSTRAINT realm_localizations_pkey PRIMARY KEY (realm_id, locale);


--
-- TOC entry 3952 (class 2606 OID 17052)
-- Name: resource_attribute res_attr_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_attribute
    ADD CONSTRAINT res_attr_pk PRIMARY KEY (id);


--
-- TOC entry 3806 (class 2606 OID 17054)
-- Name: keycloak_group sibling_names; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.keycloak_group
    ADD CONSTRAINT sibling_names UNIQUE (realm_id, parent_group, name);


--
-- TOC entry 3859 (class 2606 OID 17056)
-- Name: identity_provider uk_2daelwnibji49avxsrtuf6xj33; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider
    ADD CONSTRAINT uk_2daelwnibji49avxsrtuf6xj33 UNIQUE (provider_alias, realm_id);


--
-- TOC entry 3752 (class 2606 OID 17058)
-- Name: client uk_b71cjlbenv945rb6gcon438at; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client
    ADD CONSTRAINT uk_b71cjlbenv945rb6gcon438at UNIQUE (realm_id, client_id);


--
-- TOC entry 3767 (class 2606 OID 17060)
-- Name: client_scope uk_cli_scope; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope
    ADD CONSTRAINT uk_cli_scope UNIQUE (realm_id, name);


--
-- TOC entry 3874 (class 2606 OID 17062)
-- Name: user_entity uk_dykn684sl8up1crfei6eckhd7; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_entity
    ADD CONSTRAINT uk_dykn684sl8up1crfei6eckhd7 UNIQUE (realm_id, email_constraint);


--
-- TOC entry 4008 (class 2606 OID 17064)
-- Name: user_consent uk_external_consent; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent
    ADD CONSTRAINT uk_external_consent UNIQUE (client_storage_provider, external_client_id, user_id);


--
-- TOC entry 3976 (class 2606 OID 17066)
-- Name: resource_server_resource uk_frsr6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_resource
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5ha6 UNIQUE (name, owner, resource_server_id);


--
-- TOC entry 3966 (class 2606 OID 17068)
-- Name: resource_server_perm_ticket uk_frsr6t700s9v50bu18ws5pmt; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5pmt UNIQUE (owner, requester, resource_server_id, resource_id, scope_id);


--
-- TOC entry 3971 (class 2606 OID 17070)
-- Name: resource_server_policy uk_frsrpt700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_policy
    ADD CONSTRAINT uk_frsrpt700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- TOC entry 3981 (class 2606 OID 17072)
-- Name: resource_server_scope uk_frsrst700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_scope
    ADD CONSTRAINT uk_frsrst700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- TOC entry 4010 (class 2606 OID 17074)
-- Name: user_consent uk_local_consent; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent
    ADD CONSTRAINT uk_local_consent UNIQUE (client_id, user_id);


--
-- TOC entry 3886 (class 2606 OID 17076)
-- Name: migration_model uk_migration_update_time; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.migration_model
    ADD CONSTRAINT uk_migration_update_time UNIQUE (update_time);


--
-- TOC entry 3888 (class 2606 OID 17078)
-- Name: migration_model uk_migration_version; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.migration_model
    ADD CONSTRAINT uk_migration_version UNIQUE (version);


--
-- TOC entry 3899 (class 2606 OID 17080)
-- Name: org uk_org_alias; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.org
    ADD CONSTRAINT uk_org_alias UNIQUE (realm_id, alias);


--
-- TOC entry 3901 (class 2606 OID 17082)
-- Name: org uk_org_group; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.org
    ADD CONSTRAINT uk_org_group UNIQUE (group_id);


--
-- TOC entry 3903 (class 2606 OID 17084)
-- Name: org uk_org_name; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.org
    ADD CONSTRAINT uk_org_name UNIQUE (realm_id, name);


--
-- TOC entry 3919 (class 2606 OID 17086)
-- Name: realm uk_orvsdmla56612eaefiq6wl5oi; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm
    ADD CONSTRAINT uk_orvsdmla56612eaefiq6wl5oi UNIQUE (name);


--
-- TOC entry 3876 (class 2606 OID 17088)
-- Name: user_entity uk_ru8tt6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_entity
    ADD CONSTRAINT uk_ru8tt6t700s9v50bu18ws5ha6 UNIQUE (realm_id, username);


--
-- TOC entry 3821 (class 1259 OID 17089)
-- Name: fed_user_attr_long_values; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX fed_user_attr_long_values ON auth.fed_user_attribute USING btree (long_value_hash, name);


--
-- TOC entry 3822 (class 1259 OID 17090)
-- Name: fed_user_attr_long_values_lower_case; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX fed_user_attr_long_values_lower_case ON auth.fed_user_attribute USING btree (long_value_hash_lower_case, name);


--
-- TOC entry 3730 (class 1259 OID 17091)
-- Name: idx_admin_event_time; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_admin_event_time ON auth.admin_event_entity USING btree (realm_id, admin_event_time);


--
-- TOC entry 3733 (class 1259 OID 17092)
-- Name: idx_assoc_pol_assoc_pol_id; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_assoc_pol_assoc_pol_id ON auth.associated_policy USING btree (associated_policy_id);


--
-- TOC entry 3743 (class 1259 OID 17093)
-- Name: idx_auth_config_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_config_realm ON auth.authenticator_config USING btree (realm_id);


--
-- TOC entry 3736 (class 1259 OID 17094)
-- Name: idx_auth_exec_flow; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_exec_flow ON auth.authentication_execution USING btree (flow_id);


--
-- TOC entry 3737 (class 1259 OID 17095)
-- Name: idx_auth_exec_realm_flow; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_exec_realm_flow ON auth.authentication_execution USING btree (realm_id, flow_id);


--
-- TOC entry 3740 (class 1259 OID 17096)
-- Name: idx_auth_flow_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_flow_realm ON auth.authentication_flow USING btree (realm_id);


--
-- TOC entry 3773 (class 1259 OID 17097)
-- Name: idx_cl_clscope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_cl_clscope ON auth.client_scope_client USING btree (scope_id);


--
-- TOC entry 3755 (class 1259 OID 17098)
-- Name: idx_client_att_by_name_value; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_client_att_by_name_value ON auth.client_attributes USING btree (name, substr(value, 1, 255));


--
-- TOC entry 3750 (class 1259 OID 17099)
-- Name: idx_client_id; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_client_id ON auth.client USING btree (client_id);


--
-- TOC entry 3760 (class 1259 OID 17100)
-- Name: idx_client_init_acc_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_client_init_acc_realm ON auth.client_initial_access USING btree (realm_id);


--
-- TOC entry 3768 (class 1259 OID 17101)
-- Name: idx_clscope_attrs; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_clscope_attrs ON auth.client_scope_attributes USING btree (scope_id);


--
-- TOC entry 3774 (class 1259 OID 17102)
-- Name: idx_clscope_cl; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_clscope_cl ON auth.client_scope_client USING btree (client_id);


--
-- TOC entry 3911 (class 1259 OID 17103)
-- Name: idx_clscope_protmap; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_clscope_protmap ON auth.protocol_mapper USING btree (client_scope_id);


--
-- TOC entry 3775 (class 1259 OID 17104)
-- Name: idx_clscope_role; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_clscope_role ON auth.client_scope_role_mapping USING btree (scope_id);


--
-- TOC entry 3785 (class 1259 OID 17105)
-- Name: idx_compo_config_compo; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_compo_config_compo ON auth.component_config USING btree (component_id);


--
-- TOC entry 3781 (class 1259 OID 17106)
-- Name: idx_component_provider_type; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_component_provider_type ON auth.component USING btree (provider_type);


--
-- TOC entry 3782 (class 1259 OID 17107)
-- Name: idx_component_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_component_realm ON auth.component USING btree (realm_id);


--
-- TOC entry 3788 (class 1259 OID 17108)
-- Name: idx_composite; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_composite ON auth.composite_role USING btree (composite);


--
-- TOC entry 3789 (class 1259 OID 17109)
-- Name: idx_composite_child; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_composite_child ON auth.composite_role USING btree (child_role);


--
-- TOC entry 3795 (class 1259 OID 17110)
-- Name: idx_defcls_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_defcls_realm ON auth.default_client_scope USING btree (realm_id);


--
-- TOC entry 3796 (class 1259 OID 17111)
-- Name: idx_defcls_scope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_defcls_scope ON auth.default_client_scope USING btree (scope_id);


--
-- TOC entry 3818 (class 1259 OID 17112)
-- Name: idx_event_time; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_event_time ON auth.event_entity USING btree (realm_id, event_time);


--
-- TOC entry 3849 (class 1259 OID 17113)
-- Name: idx_fedidentity_feduser; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fedidentity_feduser ON auth.federated_identity USING btree (federated_user_id);


--
-- TOC entry 3850 (class 1259 OID 17114)
-- Name: idx_fedidentity_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fedidentity_user ON auth.federated_identity USING btree (user_id);


--
-- TOC entry 3823 (class 1259 OID 17115)
-- Name: idx_fu_attribute; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_attribute ON auth.fed_user_attribute USING btree (user_id, realm_id, name);


--
-- TOC entry 3826 (class 1259 OID 17116)
-- Name: idx_fu_cnsnt_ext; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_cnsnt_ext ON auth.fed_user_consent USING btree (user_id, client_storage_provider, external_client_id);


--
-- TOC entry 3827 (class 1259 OID 17117)
-- Name: idx_fu_consent; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_consent ON auth.fed_user_consent USING btree (user_id, client_id);


--
-- TOC entry 3828 (class 1259 OID 17118)
-- Name: idx_fu_consent_ru; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_consent_ru ON auth.fed_user_consent USING btree (realm_id, user_id);


--
-- TOC entry 3833 (class 1259 OID 17119)
-- Name: idx_fu_credential; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_credential ON auth.fed_user_credential USING btree (user_id, type);


--
-- TOC entry 3834 (class 1259 OID 17120)
-- Name: idx_fu_credential_ru; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_credential_ru ON auth.fed_user_credential USING btree (realm_id, user_id);


--
-- TOC entry 3837 (class 1259 OID 17121)
-- Name: idx_fu_group_membership; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_group_membership ON auth.fed_user_group_membership USING btree (user_id, group_id);


--
-- TOC entry 3838 (class 1259 OID 17122)
-- Name: idx_fu_group_membership_ru; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_group_membership_ru ON auth.fed_user_group_membership USING btree (realm_id, user_id);


--
-- TOC entry 3841 (class 1259 OID 17123)
-- Name: idx_fu_required_action; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_required_action ON auth.fed_user_required_action USING btree (user_id, required_action);


--
-- TOC entry 3842 (class 1259 OID 17124)
-- Name: idx_fu_required_action_ru; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_required_action_ru ON auth.fed_user_required_action USING btree (realm_id, user_id);


--
-- TOC entry 3845 (class 1259 OID 17125)
-- Name: idx_fu_role_mapping; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_role_mapping ON auth.fed_user_role_mapping USING btree (user_id, role_id);


--
-- TOC entry 3846 (class 1259 OID 17126)
-- Name: idx_fu_role_mapping_ru; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_fu_role_mapping_ru ON auth.fed_user_role_mapping USING btree (realm_id, user_id);


--
-- TOC entry 3801 (class 1259 OID 17127)
-- Name: idx_group_att_by_name_value; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_group_att_by_name_value ON auth.group_attribute USING btree (name, ((value)::character varying(250)));


--
-- TOC entry 3802 (class 1259 OID 17128)
-- Name: idx_group_attr_group; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_group_attr_group ON auth.group_attribute USING btree (group_id);


--
-- TOC entry 3809 (class 1259 OID 17129)
-- Name: idx_group_role_mapp_group; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_group_role_mapp_group ON auth.group_role_mapping USING btree (group_id);


--
-- TOC entry 3864 (class 1259 OID 17130)
-- Name: idx_id_prov_mapp_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_id_prov_mapp_realm ON auth.identity_provider_mapper USING btree (realm_id);


--
-- TOC entry 3855 (class 1259 OID 17131)
-- Name: idx_ident_prov_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_ident_prov_realm ON auth.identity_provider USING btree (realm_id);


--
-- TOC entry 3856 (class 1259 OID 17132)
-- Name: idx_idp_for_login; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_idp_for_login ON auth.identity_provider USING btree (realm_id, enabled, link_only, hide_on_login, organization_id);


--
-- TOC entry 3857 (class 1259 OID 17133)
-- Name: idx_idp_realm_org; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_idp_realm_org ON auth.identity_provider USING btree (realm_id, organization_id);


--
-- TOC entry 3814 (class 1259 OID 17134)
-- Name: idx_keycloak_role_client; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_keycloak_role_client ON auth.keycloak_role USING btree (client);


--
-- TOC entry 3815 (class 1259 OID 17135)
-- Name: idx_keycloak_role_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_keycloak_role_realm ON auth.keycloak_role USING btree (realm);


--
-- TOC entry 3893 (class 1259 OID 17136)
-- Name: idx_offline_uss_by_broker_session_id; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_offline_uss_by_broker_session_id ON auth.offline_user_session USING btree (broker_session_id, realm_id);


--
-- TOC entry 3894 (class 1259 OID 17137)
-- Name: idx_offline_uss_by_last_session_refresh; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_offline_uss_by_last_session_refresh ON auth.offline_user_session USING btree (realm_id, offline_flag, last_session_refresh);


--
-- TOC entry 3895 (class 1259 OID 17138)
-- Name: idx_offline_uss_by_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_offline_uss_by_user ON auth.offline_user_session USING btree (user_id, realm_id, offline_flag);


--
-- TOC entry 3906 (class 1259 OID 17139)
-- Name: idx_org_domain_org_id; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_org_domain_org_id ON auth.org_domain USING btree (org_id);


--
-- TOC entry 3963 (class 1259 OID 17140)
-- Name: idx_perm_ticket_owner; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_perm_ticket_owner ON auth.resource_server_perm_ticket USING btree (owner);


--
-- TOC entry 3964 (class 1259 OID 17141)
-- Name: idx_perm_ticket_requester; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_perm_ticket_requester ON auth.resource_server_perm_ticket USING btree (requester);


--
-- TOC entry 3912 (class 1259 OID 17142)
-- Name: idx_protocol_mapper_client; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_protocol_mapper_client ON auth.protocol_mapper USING btree (client_id);


--
-- TOC entry 3922 (class 1259 OID 17143)
-- Name: idx_realm_attr_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_attr_realm ON auth.realm_attribute USING btree (realm_id);


--
-- TOC entry 3763 (class 1259 OID 17144)
-- Name: idx_realm_clscope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_clscope ON auth.client_scope USING btree (realm_id);


--
-- TOC entry 3927 (class 1259 OID 17145)
-- Name: idx_realm_def_grp_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_def_grp_realm ON auth.realm_default_groups USING btree (realm_id);


--
-- TOC entry 3933 (class 1259 OID 17146)
-- Name: idx_realm_evt_list_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_evt_list_realm ON auth.realm_events_listeners USING btree (realm_id);


--
-- TOC entry 3930 (class 1259 OID 17147)
-- Name: idx_realm_evt_types_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_evt_types_realm ON auth.realm_enabled_event_types USING btree (realm_id);


--
-- TOC entry 3917 (class 1259 OID 17148)
-- Name: idx_realm_master_adm_cli; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_master_adm_cli ON auth.realm USING btree (master_admin_client);


--
-- TOC entry 3942 (class 1259 OID 17149)
-- Name: idx_realm_supp_local_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_realm_supp_local_realm ON auth.realm_supported_locales USING btree (realm_id);


--
-- TOC entry 3945 (class 1259 OID 17150)
-- Name: idx_redir_uri_client; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_redir_uri_client ON auth.redirect_uris USING btree (client_id);


--
-- TOC entry 3950 (class 1259 OID 17151)
-- Name: idx_req_act_prov_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_req_act_prov_realm ON auth.required_action_provider USING btree (realm_id);


--
-- TOC entry 3955 (class 1259 OID 17152)
-- Name: idx_res_policy_policy; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_res_policy_policy ON auth.resource_policy USING btree (policy_id);


--
-- TOC entry 3958 (class 1259 OID 17153)
-- Name: idx_res_scope_scope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_res_scope_scope ON auth.resource_scope USING btree (scope_id);


--
-- TOC entry 3969 (class 1259 OID 17154)
-- Name: idx_res_serv_pol_res_serv; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_res_serv_pol_res_serv ON auth.resource_server_policy USING btree (resource_server_id);


--
-- TOC entry 3974 (class 1259 OID 17155)
-- Name: idx_res_srv_res_res_srv; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_res_srv_res_res_srv ON auth.resource_server_resource USING btree (resource_server_id);


--
-- TOC entry 3979 (class 1259 OID 17156)
-- Name: idx_res_srv_scope_res_srv; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_res_srv_scope_res_srv ON auth.resource_server_scope USING btree (resource_server_id);


--
-- TOC entry 3986 (class 1259 OID 17157)
-- Name: idx_rev_token_on_expire; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_rev_token_on_expire ON auth.revoked_token USING btree (expire);


--
-- TOC entry 3989 (class 1259 OID 17158)
-- Name: idx_role_attribute; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_role_attribute ON auth.role_attribute USING btree (role_id);


--
-- TOC entry 3776 (class 1259 OID 17159)
-- Name: idx_role_clscope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_role_clscope ON auth.client_scope_role_mapping USING btree (role_id);


--
-- TOC entry 3992 (class 1259 OID 17160)
-- Name: idx_scope_mapping_role; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_scope_mapping_role ON auth.scope_mapping USING btree (role_id);


--
-- TOC entry 3995 (class 1259 OID 17161)
-- Name: idx_scope_policy_policy; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_scope_policy_policy ON auth.scope_policy USING btree (policy_id);


--
-- TOC entry 3884 (class 1259 OID 17162)
-- Name: idx_update_time; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_update_time ON auth.migration_model USING btree (update_time);


--
-- TOC entry 4013 (class 1259 OID 17163)
-- Name: idx_usconsent_clscope; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_usconsent_clscope ON auth.user_consent_client_scope USING btree (user_consent_id);


--
-- TOC entry 4014 (class 1259 OID 17164)
-- Name: idx_usconsent_scope_id; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_usconsent_scope_id ON auth.user_consent_client_scope USING btree (scope_id);


--
-- TOC entry 4000 (class 1259 OID 17165)
-- Name: idx_user_attribute; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_attribute ON auth.user_attribute USING btree (user_id);


--
-- TOC entry 4001 (class 1259 OID 17166)
-- Name: idx_user_attribute_name; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_attribute_name ON auth.user_attribute USING btree (name, value);


--
-- TOC entry 4006 (class 1259 OID 17167)
-- Name: idx_user_consent; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_consent ON auth.user_consent USING btree (user_id);


--
-- TOC entry 3792 (class 1259 OID 17168)
-- Name: idx_user_credential; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_credential ON auth.credential USING btree (user_id);


--
-- TOC entry 3871 (class 1259 OID 17169)
-- Name: idx_user_email; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_email ON auth.user_entity USING btree (email);


--
-- TOC entry 3879 (class 1259 OID 17170)
-- Name: idx_user_group_mapping; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_group_mapping ON auth.user_group_membership USING btree (user_id);


--
-- TOC entry 4028 (class 1259 OID 17171)
-- Name: idx_user_reqactions; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_reqactions ON auth.user_required_action USING btree (user_id);


--
-- TOC entry 4031 (class 1259 OID 17172)
-- Name: idx_user_role_mapping; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_role_mapping ON auth.user_role_mapping USING btree (user_id);


--
-- TOC entry 3872 (class 1259 OID 17173)
-- Name: idx_user_service_account; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_service_account ON auth.user_entity USING btree (realm_id, service_account_client_link);


--
-- TOC entry 4019 (class 1259 OID 17174)
-- Name: idx_usr_fed_map_fed_prv; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_usr_fed_map_fed_prv ON auth.user_federation_mapper USING btree (federation_provider_id);


--
-- TOC entry 4020 (class 1259 OID 17175)
-- Name: idx_usr_fed_map_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_usr_fed_map_realm ON auth.user_federation_mapper USING btree (realm_id);


--
-- TOC entry 4025 (class 1259 OID 17176)
-- Name: idx_usr_fed_prv_realm; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_usr_fed_prv_realm ON auth.user_federation_provider USING btree (realm_id);


--
-- TOC entry 4034 (class 1259 OID 17177)
-- Name: idx_web_orig_client; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_web_orig_client ON auth.web_origins USING btree (client_id);


--
-- TOC entry 4002 (class 1259 OID 17178)
-- Name: user_attr_long_values; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_attr_long_values ON auth.user_attribute USING btree (long_value_hash, name);


--
-- TOC entry 4003 (class 1259 OID 17179)
-- Name: user_attr_long_values_lower_case; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_attr_long_values_lower_case ON auth.user_attribute USING btree (long_value_hash_lower_case, name);


--
-- TOC entry 4056 (class 2606 OID 17180)
-- Name: identity_provider fk2b4ebc52ae5c3b34; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider
    ADD CONSTRAINT fk2b4ebc52ae5c3b34 FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4041 (class 2606 OID 17185)
-- Name: client_attributes fk3c47c64beacca966; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_attributes
    ADD CONSTRAINT fk3c47c64beacca966 FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4055 (class 2606 OID 17190)
-- Name: federated_identity fk404288b92ef007a6; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.federated_identity
    ADD CONSTRAINT fk404288b92ef007a6 FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4043 (class 2606 OID 17195)
-- Name: client_node_registrations fk4129723ba992f594; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_node_registrations
    ADD CONSTRAINT fk4129723ba992f594 FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4074 (class 2606 OID 17200)
-- Name: redirect_uris fk_1burs8pb4ouj97h5wuppahv9f; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.redirect_uris
    ADD CONSTRAINT fk_1burs8pb4ouj97h5wuppahv9f FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4100 (class 2606 OID 17205)
-- Name: user_federation_provider fk_1fj32f6ptolw2qy60cd8n01e8; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_provider
    ADD CONSTRAINT fk_1fj32f6ptolw2qy60cd8n01e8 FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4071 (class 2606 OID 17210)
-- Name: realm_required_credential fk_5hg65lybevavkqfki3kponh9v; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_required_credential
    ADD CONSTRAINT fk_5hg65lybevavkqfki3kponh9v FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4076 (class 2606 OID 17215)
-- Name: resource_attribute fk_5hrm2vlf9ql5fu022kqepovbr; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu022kqepovbr FOREIGN KEY (resource_id) REFERENCES auth.resource_server_resource(id);


--
-- TOC entry 4093 (class 2606 OID 17220)
-- Name: user_attribute fk_5hrm2vlf9ql5fu043kqepovbr; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu043kqepovbr FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4101 (class 2606 OID 17225)
-- Name: user_required_action fk_6qj3w1jw9cvafhe19bwsiuvmd; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_required_action
    ADD CONSTRAINT fk_6qj3w1jw9cvafhe19bwsiuvmd FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4054 (class 2606 OID 17230)
-- Name: keycloak_role fk_6vyqfe4cn4wlq8r6kt5vdsj5c; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.keycloak_role
    ADD CONSTRAINT fk_6vyqfe4cn4wlq8r6kt5vdsj5c FOREIGN KEY (realm) REFERENCES auth.realm(id);


--
-- TOC entry 4072 (class 2606 OID 17235)
-- Name: realm_smtp_config fk_70ej8xdxgxd0b9hh6180irr0o; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_smtp_config
    ADD CONSTRAINT fk_70ej8xdxgxd0b9hh6180irr0o FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4067 (class 2606 OID 17240)
-- Name: realm_attribute fk_8shxd6l3e9atqukacxgpffptw; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_attribute
    ADD CONSTRAINT fk_8shxd6l3e9atqukacxgpffptw FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4048 (class 2606 OID 17245)
-- Name: composite_role fk_a63wvekftu8jo1pnj81e7mce2; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.composite_role
    ADD CONSTRAINT fk_a63wvekftu8jo1pnj81e7mce2 FOREIGN KEY (composite) REFERENCES auth.keycloak_role(id);


--
-- TOC entry 4037 (class 2606 OID 17250)
-- Name: authentication_execution fk_auth_exec_flow; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authentication_execution
    ADD CONSTRAINT fk_auth_exec_flow FOREIGN KEY (flow_id) REFERENCES auth.authentication_flow(id);


--
-- TOC entry 4038 (class 2606 OID 17255)
-- Name: authentication_execution fk_auth_exec_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authentication_execution
    ADD CONSTRAINT fk_auth_exec_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4039 (class 2606 OID 17260)
-- Name: authentication_flow fk_auth_flow_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authentication_flow
    ADD CONSTRAINT fk_auth_flow_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4040 (class 2606 OID 17265)
-- Name: authenticator_config fk_auth_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.authenticator_config
    ADD CONSTRAINT fk_auth_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4102 (class 2606 OID 17270)
-- Name: user_role_mapping fk_c4fqv34p1mbylloxang7b1q3l; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_role_mapping
    ADD CONSTRAINT fk_c4fqv34p1mbylloxang7b1q3l FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4044 (class 2606 OID 17275)
-- Name: client_scope_attributes fk_cl_scope_attr_scope; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope_attributes
    ADD CONSTRAINT fk_cl_scope_attr_scope FOREIGN KEY (scope_id) REFERENCES auth.client_scope(id);


--
-- TOC entry 4045 (class 2606 OID 17280)
-- Name: client_scope_role_mapping fk_cl_scope_rm_scope; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_scope_role_mapping
    ADD CONSTRAINT fk_cl_scope_rm_scope FOREIGN KEY (scope_id) REFERENCES auth.client_scope(id);


--
-- TOC entry 4064 (class 2606 OID 17285)
-- Name: protocol_mapper fk_cli_scope_mapper; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.protocol_mapper
    ADD CONSTRAINT fk_cli_scope_mapper FOREIGN KEY (client_scope_id) REFERENCES auth.client_scope(id);


--
-- TOC entry 4042 (class 2606 OID 17290)
-- Name: client_initial_access fk_client_init_acc_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.client_initial_access
    ADD CONSTRAINT fk_client_init_acc_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4047 (class 2606 OID 17295)
-- Name: component_config fk_component_config; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.component_config
    ADD CONSTRAINT fk_component_config FOREIGN KEY (component_id) REFERENCES auth.component(id);


--
-- TOC entry 4046 (class 2606 OID 17300)
-- Name: component fk_component_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.component
    ADD CONSTRAINT fk_component_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4068 (class 2606 OID 17305)
-- Name: realm_default_groups fk_def_groups_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_default_groups
    ADD CONSTRAINT fk_def_groups_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4099 (class 2606 OID 17310)
-- Name: user_federation_mapper_config fk_fedmapper_cfg; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_mapper_config
    ADD CONSTRAINT fk_fedmapper_cfg FOREIGN KEY (user_federation_mapper_id) REFERENCES auth.user_federation_mapper(id);


--
-- TOC entry 4097 (class 2606 OID 17315)
-- Name: user_federation_mapper fk_fedmapperpm_fedprv; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_fedprv FOREIGN KEY (federation_provider_id) REFERENCES auth.user_federation_provider(id);


--
-- TOC entry 4098 (class 2606 OID 17320)
-- Name: user_federation_mapper fk_fedmapperpm_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4035 (class 2606 OID 17325)
-- Name: associated_policy fk_frsr5s213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.associated_policy
    ADD CONSTRAINT fk_frsr5s213xcx4wnkog82ssrfy FOREIGN KEY (associated_policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4091 (class 2606 OID 17330)
-- Name: scope_policy fk_frsrasp13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scope_policy
    ADD CONSTRAINT fk_frsrasp13xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4081 (class 2606 OID 17335)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog82sspmt; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82sspmt FOREIGN KEY (resource_server_id) REFERENCES auth.resource_server(id);


--
-- TOC entry 4086 (class 2606 OID 17340)
-- Name: resource_server_resource fk_frsrho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_resource
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES auth.resource_server(id);


--
-- TOC entry 4082 (class 2606 OID 17345)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog83sspmt; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog83sspmt FOREIGN KEY (resource_id) REFERENCES auth.resource_server_resource(id);


--
-- TOC entry 4083 (class 2606 OID 17350)
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog84sspmt; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog84sspmt FOREIGN KEY (scope_id) REFERENCES auth.resource_server_scope(id);


--
-- TOC entry 4036 (class 2606 OID 17355)
-- Name: associated_policy fk_frsrpas14xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.associated_policy
    ADD CONSTRAINT fk_frsrpas14xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4092 (class 2606 OID 17360)
-- Name: scope_policy fk_frsrpass3xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scope_policy
    ADD CONSTRAINT fk_frsrpass3xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES auth.resource_server_scope(id);


--
-- TOC entry 4084 (class 2606 OID 17365)
-- Name: resource_server_perm_ticket fk_frsrpo2128cx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrpo2128cx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4085 (class 2606 OID 17370)
-- Name: resource_server_policy fk_frsrpo213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_policy
    ADD CONSTRAINT fk_frsrpo213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES auth.resource_server(id);


--
-- TOC entry 4079 (class 2606 OID 17375)
-- Name: resource_scope fk_frsrpos13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_scope
    ADD CONSTRAINT fk_frsrpos13xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES auth.resource_server_resource(id);


--
-- TOC entry 4077 (class 2606 OID 17380)
-- Name: resource_policy fk_frsrpos53xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_policy
    ADD CONSTRAINT fk_frsrpos53xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES auth.resource_server_resource(id);


--
-- TOC entry 4078 (class 2606 OID 17385)
-- Name: resource_policy fk_frsrpp213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_policy
    ADD CONSTRAINT fk_frsrpp213xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4080 (class 2606 OID 17390)
-- Name: resource_scope fk_frsrps213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_scope
    ADD CONSTRAINT fk_frsrps213xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES auth.resource_server_scope(id);


--
-- TOC entry 4087 (class 2606 OID 17395)
-- Name: resource_server_scope fk_frsrso213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_server_scope
    ADD CONSTRAINT fk_frsrso213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES auth.resource_server(id);


--
-- TOC entry 4049 (class 2606 OID 17400)
-- Name: composite_role fk_gr7thllb9lu8q4vqa4524jjy8; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.composite_role
    ADD CONSTRAINT fk_gr7thllb9lu8q4vqa4524jjy8 FOREIGN KEY (child_role) REFERENCES auth.keycloak_role(id);


--
-- TOC entry 4095 (class 2606 OID 17405)
-- Name: user_consent_client_scope fk_grntcsnt_clsc_usc; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent_client_scope
    ADD CONSTRAINT fk_grntcsnt_clsc_usc FOREIGN KEY (user_consent_id) REFERENCES auth.user_consent(id);


--
-- TOC entry 4094 (class 2606 OID 17410)
-- Name: user_consent fk_grntcsnt_user; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_consent
    ADD CONSTRAINT fk_grntcsnt_user FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4052 (class 2606 OID 17415)
-- Name: group_attribute fk_group_attribute_group; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.group_attribute
    ADD CONSTRAINT fk_group_attribute_group FOREIGN KEY (group_id) REFERENCES auth.keycloak_group(id);


--
-- TOC entry 4053 (class 2606 OID 17420)
-- Name: group_role_mapping fk_group_role_group; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.group_role_mapping
    ADD CONSTRAINT fk_group_role_group FOREIGN KEY (group_id) REFERENCES auth.keycloak_group(id);


--
-- TOC entry 4069 (class 2606 OID 17425)
-- Name: realm_enabled_event_types fk_h846o4h0w8epx5nwedrf5y69j; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_enabled_event_types
    ADD CONSTRAINT fk_h846o4h0w8epx5nwedrf5y69j FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4070 (class 2606 OID 17430)
-- Name: realm_events_listeners fk_h846o4h0w8epx5nxev9f5y69j; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_events_listeners
    ADD CONSTRAINT fk_h846o4h0w8epx5nxev9f5y69j FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4058 (class 2606 OID 17435)
-- Name: identity_provider_mapper fk_idpm_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider_mapper
    ADD CONSTRAINT fk_idpm_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4059 (class 2606 OID 17440)
-- Name: idp_mapper_config fk_idpmconfig; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.idp_mapper_config
    ADD CONSTRAINT fk_idpmconfig FOREIGN KEY (idp_mapper_id) REFERENCES auth.identity_provider_mapper(id);


--
-- TOC entry 4103 (class 2606 OID 17445)
-- Name: web_origins fk_lojpho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.web_origins
    ADD CONSTRAINT fk_lojpho213xcx4wnkog82ssrfy FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4090 (class 2606 OID 17450)
-- Name: scope_mapping fk_ouse064plmlr732lxjcn1q5f1; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scope_mapping
    ADD CONSTRAINT fk_ouse064plmlr732lxjcn1q5f1 FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4065 (class 2606 OID 17455)
-- Name: protocol_mapper fk_pcm_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.protocol_mapper
    ADD CONSTRAINT fk_pcm_realm FOREIGN KEY (client_id) REFERENCES auth.client(id);


--
-- TOC entry 4050 (class 2606 OID 17460)
-- Name: credential fk_pfyr0glasqyl0dei3kl69r6v0; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.credential
    ADD CONSTRAINT fk_pfyr0glasqyl0dei3kl69r6v0 FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4066 (class 2606 OID 17465)
-- Name: protocol_mapper_config fk_pmconfig; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.protocol_mapper_config
    ADD CONSTRAINT fk_pmconfig FOREIGN KEY (protocol_mapper_id) REFERENCES auth.protocol_mapper(id);


--
-- TOC entry 4051 (class 2606 OID 17470)
-- Name: default_client_scope fk_r_def_cli_scope_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.default_client_scope
    ADD CONSTRAINT fk_r_def_cli_scope_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4075 (class 2606 OID 17475)
-- Name: required_action_provider fk_req_act_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.required_action_provider
    ADD CONSTRAINT fk_req_act_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4088 (class 2606 OID 17480)
-- Name: resource_uris fk_resource_server_uris; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.resource_uris
    ADD CONSTRAINT fk_resource_server_uris FOREIGN KEY (resource_id) REFERENCES auth.resource_server_resource(id);


--
-- TOC entry 4089 (class 2606 OID 17485)
-- Name: role_attribute fk_role_attribute_id; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role_attribute
    ADD CONSTRAINT fk_role_attribute_id FOREIGN KEY (role_id) REFERENCES auth.keycloak_role(id);


--
-- TOC entry 4073 (class 2606 OID 17490)
-- Name: realm_supported_locales fk_supported_locales_realm; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.realm_supported_locales
    ADD CONSTRAINT fk_supported_locales_realm FOREIGN KEY (realm_id) REFERENCES auth.realm(id);


--
-- TOC entry 4096 (class 2606 OID 17495)
-- Name: user_federation_config fk_t13hpu1j94r2ebpekr39x5eu5; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_federation_config
    ADD CONSTRAINT fk_t13hpu1j94r2ebpekr39x5eu5 FOREIGN KEY (user_federation_provider_id) REFERENCES auth.user_federation_provider(id);


--
-- TOC entry 4060 (class 2606 OID 17500)
-- Name: user_group_membership fk_user_group_user; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_group_membership
    ADD CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES auth.user_entity(id);


--
-- TOC entry 4063 (class 2606 OID 17505)
-- Name: policy_config fkdc34197cf864c4e43; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.policy_config
    ADD CONSTRAINT fkdc34197cf864c4e43 FOREIGN KEY (policy_id) REFERENCES auth.resource_server_policy(id);


--
-- TOC entry 4057 (class 2606 OID 17510)
-- Name: identity_provider_config fkdc4897cf864c4e43; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity_provider_config
    ADD CONSTRAINT fkdc4897cf864c4e43 FOREIGN KEY (identity_provider_id) REFERENCES auth.identity_provider(internal_id);


--
-- TOC entry 4061 (class 2606 OID 17515)
-- Name: menu_items fkdv3wkrnc2guttkjxjbr4ykqke; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.menu_items
    ADD CONSTRAINT fkdv3wkrnc2guttkjxjbr4ykqke FOREIGN KEY (role_id) REFERENCES auth.keycloak_role(id);


--
-- TOC entry 4062 (class 2606 OID 17520)
-- Name: menu_items fkkcxk88u5djnbobanga7hj14q6; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.menu_items
    ADD CONSTRAINT fkkcxk88u5djnbobanga7hj14q6 FOREIGN KEY (parent_id) REFERENCES auth.menu_items(id);


-- Completed on 2026-03-03 14:36:38

--
-- PostgreSQL database dump complete
--

