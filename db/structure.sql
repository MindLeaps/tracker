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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'male',
    'female'
);


--
-- Name: update_enrollments(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_enrollments() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  current_enrollment_group_id int := null;
BEGIN
  SELECT group_id into current_enrollment_group_id FROM enrollments e where e.student_id = new.id;
  if current_enrollment_group_id is null or current_enrollment_group_id != new.group_id then
    update enrollments set inactive_since = now() where inactive_since is null;
    insert into enrollments (student_id, group_id, active_since, inactive_since, created_at, updated_at)
    values (new.id, new.group_id, now(), null, now(), now());
  end if;
  return new;
END;
$$;


--
-- Name: update_records_with_unique_mlids(text, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.update_records_with_unique_mlids(table_name text, mlid_length integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    rec RECORD;
    new_mlid TEXT;
BEGIN
    EXECUTE format('ALTER TABLE %I ADD COLUMN mlid VARCHAR(%s) UNIQUE CONSTRAINT uppercase CHECK(mlid = UPPER(mlid));', table_name, mlid_length);
    FOR rec IN EXECUTE format('SELECT * FROM %I', table_name) LOOP
        LOOP
            IF rec.mlid IS NOT NULL THEN
                EXIT;
            END IF;
            new_mlid := SUBSTRING(UPPER(MD5(''||NOW()::TEXT||RANDOM()::TEXT)) FOR mlid_length);
            BEGIN
               UPDATE organizations SET mlid = new_mlid WHERE id = rec.id;
               EXIT; -- we successfully updated the record so we can exit this iteration and continue to the next one
            EXCEPTION WHEN unique_violation THEN
                -- we catch the exception and let this loop iteration run again
            END;
        END LOOP;
    END LOOP;
    EXECUTE format('ALTER TABLE %I ALTER COLUMN mlid SET NOT NULL;', table_name);
END;
$$;


--
-- Name: update_records_with_unique_mlids(text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.update_records_with_unique_mlids(table_name text, mlid_length integer, unique_scope text DEFAULT NULL::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    rec RECORD;
    new_mlid TEXT;
BEGIN
    IF unique_scope IS NULL THEN
        EXECUTE format('ALTER TABLE %I ADD COLUMN mlid VARCHAR(%s) UNIQUE CONSTRAINT uppercase CHECK(mlid = UPPER(mlid));', table_name, mlid_length);
    ELSE
        EXECUTE format('ALTER TABLE %I ADD COLUMN mlid VARCHAR(%s) CONSTRAINT uppercase CHECK(mlid = UPPER(mlid));', table_name, mlid_length);
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT unique_mlid_per_%I UNIQUE(mlid, %I);', table_name, unique_scope, unique_scope);
    END IF;
    FOR rec IN EXECUTE format('SELECT * FROM %I', table_name) LOOP
            LOOP
                IF rec.mlid IS NOT NULL THEN
                    EXIT;
                END IF;
                new_mlid := SUBSTRING(UPPER(MD5(''||NOW()::TEXT||RANDOM()::TEXT)) FOR mlid_length);
                BEGIN
                    EXECUTE format('UPDATE %I SET mlid = %L WHERE id = %s', table_name, new_mlid, rec.id);
                    EXIT; -- we successfully updated the record so we can exit this iteration and continue to the next one
                EXCEPTION WHEN unique_violation THEN
                -- we catch the exception and let this loop iteration run again
                END;
            END LOOP;
        END LOOP;
    EXECUTE format('ALTER TABLE %I ALTER COLUMN mlid SET NOT NULL;', table_name);
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: absences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.absences (
    id integer NOT NULL,
    student_id integer NOT NULL,
    lesson_id integer NOT NULL
);


--
-- Name: absences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.absences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: absences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.absences_id_seq OWNED BY public.absences.id;


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
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id integer NOT NULL,
    skill_id integer NOT NULL,
    subject_id integer NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: authentication_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentication_tokens (
    id integer NOT NULL,
    body character varying,
    user_id integer,
    last_used_at timestamp without time zone,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expires_in integer
);


--
-- Name: authentication_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentication_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentication_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authentication_tokens_id_seq OWNED BY public.authentication_tokens.id;


--
-- Name: chapter_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.chapter_summaries AS
SELECT
    NULL::integer AS id,
    NULL::character varying AS chapter_name,
    NULL::character varying(2) AS chapter_mlid,
    NULL::character varying(3) AS organization_mlid,
    NULL::text AS full_mlid,
    NULL::integer AS organization_id,
    NULL::character varying AS organization_name,
    NULL::timestamp without time zone AS deleted_at,
    NULL::bigint AS group_count,
    NULL::integer AS student_count,
    NULL::timestamp without time zone AS created_at,
    NULL::timestamp without time zone AS updated_at;


--
-- Name: chapters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chapters (
    id integer NOT NULL,
    chapter_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    deleted_at timestamp without time zone,
    mlid character varying(2) NOT NULL,
    CONSTRAINT uppercase CHECK (((mlid)::text = upper((mlid)::text)))
);


--
-- Name: chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chapters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chapters_id_seq OWNED BY public.chapters.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    student_id bigint NOT NULL,
    group_id bigint NOT NULL,
    active_since timestamp without time zone NOT NULL,
    inactive_since timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: grade_descriptors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grade_descriptors (
    id integer NOT NULL,
    mark integer NOT NULL,
    grade_description character varying,
    skill_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: grade_descriptors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grade_descriptors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grade_descriptors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grade_descriptors_id_seq OWNED BY public.grade_descriptors.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grades (
    id integer NOT NULL,
    student_id integer NOT NULL,
    lesson_id integer NOT NULL,
    grade_descriptor_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    lesson_uid uuid NOT NULL,
    skill_id bigint NOT NULL,
    mark integer NOT NULL
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: group_lesson_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.group_lesson_summaries AS
SELECT
    NULL::integer AS lesson_id,
    NULL::uuid AS lesson_uid,
    NULL::date AS lesson_date,
    NULL::integer AS group_id,
    NULL::integer AS chapter_id,
    NULL::integer AS subject_id,
    NULL::text AS group_chapter_name,
    NULL::double precision AS average_mark,
    NULL::bigint AS grade_count;


--
-- Name: group_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.group_summaries AS
SELECT
    NULL::integer AS id,
    NULL::character varying AS group_name,
    NULL::timestamp without time zone AS deleted_at,
    NULL::integer AS chapter_id,
    NULL::character varying AS chapter_name,
    NULL::integer AS organization_id,
    NULL::character varying(3) AS organization_mlid,
    NULL::character varying(2) AS chapter_mlid,
    NULL::character varying(2) AS mlid,
    NULL::text AS full_mlid,
    NULL::character varying AS organization_name,
    NULL::bigint AS student_count;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    chapter_id integer,
    deleted_at timestamp without time zone,
    mlid character varying(2) NOT NULL,
    CONSTRAINT uppercase CHECK (((mlid)::text = upper((mlid)::text)))
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: lesson_skill_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.lesson_skill_summaries AS
SELECT
    NULL::uuid AS lesson_uid,
    NULL::integer AS skill_id,
    NULL::character varying AS skill_name,
    NULL::numeric AS average_mark,
    NULL::bigint AS grade_count;


--
-- Name: lesson_table_rows; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.lesson_table_rows AS
SELECT
    NULL::integer AS id,
    NULL::integer AS group_id,
    NULL::date AS date,
    NULL::timestamp without time zone AS created_at,
    NULL::timestamp without time zone AS updated_at,
    NULL::integer AS subject_id,
    NULL::timestamp without time zone AS deleted_at,
    NULL::uuid AS uid,
    NULL::character varying AS group_name,
    NULL::character varying AS chapter_name,
    NULL::character varying AS subject_name,
    NULL::bigint AS group_student_count,
    NULL::bigint AS graded_student_count,
    NULL::numeric AS average_mark;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons (
    id integer NOT NULL,
    group_id integer NOT NULL,
    date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_id integer NOT NULL,
    deleted_at timestamp without time zone,
    uid uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lessons_id_seq OWNED BY public.lessons.id;


--
-- Name: organization_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.organization_summaries AS
SELECT
    NULL::integer AS id,
    NULL::character varying AS organization_name,
    NULL::bigint AS chapter_count,
    NULL::timestamp without time zone AS updated_at,
    NULL::timestamp without time zone AS created_at;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    organization_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image character varying DEFAULT 'https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200'::character varying,
    deleted_at timestamp without time zone,
    mlid character varying(3) NOT NULL,
    CONSTRAINT uppercase CHECK (((mlid)::text = upper((mlid)::text)))
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: performance_per_group_per_skill_per_lessons; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.performance_per_group_per_skill_per_lessons AS
SELECT
    NULL::integer AS group_id,
    NULL::character varying AS group_name,
    NULL::text AS group_chapter_name,
    NULL::integer AS lesson_id,
    NULL::date AS date,
    NULL::integer AS skill_id,
    NULL::character varying AS skill_name,
    NULL::integer AS subject_id,
    NULL::double precision AS mark;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    resource_type character varying,
    resource_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.skills (
    id integer NOT NULL,
    skill_name character varying NOT NULL,
    organization_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    skill_description text,
    deleted_at timestamp without time zone
);


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- Name: student_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_images (
    id integer NOT NULL,
    image character varying,
    student_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: student_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_images_id_seq OWNED BY public.student_images.id;


--
-- Name: student_lesson_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_lesson_details AS
SELECT
    NULL::integer AS student_id,
    NULL::character varying AS first_name,
    NULL::character varying AS last_name,
    NULL::timestamp without time zone AS student_deleted_at,
    NULL::integer AS lesson_id,
    NULL::date AS date,
    NULL::timestamp without time zone AS lesson_deleted_at,
    NULL::integer AS subject_id,
    NULL::numeric AS average_mark,
    NULL::bigint AS grade_count,
    NULL::jsonb AS skill_marks,
    NULL::boolean AS absent;


--
-- Name: student_lesson_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_lesson_summaries AS
SELECT
    NULL::integer AS student_id,
    NULL::integer AS group_id,
    NULL::character varying AS first_name,
    NULL::character varying AS last_name,
    NULL::timestamp without time zone AS deleted_at,
    NULL::integer AS lesson_id,
    NULL::numeric AS average_mark,
    NULL::bigint AS grade_count,
    NULL::boolean AS absent;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    dob date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    estimated_dob boolean DEFAULT true NOT NULL,
    group_id integer,
    gender public.gender NOT NULL,
    quartier character varying,
    health_insurance text,
    health_issues text,
    hiv_tested boolean,
    name_of_school character varying,
    school_level_completed character varying,
    year_of_dropout integer,
    reason_for_leaving character varying,
    notes text,
    guardian_name character varying,
    guardian_occupation character varying,
    guardian_contact character varying,
    family_members text,
    mlid character varying NOT NULL,
    deleted_at timestamp without time zone,
    profile_image_id integer,
    country_of_nationality text
);


--
-- Name: student_lessons; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_lessons AS
 SELECT s.id AS student_id,
    l.id AS lesson_id
   FROM ((public.lessons l
     JOIN public.groups g ON ((l.group_id = g.id)))
     JOIN public.students s ON ((g.id = s.group_id)));


--
-- Name: student_table_rows; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_table_rows AS
 SELECT s.id,
    s.first_name,
    s.last_name,
    s.dob,
    s.created_at,
    s.updated_at,
    s.estimated_dob,
    s.group_id,
    s.gender,
    s.quartier,
    s.health_insurance,
    s.health_issues,
    s.hiv_tested,
    s.name_of_school,
    s.school_level_completed,
    s.year_of_dropout,
    s.reason_for_leaving,
    s.notes,
    s.guardian_name,
    s.guardian_occupation,
    s.guardian_contact,
    s.family_members,
    s.mlid,
    s.deleted_at,
    s.profile_image_id,
    s.country_of_nationality,
    g.group_name,
    o.mlid AS organization_mlid,
    c.mlid AS chapter_mlid,
    g.mlid AS group_mlid,
    concat(o.mlid, '-', c.mlid, '-', g.mlid, '-', s.mlid) AS full_mlid
   FROM (((public.students s
     JOIN public.groups g ON ((s.group_id = g.id)))
     JOIN public.chapters c ON ((g.chapter_id = c.id)))
     JOIN public.organizations o ON ((c.organization_id = o.id)));


--
-- Name: student_tag_table_rows; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_tag_table_rows AS
SELECT
    NULL::uuid AS id,
    NULL::character varying AS tag_name,
    NULL::boolean AS shared,
    NULL::bigint AS organization_id,
    NULL::character varying AS organization_name,
    NULL::bigint AS student_count;


--
-- Name: student_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_tags (
    student_id bigint NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    subject_name character varying NOT NULL,
    organization_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tag_name character varying NOT NULL,
    organization_id bigint NOT NULL,
    shared boolean NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    uid character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    provider character varying,
    image character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_roles (
    user_id integer,
    role_id integer
);


--
-- Name: absences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences ALTER COLUMN id SET DEFAULT nextval('public.absences_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: authentication_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_tokens ALTER COLUMN id SET DEFAULT nextval('public.authentication_tokens_id_seq'::regclass);


--
-- Name: chapters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters ALTER COLUMN id SET DEFAULT nextval('public.chapters_id_seq'::regclass);


--
-- Name: grade_descriptors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grade_descriptors ALTER COLUMN id SET DEFAULT nextval('public.grade_descriptors_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons ALTER COLUMN id SET DEFAULT nextval('public.lessons_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- Name: student_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_images ALTER COLUMN id SET DEFAULT nextval('public.student_images_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: absences absences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences
    ADD CONSTRAINT absences_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: authentication_tokens authentication_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_tokens
    ADD CONSTRAINT authentication_tokens_pkey PRIMARY KEY (id);


--
-- Name: chapters chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: grade_descriptors grade_descriptors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grade_descriptors
    ADD CONSTRAINT grade_descriptors_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: lessons lesson_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lesson_uuid_unique UNIQUE (uid);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_mlid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_mlid_key UNIQUE (mlid);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: student_images student_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_images
    ADD CONSTRAINT student_images_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: groups unique_mlid_per_chapter_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT unique_mlid_per_chapter_id UNIQUE (mlid, chapter_id);


--
-- Name: chapters unique_mlid_per_scope; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT unique_mlid_per_scope UNIQUE (mlid, organization_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_absences_on_lesson_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_absences_on_lesson_id ON public.absences USING btree (lesson_id);


--
-- Name: index_absences_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_absences_on_student_id ON public.absences USING btree (student_id);


--
-- Name: index_assignments_on_skill_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_skill_id ON public.assignments USING btree (skill_id);


--
-- Name: index_assignments_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_subject_id ON public.assignments USING btree (subject_id);


--
-- Name: index_authentication_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authentication_tokens_on_user_id ON public.authentication_tokens USING btree (user_id);


--
-- Name: index_chapters_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chapters_on_organization_id ON public.chapters USING btree (organization_id);


--
-- Name: index_enrollments_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_group_id ON public.enrollments USING btree (group_id);


--
-- Name: index_enrollments_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_student_id ON public.enrollments USING btree (student_id);


--
-- Name: index_grade_descriptors_on_skill_id_and_mark; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_grade_descriptors_on_skill_id_and_mark ON public.grade_descriptors USING btree (skill_id, mark);


--
-- Name: index_grades_on_grade_descriptor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_grade_descriptor_id ON public.grades USING btree (grade_descriptor_id);


--
-- Name: index_grades_on_lesson_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_lesson_id ON public.grades USING btree (lesson_id);


--
-- Name: index_grades_on_lesson_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_lesson_uid ON public.grades USING btree (lesson_uid);


--
-- Name: index_grades_on_skill_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_skill_id ON public.grades USING btree (skill_id);


--
-- Name: index_grades_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_student_id ON public.grades USING btree (student_id);


--
-- Name: index_groups_on_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_chapter_id ON public.groups USING btree (chapter_id);


--
-- Name: index_lessons_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lessons_on_group_id ON public.lessons USING btree (group_id);


--
-- Name: index_lessons_on_group_id_and_subject_id_and_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lessons_on_group_id_and_subject_id_and_date ON public.lessons USING btree (group_id, subject_id, date) WHERE (deleted_at IS NULL);


--
-- Name: index_lessons_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lessons_on_subject_id ON public.lessons USING btree (subject_id);


--
-- Name: index_lessons_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lessons_on_uid ON public.lessons USING btree (uid);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON public.roles USING btree (name, resource_type, resource_id);


--
-- Name: index_roles_on_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_resource ON public.roles USING btree (resource_type, resource_id);


--
-- Name: index_skills_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skills_on_organization_id ON public.skills USING btree (organization_id);


--
-- Name: index_student_images_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_student_images_on_student_id ON public.student_images USING btree (student_id);


--
-- Name: index_student_tags_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_student_tags_on_student_id ON public.student_tags USING btree (student_id);


--
-- Name: index_student_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_student_tags_on_tag_id ON public.student_tags USING btree (tag_id);


--
-- Name: index_students_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_group_id ON public.students USING btree (group_id);


--
-- Name: index_students_on_profile_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_profile_image_id ON public.students USING btree (profile_image_id);


--
-- Name: index_subjects_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subjects_on_organization_id ON public.subjects USING btree (organization_id);


--
-- Name: index_tags_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_organization_id ON public.tags USING btree (organization_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_role_id ON public.users_roles USING btree (role_id);


--
-- Name: index_users_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id ON public.users_roles USING btree (user_id);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON public.users_roles USING btree (user_id, role_id);


--
-- Name: organization_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.organization_summaries AS
 SELECT o.id,
    o.organization_name,
    sum(
        CASE
            WHEN ((c.id IS NOT NULL) AND (c.deleted_at IS NULL)) THEN 1
            ELSE 0
        END) AS chapter_count,
    o.updated_at,
    o.created_at
   FROM (public.organizations o
     LEFT JOIN public.chapters c ON ((c.organization_id = o.id)))
  GROUP BY o.id;


--
-- Name: student_lesson_details _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.student_lesson_details AS
 SELECT s.id AS student_id,
    s.first_name,
    s.last_name,
    s.deleted_at AS student_deleted_at,
    l.id AS lesson_id,
    l.date,
    l.deleted_at AS lesson_deleted_at,
    l.subject_id,
    round(avg(grades.mark), 2) AS average_mark,
    count(grades.mark) AS grade_count,
    COALESCE(jsonb_object_agg(grades.skill_id, jsonb_build_object('mark', grades.mark, 'grade_descriptor_id', grades.grade_descriptor_id, 'skill_name', skills.skill_name)) FILTER (WHERE (skills.skill_name IS NOT NULL)), '{}'::jsonb) AS skill_marks,
        CASE
            WHEN (a.id IS NULL) THEN false
            ELSE true
        END AS absent
   FROM (((((public.students s
     JOIN public.groups g ON ((g.id = s.group_id)))
     JOIN public.lessons l ON ((g.id = l.group_id)))
     LEFT JOIN public.grades ON (((grades.student_id = s.id) AND (grades.lesson_id = l.id))))
     LEFT JOIN public.skills ON ((skills.id = grades.skill_id)))
     LEFT JOIN public.absences a ON (((a.student_id = s.id) AND (a.lesson_id = l.id))))
  GROUP BY s.id, l.id, a.id
  ORDER BY l.subject_id;


--
-- Name: group_lesson_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.group_lesson_summaries AS
 SELECT l.id AS lesson_id,
    l.uid AS lesson_uid,
    l.date AS lesson_date,
    gr.id AS group_id,
    gr.chapter_id,
    s.id AS subject_id,
    concat(gr.group_name, ' - ', c.chapter_name) AS group_chapter_name,
    (round(avg(g.mark), 2))::double precision AS average_mark,
    count(*) AS grade_count
   FROM ((((public.lessons l
     JOIN public.groups gr ON ((l.group_id = gr.id)))
     JOIN public.grades g ON ((g.lesson_id = l.id)))
     JOIN public.chapters c ON ((gr.chapter_id = c.id)))
     JOIN public.subjects s ON ((l.subject_id = s.id)))
  WHERE (g.deleted_at IS NULL)
  GROUP BY l.id, gr.id, c.id, s.id
  ORDER BY l.date;


--
-- Name: student_lesson_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.student_lesson_summaries AS
 SELECT united.student_id,
    united.group_id,
    united.first_name,
    united.last_name,
    united.deleted_at,
    united.lesson_id,
    united.average_mark,
    united.grade_count,
    united.absent
   FROM ( SELECT s.id AS student_id,
            s.group_id,
            s.first_name,
            s.last_name,
            s.deleted_at,
            l.id AS lesson_id,
            round(avg(grades.mark), 2) AS average_mark,
            count(grades.mark) AS grade_count,
                CASE
                    WHEN (a.id IS NULL) THEN false
                    ELSE true
                END AS absent
           FROM ((((public.students s
             JOIN public.groups g ON ((g.id = s.group_id)))
             JOIN public.lessons l ON ((g.id = l.group_id)))
             LEFT JOIN public.grades ON (((grades.student_id = s.id) AND (grades.lesson_id = l.id) AND (grades.deleted_at IS NULL))))
             LEFT JOIN public.absences a ON (((a.student_id = s.id) AND (a.lesson_id = l.id))))
          GROUP BY s.id, l.id, a.id
        UNION
         SELECT s.id AS student_id,
            s.group_id,
            s.first_name,
            s.last_name,
            s.deleted_at,
            l.id AS lesson_id,
            round(avg(grades.mark), 2) AS average_mark,
            count(grades.mark) AS grade_count,
                CASE
                    WHEN (a.id IS NULL) THEN false
                    ELSE true
                END AS absent
           FROM ((((public.lessons l
             JOIN public.groups g ON ((g.id = l.group_id)))
             JOIN public.grades ON (((grades.lesson_id = l.id) AND (grades.deleted_at IS NULL))))
             JOIN public.students s ON ((grades.student_id = s.id)))
             LEFT JOIN public.absences a ON (((a.student_id = s.id) AND (a.lesson_id = l.id))))
          GROUP BY s.id, l.id, a.id) united;


--
-- Name: lesson_skill_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.lesson_skill_summaries AS
 SELECT l.uid AS lesson_uid,
    sk.id AS skill_id,
    sk.skill_name,
    round(avg(g.mark), 2) AS average_mark,
    count(g.mark) AS grade_count
   FROM ((((public.lessons l
     JOIN public.subjects su ON ((su.id = l.subject_id)))
     JOIN public.assignments a ON ((su.id = a.subject_id)))
     JOIN public.skills sk ON ((a.skill_id = sk.id)))
     LEFT JOIN public.grades g ON (((g.lesson_uid = l.uid) AND (g.skill_id = sk.id) AND (g.deleted_at IS NULL))))
  GROUP BY l.uid, sk.id;


--
-- Name: lesson_table_rows _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.lesson_table_rows AS
 WITH group_student_counts AS (
         SELECT gr.id AS group_id,
            gr.group_name,
            c.chapter_name,
            COALESCE(count(s.id), (0)::bigint) AS student_count
           FROM ((public.groups gr
             LEFT JOIN public.students s ON (((s.group_id = gr.id) AND (s.deleted_at IS NULL))))
             JOIN public.chapters c ON ((gr.chapter_id = c.id)))
          GROUP BY gr.id, c.chapter_name
        )
 SELECT l.id,
    l.group_id,
    l.date,
    l.created_at,
    l.updated_at,
    l.subject_id,
    l.deleted_at,
    l.uid,
    sc.group_name,
    sc.chapter_name,
    su.subject_name,
    sc.student_count AS group_student_count,
    count(DISTINCT g.student_id) AS graded_student_count,
    round(avg(g.mark), 2) AS average_mark
   FROM (((public.lessons l
     JOIN public.subjects su ON ((l.subject_id = su.id)))
     LEFT JOIN public.grades g ON (((l.id = g.lesson_id) AND (g.deleted_at IS NULL))))
     JOIN group_student_counts sc ON ((l.group_id = sc.group_id)))
  GROUP BY l.id, su.subject_name, sc.student_count, sc.group_name, sc.chapter_name;


--
-- Name: student_tag_table_rows _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.student_tag_table_rows AS
 SELECT t.id,
    t.tag_name,
    t.shared,
    t.organization_id,
    o.organization_name,
    count(st.student_id) AS student_count
   FROM ((public.tags t
     JOIN public.organizations o ON ((t.organization_id = o.id)))
     LEFT JOIN public.student_tags st ON ((t.id = st.tag_id)))
  GROUP BY t.id, t.organization_id, o.organization_name;


--
-- Name: chapter_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.chapter_summaries AS
 WITH group_student_count AS (
         SELECT g.id AS group_id,
            g.group_name,
            g.deleted_at,
            g.chapter_id,
            sum(
                CASE
                    WHEN ((s.id IS NOT NULL) AND (s.deleted_at IS NULL)) THEN 1
                    ELSE 0
                END) AS student_count
           FROM (public.groups g
             LEFT JOIN public.students s ON ((g.id = s.group_id)))
          WHERE (g.deleted_at IS NULL)
          GROUP BY g.id
        )
 SELECT c.id,
    c.chapter_name,
    c.mlid AS chapter_mlid,
    o.mlid AS organization_mlid,
    concat(o.mlid, '-', c.mlid) AS full_mlid,
    c.organization_id,
    o.organization_name,
    c.deleted_at,
    count(group_student_count.group_id) AS group_count,
    (COALESCE(sum(group_student_count.student_count), (0)::numeric))::integer AS student_count,
    c.created_at,
    c.updated_at
   FROM ((public.chapters c
     LEFT JOIN group_student_count ON ((group_student_count.chapter_id = c.id)))
     LEFT JOIN public.organizations o ON ((c.organization_id = o.id)))
  GROUP BY c.id, o.id;


--
-- Name: group_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.group_summaries AS
 SELECT g.id,
    g.group_name,
    g.deleted_at,
    g.chapter_id,
    c.chapter_name,
    o.id AS organization_id,
    o.mlid AS organization_mlid,
    c.mlid AS chapter_mlid,
    g.mlid,
    concat(o.mlid, '-', c.mlid, '-', g.mlid) AS full_mlid,
    o.organization_name,
    sum(
        CASE
            WHEN ((s.id IS NOT NULL) AND (s.deleted_at IS NULL)) THEN 1
            ELSE 0
        END) AS student_count
   FROM (((public.groups g
     LEFT JOIN public.students s ON ((g.id = s.group_id)))
     LEFT JOIN public.chapters c ON ((g.chapter_id = c.id)))
     LEFT JOIN public.organizations o ON ((c.organization_id = o.id)))
  GROUP BY g.id, c.id, o.id;


--
-- Name: performance_per_group_per_skill_per_lessons _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.performance_per_group_per_skill_per_lessons AS
 SELECT gr.id AS group_id,
    gr.group_name,
    (((gr.group_name)::text || ' - '::text) || (c.chapter_name)::text) AS group_chapter_name,
    l.id AS lesson_id,
    l.date,
    s.id AS skill_id,
    s.skill_name,
    su.id AS subject_id,
    (round(avg(g.mark), 2))::double precision AS mark
   FROM (((((public.groups gr
     JOIN public.chapters c ON ((gr.chapter_id = c.id)))
     JOIN public.lessons l ON ((gr.id = l.group_id)))
     JOIN public.subjects su ON ((l.subject_id = su.id)))
     JOIN public.grades g ON ((l.id = g.lesson_id)))
     JOIN public.skills s ON ((s.id = g.skill_id)))
  GROUP BY gr.id, c.id, l.id, s.id, su.id
  ORDER BY gr.id, l.date, s.id;


--
-- Name: students update_enrollments_on_student_group_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_enrollments_on_student_group_change_trigger AFTER INSERT OR UPDATE ON public.students FOR EACH ROW EXECUTE FUNCTION public.update_enrollments();


--
-- Name: assignments assignments_skill_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_skill_id_fk FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- Name: assignments assignments_subject_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_subject_id_fk FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: chapters chapters_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: enrollments fk_rails_0ca8ba010f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_0ca8ba010f FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: student_tags fk_rails_21aa011b2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_tags
    ADD CONSTRAINT fk_rails_21aa011b2b FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: absences fk_rails_442f8d40b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences
    ADD CONSTRAINT fk_rails_442f8d40b0 FOREIGN KEY (lesson_id) REFERENCES public.lessons(id);


--
-- Name: students fk_rails_512f7ce835; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_rails_512f7ce835 FOREIGN KEY (profile_image_id) REFERENCES public.student_images(id);


--
-- Name: student_tags fk_rails_a7fbbb3454; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_tags
    ADD CONSTRAINT fk_rails_a7fbbb3454 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: grades fk_rails_aa113f6bf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT fk_rails_aa113f6bf8 FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- Name: authentication_tokens fk_rails_ad331ebb27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_tokens
    ADD CONSTRAINT fk_rails_ad331ebb27 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: absences fk_rails_dc2c1be879; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences
    ADD CONSTRAINT fk_rails_dc2c1be879 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: enrollments fk_rails_f01c555e06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_f01c555e06 FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: grade_descriptors grade_descriptors_skill_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grade_descriptors
    ADD CONSTRAINT grade_descriptors_skill_id_fk FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- Name: grades grades_grade_descriptor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_grade_descriptor_id_fk FOREIGN KEY (grade_descriptor_id) REFERENCES public.grade_descriptors(id);


--
-- Name: grades grades_lesson_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_lesson_id_fk FOREIGN KEY (lesson_id) REFERENCES public.lessons(id);


--
-- Name: grades grades_lesson_uid_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_lesson_uid_fk FOREIGN KEY (lesson_uid) REFERENCES public.lessons(uid);


--
-- Name: grades grades_student_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: groups groups_chapter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_chapter_id_fk FOREIGN KEY (chapter_id) REFERENCES public.chapters(id);


--
-- Name: lessons lessons_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_group_id_fk FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: lessons lessons_subject_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_subject_id_fk FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: skills skills_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: student_images student_images_student_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_images
    ADD CONSTRAINT student_images_student_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: students students_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_group_id_fk FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: subjects subjects_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: users_roles users_roles_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: users_roles users_roles_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20151101232844'),
('20151220030058'),
('20151221020928'),
('20151221024455'),
('20160627235221'),
('20160720015152'),
('20160814162037'),
('20160814164503'),
('20160831223423'),
('20160901154850'),
('20160901192307'),
('20160901202149'),
('20160901210739'),
('20160901213654'),
('20160902163711'),
('20160902165536'),
('20160903164035'),
('20160904164503'),
('20160904190345'),
('20160905214301'),
('20160912004942'),
('20160913033919'),
('20160915231926'),
('20160916192552'),
('20160916230442'),
('20160917155036'),
('20160917171524'),
('20160917182353'),
('20160918213623'),
('20160919032848'),
('20161008013423'),
('20161013042217'),
('20161014032826'),
('20161015235759'),
('20161016180809'),
('20161016224542'),
('20161016225911'),
('20161016230051'),
('20161016234425'),
('20161017000516'),
('20161017010053'),
('20161017015840'),
('20161017215259'),
('20161018060253'),
('20161018062946'),
('20161019013129'),
('20161019013750'),
('20161025175655'),
('20161113042309'),
('20161116033304'),
('20161116035756'),
('20161128023141'),
('20161217023827'),
('20161223023552'),
('20170120002843'),
('20170819212049'),
('20170824005016'),
('20170904171041'),
('20171115044314'),
('20171117013830'),
('20180918024043'),
('20180921222814'),
('20180922163840'),
('20180922202158'),
('20181008005049'),
('20181223165012'),
('20181229230953'),
('20181229235739'),
('20190121174701'),
('20190121175252'),
('20190127222433'),
('20190309000012'),
('20190309001819'),
('20190313032856'),
('20190405030134'),
('20190406163831'),
('20190817044440'),
('20191026230403'),
('20191102173151'),
('20191102200044'),
('20191102234931'),
('20191103021012'),
('20191107004248'),
('20191107010120'),
('20191201014634'),
('20191202044021'),
('20200222045456'),
('20200619222042'),
('20200626021523'),
('20210130185750'),
('20210130190336'),
('20210201004530'),
('20210201011615'),
('20210207190942'),
('20210209020704'),
('20210217042855'),
('20210221222126'),
('20210221222255'),
('20210221224324'),
('20210221224751'),
('20210810094527'),
('20210810102949'),
('20210909104020'),
('20210910115239');


