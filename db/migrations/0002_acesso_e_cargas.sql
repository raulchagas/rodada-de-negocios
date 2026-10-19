-- Rodada de Negócios — 0002: controle de migrations, login por convite e área de staging das cargas.
set search_path to rodada, public;

-- Controle de migrations aplicadas (usado por web/scripts/migrar.mjs)
create table if not exists migracao (
  nome        text primary key,
  aplicada_em timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Login por convite: token de uso único (link mágico) e sessão. Guardamos só o hash.
-- ---------------------------------------------------------------------------
create table if not exists token_login (
  hash        text primary key,
  usuario_id  int not null references usuario(id) on delete cascade,
  criado_em   timestamptz not null default now(),
  expira_em   timestamptz not null,
  usado_em    timestamptz,
  gerado_por  int references usuario(id)          -- admin que gerou o link (null = pedido pelo próprio usuário)
);
create index if not exists token_login_usuario on token_login (usuario_id);

create table if not exists sessao (
  hash        text primary key,
  usuario_id  int not null references usuario(id) on delete cascade,
  criada_em   timestamptz not null default now(),
  expira_em   timestamptz not null,
  ultimo_uso  timestamptz not null default now()
);
create index if not exists sessao_usuario on sessao (usuario_id);

-- ---------------------------------------------------------------------------
-- Cargas: o navegador lê a planilha e envia as linhas em lotes para carga_linha;
-- aplicar_carga() valida e aplica tudo numa transação (tudo ou nada).
-- ---------------------------------------------------------------------------
alter table carga add column if not exists status text not null default 'recebendo';  -- recebendo | aplicada | rejeitada
alter table carga add column if not exists abas jsonb;                                 -- resumo por aba: {aba: linhas}

create table if not exists carga_linha (
  carga_id  int not null references carga(id) on delete cascade,
  aba       text not null,
  n         int not null,           -- número da linha na planilha (cabeçalho = 1)
  dados     jsonb not null,
  primary key (carga_id, aba, n)
);
