--
-- PostgreSQL database dump
--

\restrict cHRi0kqaUxI23OYyO2iGp595i0sRYr0gYRUmqF4NyzQbBeUIfQ2tRzknsWi9rW4

-- Dumped from database version 15.18 (Debian 15.18-1.pgdg13+1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-1.pgdg13+1)

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
-- Name: allocation_mode; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.allocation_mode AS ENUM (
    'SQUAD',
    'DIRECT'
);


ALTER TYPE public.allocation_mode OWNER TO heimr;

--
-- Name: auth_provider; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.auth_provider AS ENUM (
    'LOCAL',
    'ENTRA_ID'
);


ALTER TYPE public.auth_provider OWNER TO heimr;

--
-- Name: billable_type; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.billable_type AS ENUM (
    'BILLABLE',
    'NON_BILLABLE'
);


ALTER TYPE public.billable_type OWNER TO heimr;

--
-- Name: closure_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.closure_status AS ENUM (
    'IN_REVIEW',
    'APPROVED',
    'REOPENED'
);


ALTER TYPE public.closure_status OWNER TO heimr;

--
-- Name: dependency_type; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.dependency_type AS ENUM (
    'FS',
    'SS',
    'FF',
    'SF'
);


ALTER TYPE public.dependency_type OWNER TO heimr;

--
-- Name: integration_type; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.integration_type AS ENUM (
    'HUBSPOT',
    'SLACK',
    'ENTRA_ID'
);


ALTER TYPE public.integration_type OWNER TO heimr;

--
-- Name: milestone_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.milestone_status AS ENUM (
    'PLANNED',
    'REACHED',
    'APPROVED',
    'DELAYED'
);


ALTER TYPE public.milestone_status OWNER TO heimr;

--
-- Name: notif_channel; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.notif_channel AS ENUM (
    'IN_APP',
    'EMAIL',
    'SLACK'
);


ALTER TYPE public.notif_channel OWNER TO heimr;

--
-- Name: project_model; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.project_model AS ENUM (
    'WATERFALL',
    'AGILE',
    'HYBRID'
);


ALTER TYPE public.project_model OWNER TO heimr;

--
-- Name: project_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.project_status AS ENUM (
    'DRAFT',
    'ACTIVE',
    'ON_HOLD',
    'CLOSED'
);


ALTER TYPE public.project_status OWNER TO heimr;

--
-- Name: release_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.release_status AS ENUM (
    'DRAFT',
    'RELEASED',
    'REVOKED'
);


ALTER TYPE public.release_status OWNER TO heimr;

--
-- Name: resource_kind; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.resource_kind AS ENUM (
    'ATTACHMENT',
    'DOCUMENT',
    'WIKI'
);


ALTER TYPE public.resource_kind OWNER TO heimr;

--
-- Name: risk_severity; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.risk_severity AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.risk_severity OWNER TO heimr;

--
-- Name: risk_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.risk_status AS ENUM (
    'OPEN',
    'MITIGATED',
    'ACCEPTED',
    'CLOSED'
);


ALTER TYPE public.risk_status OWNER TO heimr;

--
-- Name: sprint_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.sprint_status AS ENUM (
    'PLANNED',
    'ACTIVE',
    'COMPLETED'
);


ALTER TYPE public.sprint_status OWNER TO heimr;

--
-- Name: storage_provider; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.storage_provider AS ENUM (
    'SHAREPOINT',
    'ONEDRIVE'
);


ALTER TYPE public.storage_provider OWNER TO heimr;

--
-- Name: task_priority; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.task_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


ALTER TYPE public.task_priority OWNER TO heimr;

--
-- Name: task_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.task_status AS ENUM (
    'BACKLOG',
    'TODO',
    'IN_PROGRESS',
    'BLOCKED',
    'DONE'
);


ALTER TYPE public.task_status OWNER TO heimr;

--
-- Name: timelog_entry_type; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.timelog_entry_type AS ENUM (
    'REGULAR',
    'ADDITIONAL',
    'OVERTIME'
);


ALTER TYPE public.timelog_entry_type OWNER TO heimr;

--
-- Name: timelog_status; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.timelog_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'REVISION_REQUESTED'
);


ALTER TYPE public.timelog_status OWNER TO heimr;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: heimr
--

CREATE TYPE public.user_role AS ENUM (
    'ADMINISTRATOR',
    'PROJECT_MANAGER',
    'PROFESSIONAL',
    'CLIENT'
);


ALTER TYPE public.user_role OWNER TO heimr;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_usage; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.ai_usage (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid,
    feature character varying(80) NOT NULL,
    model character varying(80) NOT NULL,
    input_tokens integer DEFAULT 0 NOT NULL,
    output_tokens integer DEFAULT 0 NOT NULL,
    cost_amount numeric(12,4) DEFAULT 0 NOT NULL,
    currency character(3) DEFAULT 'USD'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ai_usage OWNER TO heimr;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    actor_user_id uuid,
    action character varying(60) NOT NULL,
    entity_type character varying(60) NOT NULL,
    entity_id uuid,
    before jsonb,
    after jsonb,
    ip_address inet,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_log OWNER TO heimr;

--
-- Name: TABLE audit_log; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.audit_log IS 'Append-only. No deploy: REVOKE UPDATE, DELETE ON audit_log FROM <app_role>;';


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: heimr
--

ALTER TABLE public.audit_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_runs; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.automation_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    automation_id uuid NOT NULL,
    task_id uuid,
    succeeded boolean NOT NULL,
    detail jsonb,
    executed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.automation_runs OWNER TO heimr;

--
-- Name: automations; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.automations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    trigger jsonb NOT NULL,
    actions jsonb NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.automations OWNER TO heimr;

--
-- Name: calendars; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.calendars (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(120) NOT NULL,
    country character(2) DEFAULT 'BR'::bpchar NOT NULL,
    region character varying(60),
    city character varying(120),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.calendars OWNER TO heimr;

--
-- Name: TABLE calendars; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.calendars IS 'Calendários de dias úteis. Base do alerta de 2 dias úteis sem apontamento e da classificação OVERTIME.';


--
-- Name: clients; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    region character varying(2) DEFAULT 'BR'::character varying NOT NULL,
    default_currency text DEFAULT 'BRL'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.clients OWNER TO heimr;

--
-- Name: TABLE clients; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.clients IS 'Clientes da heimr. Projeto com client_id NULL é interno.';


--
-- Name: comment_mentions; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.comment_mentions (
    comment_id uuid NOT NULL,
    mentioned_user_id uuid NOT NULL
);


ALTER TABLE public.comment_mentions OWNER TO heimr;

--
-- Name: external_resources; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.external_resources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind public.resource_kind DEFAULT 'ATTACHMENT'::public.resource_kind NOT NULL,
    provider public.storage_provider DEFAULT 'SHAREPOINT'::public.storage_provider NOT NULL,
    drive_id character varying(200) NOT NULL,
    item_id character varying(200) NOT NULL,
    web_url text NOT NULL,
    file_name character varying(255),
    mime_type character varying(120),
    size_bytes bigint,
    project_id uuid,
    task_id uuid,
    uploaded_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_resource_scope CHECK (((project_id IS NOT NULL) OR (task_id IS NOT NULL)))
);


ALTER TABLE public.external_resources OWNER TO heimr;

--
-- Name: holidays; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.holidays (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    calendar_id uuid NOT NULL,
    holiday_date date NOT NULL,
    name character varying(120) NOT NULL
);


ALTER TABLE public.holidays OWNER TO heimr;

--
-- Name: TABLE holidays; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.holidays IS 'Feriados por calendário. v1: carga via seed (SP); UI de administração na v1.1.';


--
-- Name: import_jobs; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.import_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid,
    source_file character varying(255),
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    rows_total integer,
    rows_ok integer,
    rows_error integer,
    detail jsonb,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.import_jobs OWNER TO heimr;

--
-- Name: integrations; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.integrations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type public.integration_type NOT NULL,
    client_id uuid,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    secret_ref character varying(200),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.integrations OWNER TO heimr;

--
-- Name: milestones; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.milestones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    target_date date NOT NULL,
    status public.milestone_status DEFAULT 'PLANNED'::public.milestone_status NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.milestones OWNER TO heimr;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    channel public.notif_channel DEFAULT 'IN_APP'::public.notif_channel NOT NULL,
    title character varying(255) NOT NULL,
    body text,
    task_id uuid,
    is_read boolean DEFAULT false NOT NULL,
    sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO heimr;

--
-- Name: payment_releases; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.payment_releases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    professional_user_id uuid NOT NULL,
    manager_user_id uuid NOT NULL,
    project_id uuid,
    period_start date NOT NULL,
    period_end date NOT NULL,
    total_hours numeric(8,2) DEFAULT 0 NOT NULL,
    billable_hours numeric(8,2) DEFAULT 0 NOT NULL,
    total_cost numeric(15,2) DEFAULT 0 NOT NULL,
    total_billing numeric(15,2) DEFAULT 0 NOT NULL,
    currency character(3) DEFAULT 'BRL'::bpchar NOT NULL,
    status public.release_status DEFAULT 'DRAFT'::public.release_status NOT NULL,
    signed_at timestamp with time zone,
    signature_ref character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_release_period CHECK ((period_end >= period_start))
);


ALTER TABLE public.payment_releases OWNER TO heimr;

--
-- Name: TABLE payment_releases; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.payment_releases IS 'DORMENTE na v1 (gate 2 desligado). Chancela do gestor que libera faturamento/pagamento.';


--
-- Name: project_closures; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.project_closures (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    closed_by uuid NOT NULL,
    status public.closure_status DEFAULT 'IN_REVIEW'::public.closure_status NOT NULL,
    chk_hours_resolved boolean DEFAULT false NOT NULL,
    chk_milestones boolean DEFAULT false NOT NULL,
    chk_blockers boolean DEFAULT false NOT NULL,
    chk_tasks_done boolean DEFAULT false NOT NULL,
    notes text,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_closures OWNER TO heimr;

--
-- Name: TABLE project_closures; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.project_closures IS 'Checklist de auditoria final. Regra: projects.status=CLOSED só com closure APPROVED e 4 checks TRUE (aplicação).';


--
-- Name: project_members; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.project_members (
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    added_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_members OWNER TO heimr;

--
-- Name: TABLE project_members; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.project_members IS 'Equipe do projeto (atribuição direta, RF-V1-012). Gate: só membro é responsável por tarefa e aponta horas.';


--
-- Name: project_squads; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.project_squads (
    project_id uuid NOT NULL,
    squad_id uuid NOT NULL
);


ALTER TABLE public.project_squads OWNER TO heimr;

--
-- Name: project_templates; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.project_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    model public.project_model DEFAULT 'AGILE'::public.project_model NOT NULL,
    blueprint jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_templates OWNER TO heimr;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id uuid,
    calendar_id uuid,
    manager_user_id uuid,
    title character varying(255) NOT NULL,
    description text,
    model public.project_model DEFAULT 'AGILE'::public.project_model NOT NULL,
    allocation_mode public.allocation_mode DEFAULT 'DIRECT'::public.allocation_mode NOT NULL,
    status public.project_status DEFAULT 'DRAFT'::public.project_status NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    currency character(3) DEFAULT 'BRL'::bpchar NOT NULL,
    estimated_cost numeric(15,2) DEFAULT 0 NOT NULL,
    estimated_revenue numeric(15,2) DEFAULT 0 NOT NULL,
    hubspot_deal_id character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_proj_dates CHECK ((end_date >= start_date))
);


ALTER TABLE public.projects OWNER TO heimr;

--
-- Name: TABLE projects; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.projects IS 'Projetos internos (client_id NULL) e de cliente. manager_user_id ancora o RBAC do PM na v1.';


--
-- Name: rate_cards; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.rate_cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    client_id uuid,
    cost_per_hour numeric(15,2) NOT NULL,
    bill_per_hour numeric(15,2) NOT NULL,
    currency character(3) DEFAULT 'BRL'::bpchar NOT NULL,
    valid_from date DEFAULT CURRENT_DATE NOT NULL,
    valid_to date,
    CONSTRAINT chk_rate_period CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))
);


ALTER TABLE public.rate_cards OWNER TO heimr;

--
-- Name: TABLE rate_cards; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.rate_cards IS 'DORMENTE na v1 (sem UI). Custo/faturamento por hora, por usuário e/ou cliente.';


--
-- Name: risks; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.risks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    severity public.risk_severity DEFAULT 'MEDIUM'::public.risk_severity NOT NULL,
    status public.risk_status DEFAULT 'OPEN'::public.risk_status NOT NULL,
    mitigation text,
    owner_user_id uuid,
    is_client_visible boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.risks OWNER TO heimr;

--
-- Name: sprints; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.sprints (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    goal text,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status public.sprint_status DEFAULT 'PLANNED'::public.sprint_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_sprint_dates CHECK ((end_date >= start_date))
);


ALTER TABLE public.sprints OWNER TO heimr;

--
-- Name: squad_members; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.squad_members (
    squad_id uuid NOT NULL,
    user_id uuid NOT NULL,
    allocation_pct numeric(5,2) DEFAULT 100 NOT NULL,
    CONSTRAINT squad_members_allocation_pct_check CHECK (((allocation_pct > (0)::numeric) AND (allocation_pct <= (100)::numeric)))
);


ALTER TABLE public.squad_members OWNER TO heimr;

--
-- Name: squads; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.squads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(120) NOT NULL,
    lead_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.squads OWNER TO heimr;

--
-- Name: TABLE squads; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.squads IS 'Entidade squad. v1-mínima usa atribuição direta; UI de squads chega na v1.1.';


--
-- Name: tags; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid,
    name character varying(60) NOT NULL,
    color character(6) DEFAULT '0D2B28'::bpchar NOT NULL
);


ALTER TABLE public.tags OWNER TO heimr;

--
-- Name: task_comments; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.task_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    author_user_id uuid,
    body text NOT NULL,
    is_internal boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.task_comments OWNER TO heimr;

--
-- Name: task_dependencies; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.task_dependencies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    predecessor_task_id uuid NOT NULL,
    successor_task_id uuid NOT NULL,
    type public.dependency_type DEFAULT 'FS'::public.dependency_type NOT NULL,
    lag_days integer DEFAULT 0 NOT NULL,
    CONSTRAINT chk_no_self_dep CHECK ((predecessor_task_id <> successor_task_id))
);


ALTER TABLE public.task_dependencies OWNER TO heimr;

--
-- Name: TABLE task_dependencies; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.task_dependencies IS 'Grafo de dependências. Validação de ciclo na aplicação (RF-V1-031).';


--
-- Name: task_tags; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.task_tags (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tags OWNER TO heimr;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    sprint_id uuid,
    milestone_id uuid,
    parent_task_id uuid,
    assigned_user_id uuid,
    title character varying(255) NOT NULL,
    description text,
    status public.task_status DEFAULT 'TODO'::public.task_status NOT NULL,
    priority public.task_priority DEFAULT 'MEDIUM'::public.task_priority NOT NULL,
    story_points smallint,
    billable public.billable_type DEFAULT 'BILLABLE'::public.billable_type NOT NULL,
    estimated_effort_hours integer DEFAULT 0 NOT NULL,
    start_date date,
    end_date date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    due_date date,
    CONSTRAINT chk_task_dates CHECK (((end_date IS NULL) OR (start_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT tasks_estimated_effort_hours_check CHECK ((estimated_effort_hours >= 0))
);


ALTER TABLE public.tasks OWNER TO heimr;

--
-- Name: TABLE tasks; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.tasks IS 'Tarefas e subtarefas (parent_task_id). Base do Kanban, timeline e apontamento.';


--
-- Name: time_logs; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.time_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    logged_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    hours_spent numeric(5,2) GENERATED ALWAYS AS (round((EXTRACT(epoch FROM (end_time - start_time)) / 3600.0), 2)) STORED NOT NULL,
    billable public.billable_type DEFAULT 'BILLABLE'::public.billable_type NOT NULL,
    entry_type public.timelog_entry_type DEFAULT 'REGULAR'::public.timelog_entry_type NOT NULL,
    approval_status public.timelog_status DEFAULT 'PENDING'::public.timelog_status NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    rejection_reason text,
    revision_note text,
    payment_release_id uuid,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_time_range CHECK ((end_time > start_time))
);


ALTER TABLE public.time_logs OWNER TO heimr;

--
-- Name: TABLE time_logs; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.time_logs IS 'Apontamentos. hours_spent é coluna gerada (end-start). Regras: custo/faturamento só com APPROVED; sobreposição validada na aplicação; ADDITIONAL/OVERTIME derivados por regra.';


--
-- Name: users; Type: TABLE; Schema: public; Owner: heimr
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    auth_provider public.auth_provider DEFAULT 'LOCAL'::public.auth_provider NOT NULL,
    password_hash character varying(255),
    entra_object_id character varying(100),
    role public.user_role DEFAULT 'PROFESSIONAL'::public.user_role NOT NULL,
    client_id uuid,
    calendar_id uuid,
    weekly_capacity_hours integer DEFAULT 40 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_auth CHECK ((((auth_provider = 'LOCAL'::public.auth_provider) AND (password_hash IS NOT NULL)) OR ((auth_provider = 'ENTRA_ID'::public.auth_provider) AND (entra_object_id IS NOT NULL)))),
    CONSTRAINT chk_client_role CHECK ((((role = 'CLIENT'::public.user_role) AND (client_id IS NOT NULL)) OR (role <> 'CLIENT'::public.user_role)))
);


ALTER TABLE public.users OWNER TO heimr;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: heimr
--

COMMENT ON TABLE public.users IS 'Usuários internos e (futuro) externos. E-mail único apenas entre ativos.';


--
-- Data for Name: ai_usage; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.ai_usage (id, project_id, feature, model, input_tokens, output_tokens, cost_amount, currency, created_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.audit_log (id, actor_user_id, action, entity_type, entity_id, before, after, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: automation_runs; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.automation_runs (id, automation_id, task_id, succeeded, detail, executed_at) FROM stdin;
\.


--
-- Data for Name: automations; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.automations (id, project_id, name, is_active, trigger, actions, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: calendars; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.calendars (id, name, country, region, city, created_at) FROM stdin;
00000000-0000-0000-0000-000000000001	Brasil — SP (padrão)	BR	SP	\N	2026-07-02 19:59:19.448718+00
3fa85f64-5717-4562-b3fc-2c963f66afa6	Calendário Padrão	BR	\N	\N	2026-07-13 14:38:44.507258+00
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.clients (id, name, region, default_currency, created_at, deleted_at) FROM stdin;
3fa85f64-5717-4562-b3fc-2c963f66afa6	Cliente de Teste	SP	BRL	2026-07-13 11:35:47+00	\N
\.


--
-- Data for Name: comment_mentions; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.comment_mentions (comment_id, mentioned_user_id) FROM stdin;
\.


--
-- Data for Name: external_resources; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.external_resources (id, kind, provider, drive_id, item_id, web_url, file_name, mime_type, size_bytes, project_id, task_id, uploaded_by, created_at) FROM stdin;
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.holidays (id, calendar_id, holiday_date, name) FROM stdin;
fae83ed0-6cc2-453a-ba35-fe8ba33e69bc	00000000-0000-0000-0000-000000000001	2026-01-01	Confraternização Universal
b1a2d08e-3b3c-4ec6-b208-9dc76823b1b3	00000000-0000-0000-0000-000000000001	2026-02-16	Carnaval (segunda)
aa3ed298-1e38-49b1-b25f-a65f81427c85	00000000-0000-0000-0000-000000000001	2026-02-17	Carnaval (terça)
af15f370-2825-4842-89a5-bc7d21dc4acc	00000000-0000-0000-0000-000000000001	2026-04-03	Sexta-feira Santa
69a76f7c-ede6-4d88-b841-44e2b6f1729e	00000000-0000-0000-0000-000000000001	2026-04-21	Tiradentes
1ad4cfac-9a73-492c-b24e-ad1f856897e8	00000000-0000-0000-0000-000000000001	2026-05-01	Dia do Trabalho
16c45bd4-0c59-4896-8125-88769074d4fd	00000000-0000-0000-0000-000000000001	2026-06-04	Corpus Christi
375f7a55-9079-4fe0-913a-325a27f48399	00000000-0000-0000-0000-000000000001	2026-07-09	Revolução Constitucionalista (SP)
65a8cde8-4115-4811-b6f5-7e9513267e59	00000000-0000-0000-0000-000000000001	2026-09-07	Independência do Brasil
8c5c74d6-03ad-4f01-9c33-3cfa85b9c72e	00000000-0000-0000-0000-000000000001	2026-10-12	Nossa Senhora Aparecida
16f4fc92-bece-4586-b145-011259492b26	00000000-0000-0000-0000-000000000001	2026-11-02	Finados
13e83327-785a-405d-9cf3-de6d8e5313cf	00000000-0000-0000-0000-000000000001	2026-11-15	Proclamação da República
c17f5fd4-2b76-4bb3-a5fe-9ec3a1963ecb	00000000-0000-0000-0000-000000000001	2026-11-20	Dia Nacional de Zumbi e da Consciência Negra
36639e75-d757-4726-8587-1b70d977b11c	00000000-0000-0000-0000-000000000001	2026-12-25	Natal
\.


--
-- Data for Name: import_jobs; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.import_jobs (id, project_id, source_file, status, rows_total, rows_ok, rows_error, detail, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: integrations; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.integrations (id, type, client_id, config, secret_ref, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: milestones; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.milestones (id, project_id, name, target_date, status, approved_by, approved_at, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.notifications (id, user_id, channel, title, body, task_id, is_read, sent_at, created_at) FROM stdin;
\.


--
-- Data for Name: payment_releases; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.payment_releases (id, professional_user_id, manager_user_id, project_id, period_start, period_end, total_hours, billable_hours, total_cost, total_billing, currency, status, signed_at, signature_ref, created_at) FROM stdin;
\.


--
-- Data for Name: project_closures; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.project_closures (id, project_id, closed_by, status, chk_hours_resolved, chk_milestones, chk_blockers, chk_tasks_done, notes, closed_at, created_at) FROM stdin;
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.project_members (project_id, user_id, added_at) FROM stdin;
\.


--
-- Data for Name: project_squads; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.project_squads (project_id, squad_id) FROM stdin;
\.


--
-- Data for Name: project_templates; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.project_templates (id, name, description, model, blueprint, created_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.projects (id, client_id, calendar_id, manager_user_id, title, description, model, allocation_mode, status, start_date, end_date, currency, estimated_cost, estimated_revenue, hubspot_deal_id, created_at, deleted_at) FROM stdin;
fe119b62-1cd0-4298-92f1-ef5d8c355a36	\N	\N	\N	Projeto de Teste	Testando a edição de projetos	WATERFALL	SQUAD	ACTIVE	2026-07-07	2026-07-07	BRL	0.00	0.00	\N	2026-07-07 12:29:43.042035+00	\N
8dd4e485-78ca-428e-86f6-20f8c010d375	\N	\N	\N	Projeto de Teste Real	Criando sem dependências externas	WATERFALL	SQUAD	DRAFT	2026-07-08	2026-07-08	BRL	0.00	0.00	\N	2026-07-08 17:26:12.600735+00	\N
0cd07d6b-73ff-4e03-9995-efd8ce58f7c4	3fa85f64-5717-4562-b3fc-2c963f66afa6	00000000-0000-0000-0000-000000000001	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	Teste final	Teste sequencial de validação	WATERFALL	SQUAD	DRAFT	2026-07-13	2026-07-15	BRL	0.00	0.00	teste	2026-07-13 14:39:58.997736+00	\N
\.


--
-- Data for Name: rate_cards; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.rate_cards (id, user_id, client_id, cost_per_hour, bill_per_hour, currency, valid_from, valid_to) FROM stdin;
\.


--
-- Data for Name: risks; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.risks (id, project_id, title, description, severity, status, mitigation, owner_user_id, is_client_visible, created_at) FROM stdin;
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.sprints (id, project_id, name, goal, start_date, end_date, status, created_at) FROM stdin;
\.


--
-- Data for Name: squad_members; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.squad_members (squad_id, user_id, allocation_pct) FROM stdin;
\.


--
-- Data for Name: squads; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.squads (id, name, lead_user_id, created_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.tags (id, project_id, name, color) FROM stdin;
\.


--
-- Data for Name: task_comments; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.task_comments (id, task_id, author_user_id, body, is_internal, created_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: task_dependencies; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.task_dependencies (id, predecessor_task_id, successor_task_id, type, lag_days) FROM stdin;
\.


--
-- Data for Name: task_tags; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.task_tags (task_id, tag_id) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.tasks (id, project_id, sprint_id, milestone_id, parent_task_id, assigned_user_id, title, description, status, priority, story_points, billable, estimated_effort_hours, start_date, end_date, created_at, deleted_at, due_date) FROM stdin;
9e515660-0897-4bd3-9d44-2f8bbd524b21	fe119b62-1cd0-4298-92f1-ef5d8c355a36	\N	\N	\N	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	Tarefa de Teste Final	Validando o campo billable com valores corretos.	TODO	MEDIUM	5	BILLABLE	20	2026-07-10	2026-07-20	2026-07-08 13:17:40.033415+00	\N	2026-07-20
29c34ef3-d5ad-45b8-aa04-38157b3695e7	fe119b62-1cd0-4298-92f1-ef5d8c355a36	\N	\N	\N	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	Teste de criacao de task	teste de criacao	IN_PROGRESS	MEDIUM	\N	BILLABLE	0	\N	\N	2026-07-08 12:42:15.952744+00	\N	\N
9f593852-204d-4cae-9a28-885f715a7e13	0cd07d6b-73ff-4e03-9995-efd8ce58f7c4	\N	\N	\N	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	Teste final	Teste de ececução final	TODO	MEDIUM	0	BILLABLE	2	2026-07-13	2026-07-13	2026-07-13 14:50:35.883192+00	\N	2026-07-13
\.


--
-- Data for Name: time_logs; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.time_logs (id, task_id, user_id, logged_date, start_time, end_time, billable, entry_type, approval_status, approved_by, approved_at, rejection_reason, revision_note, payment_release_id, description, created_at, deleted_at) FROM stdin;
e6ac9b67-a39a-41b4-a121-56983a764db4	29c34ef3-d5ad-45b8-aa04-38157b3695e7	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	2026-07-10	13:38:32.303	13:50:32.003	BILLABLE	REGULAR	APPROVED	\N	\N	\N	Ajuste manual de horas conforme alinhamento com o gestor.	\N	Relatório detalhado de horas trabalhadas no projeto Norn.	2026-07-13 13:00:19.72621+00	\N
f89b4b35-ae1e-4d66-800d-91533e57f5f3	9f593852-204d-4cae-9a28-885f715a7e13	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	2026-07-13	14:52:02.104	16:52:02.104	BILLABLE	REGULAR	APPROVED	\N	\N	teste	teste	\N	teste final	2026-07-13 14:53:17.344408+00	\N
e95d7a6c-7043-4ab7-97f7-78d34de7c591	29c34ef3-d5ad-45b8-aa04-38157b3695e7	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	2026-07-10	13:38:32.303	13:50:32.003	BILLABLE	REGULAR	APPROVED	1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	2026-07-13 15:13:05.626936+00	\N	\N	\N	string	2026-07-10 13:59:49.018764+00	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: heimr
--

COPY public.users (id, name, email, auth_provider, password_hash, entra_object_id, role, client_id, calendar_id, weekly_capacity_hours, is_active, created_at, deleted_at) FROM stdin;
370dd863-372c-4515-826e-8b0d229f767e	Bruno Ferreira	bruno.ferreira@heimr.co	LOCAL	placeholder_hash_123	\N	ADMINISTRATOR	\N	\N	40	t	2026-07-02 20:03:29.098297+00	\N
1dbbdf6e-e509-4f7d-b19b-dd88de7e441e	Admin Norn	admin@norn.com	LOCAL	$2b$12$O8spHKvDqgWBKoXOr8/5T.mS933yVvIL0RKIbHKqwFoYs9VLITNj2	\N	ADMINISTRATOR	\N	\N	40	t	2026-07-03 14:43:55.044267+00	\N
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: heimr
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: ai_usage ai_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.ai_usage
    ADD CONSTRAINT ai_usage_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: automation_runs automation_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automation_runs
    ADD CONSTRAINT automation_runs_pkey PRIMARY KEY (id);


--
-- Name: automations automations_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automations
    ADD CONSTRAINT automations_pkey PRIMARY KEY (id);


--
-- Name: calendars calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT calendars_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: comment_mentions comment_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.comment_mentions
    ADD CONSTRAINT comment_mentions_pkey PRIMARY KEY (comment_id, mentioned_user_id);


--
-- Name: external_resources external_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.external_resources
    ADD CONSTRAINT external_resources_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (id);


--
-- Name: integrations integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payment_releases payment_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.payment_releases
    ADD CONSTRAINT payment_releases_pkey PRIMARY KEY (id);


--
-- Name: project_closures project_closures_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_closures
    ADD CONSTRAINT project_closures_pkey PRIMARY KEY (id);


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (project_id, user_id);


--
-- Name: project_squads project_squads_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_squads
    ADD CONSTRAINT project_squads_pkey PRIMARY KEY (project_id, squad_id);


--
-- Name: project_templates project_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_templates
    ADD CONSTRAINT project_templates_pkey PRIMARY KEY (id);


--
-- Name: projects projects_hubspot_deal_id_key; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_hubspot_deal_id_key UNIQUE (hubspot_deal_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: rate_cards rate_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.rate_cards
    ADD CONSTRAINT rate_cards_pkey PRIMARY KEY (id);


--
-- Name: risks risks_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.risks
    ADD CONSTRAINT risks_pkey PRIMARY KEY (id);


--
-- Name: sprints sprints_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.sprints
    ADD CONSTRAINT sprints_pkey PRIMARY KEY (id);


--
-- Name: squad_members squad_members_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.squad_members
    ADD CONSTRAINT squad_members_pkey PRIMARY KEY (squad_id, user_id);


--
-- Name: squads squads_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.squads
    ADD CONSTRAINT squads_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: task_comments task_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_comments
    ADD CONSTRAINT task_comments_pkey PRIMARY KEY (id);


--
-- Name: task_dependencies task_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_pkey PRIMARY KEY (id);


--
-- Name: task_tags task_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_pkey PRIMARY KEY (task_id, tag_id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: time_logs time_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.time_logs
    ADD CONSTRAINT time_logs_pkey PRIMARY KEY (id);


--
-- Name: project_closures uq_closure_active; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_closures
    ADD CONSTRAINT uq_closure_active UNIQUE (project_id);


--
-- Name: task_dependencies uq_dependency; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT uq_dependency UNIQUE (predecessor_task_id, successor_task_id);


--
-- Name: holidays uq_holiday; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT uq_holiday UNIQUE (calendar_id, holiday_date);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_usage_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_ai_usage_project ON public.ai_usage USING btree (project_id);


--
-- Name: idx_audit_actor; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_audit_actor ON public.audit_log USING btree (actor_user_id, created_at);


--
-- Name: idx_audit_entity; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_audit_entity ON public.audit_log USING btree (entity_type, entity_id);


--
-- Name: idx_autoruns_automation; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_autoruns_automation ON public.automation_runs USING btree (automation_id);


--
-- Name: idx_comments_task; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_comments_task ON public.task_comments USING btree (task_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_extres_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_extres_project ON public.external_resources USING btree (project_id);


--
-- Name: idx_extres_task; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_extres_task ON public.external_resources USING btree (task_id);


--
-- Name: idx_milestones_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_milestones_project ON public.milestones USING btree (project_id);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id, is_read);


--
-- Name: idx_projects_client; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_projects_client ON public.projects USING btree (client_id);


--
-- Name: idx_projects_manager; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_projects_manager ON public.projects USING btree (manager_user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_projects_status; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_projects_status ON public.projects USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: idx_projmembers_user; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_projmembers_user ON public.project_members USING btree (user_id);


--
-- Name: idx_ratecards_client; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_ratecards_client ON public.rate_cards USING btree (client_id);


--
-- Name: idx_ratecards_user; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_ratecards_user ON public.rate_cards USING btree (user_id);


--
-- Name: idx_releases_professional; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_releases_professional ON public.payment_releases USING btree (professional_user_id, period_start);


--
-- Name: idx_risks_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_risks_project ON public.risks USING btree (project_id);


--
-- Name: idx_sprints_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_sprints_project ON public.sprints USING btree (project_id);


--
-- Name: idx_squadmembers_user; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_squadmembers_user ON public.squad_members USING btree (user_id);


--
-- Name: idx_tags_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tags_project ON public.tags USING btree (project_id);


--
-- Name: idx_taskdeps_successor; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_taskdeps_successor ON public.task_dependencies USING btree (successor_task_id);


--
-- Name: idx_tasks_assignee; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_assignee ON public.tasks USING btree (assigned_user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_tasks_milestone; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_milestone ON public.tasks USING btree (milestone_id);


--
-- Name: idx_tasks_parent; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_parent ON public.tasks USING btree (parent_task_id);


--
-- Name: idx_tasks_project; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_project ON public.tasks USING btree (project_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_tasks_sprint; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_sprint ON public.tasks USING btree (sprint_id);


--
-- Name: idx_tasks_status; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_tasks_status ON public.tasks USING btree (status);


--
-- Name: idx_timelogs_approval; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_timelogs_approval ON public.time_logs USING btree (approval_status);


--
-- Name: idx_timelogs_release; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_timelogs_release ON public.time_logs USING btree (payment_release_id);


--
-- Name: idx_timelogs_task; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_timelogs_task ON public.time_logs USING btree (task_id);


--
-- Name: idx_timelogs_user_date; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_timelogs_user_date ON public.time_logs USING btree (user_id, logged_date);


--
-- Name: idx_timelogs_user_day_interval; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_timelogs_user_day_interval ON public.time_logs USING btree (user_id, logged_date, start_time, end_time) WHERE (deleted_at IS NULL);


--
-- Name: idx_users_client; Type: INDEX; Schema: public; Owner: heimr
--

CREATE INDEX idx_users_client ON public.users USING btree (client_id);


--
-- Name: uq_users_email_active; Type: INDEX; Schema: public; Owner: heimr
--

CREATE UNIQUE INDEX uq_users_email_active ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: ai_usage ai_usage_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.ai_usage
    ADD CONSTRAINT ai_usage_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: automation_runs automation_runs_automation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automation_runs
    ADD CONSTRAINT automation_runs_automation_id_fkey FOREIGN KEY (automation_id) REFERENCES public.automations(id) ON DELETE CASCADE;


--
-- Name: automation_runs automation_runs_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automation_runs
    ADD CONSTRAINT automation_runs_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;


--
-- Name: automations automations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automations
    ADD CONSTRAINT automations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: automations automations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.automations
    ADD CONSTRAINT automations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: comment_mentions comment_mentions_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.comment_mentions
    ADD CONSTRAINT comment_mentions_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.task_comments(id) ON DELETE CASCADE;


--
-- Name: comment_mentions comment_mentions_mentioned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.comment_mentions
    ADD CONSTRAINT comment_mentions_mentioned_user_id_fkey FOREIGN KEY (mentioned_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: external_resources external_resources_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.external_resources
    ADD CONSTRAINT external_resources_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: external_resources external_resources_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.external_resources
    ADD CONSTRAINT external_resources_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: external_resources external_resources_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.external_resources
    ADD CONSTRAINT external_resources_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: holidays holidays_calendar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES public.calendars(id) ON DELETE CASCADE;


--
-- Name: import_jobs import_jobs_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.import_jobs
    ADD CONSTRAINT import_jobs_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: import_jobs import_jobs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.import_jobs
    ADD CONSTRAINT import_jobs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: integrations integrations_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: milestones milestones_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: milestones milestones_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_releases payment_releases_manager_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.payment_releases
    ADD CONSTRAINT payment_releases_manager_user_id_fkey FOREIGN KEY (manager_user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: payment_releases payment_releases_professional_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.payment_releases
    ADD CONSTRAINT payment_releases_professional_user_id_fkey FOREIGN KEY (professional_user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: payment_releases payment_releases_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.payment_releases
    ADD CONSTRAINT payment_releases_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: project_closures project_closures_closed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_closures
    ADD CONSTRAINT project_closures_closed_by_fkey FOREIGN KEY (closed_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: project_closures project_closures_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_closures
    ADD CONSTRAINT project_closures_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_members project_members_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_members project_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: project_squads project_squads_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_squads
    ADD CONSTRAINT project_squads_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_squads project_squads_squad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.project_squads
    ADD CONSTRAINT project_squads_squad_id_fkey FOREIGN KEY (squad_id) REFERENCES public.squads(id) ON DELETE CASCADE;


--
-- Name: projects projects_calendar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES public.calendars(id) ON DELETE SET NULL;


--
-- Name: projects projects_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- Name: projects projects_manager_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_manager_user_id_fkey FOREIGN KEY (manager_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: rate_cards rate_cards_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.rate_cards
    ADD CONSTRAINT rate_cards_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: rate_cards rate_cards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.rate_cards
    ADD CONSTRAINT rate_cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: risks risks_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.risks
    ADD CONSTRAINT risks_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: risks risks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.risks
    ADD CONSTRAINT risks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: sprints sprints_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.sprints
    ADD CONSTRAINT sprints_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: squad_members squad_members_squad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.squad_members
    ADD CONSTRAINT squad_members_squad_id_fkey FOREIGN KEY (squad_id) REFERENCES public.squads(id) ON DELETE CASCADE;


--
-- Name: squad_members squad_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.squad_members
    ADD CONSTRAINT squad_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: squads squads_lead_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.squads
    ADD CONSTRAINT squads_lead_user_id_fkey FOREIGN KEY (lead_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tags tags_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: task_comments task_comments_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_comments
    ADD CONSTRAINT task_comments_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: task_comments task_comments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_comments
    ADD CONSTRAINT task_comments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_dependencies task_dependencies_predecessor_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_predecessor_task_id_fkey FOREIGN KEY (predecessor_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_dependencies task_dependencies_successor_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_successor_task_id_fkey FOREIGN KEY (successor_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_tags task_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: task_tags task_tags_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_assigned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_assigned_user_id_fkey FOREIGN KEY (assigned_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tasks tasks_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;


--
-- Name: tasks tasks_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE SET NULL;


--
-- Name: time_logs time_logs_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.time_logs
    ADD CONSTRAINT time_logs_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: time_logs time_logs_payment_release_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.time_logs
    ADD CONSTRAINT time_logs_payment_release_id_fkey FOREIGN KEY (payment_release_id) REFERENCES public.payment_releases(id) ON DELETE SET NULL;


--
-- Name: time_logs time_logs_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.time_logs
    ADD CONSTRAINT time_logs_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: time_logs time_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.time_logs
    ADD CONSTRAINT time_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_calendar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES public.calendars(id) ON DELETE SET NULL;


--
-- Name: users users_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: heimr
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict cHRi0kqaUxI23OYyO2iGp595i0sRYr0gYRUmqF4NyzQbBeUIfQ2tRzknsWi9rW4

