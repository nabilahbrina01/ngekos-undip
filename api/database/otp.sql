-- 1) Status verifikasi email untuk setiap user
alter table users add column is_verified boolean not null default false;

-- Akun yang sudah ada sebelum fitur OTP dianggap sudah terverifikasi
update users set is_verified = true;

-- 2) Kode OTP (disimpan dalam bentuk hash, berlaku 1 menit)
create table otp_codes (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  purpose text not null check (purpose in ('register', 'reset')),
  code_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0,
  created_at timestamptz default now()
);

create index otp_codes_email_purpose_idx on otp_codes (email, purpose);