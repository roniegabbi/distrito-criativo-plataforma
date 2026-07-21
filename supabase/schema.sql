-- =====================================================================
--  PLATAFORMA DE GESTÃO · DISTRITO CRIATIVO CENTRO-GARE
--  Schema Supabase (PostgreSQL) — estrutura completa
--  Ordem de execução: schema.sql → policies (incluídas abaixo) → seed.sql
-- =====================================================================

create extension if not exists "pgcrypto";      -- gen_random_uuid()
create extension if not exists "unaccent";       -- buscas sem acento

-- =====================================================================
--  1. TIPOS (ENUMS)
-- =====================================================================
create type tipo_instituicao   as enum ('publica','privada','ensino','terceiro','coletivo');
create type papel_governanca   as enum ('coordenacao','gestor','lider','membro','gt');
create type tipo_comite        as enum ('assembleia','gestor','coordenacao','executivo','grupo_trabalho');
create type papel_comite       as enum ('coordenador','lider','membro');
create type status_projeto     as enum ('planejado','em_execucao','concluido','atrasado');
create type status_acao        as enum ('planejado','em_execucao','concluido','atrasado');
create type natureza_recurso   as enum ('publica','privada');
create type status_reuniao     as enum ('agendada','realizada','cancelada');
create type eixo_evento        as enum ('gastro','univ','inova','memoria','social');
create type status_evento      as enum ('planejado','recorrente','continuo','realizado');
create type tipo_contribuicao  as enum ('ideia','problema','voluntario','empreendedor','contato');
create type user_role          as enum ('admin','coordenacao','gestor','comite','leitura');

-- =====================================================================
--  2. FUNÇÕES UTILITÁRIAS
-- =====================================================================
-- Atualiza updated_at automaticamente
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

-- Obs.: auth_role() e can_edit() são definidas na seção 10, DEPOIS da
-- tabela profile (que elas referenciam), para não falhar na validação.

-- =====================================================================
--  3. PLANEJAMENTO ESTRATÉGICO
-- =====================================================================
create table dimensao (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,                 -- amb, gov, eco, ide
  nome        text not null,
  cor         text not null,                        -- hex da marca
  descricao   text,
  ordem       int default 0
);

create table objetivo_estrategico (
  id          uuid primary key default gen_random_uuid(),
  dimensao_id uuid not null references dimensao(id) on delete cascade,
  numero      int not null,
  titulo      text not null,
  prioritario boolean default false,
  unique (dimensao_id, numero)
);

-- =====================================================================
--  4. CADASTROS: INSTITUIÇÕES E PESSOAS
-- =====================================================================
create table instituicao (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  sigla       text,
  tipo        tipo_instituicao not null default 'publica',
  email       text,
  telefone    text,
  logo_url    text,
  is_fonte_recurso boolean default false,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table pessoa (
  id            uuid primary key default gen_random_uuid(),
  nome          text not null,
  email         text,
  telefone      text,
  foto_url      text,
  instituicao_id uuid references instituicao(id) on delete set null,
  cargo         text,
  dimensao_id   uuid references dimensao(id) on delete set null,
  papel         papel_governanca,
  competencias  text[] default '{}',
  ativo         boolean default true,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index on pessoa (instituicao_id);
create index on pessoa (dimensao_id);

-- =====================================================================
--  5. GOVERNANÇA (COMITÊS)
-- =====================================================================
create table comite (
  id          uuid primary key default gen_random_uuid(),
  tipo        tipo_comite not null,
  nome        text not null,
  dimensao_id uuid references dimensao(id) on delete set null   -- p/ comitês executivos
);

create table pessoa_comite (
  pessoa_id   uuid references pessoa(id) on delete cascade,
  comite_id   uuid references comite(id) on delete cascade,
  papel       papel_comite not null default 'membro',
  primary key (pessoa_id, comite_id)
);

-- =====================================================================
--  6. PROJETOS / PROCESSOS
-- =====================================================================
create table projeto (
  id            uuid primary key default gen_random_uuid(),
  nome          text not null,
  dimensao_id   uuid references dimensao(id) on delete set null,
  status        status_projeto not null default 'planejado',
  progresso     int default 0 check (progresso between 0 and 100),
  descricao     text,
  lider_id      uuid references pessoa(id) on delete set null,
  inicio        text,          -- texto livre (ex.: "14/07/2026") ou trocar por date
  fim           text,
  prazo         text,
  orcamento     numeric(14,2) default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index on projeto (dimensao_id);
create index on projeto (status);

create table projeto_equipe (
  projeto_id  uuid references projeto(id) on delete cascade,
  pessoa_id   uuid references pessoa(id) on delete cascade,
  papel       text,                          -- função no projeto
  primary key (projeto_id, pessoa_id)
);

create table acao (
  id          uuid primary key default gen_random_uuid(),
  projeto_id  uuid not null references projeto(id) on delete cascade,
  nome        text not null,
  responsavel text,
  prazo       text,
  status      status_acao not null default 'planejado',
  progresso   int default 0 check (progresso between 0 and 100),
  ordem       int default 0
);
create index on acao (projeto_id);

create table indicador (
  id          uuid primary key default gen_random_uuid(),
  projeto_id  uuid not null references projeto(id) on delete cascade,
  nome        text not null,
  meta        numeric,
  atual       numeric default 0,
  unidade     text default ''
);
create index on indicador (projeto_id);

create table fonte_recurso (
  id            uuid primary key default gen_random_uuid(),
  projeto_id    uuid not null references projeto(id) on delete cascade,
  instituicao_id uuid references instituicao(id) on delete set null,
  natureza      natureza_recurso not null,
  nome          text not null,               -- descrição da fonte
  valor         numeric(14,2) not null default 0
);
create index on fonte_recurso (projeto_id);

-- =====================================================================
--  7. AGENDA, REUNIÕES E ATAS
-- =====================================================================
create table reuniao (
  id          uuid primary key default gen_random_uuid(),
  titulo      text not null,
  comite_id   uuid references comite(id) on delete set null,
  tipo        text,                          -- rótulo livre (Comitê Gestor…)
  data        date not null,
  hora        text,
  local       text,
  status      status_reuniao not null default 'agendada',
  created_at  timestamptz default now()
);

create table reuniao_pauta (
  id          uuid primary key default gen_random_uuid(),
  reuniao_id  uuid not null references reuniao(id) on delete cascade,
  ordem       int default 0,
  item        text not null
);

create table reuniao_participante (
  reuniao_id  uuid references reuniao(id) on delete cascade,
  pessoa_id   uuid references pessoa(id) on delete cascade,
  nome_livre  text,                          -- p/ participante ainda não cadastrado
  presente    boolean default true,
  primary key (reuniao_id, pessoa_id)
);

create table ata (
  id           uuid primary key default gen_random_uuid(),
  reuniao_id   uuid not null unique references reuniao(id) on delete cascade,
  conteudo     text not null,
  gerada_por_ia boolean default false,
  aprovada     boolean default false,
  created_at   timestamptz default now()
);

-- =====================================================================
--  8. EVENTOS E INICIATIVAS
-- =====================================================================
create table evento (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  eixo        eixo_evento not null,
  status      status_evento not null default 'planejado',
  resumo      text,
  local       text,
  quando      text,
  publico_txt text,
  publico_num int default 0,
  orcamento   numeric(14,2) default 0,
  destaque    text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table evento_organizador (
  evento_id     uuid references evento(id) on delete cascade,
  instituicao_id uuid references instituicao(id) on delete cascade,
  nome_livre    text,
  primary key (evento_id, instituicao_id)
);

-- =====================================================================
--  9. INTERAÇÃO CIDADÃO (formulário público da Vitrine)
-- =====================================================================
create table contribuicao_cidadao (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  contato     text,
  tipo        tipo_contribuicao,
  dimensao_id uuid references dimensao(id) on delete set null,
  mensagem    text not null,
  status      text default 'novo',           -- novo / em_analise / respondido
  created_at  timestamptz default now()
);

-- =====================================================================
-- 10. USUÁRIOS / PERFIS (liga auth.users ao cadastro de pessoas)
-- =====================================================================
create table profile (
  id          uuid primary key references auth.users(id) on delete cascade,
  pessoa_id   uuid references pessoa(id) on delete set null,
  role        user_role not null default 'leitura',
  created_at  timestamptz default now()
);

-- Papel do usuário autenticado (referencia profile — por isso vem aqui)
create or replace function auth_role() returns user_role as $$
  select coalesce(
    (select role from public.profile where id = auth.uid()),
    'leitura'::user_role);
$$ language sql stable security definer;

-- Pode editar? (admin/coordenacao/gestor)
create or replace function can_edit() returns boolean as $$
  select auth_role() in ('admin','coordenacao','gestor');
$$ language sql stable security definer;

-- Cria profile automaticamente ao surgir um novo usuário no Auth
create or replace function handle_new_user() returns trigger as $$
begin
  insert into public.profile (id, role) values (new.id, 'leitura')
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- =====================================================================
-- 11. TRIGGERS updated_at
-- =====================================================================
create trigger t_inst_upd  before update on instituicao for each row execute function set_updated_at();
create trigger t_pes_upd   before update on pessoa      for each row execute function set_updated_at();
create trigger t_proj_upd  before update on projeto     for each row execute function set_updated_at();
create trigger t_evt_upd   before update on evento      for each row execute function set_updated_at();

-- =====================================================================
-- 12. VIEWS PÚBLICAS (Vitrine) — leitura anônima segura
-- =====================================================================
create or replace view v_projeto_publico as
  select p.id, p.nome, p.status, p.progresso, d.nome as dimensao, d.cor
  from projeto p left join dimensao d on d.id = p.dimensao_id;

-- =====================================================================
-- 13. ROW LEVEL SECURITY
-- =====================================================================
alter table dimensao              enable row level security;
alter table objetivo_estrategico  enable row level security;
alter table instituicao           enable row level security;
alter table pessoa                enable row level security;
alter table comite                enable row level security;
alter table pessoa_comite         enable row level security;
alter table projeto               enable row level security;
alter table projeto_equipe        enable row level security;
alter table acao                  enable row level security;
alter table indicador             enable row level security;
alter table fonte_recurso         enable row level security;
alter table reuniao               enable row level security;
alter table reuniao_pauta         enable row level security;
alter table reuniao_participante  enable row level security;
alter table ata                   enable row level security;
alter table evento                enable row level security;
alter table evento_organizador    enable row level security;
alter table contribuicao_cidadao  enable row level security;
alter table profile               enable row level security;

-- ---- 13.1 Leitura PÚBLICA (anon + authenticated) para a Vitrine ----
create policy pub_read_dim   on dimensao             for select using (true);
create policy pub_read_obj   on objetivo_estrategico for select using (true);
create policy pub_read_evt   on evento               for select using (true);
create policy pub_read_evto  on evento_organizador   for select using (true);

-- Cidadão pode ENVIAR contribuição (insert anônimo), mas não ler
create policy pub_insert_contrib on contribuicao_cidadao
  for insert with check (true);

-- ---- 13.2 Leitura RESTRITA (apenas autenticados) ----
-- Aplica a todas as tabelas de governança:
create policy auth_read_inst   on instituicao          for select using (auth.role() = 'authenticated');
create policy auth_read_pes    on pessoa               for select using (auth.role() = 'authenticated');
create policy auth_read_com    on comite               for select using (auth.role() = 'authenticated');
create policy auth_read_pc     on pessoa_comite        for select using (auth.role() = 'authenticated');
create policy auth_read_proj   on projeto              for select using (auth.role() = 'authenticated');
create policy auth_read_pe     on projeto_equipe       for select using (auth.role() = 'authenticated');
create policy auth_read_acao   on acao                 for select using (auth.role() = 'authenticated');
create policy auth_read_ind    on indicador            for select using (auth.role() = 'authenticated');
create policy auth_read_fr     on fonte_recurso        for select using (auth.role() = 'authenticated');
create policy auth_read_reu    on reuniao              for select using (auth.role() = 'authenticated');
create policy auth_read_rp     on reuniao_pauta        for select using (auth.role() = 'authenticated');
create policy auth_read_rpa    on reuniao_participante for select using (auth.role() = 'authenticated');
create policy auth_read_ata    on ata                  for select using (auth.role() = 'authenticated');
create policy auth_read_contr  on contribuicao_cidadao for select using (auth.role() = 'authenticated');

-- ---- 13.3 Escrita (insert/update/delete) para papéis editores ----
--  Macro aplicado a cada tabela editável:
--     for all using (can_edit()) with check (can_edit())
create policy edit_inst  on instituicao          for all using (can_edit()) with check (can_edit());
create policy edit_pes   on pessoa               for all using (can_edit()) with check (can_edit());
create policy edit_com   on comite               for all using (can_edit()) with check (can_edit());
create policy edit_pc    on pessoa_comite        for all using (can_edit()) with check (can_edit());
create policy edit_proj  on projeto              for all using (can_edit()) with check (can_edit());
create policy edit_pe    on projeto_equipe       for all using (can_edit()) with check (can_edit());
create policy edit_acao  on acao                 for all using (can_edit()) with check (can_edit());
create policy edit_ind   on indicador            for all using (can_edit()) with check (can_edit());
create policy edit_fr    on fonte_recurso        for all using (can_edit()) with check (can_edit());
create policy edit_reu   on reuniao              for all using (can_edit()) with check (can_edit());
create policy edit_rp    on reuniao_pauta        for all using (can_edit()) with check (can_edit());
create policy edit_rpa   on reuniao_participante for all using (can_edit()) with check (can_edit());
create policy edit_ata   on ata                  for all using (can_edit()) with check (can_edit());
create policy edit_evt   on evento               for all using (can_edit()) with check (can_edit());
create policy edit_evto  on evento_organizador   for all using (can_edit()) with check (can_edit());
create policy edit_dim   on dimensao             for all using (can_edit()) with check (can_edit());
create policy edit_obj   on objetivo_estrategico for all using (can_edit()) with check (can_edit());
create policy edit_contr on contribuicao_cidadao for update using (can_edit()) with check (can_edit());

-- ---- 13.4 Perfis: cada um lê o próprio; admin gerencia todos ----
create policy prof_self_read on profile for select using (id = auth.uid() or auth_role() = 'admin');
create policy prof_admin_all on profile for all    using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- =====================================================================
--  FIM DO SCHEMA
-- =====================================================================
