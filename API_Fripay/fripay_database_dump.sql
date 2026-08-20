--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

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

ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_sender_user_id_foreign;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_sender_account_id_foreign;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_recipient_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_corridor_id_foreign;
ALTER TABLE IF EXISTS ONLY public.transaction_status_history DROP CONSTRAINT IF EXISTS transaction_status_history_transaction_id_foreign;
ALTER TABLE IF EXISTS ONLY public.staff_users DROP CONSTRAINT IF EXISTS staff_users_role_id_foreign;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_foreign;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_foreign;
ALTER TABLE IF EXISTS ONLY public.phone_prefixes DROP CONSTRAINT IF EXISTS phone_prefixes_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_user_id_foreign;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_related_transaction_id_foreign;
ALTER TABLE IF EXISTS ONLY public.linked_accounts DROP CONSTRAINT IF EXISTS linked_accounts_user_id_foreign;
ALTER TABLE IF EXISTS ONLY public.linked_accounts DROP CONSTRAINT IF EXISTS linked_accounts_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.corridors DROP CONSTRAINT IF EXISTS corridors_source_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.corridors DROP CONSTRAINT IF EXISTS corridors_destination_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.contacts DROP CONSTRAINT IF EXISTS contacts_user_id_foreign;
ALTER TABLE IF EXISTS ONLY public.contacts DROP CONSTRAINT IF EXISTS contacts_detected_operator_id_foreign;
ALTER TABLE IF EXISTS ONLY public.auth_sessions DROP CONSTRAINT IF EXISTS auth_sessions_user_id_foreign;
DROP INDEX IF EXISTS public.personal_access_tokens_tokenable_type_tokenable_id_index;
DROP INDEX IF EXISTS public.personal_access_tokens_expires_at_index;
ALTER TABLE IF EXISTS ONLY public.webhook_events DROP CONSTRAINT IF EXISTS webhook_events_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_phone_number_unique;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_unique;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_reference_unique;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_idempotency_key_unique;
ALTER TABLE IF EXISTS ONLY public.transaction_status_history DROP CONSTRAINT IF EXISTS transaction_status_history_pkey;
ALTER TABLE IF EXISTS ONLY public.staff_users DROP CONSTRAINT IF EXISTS staff_users_pkey;
ALTER TABLE IF EXISTS ONLY public.staff_users DROP CONSTRAINT IF EXISTS staff_users_email_unique;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_name_unique;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_permission_id_unique;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.phone_prefixes DROP CONSTRAINT IF EXISTS phone_prefixes_pkey;
ALTER TABLE IF EXISTS ONLY public.personal_access_tokens DROP CONSTRAINT IF EXISTS personal_access_tokens_token_unique;
ALTER TABLE IF EXISTS ONLY public.personal_access_tokens DROP CONSTRAINT IF EXISTS personal_access_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_code_unique;
ALTER TABLE IF EXISTS ONLY public.otp_codes DROP CONSTRAINT IF EXISTS otp_codes_pkey;
ALTER TABLE IF EXISTS ONLY public.operators DROP CONSTRAINT IF EXISTS operators_pkey;
ALTER TABLE IF EXISTS ONLY public.operators DROP CONSTRAINT IF EXISTS operators_code_unique;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.linked_accounts DROP CONSTRAINT IF EXISTS linked_accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.corridors DROP CONSTRAINT IF EXISTS corridors_pkey;
ALTER TABLE IF EXISTS ONLY public.contacts DROP CONSTRAINT IF EXISTS contacts_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_sessions DROP CONSTRAINT IF EXISTS auth_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_pkey;
ALTER TABLE IF EXISTS public.webhook_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.transaction_status_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.staff_users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.role_permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.phone_prefixes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.operators ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.migrations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.corridors ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_logs ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.webhook_events_id_seq;
DROP TABLE IF EXISTS public.webhook_events;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.transactions;
DROP SEQUENCE IF EXISTS public.transaction_status_history_id_seq;
DROP TABLE IF EXISTS public.transaction_status_history;
DROP SEQUENCE IF EXISTS public.staff_users_id_seq;
DROP TABLE IF EXISTS public.staff_users;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.role_permissions_id_seq;
DROP TABLE IF EXISTS public.role_permissions;
DROP SEQUENCE IF EXISTS public.phone_prefixes_id_seq;
DROP TABLE IF EXISTS public.phone_prefixes;
DROP SEQUENCE IF EXISTS public.personal_access_tokens_id_seq;
DROP TABLE IF EXISTS public.personal_access_tokens;
DROP SEQUENCE IF EXISTS public.permissions_id_seq;
DROP TABLE IF EXISTS public.permissions;
DROP TABLE IF EXISTS public.otp_codes;
DROP SEQUENCE IF EXISTS public.operators_id_seq;
DROP TABLE IF EXISTS public.operators;
DROP TABLE IF EXISTS public.notifications;
DROP SEQUENCE IF EXISTS public.migrations_id_seq;
DROP TABLE IF EXISTS public.migrations;
DROP TABLE IF EXISTS public.linked_accounts;
DROP SEQUENCE IF EXISTS public.corridors_id_seq;
DROP TABLE IF EXISTS public.corridors;
DROP TABLE IF EXISTS public.contacts;
DROP TABLE IF EXISTS public.auth_sessions;
DROP SEQUENCE IF EXISTS public.audit_logs_id_seq;
DROP TABLE IF EXISTS public.audit_logs;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    actor_type character varying(20) NOT NULL,
    actor_id character varying(100) NOT NULL,
    action character varying(100) NOT NULL,
    entity_type character varying(100),
    entity_id character varying(100),
    payload jsonb,
    ip_address character varying(45),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    refresh_token_hash text NOT NULL,
    device_info text,
    ip_address character varying(45),
    revoked boolean DEFAULT false NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    contact_phone character varying(20) NOT NULL,
    contact_name character varying(150) NOT NULL,
    detected_operator_id smallint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: corridors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.corridors (
    id bigint NOT NULL,
    source_operator_id smallint NOT NULL,
    destination_operator_id smallint NOT NULL,
    rail character varying(20) NOT NULL,
    aggregator_provider character varying(50),
    priority smallint DEFAULT '10'::smallint NOT NULL,
    fee_type character varying(20) NOT NULL,
    fee_value numeric(12,4) NOT NULL,
    fee_cap numeric(14,2),
    min_amount numeric(14,2) NOT NULL,
    max_amount numeric(14,2) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: corridors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.corridors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: corridors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.corridors_id_seq OWNED BY public.corridors.id;


--
-- Name: linked_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linked_accounts (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    operator_id smallint NOT NULL,
    msisdn character varying(20) NOT NULL,
    alias_type character varying(20),
    alias_value character varying(64),
    is_primary boolean DEFAULT false NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    type character varying(30) NOT NULL,
    channel character varying(20) NOT NULL,
    title character varying(200) NOT NULL,
    body text NOT NULL,
    related_transaction_id uuid,
    read boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: operators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operators (
    id smallint NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    country_code character(2) DEFAULT 'BJ'::bpchar NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: operators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operators_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operators_id_seq OWNED BY public.operators.id;


--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_codes (
    id uuid NOT NULL,
    phone_number character varying(20) NOT NULL,
    code_hash text NOT NULL,
    purpose character varying(30) NOT NULL,
    attempts smallint DEFAULT '0'::smallint NOT NULL,
    consumed boolean DEFAULT false NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    code character varying(100) NOT NULL,
    description character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: phone_prefixes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phone_prefixes (
    id bigint NOT NULL,
    operator_id smallint NOT NULL,
    prefix character varying(10) NOT NULL,
    country_code character(2) NOT NULL
);


--
-- Name: phone_prefixes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phone_prefixes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phone_prefixes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phone_prefixes_id_seq OWNED BY public.phone_prefixes.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: staff_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_users (
    id bigint NOT NULL,
    email character varying(150) NOT NULL,
    password_hash text NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    role_id bigint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: staff_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staff_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_users_id_seq OWNED BY public.staff_users.id;


--
-- Name: transaction_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_status_history (
    id bigint NOT NULL,
    transaction_id uuid NOT NULL,
    previous_status character varying(20),
    new_status character varying(20) NOT NULL,
    source character varying(50) DEFAULT 'system'::character varying NOT NULL,
    note text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: transaction_status_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_status_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_status_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_status_history_id_seq OWNED BY public.transaction_status_history.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id uuid NOT NULL,
    reference character varying(40) NOT NULL,
    idempotency_key character varying(100) NOT NULL,
    sender_user_id uuid NOT NULL,
    sender_account_id uuid NOT NULL,
    recipient_phone character varying(20) NOT NULL,
    recipient_operator_id smallint NOT NULL,
    recipient_name character varying(150),
    amount numeric(14,2) NOT NULL,
    currency character(3) DEFAULT 'XOF'::bpchar NOT NULL,
    fee_amount numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    total_debited numeric(14,2) NOT NULL,
    rail_used character varying(20),
    aggregator_provider character varying(50),
    corridor_id bigint,
    status character varying(20) DEFAULT 'initiated'::character varying NOT NULL,
    failure_reason text,
    external_reference character varying(100),
    client_type_snapshot character varying(1),
    metadata jsonb,
    initiated_at timestamp(0) without time zone NOT NULL,
    completed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    phone_number character varying(20) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email character varying(150),
    pin_hash text,
    kyc_status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    client_type character varying(1) DEFAULT 'P'::character varying NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    preferred_language character varying(5) DEFAULT 'fr'::character varying NOT NULL,
    last_login_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: webhook_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_events (
    id bigint NOT NULL,
    provider character varying(50) NOT NULL,
    signature_valid boolean DEFAULT false NOT NULL,
    payload jsonb NOT NULL,
    processed boolean DEFAULT false NOT NULL,
    processing_error text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: webhook_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_events_id_seq OWNED BY public.webhook_events.id;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: corridors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corridors ALTER COLUMN id SET DEFAULT nextval('public.corridors_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: operators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators ALTER COLUMN id SET DEFAULT nextval('public.operators_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: phone_prefixes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_prefixes ALTER COLUMN id SET DEFAULT nextval('public.phone_prefixes_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: staff_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_users ALTER COLUMN id SET DEFAULT nextval('public.staff_users_id_seq'::regclass);


--
-- Name: transaction_status_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_status_history ALTER COLUMN id SET DEFAULT nextval('public.transaction_status_history_id_seq'::regclass);


--
-- Name: webhook_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_events ALTER COLUMN id SET DEFAULT nextval('public.webhook_events_id_seq'::regclass);


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, actor_type, actor_id, action, entity_type, entity_id, payload, ip_address, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_sessions (id, user_id, refresh_token_hash, device_info, ip_address, revoked, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contacts (id, user_id, contact_phone, contact_name, detected_operator_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: corridors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.corridors (id, source_operator_id, destination_operator_id, rail, aggregator_provider, priority, fee_type, fee_value, fee_cap, min_amount, max_amount, active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: linked_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.linked_accounts (id, user_id, operator_id, msisdn, alias_type, alias_value, is_primary, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000001_create_operators_table	1
2	0001_01_01_000002_create_phone_prefixes_table	1
3	0001_01_01_000003_create_users_table	1
4	0001_01_01_000004_create_otp_codes_table	1
5	0001_01_01_000005_create_auth_sessions_table	1
6	0001_01_01_000006_create_linked_accounts_table	1
7	0001_01_01_000007_create_contacts_table	1
8	0001_01_01_000008_create_corridors_table	1
9	0001_01_01_000009_create_transactions_table	1
10	0001_01_01_000010_create_transaction_status_history_table	1
11	0001_01_01_000011_create_notifications_table	1
12	0001_01_01_000012_create_audit_logs_table	1
13	0001_01_01_000013_create_webhook_events_table	1
14	0001_01_01_000014_create_roles_table	1
15	0001_01_01_000015_create_permissions_table	1
16	0001_01_01_000016_create_role_permissions_table	1
17	0001_01_01_000017_create_staff_users_table	1
18	2026_07_20_103800_create_personal_access_tokens_table	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, type, channel, title, body, related_transaction_id, read, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: operators; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.operators (id, code, name, country_code, active, created_at, updated_at) FROM stdin;
1	MTN	MTN Bénin	BJ	t	2026-07-20 10:57:07	2026-07-20 10:57:07
2	MOOV	Moov Africa Bénin	BJ	t	2026-07-20 10:57:07	2026-07-20 10:57:07
3	CELTIIS	Celtiis Bénin	BJ	t	2026-07-20 10:57:07	2026-07-20 10:57:07
\.


--
-- Data for Name: otp_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.otp_codes (id, phone_number, code_hash, purpose, attempts, consumed, expires_at, created_at, updated_at) FROM stdin;
019f7f47-a5e2-7151-896e-dfa1712d12f4	+22997000001	$2y$12$Yof0BzJ1kkirqAcAmy/7Be5syVMWPNSuR2jnlifyA0feTRh0Tg/6G	registration	0	f	2026-07-20 11:32:09	2026-07-20 11:27:09	2026-07-20 11:27:09
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, code, description, created_at, updated_at) FROM stdin;
1	users.read	Consulter les utilisateurs	2026-07-20 10:57:07	2026-07-20 10:57:07
2	users.block	Bloquer/débloquer un utilisateur	2026-07-20 10:57:07	2026-07-20 10:57:07
3	transactions.read	Consulter les transactions	2026-07-20 10:57:07	2026-07-20 10:57:07
4	transactions.retry	Relancer une transaction en échec	2026-07-20 10:57:07	2026-07-20 10:57:07
5	corridors.read	Consulter les corridors	2026-07-20 10:57:07	2026-07-20 10:57:07
6	corridors.write	Créer/modifier les corridors	2026-07-20 10:57:07	2026-07-20 10:57:07
7	dashboard.read	Consulter le tableau de bord	2026-07-20 10:57:07	2026-07-20 10:57:07
8	staff.read	Consulter le personnel	2026-07-20 10:57:07	2026-07-20 10:57:07
9	staff.write	Gérer le personnel	2026-07-20 10:57:07	2026-07-20 10:57:07
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: phone_prefixes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.phone_prefixes (id, operator_id, prefix, country_code) FROM stdin;
1	1	22901	BJ
2	1	22997	BJ
3	1	22967	BJ
4	1	22969	BJ
5	1	22999	BJ
6	2	22941	BJ
7	2	22942	BJ
8	2	22943	BJ
9	2	22944	BJ
10	2	22945	BJ
11	3	22946	BJ
12	3	22947	BJ
13	3	22948	BJ
14	3	22949	BJ
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (id, role_id, permission_id) FROM stdin;
1	1	1
2	1	2
3	1	3
4	1	4
5	1	5
6	1	6
7	1	7
8	1	8
9	1	9
10	2	1
11	2	3
12	2	4
13	2	7
14	3	3
15	3	5
16	3	6
17	3	7
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, created_at, updated_at) FROM stdin;
1	super_admin	Accès complet à toutes les fonctionnalités	2026-07-20 10:57:07	2026-07-20 10:57:07
2	support	Support client - consultation et actions limitées	2026-07-20 10:57:07	2026-07-20 10:57:07
3	finance	Gestion des corridors et rapports financiers	2026-07-20 10:57:07	2026-07-20 10:57:07
\.


--
-- Data for Name: staff_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.staff_users (id, email, password_hash, first_name, last_name, role_id, active, created_at, updated_at) FROM stdin;
1	admin@fripay.bj	$2y$12$F6SPrM7TOYYa1Xw.DkHx.e5tfaqDejKP124eOsekmXhnWYhA6vWVW	Super	Admin	1	t	2026-07-20 10:57:08	2026-07-20 10:57:08
\.


--
-- Data for Name: transaction_status_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction_status_history (id, transaction_id, previous_status, new_status, source, note, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, reference, idempotency_key, sender_user_id, sender_account_id, recipient_phone, recipient_operator_id, recipient_name, amount, currency, fee_amount, total_debited, rail_used, aggregator_provider, corridor_id, status, failure_reason, external_reference, client_type_snapshot, metadata, initiated_at, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, phone_number, first_name, last_name, email, pin_hash, kyc_status, client_type, status, preferred_language, last_login_at, created_at, updated_at) FROM stdin;
019f7f47-a3b8-70a6-b800-96dd211ec961	+22997000001	Test	User	\N	\N	pending	P	active	fr	\N	2026-07-20 11:27:09	2026-07-20 11:27:09
\.


--
-- Data for Name: webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.webhook_events (id, provider, signature_valid, payload, processed, processing_error, created_at, updated_at) FROM stdin;
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 1, false);


--
-- Name: corridors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.corridors_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 18, true);


--
-- Name: operators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.operators_id_seq', 3, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 9, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: phone_prefixes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.phone_prefixes_id_seq', 14, true);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.role_permissions_id_seq', 17, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: staff_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.staff_users_id_seq', 1, true);


--
-- Name: transaction_status_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transaction_status_history_id_seq', 1, false);


--
-- Name: webhook_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.webhook_events_id_seq', 1, false);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: corridors corridors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corridors
    ADD CONSTRAINT corridors_pkey PRIMARY KEY (id);


--
-- Name: linked_accounts linked_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_accounts
    ADD CONSTRAINT linked_accounts_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: operators operators_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_code_unique UNIQUE (code);


--
-- Name: operators operators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_unique UNIQUE (code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: phone_prefixes phone_prefixes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_prefixes
    ADD CONSTRAINT phone_prefixes_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_unique UNIQUE (role_id, permission_id);


--
-- Name: roles roles_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_unique UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: staff_users staff_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_users
    ADD CONSTRAINT staff_users_email_unique UNIQUE (email);


--
-- Name: staff_users staff_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_users
    ADD CONSTRAINT staff_users_pkey PRIMARY KEY (id);


--
-- Name: transaction_status_history transaction_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_status_history
    ADD CONSTRAINT transaction_status_history_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_idempotency_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_idempotency_key_unique UNIQUE (idempotency_key);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_reference_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_reference_unique UNIQUE (reference);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_phone_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_unique UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_events webhook_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_events
    ADD CONSTRAINT webhook_events_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: auth_sessions auth_sessions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: contacts contacts_detected_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_detected_operator_id_foreign FOREIGN KEY (detected_operator_id) REFERENCES public.operators(id);


--
-- Name: contacts contacts_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: corridors corridors_destination_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corridors
    ADD CONSTRAINT corridors_destination_operator_id_foreign FOREIGN KEY (destination_operator_id) REFERENCES public.operators(id);


--
-- Name: corridors corridors_source_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corridors
    ADD CONSTRAINT corridors_source_operator_id_foreign FOREIGN KEY (source_operator_id) REFERENCES public.operators(id);


--
-- Name: linked_accounts linked_accounts_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_accounts
    ADD CONSTRAINT linked_accounts_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.operators(id);


--
-- Name: linked_accounts linked_accounts_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_accounts
    ADD CONSTRAINT linked_accounts_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_related_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_related_transaction_id_foreign FOREIGN KEY (related_transaction_id) REFERENCES public.transactions(id);


--
-- Name: notifications notifications_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: phone_prefixes phone_prefixes_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_prefixes
    ADD CONSTRAINT phone_prefixes_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.operators(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: staff_users staff_users_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_users
    ADD CONSTRAINT staff_users_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: transaction_status_history transaction_status_history_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_status_history
    ADD CONSTRAINT transaction_status_history_transaction_id_foreign FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_corridor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_corridor_id_foreign FOREIGN KEY (corridor_id) REFERENCES public.corridors(id);


--
-- Name: transactions transactions_recipient_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_recipient_operator_id_foreign FOREIGN KEY (recipient_operator_id) REFERENCES public.operators(id);


--
-- Name: transactions transactions_sender_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_sender_account_id_foreign FOREIGN KEY (sender_account_id) REFERENCES public.linked_accounts(id);


--
-- Name: transactions transactions_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

