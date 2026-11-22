create table areas (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  distance_km numeric(4,1)  -- perkiraan jarak ke kampus Undip Tembalang
);

create table kos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area_id uuid references areas(id) on delete set null,
  type text not null default 'campur' check (type in ('putra', 'putri', 'campur')),
  price_per_month integer not null default 0,
  address text,
  description text,
  facilities text[] default '{}',
  image_url text,
  owner_name text,
  owner_phone text,
  distance_km numeric(4,1),
  available_rooms integer default 0,
  created_at timestamptz default now()
);

create table kontrakan (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area_id uuid references areas(id) on delete set null,
  price_per_year integer not null default 0,
  bedrooms integer default 1,
  bathrooms integer default 1,
  address text,
  description text,
  facilities text[] default '{}',
  image_url text,
  owner_name text,
  owner_phone text,
  distance_km numeric(4,1),
  is_available boolean default true,
  created_at timestamptz default now()
);