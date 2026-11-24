-- Pap&ando | PostgreSQL / Supabase
create extension if not exists pgcrypto;
create type public.app_role as enum ('customer','owner','admin');
create type public.establishment_status as enum ('pending','under_review','approved','rejected','suspended');
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null, full_name text not null, avatar_url text,
 role public.app_role not null default 'customer',
 public_ranking boolean not null default true,
 created_at timestamptz not null default now()
);
create table public.establishments (
 id uuid primary key default gen_random_uuid(), name text not null, legal_name text,
 cnpj text unique, description text, logo_url text, cover_url text,
 phone text, address text, city text not null, state char(2) not null,
 category text not null, status public.establishment_status not null default 'pending',
 opening_hours jsonb not null default '{}', created_at timestamptz not null default now()
);
create table public.establishment_owners (
 establishment_id uuid references public.establishments(id) on delete cascade,
 owner_id uuid references public.profiles(id) on delete cascade,
 primary key(establishment_id,owner_id)
);
create table public.products (
 id uuid primary key default gen_random_uuid(), establishment_id uuid not null references public.establishments(id) on delete cascade,
 name text not null, description text, category text, price numeric(10,2) not null check(price>=0),
 promotional_price numeric(10,2) check(promotional_price>=0), stock integer check(stock>=0),
 available boolean not null default true, created_at timestamptz not null default now()
);
create table public.product_images (id uuid primary key default gen_random_uuid(), product_id uuid references public.products(id) on delete cascade, storage_path text not null);
create table public.reviews (
 id uuid primary key default gen_random_uuid(), establishment_id uuid not null references public.establishments(id) on delete cascade,
 author_id uuid not null references public.profiles(id), anonymous boolean not null default false,
 body text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(establishment_id,author_id)
);
create table public.review_criteria (
 review_id uuid references public.reviews(id) on delete cascade, criterion text not null check(criterion in ('value','taste','seasoning','service','presentation','overall')),
 score smallint not null check(score between 1 and 5), primary key(review_id,criterion)
);
create table public.comments (id uuid primary key default gen_random_uuid(), author_id uuid references public.profiles(id), review_id uuid references public.reviews(id) on delete cascade, body text not null, created_at timestamptz default now());
create table public.posts (id uuid primary key default gen_random_uuid(), author_id uuid references public.profiles(id), establishment_id uuid references public.establishments(id), body text not null, created_at timestamptz default now(), visibility text default 'public');
create table public.post_images (id uuid primary key default gen_random_uuid(), post_id uuid references public.posts(id) on delete cascade, storage_path text not null);
create table public.conversations (id uuid primary key default gen_random_uuid(), created_at timestamptz default now());
create table public.conversation_participants (conversation_id uuid references public.conversations(id) on delete cascade, profile_id uuid references public.profiles(id) on delete cascade, primary key(conversation_id,profile_id));
create table public.messages (id uuid primary key default gen_random_uuid(), conversation_id uuid references public.conversations(id) on delete cascade, sender_id uuid references public.profiles(id), body text not null, read_at timestamptz, created_at timestamptz default now());
create table public.documents (id uuid primary key default gen_random_uuid(), establishment_id uuid references public.establishments(id) on delete cascade, kind text not null, storage_path text not null, expires_at date, status text not null default 'pending', reviewed_by uuid references public.profiles(id), reviewed_at timestamptz);
create table public.reports (id uuid primary key default gen_random_uuid(), reporter_id uuid references public.profiles(id), target_type text not null, target_id uuid not null, reason text not null, status text not null default 'open', created_at timestamptz default now());
create table public.ranking_scores (id uuid primary key default gen_random_uuid(), profile_id uuid references public.profiles(id), establishment_id uuid references public.establishments(id), score numeric(8,2) not null, calculated_at timestamptz default now());
create table public.notifications (id uuid primary key default gen_random_uuid(), profile_id uuid references public.profiles(id), title text not null, body text, read_at timestamptz, created_at timestamptz default now());
create table public.audit_logs (id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id), action text not null, target_type text not null, target_id uuid, metadata jsonb default '{}', created_at timestamptz default now());

create index products_establishment_idx on public.products(establishment_id);
create index reviews_establishment_idx on public.reviews(establishment_id);
create index posts_created_idx on public.posts(created_at desc);
create index messages_conversation_idx on public.messages(conversation_id,created_at);
create index establishments_city_category_idx on public.establishments(city,category);

-- RLS baseline. Admin authorization must be granted only through trusted server-side provisioning.
alter table public.profiles enable row level security;
alter table public.establishments enable row level security;
alter table public.establishment_owners enable row level security;
alter table public.products enable row level security;
alter table public.reviews enable row level security;
alter table public.review_criteria enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;
alter table public.documents enable row level security;
alter table public.audit_logs enable row level security;

create policy "profiles readable" on public.profiles for select using (true);
create policy "profile self update" on public.profiles for update using (auth.uid()=id) with check (auth.uid()=id);
create policy "approved establishments public" on public.establishments for select using (status='approved');
create policy "owner sees own establishments" on public.establishments for select using (exists(select 1 from public.establishment_owners eo where eo.establishment_id=id and eo.owner_id=auth.uid()));
create policy "approved products public" on public.products for select using (exists(select 1 from public.establishments e where e.id=establishment_id and e.status='approved'));
create policy "owner manages products" on public.products for all using (exists(select 1 from public.establishment_owners eo where eo.establishment_id=products.establishment_id and eo.owner_id=auth.uid())) with check (exists(select 1 from public.establishment_owners eo where eo.establishment_id=products.establishment_id and eo.owner_id=auth.uid()));
create policy "reviews public read" on public.reviews for select using (true);
create policy "author manages review" on public.reviews for all using (author_id=auth.uid()) with check (author_id=auth.uid());
create policy "participants read conversations" on public.conversations for select using (exists(select 1 from public.conversation_participants cp where cp.conversation_id=id and cp.profile_id=auth.uid()));
create policy "participants read messages" on public.messages for select using (exists(select 1 from public.conversation_participants cp where cp.conversation_id=conversation_id and cp.profile_id=auth.uid()));
create policy "participants send messages" on public.messages for insert with check (sender_id=auth.uid() and exists(select 1 from public.conversation_participants cp where cp.conversation_id=conversation_id and cp.profile_id=auth.uid()));
create policy "documents owner/admin access via server" on public.documents for select using (false);
create policy "audit admin only via server" on public.audit_logs for select using (false);

-- Production note: complete policies for every table, Storage buckets, role provisioning,
-- moderation RPCs and admin checks before connecting a real Supabase project.
