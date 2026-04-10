-- Nepali demo data for 3 gyms.
-- Run after schema creation. This script is idempotent by email/member_code checks.

begin;

do $$
declare
  g_idx int;
  v_gym_name text;
  v_owner_name text;
  v_gym_phone text;
  v_gym_email text;
  v_gym_addr text;
  v_gym_code text;
  v_gym_id uuid;
  manager_id uuid;
  reception_id uuid;
  pkg_basic uuid;
  pkg_std uuid;
  pkg_premium uuid;
  m_idx int;
  member_limit int;
  base_price numeric;
  std_price numeric;
  premium_price numeric;
  attendance_limit int;
  payment_mode text;
  status_value text;
  start_offset_days int;
  payment_lag_days int;
  member_id uuid;
  v_member_code text;
  v_member_name text;
  sub_id uuid;
  chosen_pkg uuid;
  chosen_days int;
  chosen_amount numeric;
begin
  for g_idx in 1..3 loop
    v_gym_name := case g_idx
      when 1 then 'सुबिसु फिटनेस सेन्टर - काठमाडौं'
      when 2 then 'सुबिसु फिटनेस सेन्टर - ललितपुर'
      else 'सुबिसु फिटनेस सेन्टर - भक्तपुर'
    end;
    v_owner_name := case g_idx
      when 1 then 'रामबहादुर थापा'
      when 2 then 'किरण श्रेष्ठ'
      else 'सन्तोष राई'
    end;
    v_gym_phone := '9841-00000' || g_idx::text;
    v_gym_email := 'owner' || g_idx::text || '@subisu-fit.com';
    v_gym_addr := case g_idx
      when 1 then 'कालीमाटी, काठमाडौं'
      when 2 then 'कुमारीपाटी, ललितपुर'
      else 'सल्लाघारी, भक्तपुर'
    end;
    v_gym_code := 'GYM' || g_idx::text;
    member_limit := case g_idx when 1 then 16 when 2 then 12 else 9 end;
    attendance_limit := case g_idx when 1 then 9 when 2 then 6 else 4 end;
    base_price := case g_idx when 1 then 2500 when 2 then 2100 else 1800 end;
    std_price := case g_idx when 1 then 7200 when 2 then 5900 else 5100 end;
    premium_price := case g_idx when 1 then 22500 when 2 then 18800 else 16500 end;

    select g.gym_id into v_gym_id
    from public.gyms g
    where g.email = v_gym_email
    limit 1;

    if v_gym_id is null then
      insert into public.gyms (gym_name, owner_name, phone, email, address, gst_number, logo_url)
      values (v_gym_name, v_owner_name, v_gym_phone, v_gym_email, v_gym_addr, 'NP-GST-' || v_gym_code, null)
      returning gyms.gym_id into v_gym_id;
    else
      update public.gyms
      set
        gym_name = v_gym_name,
        owner_name = v_owner_name,
        phone = v_gym_phone,
        address = v_gym_addr,
        gst_number = 'NP-GST-' || v_gym_code
      where public.gyms.gym_id = v_gym_id;
    end if;

    insert into public.gym_settings (gym_id, monthly_target, currency, timezone, receipt_prefix, enable_biometric)
    values (
      v_gym_id,
      case g_idx when 1 then 350000 when 2 then 220000 else 140000 end,
      'NPR',
      'Asia/Kathmandu',
      v_gym_code,
      true
    )
    on conflict do nothing;

    insert into public.staff (gym_id, full_name, email, phone, role, is_active)
    select v_gym_id, x.full_name, x.email, x.phone, x.role, true
    from (
      values
        ('जिम म्यानेजर ' || g_idx::text, 'manager' || g_idx::text || '@fit.com', '9851-2000' || g_idx::text, 'manager'),
        ('रिसेप्सन ' || g_idx::text, 'reception' || g_idx::text || '@fit.com', '9851-3000' || g_idx::text, 'reception'),
        ('ट्रेनर ' || g_idx::text, 'trainer' || g_idx::text || '@fit.com', '9851-4000' || g_idx::text, 'trainer')
    ) as x(full_name, email, phone, role)
    where not exists (
      select 1 from public.staff s where s.email = x.email
    );

    -- Only one platform super admin (global SaaS operator).
    if g_idx = 1 then
      insert into public.staff (gym_id, full_name, email, phone, role, is_active)
      select v_gym_id, 'सुपर एडमिन', 'superadmin@fit.com', '9851-10000', 'super_admin', true
      where not exists (
        select 1 from public.staff s where lower(s.role) = 'super_admin'
      );
    end if;

    select staff_id into manager_id from public.staff where email = 'manager' || g_idx::text || '@fit.com' limit 1;
    select staff_id into reception_id from public.staff where email = 'reception' || g_idx::text || '@fit.com' limit 1;

    insert into public.packages (gym_id, package_name, duration_type, duration_days, price, features, is_active)
    values
      (v_gym_id, 'बेसिक (' || g_idx::text || ')', 'monthly', 30, base_price, '{"locker": false, "pt_sessions": 0}'::jsonb, true),
      (v_gym_id, 'स्ट्यान्डर्ड (' || g_idx::text || ')', 'quarterly', 90, std_price, '{"locker": true, "pt_sessions": 2}'::jsonb, true),
      (v_gym_id, 'प्रिमियम (' || g_idx::text || ')', 'yearly', 365, premium_price, '{"locker": true, "pt_sessions": 6, "sauna": true}'::jsonb, true)
    on conflict do nothing;

    select p.package_id into pkg_basic
    from public.packages p
    where p.gym_id = v_gym_id and p.package_name like 'बेसिक%'
    order by p.created_at desc limit 1;
    select p.package_id into pkg_std
    from public.packages p
    where p.gym_id = v_gym_id and p.package_name like 'स्ट्यान्डर्ड%'
    order by p.created_at desc limit 1;
    select p.package_id into pkg_premium
    from public.packages p
    where p.gym_id = v_gym_id and p.package_name like 'प्रिमियम%'
    order by p.created_at desc limit 1;

    for m_idx in 1..member_limit loop
      v_member_code := v_gym_code || '-M-' || lpad(m_idx::text, 4, '0');
      v_member_name := 'सदस्य ' || g_idx::text || '-' || m_idx::text;

      if not exists (select 1 from public.members m where m.member_code = v_member_code) then
        insert into public.members (
          gym_id, member_code, full_name, phone, email, address,
          emergency_contact_name, emergency_contact_phone, date_of_birth,
          gender, joined_date, status, notes
        ) values (
          v_gym_id,
          v_member_code,
          v_member_name,
          '9860-' || lpad((g_idx * 10000 + m_idx)::text, 6, '0'),
          lower(replace(v_member_code, '-', '')) || '@demo.fit',
          v_gym_addr,
          'सम्पर्क ' || m_idx::text,
          '9800-' || lpad((g_idx * 10000 + m_idx)::text, 6, '0'),
          (date '1990-01-01' + ((m_idx * 120) * interval '1 day'))::date,
          case when m_idx % 2 = 0 then 'male' else 'female' end,
          current_date - ((m_idx * 3) * interval '1 day'),
          'active',
          'डेमो सदस्य'
        );
      end if;

      select m.member_id into member_id from public.members m where m.member_code = v_member_code limit 1;

      if m_idx <= 4 then
        chosen_pkg := pkg_basic; chosen_days := 30; chosen_amount := base_price;
      elsif m_idx <= (member_limit * 2 / 3) then
        chosen_pkg := pkg_std; chosen_days := 90; chosen_amount := std_price;
      else
        chosen_pkg := pkg_premium; chosen_days := 365; chosen_amount := premium_price;
      end if;

      status_value := case
        when (m_idx % 7 = 0) then 'expired'
        when (m_idx % 5 = 0) then 'grace'
        when (m_idx % 9 = 0) then 'cancelled'
        else 'active'
      end;
      payment_mode := case
        when g_idx = 1 then (case when m_idx % 3 = 0 then 'card' when m_idx % 2 = 0 then 'upi' else 'cash' end)
        when g_idx = 2 then (case when m_idx % 2 = 0 then 'upi' else 'cash' end)
        else (case when m_idx % 4 = 0 then 'bank_transfer' else 'cash' end)
      end;
      start_offset_days := case g_idx when 1 then 20 when 2 then 35 else 55 end + (m_idx % 10);
      payment_lag_days := case g_idx when 1 then 0 when 2 then 1 else 2 end;

      insert into public.subscriptions (
        member_id, package_id, start_date, expiry_date, status, amount_paid, payment_mode, payment_reference, created_by
      ) values (
        member_id, chosen_pkg, current_date - (start_offset_days * interval '1 day'),
        (current_date - (start_offset_days * interval '1 day')) + (chosen_days * interval '1 day'),
        status_value,
        chosen_amount, payment_mode,
        v_gym_code || '-SUB-' || lpad(m_idx::text, 3, '0'),
        manager_id
      )
      on conflict do nothing
      returning subscription_id into sub_id;

      if sub_id is null then
        select s.subscription_id into sub_id
        from public.subscriptions s
        where s.member_id = member_id
        order by s.created_at desc
        limit 1;
      end if;

      insert into public.payments (
        member_id, subscription_id, amount, payment_mode, payment_date, receipt_number, notes, recorded_by
      ) values (
        member_id, sub_id, chosen_amount,
        payment_mode,
        current_date - (payment_lag_days * interval '1 day'),
        v_gym_code || '-RCPT-' || lpad(m_idx::text, 4, '0'),
        case g_idx
          when 1 then 'प्रिमियम क्लस्टर डेमो भुक्तानी'
          when 2 then 'मिड-सेग्मेन्ट डेमो भुक्तानी'
          else 'बजेट जिम डेमो भुक्तानी'
        end,
        reception_id
      )
      on conflict do nothing;

      if m_idx <= attendance_limit then
        insert into public.attendance (
          member_id, gym_id, check_in_time, check_out_time, marked_by, attendance_date
        ) values (
          member_id, v_gym_id,
          now() - ((m_idx + g_idx) * interval '35 minute'),
          now() - ((m_idx + g_idx) * interval '35 minute') + interval '75 minute',
          reception_id, current_date
        )
        on conflict do nothing;
      end if;
    end loop;
  end loop;
end $$;

-- Keep exactly one super admin in demo dataset.
delete from public.staff
where lower(role) = 'super_admin'
  and lower(email) <> 'superadmin@fit.com';

select
  (select count(*) from public.gyms) as gyms_total,
  (select count(*) from public.staff) as staff_total,
  (select count(*) from public.members) as members_total,
  (select count(*) from public.packages) as packages_total,
  (select count(*) from public.subscriptions) as subscriptions_total,
  (select count(*) from public.payments) as payments_total,
  (select count(*) from public.attendance) as attendance_total;

commit;

