-- ============================================================================
--  PHOENIX HOLIDAYS — lock the dashboard to named accounts only
--  Run this ONCE in Supabase -> SQL Editor -> New query -> Run
--
--  WHY: the first setup gave write access to any *logged-in* user. If public
--  signups are ever left on, a stranger could register and edit your hotels.
--  After this, only accounts listed in the admins table can change anything —
--  even if someone manages to create an account.
-- ============================================================================

-- 1. who is allowed to manage the site
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  note    text,
  added_at timestamptz not null default now()
);

alter table public.admins enable row level security;

drop policy if exists "admins read themselves" on public.admins;
create policy "admins read themselves"
  on public.admins for select to authenticated
  using (user_id = auth.uid());

-- 2. everyone who already has an account becomes an admin.
--    (Right now that should be just you.)
insert into public.admins (user_id, note)
select id, email from auth.users
on conflict (user_id) do nothing;

-- 3. helper
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- 4. rewrite the write rules to require membership
drop policy if exists "owner reads all hotels" on public.hotels;
create policy "owner reads all hotels"
  on public.hotels for select to authenticated using (public.is_admin());

drop policy if exists "owner writes hotels" on public.hotels;
create policy "owner writes hotels"
  on public.hotels for insert to authenticated with check (public.is_admin());

drop policy if exists "owner updates hotels" on public.hotels;
create policy "owner updates hotels"
  on public.hotels for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "owner deletes hotels" on public.hotels;
create policy "owner deletes hotels"
  on public.hotels for delete to authenticated using (public.is_admin());

drop policy if exists "owner writes settings" on public.settings;
create policy "owner writes settings"
  on public.settings for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- 5. same for the photo bucket
drop policy if exists "owner uploads photos" on storage.objects;
create policy "owner uploads photos"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'hotel-photos' and public.is_admin());

drop policy if exists "owner replaces photos" on storage.objects;
create policy "owner replaces photos"
  on storage.objects for update to authenticated
  using (bucket_id = 'hotel-photos' and public.is_admin());

drop policy if exists "owner deletes photos" on storage.objects;
create policy "owner deletes photos"
  on storage.objects for delete to authenticated
  using (bucket_id = 'hotel-photos' and public.is_admin());

-- ============================================================================
--  Check it worked — this should list your account:
--      select u.email from auth.users u join public.admins a on a.user_id = u.id;
--
--  To add a colleague later:
--    1. Authentication -> Users -> Add user  (create their login)
--    2. run:  insert into public.admins (user_id, note)
--             select id, email from auth.users where email = 'them@example.com';
--
--  STILL DO THIS TOO:
--    Authentication -> Providers -> Email -> turn OFF "Enable email signups".
--    This SQL is the second lock; that setting is the first.
-- ============================================================================
