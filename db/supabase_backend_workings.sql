-- Backend workings for Supabase/Postgres
-- SaaS roles:
--   super_admin -> can access all gyms and all data
--   manager/staff/reception/trainer -> only their own gym data
--   manager -> can create/update/delete staff in own gym except super_admin role

begin;

-- Ensure staff role constraint supports SaaS super admin model
alter table public.staff drop constraint if exists staff_role_check;
alter table public.staff
add constraint staff_role_check
check (
  lower(role) in ('super_admin', 'admin', 'manager', 'staff', 'reception', 'trainer')
);

-- Only one global super admin row allowed.
drop index if exists public.staff_single_super_admin_idx;
create unique index staff_single_super_admin_idx
on public.staff ((lower(role)))
where lower(role) = 'super_admin';

alter table public.gyms enable row level security;
alter table public.gym_settings enable row level security;
alter table public.staff enable row level security;
alter table public.members enable row level security;
alter table public.packages enable row level security;
alter table public.subscriptions enable row level security;
alter table public.payments enable row level security;
alter table public.attendance enable row level security;

create or replace function public.current_gym_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select s.gym_id
  from public.staff s
  where s.staff_id = auth.uid()
     or lower(s.email) = lower(auth.email())
  limit 1
$$;

create or replace function public.current_staff_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select lower(coalesce(s.role, ''))
  from public.staff s
  where s.staff_id = auth.uid()
     or lower(s.email) = lower(auth.email())
  limit 1
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_staff_role() = 'super_admin'
$$;

drop policy if exists "gyms_select" on public.gyms;
create policy "gyms_select" on public.gyms
for select
using (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "gyms_write" on public.gyms;
create policy "gyms_write" on public.gyms
for all
using (public.is_super_admin())
with check (public.is_super_admin());

drop policy if exists "gym_settings_select" on public.gym_settings;
create policy "gym_settings_select" on public.gym_settings
for select
using (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "gym_settings_write" on public.gym_settings;
create policy "gym_settings_write" on public.gym_settings
for all
using (public.is_super_admin() or gym_id = public.current_gym_id())
with check (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "staff_select" on public.staff;
create policy "staff_select" on public.staff
for select
using (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "staff_insert" on public.staff;
create policy "staff_insert" on public.staff
for insert
with check (
  public.is_super_admin()
  or (
    public.current_staff_role() = 'manager'
    and gym_id = public.current_gym_id()
    and lower(role) in ('manager', 'staff', 'reception', 'trainer')
  )
);

drop policy if exists "staff_update" on public.staff;
create policy "staff_update" on public.staff
for update
using (
  public.is_super_admin()
  or (
    public.current_staff_role() = 'manager'
    and gym_id = public.current_gym_id()
    and lower(role) <> 'super_admin'
  )
)
with check (
  public.is_super_admin()
  or (
    public.current_staff_role() = 'manager'
    and gym_id = public.current_gym_id()
    and lower(role) <> 'super_admin'
  )
);

drop policy if exists "staff_delete" on public.staff;
create policy "staff_delete" on public.staff
for delete
using (
  public.is_super_admin()
  or (
    public.current_staff_role() = 'manager'
    and gym_id = public.current_gym_id()
    and lower(role) in ('staff', 'reception', 'trainer')
  )
);

drop policy if exists "members_policy" on public.members;
create policy "members_policy" on public.members
for all
using (public.is_super_admin() or gym_id = public.current_gym_id())
with check (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "packages_policy" on public.packages;
create policy "packages_policy" on public.packages
for all
using (public.is_super_admin() or gym_id = public.current_gym_id())
with check (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "attendance_policy" on public.attendance;
create policy "attendance_policy" on public.attendance
for all
using (public.is_super_admin() or gym_id = public.current_gym_id())
with check (public.is_super_admin() or gym_id = public.current_gym_id());

drop policy if exists "subscriptions_policy" on public.subscriptions;
create policy "subscriptions_policy" on public.subscriptions
for all
using (
  public.is_super_admin()
  or member_id in (
    select m.member_id from public.members m where m.gym_id = public.current_gym_id()
  )
)
with check (
  public.is_super_admin()
  or member_id in (
    select m.member_id from public.members m where m.gym_id = public.current_gym_id()
  )
);

drop policy if exists "payments_policy" on public.payments;
create policy "payments_policy" on public.payments
for all
using (
  public.is_super_admin()
  or member_id in (
    select m.member_id from public.members m where m.gym_id = public.current_gym_id()
  )
)
with check (
  public.is_super_admin()
  or member_id in (
    select m.member_id from public.members m where m.gym_id = public.current_gym_id()
  )
);

create or replace function public.dashboard_stats(p_gym_id uuid)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_total_members int;
  v_today_checkins int;
  v_expiring_7 int;
  v_month_revenue numeric;
  v_target numeric;
begin
  if not public.is_super_admin() and p_gym_id <> public.current_gym_id() then
    raise exception 'forbidden';
  end if;

  select count(*) into v_total_members
  from public.members
  where gym_id = p_gym_id and status = 'active';

  select count(*) into v_today_checkins
  from public.attendance
  where gym_id = p_gym_id and attendance_date = current_date;

  select count(*) into v_expiring_7
  from public.subscriptions s
  join public.members m on m.member_id = s.member_id
  where m.gym_id = p_gym_id
    and s.expiry_date between current_date and (current_date + 7)
    and s.status in ('active','grace');

  select coalesce(sum(amount), 0) into v_month_revenue
  from public.payments p
  join public.members m on m.member_id = p.member_id
  where m.gym_id = p_gym_id
    and date_trunc('month', p.payment_date::timestamp) = date_trunc('month', now());

  select coalesce(gs.monthly_target, 50000) into v_target
  from public.gym_settings gs
  where gs.gym_id = p_gym_id;

  return jsonb_build_object(
    'totalMembers', v_total_members,
    'todayCheckins', v_today_checkins,
    'expiringThisWeek', v_expiring_7,
    'monthlyRevenue', v_month_revenue,
    'collectionTarget', v_target
  );
end;
$$;

commit;

