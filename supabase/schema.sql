-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.collections (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title_ar text NOT NULL,
  description_ar text,
  cover_url text,
  is_free boolean NOT NULL DEFAULT false,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  rc_identifier text,
  price real,
  CONSTRAINT collections_pkey PRIMARY KEY (id)
);
CREATE TABLE public.entitlements (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  collection_id uuid NOT NULL,
  source text NOT NULL DEFAULT 'revenuecat'::text,
  product_id text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone,
  CONSTRAINT entitlements_pkey PRIMARY KEY (id),
  CONSTRAINT entitlements_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT entitlements_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id)
);
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  event_type text NOT NULL,
  event_data jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  user_id uuid NOT NULL,
  is_admin boolean NOT NULL DEFAULT false,
  username text,
  avatar_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.purchases (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  collection_id uuid NOT NULL,
  product_id text NOT NULL,
  transaction_id text NOT NULL UNIQUE,
  source text NOT NULL DEFAULT 'revenuecat'::text,
  amount_cents integer,
  currency text,
  status text NOT NULL DEFAULT 'completed'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT purchases_pkey PRIMARY KEY (id),
  CONSTRAINT purchases_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT purchases_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id)
);
CREATE TABLE public.stories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title_ar text NOT NULL,
  intro_ar text,
  commentary_ar text,
  content_url text,
  content_version integer NOT NULL DEFAULT 1,
  content_size_bytes bigint,
  order_index integer NOT NULL DEFAULT 0,
  is_free boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT stories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.story_collections (
  story_id uuid NOT NULL,
  collection_id uuid NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT story_collections_pkey PRIMARY KEY (story_id, collection_id),
  CONSTRAINT story_collections_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.stories(id),
  CONSTRAINT story_collections_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id)
);