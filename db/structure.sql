SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'male',
    'female'
);


SET default_tablespace = '';

SET default_with_oids = false;

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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentication_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentication_tokens_id_seq
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
-- Name: chapters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chapters (
    id integer NOT NULL,
    chapter_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    deleted_at timestamp without time zone
);


--
-- Name: chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chapters_id_seq
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
    deleted_at timestamp without time zone
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grades_id_seq
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
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    chapter_id integer,
    deleted_at timestamp without time zone
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
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
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons (
    id integer NOT NULL,
    group_id integer NOT NULL,
    date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_id integer NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lessons_id_seq
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
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    organization_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image character varying DEFAULT 'https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200'::character varying,
    deleted_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
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
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    resource_type character varying,
    resource_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: student_lesson_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.student_lesson_summaries AS
SELECT
    NULL::integer AS student_id,
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
    organization_id integer NOT NULL,
    mlid character varying NOT NULL,
    deleted_at timestamp without time zone,
    profile_image_id integer
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.students_id_seq
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
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


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
-- Name: index_grade_descriptors_on_mark_and_skill_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_grade_descriptors_on_mark_and_skill_id ON public.grade_descriptors USING btree (mark, skill_id);


--
-- Name: index_grade_descriptors_on_skill_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grade_descriptors_on_skill_id ON public.grade_descriptors USING btree (skill_id);


--
-- Name: index_grades_on_grade_descriptor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_grade_descriptor_id ON public.grades USING btree (grade_descriptor_id);


--
-- Name: index_grades_on_lesson_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_lesson_id ON public.grades USING btree (lesson_id);


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
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON public.roles USING btree (name, resource_type, resource_id);


--
-- Name: index_skills_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skills_on_organization_id ON public.skills USING btree (organization_id);


--
-- Name: index_student_images_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_student_images_on_student_id ON public.student_images USING btree (student_id);


--
-- Name: index_students_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_group_id ON public.students USING btree (group_id);


--
-- Name: index_students_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_organization_id ON public.students USING btree (organization_id);


--
-- Name: index_students_on_profile_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_profile_image_id ON public.students USING btree (profile_image_id);


--
-- Name: index_subjects_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subjects_on_organization_id ON public.subjects USING btree (organization_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON public.users_roles USING btree (user_id, role_id);


--
-- Name: student_lesson_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.student_lesson_summaries AS
 WITH descriptive_grades AS (
         SELECT grades.id,
            grades.student_id,
            grades.lesson_id,
            grades.grade_descriptor_id,
            grades.created_at,
            grades.updated_at,
            grades.deleted_at,
            grade_descriptors.id,
            grade_descriptors.mark,
            grade_descriptors.grade_description,
            grade_descriptors.skill_id,
            grade_descriptors.created_at,
            grade_descriptors.updated_at,
            grade_descriptors.deleted_at
           FROM (public.grades
             JOIN public.grade_descriptors ON ((grades.grade_descriptor_id = grade_descriptors.id)))
          WHERE (grades.deleted_at IS NULL)
        )
 SELECT s.id AS student_id,
    s.first_name,
    s.last_name,
    s.deleted_at,
    l.id AS lesson_id,
    round(avg(descriptive_grades.mark), 2) AS average_mark,
    count(descriptive_grades.mark) AS grade_count,
        CASE
            WHEN (a.id IS NULL) THEN false
            ELSE true
        END AS absent
   FROM ((((public.students s
     JOIN public.groups g ON ((g.id = s.group_id)))
     JOIN public.lessons l ON ((g.id = l.group_id)))
     LEFT JOIN descriptive_grades descriptive_grades(id, student_id, lesson_id, grade_descriptor_id, created_at, updated_at, deleted_at, id_1, mark, grade_description, skill_id, created_at_1, updated_at_1, deleted_at_1) ON (((descriptive_grades.student_id = s.id) AND (descriptive_grades.lesson_id = l.id))))
     LEFT JOIN public.absences a ON (((a.student_id = s.id) AND (a.lesson_id = l.id))))
  GROUP BY s.id, l.id, a.id
  ORDER BY s.last_name;


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
-- Name: students students_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: subjects subjects_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: users_roles users_roles_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: users_roles users_roles_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


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
('20180918024043');


