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
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: group_score_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_score_categories (
    id integer NOT NULL,
    group_score_type_id integer NOT NULL,
    competition_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_scores (
    id integer NOT NULL,
    team_id integer NOT NULL,
    team_number integer DEFAULT 0 NOT NULL,
    gender integer NOT NULL,
    "time" integer NOT NULL,
    group_score_category_id integer NOT NULL,
    run character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    last_name character varying NOT NULL,
    first_name character varying NOT NULL,
    gender integer NOT NULL,
    nation_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scores (
    id integer NOT NULL,
    person_id integer NOT NULL,
    discipline character varying NOT NULL,
    competition_id integer NOT NULL,
    "time" integer NOT NULL,
    team_id integer,
    team_number integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: competition_team_numbers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW competition_team_numbers AS
 SELECT group_scores.team_id,
    group_scores.team_number,
    group_scores.gender,
    group_score_categories.competition_id
   FROM (group_scores
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
  WHERE (group_scores.team_number >= 0)
UNION
 SELECT scores.team_id,
    scores.team_number,
    people.gender,
    scores.competition_id
   FROM (scores
     JOIN people ON ((people.id = scores.person_id)))
  WHERE ((scores.team_number >= 0) AND (scores.team_id IS NOT NULL));


--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE competitions (
    id integer NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    place_id integer NOT NULL,
    event_id integer NOT NULL,
    score_type_id integer,
    date date NOT NULL,
    published_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE competitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE competitions_id_seq OWNED BY competitions.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: group_score_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_score_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_score_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_score_categories_id_seq OWNED BY group_score_categories.id;


--
-- Name: group_score_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_score_types (
    id integer NOT NULL,
    discipline character varying NOT NULL,
    name character varying NOT NULL,
    regular boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: person_participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE person_participations (
    id integer NOT NULL,
    person_id integer NOT NULL,
    group_score_id integer NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_score_participations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW group_score_participations AS
 SELECT person_participations.person_id,
    group_scores.team_id,
    group_score_categories.competition_id,
    group_score_categories.group_score_type_id,
    group_score_types.discipline,
    group_scores."time",
    person_participations."position"
   FROM (((person_participations
     JOIN group_scores ON ((group_scores.id = person_participations.group_score_id)))
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
     JOIN group_score_types ON ((group_score_types.id = group_score_categories.group_score_type_id)));


--
-- Name: group_score_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_score_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_score_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_score_types_id_seq OWNED BY group_score_types.id;


--
-- Name: group_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_scores_id_seq OWNED BY group_scores.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    label character varying,
    linkable_id integer,
    linkable_type character varying,
    url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: nations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nations (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nations_id_seq OWNED BY nations.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE news (
    id integer NOT NULL,
    title character varying,
    admin_user_id integer,
    content character varying,
    published_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE news_id_seq OWNED BY news.id;


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: person_participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE person_participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE person_participations_id_seq OWNED BY person_participations.id;


--
-- Name: places; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE places (
    id integer NOT NULL,
    name character varying NOT NULL,
    latitude numeric(15,10),
    longitude numeric(15,10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE places_id_seq OWNED BY places.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: score_double_events; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW score_double_events AS
 SELECT DISTINCT ON (concat(hb_scores.competition_id, '-', hb_scores.person_id)) hb_scores.person_id,
    hb_scores.competition_id,
    hb_scores."time" AS hb,
    hl_scores."time" AS hl,
    (hb_scores."time" + hl_scores."time") AS "time"
   FROM (( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE (((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hb'::text)) AND (scores.team_number >= 0))) hb_scores
     JOIN ( SELECT scores."time",
            scores.competition_id,
            scores.person_id
           FROM scores
          WHERE (((scores."time" <> 99999999) AND ((scores.discipline)::text = 'hl'::text)) AND (scores.team_number >= 0))) hl_scores ON (((hb_scores.competition_id = hl_scores.competition_id) AND (hb_scores.person_id = hl_scores.person_id))))
  ORDER BY concat(hb_scores.competition_id, '-', hb_scores.person_id), (hb_scores."time" + hl_scores."time");


--
-- Name: score_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE score_types (
    id integer NOT NULL,
    people integer NOT NULL,
    run integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: score_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE score_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: score_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE score_types_id_seq OWNED BY score_types.id;


--
-- Name: scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scores_id_seq OWNED BY scores.id;


--
-- Name: series_assessments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE series_assessments (
    id integer NOT NULL,
    round_id integer NOT NULL,
    aggregate_type character varying NOT NULL,
    discipline character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    type character varying NOT NULL,
    gender integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: series_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE series_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_assessments_id_seq OWNED BY series_assessments.id;


--
-- Name: series_cups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE series_cups (
    id integer NOT NULL,
    round_id integer NOT NULL,
    competition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: series_cups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE series_cups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_cups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_cups_id_seq OWNED BY series_cups.id;


--
-- Name: series_participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE series_participations (
    id integer NOT NULL,
    assessment_id integer NOT NULL,
    cup_id integer NOT NULL,
    type character varying NOT NULL,
    team_id integer,
    team_number integer,
    person_id integer,
    "time" integer NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    rank integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: series_participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE series_participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_participations_id_seq OWNED BY series_participations.id;


--
-- Name: series_rounds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE series_rounds (
    id integer NOT NULL,
    name character varying NOT NULL,
    year integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: series_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE series_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE series_rounds_id_seq OWNED BY series_rounds.id;


--
-- Name: team_competitions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW team_competitions AS
 SELECT group_scores.team_id,
    group_score_categories.competition_id
   FROM (group_scores
     JOIN group_score_categories ON ((group_score_categories.id = group_scores.group_score_category_id)))
UNION
 SELECT scores.team_id,
    scores.competition_id
   FROM scores
  WHERE (scores.team_id IS NOT NULL);


--
-- Name: team_members; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW team_members AS
 SELECT group_scores.team_id,
    person_participations.person_id
   FROM (group_scores
     JOIN person_participations ON ((person_participations.group_score_id = group_scores.id)))
UNION
 SELECT scores.team_id,
    scores.person_id
   FROM scores
  WHERE (scores.team_id IS NOT NULL);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE teams (
    id integer NOT NULL,
    name character varying NOT NULL,
    shortcut character varying NOT NULL,
    status integer NOT NULL,
    latitude numeric(15,10),
    longitude numeric(15,10),
    image character varying,
    state character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying,
    email_address character varying,
    ip_address character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: years; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW years AS
 SELECT date_part('year'::text, competitions.date) AS year
   FROM competitions
  GROUP BY date_part('year'::text, competitions.date)
  ORDER BY date_part('year'::text, competitions.date) DESC;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions ALTER COLUMN id SET DEFAULT nextval('competitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_score_categories ALTER COLUMN id SET DEFAULT nextval('group_score_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_score_types ALTER COLUMN id SET DEFAULT nextval('group_score_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_scores ALTER COLUMN id SET DEFAULT nextval('group_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nations ALTER COLUMN id SET DEFAULT nextval('nations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY news ALTER COLUMN id SET DEFAULT nextval('news_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_participations ALTER COLUMN id SET DEFAULT nextval('person_participations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY places ALTER COLUMN id SET DEFAULT nextval('places_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY score_types ALTER COLUMN id SET DEFAULT nextval('score_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scores ALTER COLUMN id SET DEFAULT nextval('scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_assessments ALTER COLUMN id SET DEFAULT nextval('series_assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_cups ALTER COLUMN id SET DEFAULT nextval('series_cups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_participations ALTER COLUMN id SET DEFAULT nextval('series_participations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_rounds ALTER COLUMN id SET DEFAULT nextval('series_rounds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: group_score_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_score_categories
    ADD CONSTRAINT group_score_categories_pkey PRIMARY KEY (id);


--
-- Name: group_score_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_score_types
    ADD CONSTRAINT group_score_types_pkey PRIMARY KEY (id);


--
-- Name: group_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_scores
    ADD CONSTRAINT group_scores_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: nations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nations
    ADD CONSTRAINT nations_pkey PRIMARY KEY (id);


--
-- Name: news_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: person_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY person_participations
    ADD CONSTRAINT person_participations_pkey PRIMARY KEY (id);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: score_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY score_types
    ADD CONSTRAINT score_types_pkey PRIMARY KEY (id);


--
-- Name: scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: series_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY series_assessments
    ADD CONSTRAINT series_assessments_pkey PRIMARY KEY (id);


--
-- Name: series_cups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY series_cups
    ADD CONSTRAINT series_cups_pkey PRIMARY KEY (id);


--
-- Name: series_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY series_participations
    ADD CONSTRAINT series_participations_pkey PRIMARY KEY (id);


--
-- Name: series_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY series_rounds
    ADD CONSTRAINT series_rounds_pkey PRIMARY KEY (id);


--
-- Name: teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_competitions_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_competitions_on_event_id ON competitions USING btree (event_id);


--
-- Name: index_competitions_on_place_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_competitions_on_place_id ON competitions USING btree (place_id);


--
-- Name: index_competitions_on_score_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_competitions_on_score_type_id ON competitions USING btree (score_type_id);


--
-- Name: index_group_score_categories_on_competition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_score_categories_on_competition_id ON group_score_categories USING btree (competition_id);


--
-- Name: index_group_score_categories_on_group_score_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_score_categories_on_group_score_type_id ON group_score_categories USING btree (group_score_type_id);


--
-- Name: index_group_scores_on_group_score_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_scores_on_group_score_category_id ON group_scores USING btree (group_score_category_id);


--
-- Name: index_group_scores_on_team_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_scores_on_team_id ON group_scores USING btree (team_id);


--
-- Name: index_news_on_admin_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_news_on_admin_user_id ON news USING btree (admin_user_id);


--
-- Name: index_people_on_gender; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_gender ON people USING btree (gender);


--
-- Name: index_people_on_nation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_nation_id ON people USING btree (nation_id);


--
-- Name: index_person_participations_on_group_score_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_person_participations_on_group_score_id ON person_participations USING btree (group_score_id);


--
-- Name: index_person_participations_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_person_participations_on_person_id ON person_participations USING btree (person_id);


--
-- Name: index_scores_on_competition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scores_on_competition_id ON scores USING btree (competition_id);


--
-- Name: index_scores_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scores_on_person_id ON scores USING btree (person_id);


--
-- Name: index_scores_on_team_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scores_on_team_id ON scores USING btree (team_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_087bd7ddca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_score_categories
    ADD CONSTRAINT fk_rails_087bd7ddca FOREIGN KEY (group_score_type_id) REFERENCES group_score_types(id);


--
-- Name: fk_rails_0a382359da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_participations
    ADD CONSTRAINT fk_rails_0a382359da FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: fk_rails_10e3de7ab6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_participations
    ADD CONSTRAINT fk_rails_10e3de7ab6 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: fk_rails_15526a74ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_participations
    ADD CONSTRAINT fk_rails_15526a74ba FOREIGN KEY (cup_id) REFERENCES series_cups(id);


--
-- Name: fk_rails_17052afd34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT fk_rails_17052afd34 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: fk_rails_23d89423d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT fk_rails_23d89423d6 FOREIGN KEY (competition_id) REFERENCES competitions(id);


--
-- Name: fk_rails_2fdd48a6eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_assessments
    ADD CONSTRAINT fk_rails_2fdd48a6eb FOREIGN KEY (round_id) REFERENCES series_rounds(id);


--
-- Name: fk_rails_339a5440d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT fk_rails_339a5440d1 FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_rails_63932e2707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_cups
    ADD CONSTRAINT fk_rails_63932e2707 FOREIGN KEY (competition_id) REFERENCES competitions(id);


--
-- Name: fk_rails_6c5935622b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY news
    ADD CONSTRAINT fk_rails_6c5935622b FOREIGN KEY (admin_user_id) REFERENCES admin_users(id);


--
-- Name: fk_rails_6d79ed02ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_participations
    ADD CONSTRAINT fk_rails_6d79ed02ed FOREIGN KEY (group_score_id) REFERENCES group_scores(id);


--
-- Name: fk_rails_7f26f3b040; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT fk_rails_7f26f3b040 FOREIGN KEY (score_type_id) REFERENCES score_types(id);


--
-- Name: fk_rails_88b53fe618; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT fk_rails_88b53fe618 FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: fk_rails_a3a6694385; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_score_categories
    ADD CONSTRAINT fk_rails_a3a6694385 FOREIGN KEY (competition_id) REFERENCES competitions(id);


--
-- Name: fk_rails_bb2ca8f375; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_scores
    ADD CONSTRAINT fk_rails_bb2ca8f375 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: fk_rails_c201f283e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT fk_rails_c201f283e7 FOREIGN KEY (nation_id) REFERENCES nations(id);


--
-- Name: fk_rails_deb9c05685; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT fk_rails_deb9c05685 FOREIGN KEY (place_id) REFERENCES places(id);


--
-- Name: fk_rails_e0f7fe67d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_participations
    ADD CONSTRAINT fk_rails_e0f7fe67d8 FOREIGN KEY (assessment_id) REFERENCES series_assessments(id);


--
-- Name: fk_rails_e53e7ce3f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_scores
    ADD CONSTRAINT fk_rails_e53e7ce3f3 FOREIGN KEY (group_score_category_id) REFERENCES group_score_categories(id);


--
-- Name: fk_rails_ecdcb1c04e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_cups
    ADD CONSTRAINT fk_rails_ecdcb1c04e FOREIGN KEY (round_id) REFERENCES series_rounds(id);


--
-- Name: fk_rails_fb34e7583c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY series_participations
    ADD CONSTRAINT fk_rails_fb34e7583c FOREIGN KEY (person_id) REFERENCES people(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150921202610');

INSERT INTO schema_migrations (version) VALUES ('20150921202842');

INSERT INTO schema_migrations (version) VALUES ('20150921202933');

INSERT INTO schema_migrations (version) VALUES ('20150921203221');

INSERT INTO schema_migrations (version) VALUES ('20150921203415');

INSERT INTO schema_migrations (version) VALUES ('20150921203620');

INSERT INTO schema_migrations (version) VALUES ('20150921203851');

INSERT INTO schema_migrations (version) VALUES ('20150921204000');

INSERT INTO schema_migrations (version) VALUES ('20150921204228');

INSERT INTO schema_migrations (version) VALUES ('20150921204445');

INSERT INTO schema_migrations (version) VALUES ('20150921204903');

INSERT INTO schema_migrations (version) VALUES ('20150921205018');

INSERT INTO schema_migrations (version) VALUES ('20150927070536');

INSERT INTO schema_migrations (version) VALUES ('20150927070537');

INSERT INTO schema_migrations (version) VALUES ('20150928060950');

INSERT INTO schema_migrations (version) VALUES ('20151019081006');

INSERT INTO schema_migrations (version) VALUES ('20151019133228');

INSERT INTO schema_migrations (version) VALUES ('20151029081006');

INSERT INTO schema_migrations (version) VALUES ('20151108070537');

INSERT INTO schema_migrations (version) VALUES ('20151113161728');

INSERT INTO schema_migrations (version) VALUES ('20151113161743');

INSERT INTO schema_migrations (version) VALUES ('20151113163555');

INSERT INTO schema_migrations (version) VALUES ('20151113163556');

INSERT INTO schema_migrations (version) VALUES ('20151117103227');

INSERT INTO schema_migrations (version) VALUES ('20151121000132');

INSERT INTO schema_migrations (version) VALUES ('20151127185700');

INSERT INTO schema_migrations (version) VALUES ('20151205201552');

