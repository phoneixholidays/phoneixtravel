-- ============================================================================
--  PHOENIX HOLIDAYS — database setup
--  Run this ONCE in Supabase:  Dashboard -> SQL Editor -> New query -> Run
-- ============================================================================

-- ---------------------------------------------------------------- hotels ---
create table if not exists public.hotels (
  id          uuid primary key default gen_random_uuid(),
  name_ar     text not null,
  name_en     text not null,
  city        text not null default 'hurghada',   -- hurghada|somabay|makadi|marsaalam|sharm|other
  stars       smallint not null default 5,
  price       integer  not null default 0,        -- EGP per night, double room
  board       text     not null default 'AI',     -- UAI|AI|HB|BB|RO
  features    text[]   not null default '{}',
  desc_ar     text default '',
  desc_en     text default '',
  photos      text[]   not null default '{}',     -- public URLs, first one is the cover
  popular     boolean  not null default false,
  published   boolean  not null default true,
  sort_order  integer  not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists hotels_city_idx      on public.hotels (city);
create index if not exists hotels_published_idx on public.hotels (published);

-- keep updated_at honest
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists hotels_touch on public.hotels;
create trigger hotels_touch before update on public.hotels
  for each row execute function public.touch_updated_at();

-- --------------------------------------------------------- site settings ---
-- lets the owner change the WhatsApp number / contact details from /admin
create table if not exists public.settings (
  key   text primary key,
  value text not null
);

insert into public.settings (key, value) values
  ('wa_number',  '201224741570'),
  ('phone',      '+20 122 474 1570'),
  ('email',      'info@phoenixholidays.com'),
  ('address_ar', 'القاهرة، مصر'),
  ('address_en', 'Cairo, Egypt'),
  ('hours_ar',   'يومياً من ٩ ص حتى ١١ م'),
  ('hours_en',   'Daily 9:00 - 23:00')
on conflict (key) do nothing;

-- ------------------------------------------------------------------ RLS ----
-- Row Level Security: visitors can only READ published hotels.
-- Only a logged-in user (the owner) can add, change or delete anything.
alter table public.hotels   enable row level security;
alter table public.settings enable row level security;

drop policy if exists "public reads published hotels" on public.hotels;
create policy "public reads published hotels"
  on public.hotels for select
  to anon
  using (published = true);

drop policy if exists "owner reads all hotels" on public.hotels;
create policy "owner reads all hotels"
  on public.hotels for select to authenticated using (true);

drop policy if exists "owner writes hotels" on public.hotels;
create policy "owner writes hotels"
  on public.hotels for insert to authenticated with check (true);

drop policy if exists "owner updates hotels" on public.hotels;
create policy "owner updates hotels"
  on public.hotels for update to authenticated using (true) with check (true);

drop policy if exists "owner deletes hotels" on public.hotels;
create policy "owner deletes hotels"
  on public.hotels for delete to authenticated using (true);

drop policy if exists "public reads settings" on public.settings;
create policy "public reads settings"
  on public.settings for select to anon, authenticated using (true);

drop policy if exists "owner writes settings" on public.settings;
create policy "owner writes settings"
  on public.settings for update to authenticated using (true) with check (true);

-- -------------------------------------------------------------- storage ----
-- Public bucket for hotel photos. Anyone can view; only the owner can upload.
insert into storage.buckets (id, name, public)
values ('hotel-photos', 'hotel-photos', true)
on conflict (id) do nothing;

drop policy if exists "public views photos" on storage.objects;
create policy "public views photos"
  on storage.objects for select
  using (bucket_id = 'hotel-photos');

drop policy if exists "owner uploads photos" on storage.objects;
create policy "owner uploads photos"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'hotel-photos');

drop policy if exists "owner replaces photos" on storage.objects;
create policy "owner replaces photos"
  on storage.objects for update to authenticated
  using (bucket_id = 'hotel-photos');

drop policy if exists "owner deletes photos" on storage.objects;
create policy "owner deletes photos"
  on storage.objects for delete to authenticated
  using (bucket_id = 'hotel-photos');

-- ============================================================================
--  DONE.
--  Next, in order:
--    1. Authentication -> Users -> Add user   (this becomes your /admin login)
--    2. Authentication -> Providers -> Email  -> turn OFF "Enable email signups"
--    3. Run harden-admin.sql  (locks writing to named accounts only)
-- ============================================================================
