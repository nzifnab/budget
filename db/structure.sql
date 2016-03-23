--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_histories (
    id integer NOT NULL,
    amount numeric(10,2),
    description text,
    overflow_from_id integer,
    account_id integer,
    quick_fund_id integer,
    income_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    explanation text
);


--
-- Name: account_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_histories_id_seq OWNED BY account_histories.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name text,
    description text,
    priority integer,
    enabled boolean,
    amount numeric(10,2),
    negative_overflow_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    prerequisite_account_id integer,
    cap numeric,
    add_per_month numeric,
    add_per_month_type text,
    monthly_cap numeric,
    overflow_into_id integer,
    annual_cap numeric(8,2),
    category_sum_id integer
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: category_sums; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE category_sums (
    id integer NOT NULL,
    name text,
    amount numeric(8,2) DEFAULT 0,
    user_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: category_sums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE category_sums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_sums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE category_sums_id_seq OWNED BY category_sums.id;


--
-- Name: incomes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE incomes (
    id integer NOT NULL,
    amount numeric,
    user_id integer,
    description text,
    income_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    applied_at timestamp without time zone
);


--
-- Name: incomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE incomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE incomes_id_seq OWNED BY incomes.id;


--
-- Name: quick_funds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_funds (
    id integer NOT NULL,
    amount numeric(10,2),
    account_id integer,
    description text,
    fund_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: quick_funds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_funds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_funds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_funds_id_seq OWNED BY quick_funds.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    first_name text,
    last_name text,
    email text,
    password_digest character varying,
    undistributed_funds numeric(10,2) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_login_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_histories ALTER COLUMN id SET DEFAULT nextval('account_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_sums ALTER COLUMN id SET DEFAULT nextval('category_sums_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY incomes ALTER COLUMN id SET DEFAULT nextval('incomes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_funds ALTER COLUMN id SET DEFAULT nextval('quick_funds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: account_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_histories
    ADD CONSTRAINT account_histories_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: category_sums_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY category_sums
    ADD CONSTRAINT category_sums_pkey PRIMARY KEY (id);


--
-- Name: incomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incomes
    ADD CONSTRAINT incomes_pkey PRIMARY KEY (id);


--
-- Name: quick_funds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_funds
    ADD CONSTRAINT quick_funds_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_account_histories_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_histories_on_account_id ON account_histories USING btree (account_id);


--
-- Name: index_account_histories_on_income_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_histories_on_income_id ON account_histories USING btree (income_id);


--
-- Name: index_account_histories_on_overflow_from_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_histories_on_overflow_from_id ON account_histories USING btree (overflow_from_id);


--
-- Name: index_account_histories_on_quick_fund_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_histories_on_quick_fund_id ON account_histories USING btree (quick_fund_id);


--
-- Name: index_accounts_on_category_sum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_category_sum_id ON accounts USING btree (category_sum_id);


--
-- Name: index_accounts_on_negative_overflow_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_negative_overflow_id ON accounts USING btree (negative_overflow_id);


--
-- Name: index_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_user_id ON accounts USING btree (user_id);


--
-- Name: index_category_sums_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_category_sums_on_user_id ON category_sums USING btree (user_id);


--
-- Name: index_incomes_on_applied_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_incomes_on_applied_at ON incomes USING btree (applied_at);


--
-- Name: index_quick_funds_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quick_funds_on_account_id ON quick_funds USING btree (account_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130824223328');

INSERT INTO schema_migrations (version) VALUES ('20140223180028');

INSERT INTO schema_migrations (version) VALUES ('20140223220744');

INSERT INTO schema_migrations (version) VALUES ('20140224023334');

INSERT INTO schema_migrations (version) VALUES ('20140317033438');

INSERT INTO schema_migrations (version) VALUES ('20140323022130');

INSERT INTO schema_migrations (version) VALUES ('20140707010619');

INSERT INTO schema_migrations (version) VALUES ('20160115031516');

INSERT INTO schema_migrations (version) VALUES ('20160319025652');

INSERT INTO schema_migrations (version) VALUES ('20160319043433');

INSERT INTO schema_migrations (version) VALUES ('20160321032939');

INSERT INTO schema_migrations (version) VALUES ('20160321232118');

