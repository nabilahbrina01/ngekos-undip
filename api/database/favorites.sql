-- Tabel favorit: setiap user punya daftar kos/kontrakan favoritnya sendiri
create table favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  item_type text not null check (item_type in ('kos', 'kontrakan')),
  item_id uuid not null,
  created_at timestamptz default now(),
  unique (user_id, item_type, item_id)
);