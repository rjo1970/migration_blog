--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2
-- Dumped by pg_dump version 11.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    snark character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    post_id bigint
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    title character varying(255),
    body text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_id_seq OWNER TO postgres;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, snark, inserted_at, updated_at, post_id) FROM stdin;
1	Very bad you change a migration from the past.  The lies, they become impossible to keep.	2019-03-30 12:57:46	2019-03-30 12:57:46	1
4	It is fine to modify migrations as long as you don't mind dropping production.	2019-03-31 23:56:14	2019-03-31 23:56:14	1
5	It should be a simple post has_many comments; comment belongs_to :post.	2019-04-02 00:10:23	2019-04-02 00:10:23	2
6	It does not yet have the not null constraint.	2019-04-02 02:36:35	2019-04-02 02:36:35	3
7	No index yet, either.	2019-04-02 13:18:55	2019-04-02 13:18:55	3
8	Be sure to check your changesets for sanity.  Also, there will be lots of places to simplify your business logic.  Let your tests be your guide.	2019-04-02 13:26:24	2019-04-02 13:26:24	6
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, title, body, inserted_at, updated_at) FROM stdin;
6	Fixing the Code 🏥	## Comment\r\n\r\n```\r\n  schema "comments" do\r\n    field :snark, :string\r\n    belongs_to(:post, Post)\r\n\r\n    timestamps()\r\n  end\r\n```\r\n\r\n## Post\r\n\r\n```\r\n schema "posts" do\r\n    field :body, :string\r\n    field :title, :string\r\n    has_many(:comments, Comment)\r\n\r\n    timestamps()\r\n  end\r\n```\r\n\r\n## PostComment\r\n\r\n ⚰️\r\n	2019-04-02 12:05:15	2019-04-02 15:06:34
7	Adding an index and optimizing the query	## Migration\r\n\r\n```\r\n  def change do\r\n    create_if_not_exists index(:comments, [:post_id])\r\n  end\r\n```\r\n\r\n## Let's get our post and comments in a single query...\r\n\r\n```\r\n  def get_post!(id) do\r\n    Repo.one! from(\r\n      p in Post,\r\n     where: p.id == ^id,\r\n     left_join: comments in assoc(p, :comments),\r\n     preload: [comments: comments]\r\n     )\r\n  end\r\n```\r\n\r\n## And, the resulting query:\r\n\r\n```\r\nSELECT p0."id", p0."body", p0."title", p0."inserted_at",\r\n  p0."updated_at", c1."id", c1."snark", c1."post_id",\r\n  c1."inserted_at", c1."updated_at"\r\nFROM "posts" AS p0\r\nLEFT OUTER JOIN "comments" AS c1\r\nON c1."post_id" = p0."id"\r\nWHERE (p0."id" = $1) [7]\r\n```	2019-04-02 17:03:08	2019-04-02 17:06:58
2	The Story So Far 💔	![starting ddl](/images/starting_ddl.png)\r\n\r\n```\r\n def changeset(post_comment, attrs) do\r\n    post_comment\r\n    |> cast(attrs, [:post_id, :comment_id])\r\n    |> foreign_key_constraint(:post_id)\r\n    |> foreign_key_constraint(:comment_id)\r\n    # First sign of trouble...\r\n    |> unique_constraint(:comment_id)\r\n  end\r\n```	2019-04-01 02:26:51	2019-04-02 17:44:18
5	Extract, Transform, Load...	## First, the test...\r\n\r\n```\r\n    describe "updating existing data to relate a comment to a post" do\r\n        test "a comment belongs_to a post" do\r\n            post =\r\n             %Post{}\r\n             |> Repo.insert!()\r\n\r\n            comment =\r\n             %Comment{}\r\n             |> Repo.insert!()\r\n\r\n             %PostComment{post_id: post.id, comment_id: comment.id}\r\n             |> Repo.insert!()\r\n\r\n            Blog.ETL.MovePostIdToComments.run()\r\n\r\n            result = Repo.get!(Comment, comment.id)\r\n            assert result.post_id == post.id\r\n        end\r\n    end\r\n\r\n```\r\n\r\nNote that tests run in a transaction, so they roll back and can be made concurrently.  If you're doing something clever with direct SQL calls outside that transaction, you're going to be hosed.\r\n\r\n## Then, the ETL job itself:\r\n\r\n```\r\n  def run() do\r\n    Repo.transaction(fn ->\r\n      comment_and_post_ids_stream()\r\n      |> Stream.each(&update_comment/1)\r\n      |> Enum.count()\r\n    end)\r\n  end\r\n\r\n  defp update_comment({comment_id, post_id}) do\r\n    post = Repo.get!(Post, post_id)\r\n\r\n    Repo.get!(Comment, comment_id)\r\n    |> Repo.preload(:post)\r\n    |> Ecto.Changeset.change(post: post)\r\n    |> Repo.update!()\r\n  end\r\n\r\n  defp comment_and_post_ids_stream() do\r\n    from(\r\n      pc in PostComment,\r\n      select: {pc.comment_id, pc.post_id}\r\n    )\r\n    |> Repo.stream()\r\n  end\r\n```\r\n\r\n## One last gotcha:  The Schemas\r\n\r\n```\r\ndefmodule Post do\r\n    use Ecto.Schema\r\n\r\n    schema "posts" do\r\n      # All I need is the implicit id field\r\n      timestamps()\r\n    end\r\n  end\r\n\r\n  defmodule Comment do\r\n    use Ecto.Schema\r\n\r\n    schema "comments" do\r\n      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)\r\n      timestamps()\r\n    end\r\n  end\r\n\r\n  defmodule PostComment do\r\n    use Ecto.Schema\r\n\r\n    schema "posts_comments" do\r\n      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)\r\n      belongs_to(:comment, Blog.ETL.MovePostIdToComments.Comment)\r\n      timestamps()\r\n    end\r\n  end\r\n```\r\n\r\nYou want to keep your migrations decoupled from your future business schemas.  That can really bite you down the road if not immediately.	2019-04-02 03:52:59	2019-04-02 03:57:29
1	🤦 Migration Pitfall #1	__Never__ edit old migrations that have run against production.\r\n\r\n__Always__ make new migrations.\r\n	2019-03-30 12:13:40	2019-04-02 13:17:54
3	🔧First Migration of the Fix	```\r\n  def change do\r\n    alter table(:comments) do\r\n      add(:post_id, :integer)\r\n    end\r\n  end\r\n```\r\n	2019-04-02 00:34:17	2019-04-02 13:23:50
8	...And They All Lived Happily Ever After. 🌈	\r\n## Add Foreign key constraint to comments\r\n\r\n```\r\n  def change do\r\n    alter table(:comments) do\r\n      modify :post_id, references(:posts) \r\n    end\r\n  end\r\n```\r\n\r\n![ending ddl](/images/final_erd.png)	2019-04-02 17:49:01	2019-04-02 18:01:07
9	...The Evil Table Was Dead 💀	## The posts_comments is dropped\r\n\r\n```\r\n  def change do\r\n    drop table(:posts_comments)\r\n  end\r\n```	2019-04-02 18:10:30	2019-04-02 18:10:30
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20190330120015	2019-03-30 12:07:31
20190330125002	2019-03-30 12:55:37
20190330131840	2019-03-30 13:18:47
20190401174423	2019-04-01 17:46:58
20190402001338	2019-04-02 00:25:12
20190402160727	2019-04-02 16:10:22
20190402161341	2019-04-02 16:17:40
20190402175358	2019-04-02 17:56:10
20190402180744	2019-04-02 18:08:33
\.


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_id_seq', 8, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.posts_id_seq', 9, true);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: comments_post_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comments_post_id_index ON public.comments USING btree (post_id);


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- PostgreSQL database dump complete
--

