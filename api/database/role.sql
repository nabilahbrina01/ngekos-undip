-- Role pengguna: pencari (hanya melihat) atau pemilik (boleh pasang iklan)
alter table users add column role text not null default 'pencari'
  check (role in ('pencari', 'pemilik'));

-- Setiap kos/kontrakan dicatat siapa pemiliknya (akun yang memasang iklan).
-- Data contoh lama tidak punya pemilik (null), jadi tidak bisa diubah lewat aplikasi.
alter table kos add column owner_id uuid references users(id) on delete set null;
alter table kontrakan add column owner_id uuid references users(id) on delete set null;
