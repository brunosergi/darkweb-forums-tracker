BEGIN;

create table public.darkweb_forums (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  monitored_at timestamp with time zone null,
  forum_name text null,
  forum_url text null,
  post_title text null,
  post_link text not null,
  post_visibility text null,
  post_summary text null,
  post_screenshot_url text null,
  post_author_name text null,
  post_author_link text null,
  last_post_date timestamp with time zone null,
  last_post_author text null,
  last_post_author_link text null,
  post_alert boolean not null default false,
  sent boolean not null default false,
  sent_at timestamp with time zone null,
  entity_name text[] null,
  post_date timestamp with time zone null,
  constraint darkweb_forums_pkey primary key (id),
  constraint darkweb_forums_post_link_key unique (post_link)
) TABLESPACE pg_default;

-- Enable Row Level Security (RLS) for the table
ALTER TABLE public.darkweb_forums ENABLE ROW LEVEL SECURITY;

-- Create policy to allow service role to access all rows
CREATE POLICY "Allow service role full access" ON public.darkweb_forums
  FOR ALL 
  USING (true)
  WITH CHECK (true);

-- Grant full access to authenticated users (for n8n workflows)
CREATE POLICY "Allow authenticated full access" ON public.darkweb_forums
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- CREATE SECURE FUNCTION FOR CHECKING EXISTING FORUM POST LINKS
CREATE OR REPLACE FUNCTION public.check_existing_forum_posts(post_links_to_check TEXT[])
RETURNS TABLE(existing_post_link TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT df.post_link
  FROM public.darkweb_forums AS df
  WHERE df.post_link = ANY(post_links_to_check);
END;
$$;

-- Grant execute permission to anon and authenticated users
GRANT EXECUTE ON FUNCTION public.check_existing_forum_posts(TEXT[]) TO anon, authenticated;

COMMIT;