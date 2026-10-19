-- Rodada de Negócios — schema base (0001)
-- Postgres puro, sem dependência de provedor. Idempotente.
-- Regras de negócio em rodada/docs/decisoes.md.

create schema if not exists rodada;
set search_path to rodada, public;

-- ---------------------------------------------------------------------------
-- Tipos
-- ---------------------------------------------------------------------------
do $$ begin
  create type perfil as enum ('admin','regional','cpv','cna','cne','fi','grupo','fornecedor');
exception when duplicate_object then null; end $$;

do $$ begin
  create type fase as enum ('pre','evento','pos','encerrada');
exception when duplicate_object then null; end $$;

do $$ begin
  create type status_linha as enum ('rascunho','fechado','cancelado');
exception when duplicate_object then null; end $$;

-- Consultor = perfil interno que pode ser responsável por uma linha
create or replace function perfis_consultor() returns perfil[] language sql immutable as
$$ select array['cpv','cna','cne','fi','regional','admin']::perfil[] $$;

-- ---------------------------------------------------------------------------
-- Rodada e cadastro da rodada
-- ---------------------------------------------------------------------------
create table if not exists rodada (
  id            serial primary key,
  codigo        text not null unique,            -- ex.: 2026-12
  nome          text not null,                   -- ex.: Rodada de Negócios — Dezembro 2026
  ativa         boolean not null default false,  -- só uma ativa por vez (índice abaixo)
  criada_em     timestamptz not null default now()
);
create unique index if not exists rodada_ativa_unica on rodada (ativa) where ativa;

-- Fases com datas e quem edita em cada uma (regra exata definida perto do evento)
create table if not exists rodada_fase (
  rodada_id     int not null references rodada(id) on delete cascade,
  fase          fase not null,
  inicio        timestamptz not null,
  fim           timestamptz not null,
  perfis_editam perfil[] not null default '{}',
  primary key (rodada_id, fase),
  check (fim > inicio)
);

-- Categorias da rodada (cadastro, não código): ordem, ícone, unidade secundária opcional
create table if not exists categoria (
  id                  serial primary key,
  rodada_id           int not null references rodada(id) on delete cascade,
  codigo              text not null,              -- PECAS, ACESSORIOS, ENVIOS_FULL, BPRO, CIRC_AUTOPECAS, SHELL, OUTROS_DFS
  nome                text not null,
  ordem               int not null default 0,
  icone               text,
  unidade_secundaria  text,                       -- ex.: 'litros'
  conta_no_total      boolean not null default true,
  unique (rodada_id, codigo)
);

-- Matriz perfil × categoria: quais perfis podem ser responsáveis por linha de cada categoria
create table if not exists perfil_categoria (
  categoria_id  int not null references categoria(id) on delete cascade,
  perfil        perfil not null,
  primary key (categoria_id, perfil)
);

-- ---------------------------------------------------------------------------
-- Hierarquia: Marca → Regional → Setor → (CPV) → Grupo → Dealer
-- Cadastro mestre, válido entre rodadas; a carteira (consultor × grupo) é por rodada.
-- ---------------------------------------------------------------------------
create table if not exists marca (
  codigo  text primary key,                       -- FIAT, CJDR, PSA
  nome    text not null,
  ordem   int not null default 0
);

create table if not exists regional (
  codigo        text primary key,                 -- 11..15, 21..24
  nome          text not null,
  marca_codigo  text not null references marca(codigo)
);

create table if not exists setor (
  codigo          text primary key,               -- 132, 122, ...
  nome            text,
  regional_codigo text not null references regional(codigo)
);

create table if not exists grupo (
  codigo          text primary key,               -- código do grupo na marca (um grupo por marca)
  nome            text not null,
  marca_codigo    text not null references marca(codigo),
  regional_codigo text not null references regional(codigo),
  setor_codigo    text references setor(codigo),
  ativo           boolean not null default true
);

create table if not exists dealer (
  codigo        text primary key,                 -- código do dealer no CSPS
  nome          text not null,
  grupo_codigo  text not null references grupo(codigo),
  cidade        text,
  uf            text,
  ativo         boolean not null default true
);
create index if not exists dealer_grupo on dealer (grupo_codigo);

-- Consultores (pessoas do time interno). Perfil define as categorias que conduzem via perfil_categoria.
create table if not exists consultor (
  id              serial primary key,
  nome            text not null,
  perfil          perfil not null check (perfil = any (perfis_consultor())),
  setor_codigo    text references setor(codigo),
  regional_codigo text references regional(codigo),
  ativo           boolean not null default true
);

-- Carteira por rodada: consultor × grupo
create table if not exists carteira (
  rodada_id     int not null references rodada(id) on delete cascade,
  consultor_id  int not null references consultor(id),
  grupo_codigo  text not null references grupo(codigo),
  primary key (rodada_id, consultor_id, grupo_codigo)
);
create index if not exists carteira_grupo on carteira (rodada_id, grupo_codigo);

-- Fornecedores (DFS/DSH): catálogo próprio, login próprio
create table if not exists fornecedor (
  id      serial primary key,
  codigo  text not null unique,
  nome    text not null,
  ativo   boolean not null default true
);

-- ---------------------------------------------------------------------------
-- Usuários e acesso (a autenticação em si fica no app; aqui só identidade e escopo)
-- ---------------------------------------------------------------------------
create table if not exists usuario (
  id              serial primary key,
  email           text not null unique,
  nome            text not null,
  perfil          perfil not null,
  consultor_id    int references consultor(id),      -- perfis cpv/cna/cne/fi
  fornecedor_id   int references fornecedor(id),     -- perfil fornecedor
  regional_codigo text references regional(codigo),  -- perfil regional
  ativo           boolean not null default true,
  convidado_em    timestamptz not null default now(),
  ultimo_acesso   timestamptz,
  check (perfil <> 'fornecedor' or fornecedor_id is not null),
  check (perfil <> 'regional'   or regional_codigo is not null),
  check (perfil not in ('cpv','cna','cne','fi') or consultor_id is not null)
);

-- Perfil grupo: um login pode ver vários grupos (um por marca do mesmo grupo econômico)
create table if not exists usuario_grupo (
  usuario_id    int not null references usuario(id) on delete cascade,
  grupo_codigo  text not null references grupo(codigo),
  primary key (usuario_id, grupo_codigo)
);

-- ---------------------------------------------------------------------------
-- Itens da rodada (PNs Stellantis e itens de fornecedor) e base 21 pontos
-- ---------------------------------------------------------------------------
create table if not exists item (
  id              serial primary key,
  rodada_id       int not null references rodada(id) on delete cascade,
  pn              text not null,
  descricao       text,
  categoria_id    int not null references categoria(id),
  fornecedor_id   int references fornecedor(id),      -- null = item Stellantis
  familia         text,
  qme             int not null default 1 check (qme >= 1),
  preco_unit      numeric(14,2) not null check (preco_unit >= 0),   -- preço da condição da rodada
  condicao        text,                                              -- descrição da condição promocional
  desconto_pct    numeric(6,2),
  minimo_qtd      int,                                               -- mínimo da condição, se houver
  qtd_secundaria  numeric(12,3),                                     -- ex.: litros por unidade (categoria com unidade secundária)
  unique (rodada_id, pn, fornecedor_id)
);
create index if not exists item_categoria on item (rodada_id, categoria_id);

-- Base 21 pontos: dealer × item. Sugestão calculada na gravação.
create table if not exists demanda (
  rodada_id   int not null references rodada(id) on delete cascade,
  dealer_codigo text not null references dealer(codigo),
  item_id     int not null references item(id) on delete cascade,
  demanda     numeric(12,2) not null default 0,
  estoque     numeric(12,2) not null default 0,
  transito    numeric(12,2) not null default 0,
  sugestao    int not null default 0,          -- (demanda - estoque - transito) arredondado p/ cima ao QME, >= 0
  primary key (rodada_id, dealer_codigo, item_id)
);
create index if not exists demanda_item on demanda (rodada_id, item_id);

create or replace function calc_sugestao(p_demanda numeric, p_estoque numeric, p_transito numeric, p_qme int)
returns int language sql immutable as $$
  select case
    when (p_demanda - p_estoque - p_transito) <= 0 then 0
    else (ceil((p_demanda - p_estoque - p_transito) / greatest(p_qme,1)) * greatest(p_qme,1))::int
  end
$$;

create or replace function demanda_bi() returns trigger language plpgsql
  set search_path = rodada, public as $$
declare v_qme int;
begin
  select qme into v_qme from item where id = new.item_id;
  new.sugestao := calc_sugestao(new.demanda, new.estoque, new.transito, coalesce(v_qme,1));
  return new;
end $$;
drop trigger if exists demanda_sugestao on demanda;
create trigger demanda_sugestao before insert or update on demanda
  for each row execute function demanda_bi();

-- ---------------------------------------------------------------------------
-- Metas: grupo × categoria (R$). Metas de consultor para rankings.
-- ---------------------------------------------------------------------------
create table if not exists meta_grupo (
  rodada_id     int not null references rodada(id) on delete cascade,
  grupo_codigo  text not null references grupo(codigo),
  categoria_id  int not null references categoria(id),
  valor         numeric(14,2) not null check (valor >= 0),
  primary key (rodada_id, grupo_codigo, categoria_id)
);

create table if not exists meta_consultor (
  id            serial primary key,
  rodada_id     int not null references rodada(id) on delete cascade,
  consultor_id  int not null references consultor(id),
  categoria_id  int references categoria(id),      -- null = total
  valor         numeric(14,2) not null check (valor >= 0)
);
create unique index if not exists meta_consultor_chave on meta_consultor (rodada_id, consultor_id, coalesce(categoria_id, 0));

-- ---------------------------------------------------------------------------
-- Pedidos. Uma linha = grupo × item × dealer destino × quantidade × responsável.
-- O "pedido do grupo" é a soma das linhas; não há cabeçalho separado.
-- ---------------------------------------------------------------------------
create table if not exists pedido_linha (
  id              bigserial primary key,
  rodada_id       int not null references rodada(id) on delete cascade,
  grupo_codigo    text not null references grupo(codigo),
  item_id         int not null references item(id),
  dealer_codigo   text not null references dealer(codigo),     -- destino de entrega
  quantidade      int not null check (quantidade > 0),
  preco_unit      numeric(14,2) not null,                      -- foto do preço no momento da gravação
  valor           numeric(14,2) generated always as (quantidade * preco_unit) stored,
  responsavel_id  int references consultor(id),                -- consultor que conduziu (null = grupo ou fornecedor)
  status          status_linha not null default 'rascunho',
  fase            fase not null,                               -- fase em que foi registrada
  motivo_ajuste   text,                                        -- obrigatório no pós-evento
  versao          int not null default 1,                      -- bloqueio otimista (CPV e grupo na mesma tela)
  criado_por      int not null references usuario(id),
  criado_em       timestamptz not null default now(),
  atualizado_por  int references usuario(id),
  atualizado_em   timestamptz not null default now(),
  fechado_em      timestamptz,
  unique (rodada_id, grupo_codigo, item_id, dealer_codigo)     -- uma linha por grupo×PN×destino; quantidade editada na linha
);
create index if not exists pedido_grupo  on pedido_linha (rodada_id, grupo_codigo, status);
create index if not exists pedido_item   on pedido_linha (rodada_id, item_id);
create index if not exists pedido_resp   on pedido_linha (rodada_id, responsavel_id);

-- Validações de gravação: destino pertence ao grupo; quantidade múltipla do QME; responsável autorizado na categoria.
create or replace function pedido_linha_bi() returns trigger language plpgsql
  set search_path = rodada, public as $$
declare v_item item%rowtype; v_grupo text; v_perfil perfil; v_ok boolean;
begin
  select * into v_item from item where id = new.item_id;
  if v_item.rodada_id <> new.rodada_id then
    raise exception 'Item % não pertence à rodada %', new.item_id, new.rodada_id;
  end if;
  select grupo_codigo into v_grupo from dealer where codigo = new.dealer_codigo;
  if v_grupo is distinct from new.grupo_codigo then
    raise exception 'Dealer % não pertence ao grupo %', new.dealer_codigo, new.grupo_codigo;
  end if;
  if new.quantidade % v_item.qme <> 0 then
    raise exception 'Quantidade % não é múltiplo do QME % do PN %', new.quantidade, v_item.qme, v_item.pn;
  end if;
  if v_item.minimo_qtd is not null and new.quantidade < v_item.minimo_qtd then
    raise exception 'Quantidade % abaixo do mínimo % do PN %', new.quantidade, v_item.minimo_qtd, v_item.pn;
  end if;
  if new.responsavel_id is not null then
    select perfil into v_perfil from consultor where id = new.responsavel_id;
    select exists (select 1 from perfil_categoria where categoria_id = v_item.categoria_id and perfil = v_perfil) into v_ok;
    if not v_ok then
      raise exception 'Perfil % não pode conduzir a categoria do PN %', v_perfil, v_item.pn;
    end if;
  end if;
  if tg_op = 'INSERT' then
    new.preco_unit := coalesce(new.preco_unit, v_item.preco_unit);
  else
    if new.versao <> old.versao + 1 then
      raise exception 'Linha % foi alterada por outra pessoa (versão %). Recarregue.', old.id, old.versao
        using errcode = 'serialization_failure';
    end if;
    new.atualizado_em := now();
  end if;
  if new.status = 'fechado' and new.fechado_em is null then new.fechado_em := now(); end if;
  return new;
end $$;
drop trigger if exists pedido_linha_valida on pedido_linha;
create trigger pedido_linha_valida before insert or update on pedido_linha
  for each row execute function pedido_linha_bi();

-- Trilha: toda alteração de linha
create table if not exists auditoria (
  id          bigserial primary key,
  tabela      text not null,
  registro_id bigint not null,
  acao        text not null,          -- insert | update | delete
  usuario_id  int,
  antes       jsonb,
  depois      jsonb,
  em          timestamptz not null default now()
);
create index if not exists auditoria_registro on auditoria (tabela, registro_id);

create or replace function auditoria_pedido() returns trigger language plpgsql
  set search_path = rodada, public as $$
begin
  if tg_op = 'DELETE' then
    insert into auditoria (tabela, registro_id, acao, usuario_id, antes)
      values ('pedido_linha', old.id, 'delete', old.atualizado_por, to_jsonb(old));
    return old;
  end if;
  insert into auditoria (tabela, registro_id, acao, usuario_id, antes, depois)
    values ('pedido_linha', new.id, lower(tg_op), coalesce(new.atualizado_por, new.criado_por),
            case when tg_op = 'UPDATE' then to_jsonb(old) end, to_jsonb(new));
  return new;
end $$;
drop trigger if exists pedido_linha_auditoria on pedido_linha;
create trigger pedido_linha_auditoria after insert or update or delete on pedido_linha
  for each row execute function auditoria_pedido();

-- ---------------------------------------------------------------------------
-- Cargas (registro) e pós-evento (colocado no CSPS)
-- ---------------------------------------------------------------------------
create table if not exists carga (
  id          serial primary key,
  rodada_id   int references rodada(id) on delete cascade,
  tipo        text not null,          -- hierarquia | carteira | usuarios | base21 | catalogo_fornecedor | metas | csps
  arquivo     text,
  linhas      int,
  erros       jsonb,
  usuario_id  int references usuario(id),
  em          timestamptz not null default now()
);

create table if not exists csps_colocado (
  id              bigserial primary key,
  rodada_id       int not null references rodada(id) on delete cascade,
  carga_id        int references carga(id),
  dealer_codigo   text not null,                  -- sem FK: a extração pode trazer dealer fora do cadastro (vira exceção)
  pn              text not null,
  quantidade      int not null,
  numero_pedido   text,
  data_pedido     date,
  unique (rodada_id, dealer_codigo, pn, numero_pedido)
);
create index if not exists csps_chave on csps_colocado (rodada_id, dealer_codigo, pn);

-- ---------------------------------------------------------------------------
-- Visões de leitura (o painel e as telas leem daqui; nunca da tabela bruta no front)
-- ---------------------------------------------------------------------------

-- Pedido fechado agregado por grupo × categoria (base de todo atingimento)
create or replace view v_pedido_grupo_categoria as
select p.rodada_id, p.grupo_codigo, i.categoria_id,
       sum(p.valor) as valor,
       sum(p.quantidade) as quantidade,
       sum(p.quantidade * coalesce(i.qtd_secundaria, 0)) as qtd_secundaria
from pedido_linha p join item i on i.id = p.item_id
where p.status = 'fechado'
group by p.rodada_id, p.grupo_codigo, i.categoria_id;

-- Atingimento grupo × categoria (meta pode não existir: atingimento nulo)
create or replace view v_atingimento_grupo as
select c.rodada_id, g.codigo as grupo_codigo, g.nome as grupo, g.marca_codigo, g.regional_codigo, g.setor_codigo,
       c.id as categoria_id, c.codigo as categoria, c.ordem,
       coalesce(m.valor, 0) as meta,
       coalesce(v.valor, 0) as realizado,
       case when coalesce(m.valor,0) > 0 then round(coalesce(v.valor,0) / m.valor * 100, 1) end as pct,
       coalesce(v.qtd_secundaria, 0) as qtd_secundaria
from categoria c
cross join grupo g
left join meta_grupo m on m.rodada_id = c.rodada_id and m.grupo_codigo = g.codigo and m.categoria_id = c.id
left join v_pedido_grupo_categoria v on v.rodada_id = c.rodada_id and v.grupo_codigo = g.codigo and v.categoria_id = c.id
where g.ativo and (m.valor is not null or v.valor is not null);

-- Atingimento por consultor (ranking): realizado = linhas fechadas sob sua responsabilidade
create or replace view v_atingimento_consultor as
select p.rodada_id, k.id as consultor_id, k.nome, k.perfil, k.setor_codigo, k.regional_codigo,
       i.categoria_id, sum(p.valor) as realizado
from pedido_linha p
join item i on i.id = p.item_id
join consultor k on k.id = p.responsavel_id
where p.status = 'fechado'
group by p.rodada_id, k.id, k.nome, k.perfil, k.setor_codigo, k.regional_codigo, i.categoria_id;

-- Realizado por fornecedor (top fornecedores)
create or replace view v_realizado_fornecedor as
select p.rodada_id, f.id as fornecedor_id, f.nome, sum(p.valor) as realizado
from pedido_linha p join item i on i.id = p.item_id join fornecedor f on f.id = i.fornecedor_id
where p.status = 'fechado'
group by p.rodada_id, f.id, f.nome;

-- Potencial restante por grupo × item (número vivo da tela de negociação)
create or replace view v_potencial as
select d.rodada_id, dl.grupo_codigo, d.dealer_codigo, d.item_id, i.pn, i.categoria_id,
       d.demanda, d.estoque, d.transito, d.sugestao, i.qme, i.preco_unit,
       coalesce(sum(p.quantidade) filter (where p.status <> 'cancelado'), 0) as pedido,
       d.sugestao - coalesce(sum(p.quantidade) filter (where p.status <> 'cancelado'), 0) as restante
from demanda d
join item i on i.id = d.item_id
join dealer dl on dl.codigo = d.dealer_codigo
left join pedido_linha p on p.rodada_id = d.rodada_id and p.item_id = d.item_id and p.dealer_codigo = d.dealer_codigo
group by d.rodada_id, dl.grupo_codigo, d.dealer_codigo, d.item_id, i.pn, i.categoria_id,
         d.demanda, d.estoque, d.transito, d.sugestao, i.qme, i.preco_unit;

-- Conciliação evento × colocado no CSPS, por dealer × PN
create or replace view v_conciliacao as
with evento as (
  select p.rodada_id, p.dealer_codigo, i.pn, sum(p.quantidade) as qtd_evento
  from pedido_linha p join item i on i.id = p.item_id
  where p.status = 'fechado' and i.fornecedor_id is null
  group by p.rodada_id, p.dealer_codigo, i.pn
), csps as (
  select rodada_id, dealer_codigo, pn, sum(quantidade) as qtd_csps
  from csps_colocado group by rodada_id, dealer_codigo, pn
)
select coalesce(e.rodada_id, c.rodada_id) as rodada_id,
       coalesce(e.dealer_codigo, c.dealer_codigo) as dealer_codigo,
       coalesce(e.pn, c.pn) as pn,
       coalesce(e.qtd_evento, 0) as qtd_evento,
       coalesce(c.qtd_csps, 0) as qtd_csps,
       case
         when e.pn is null then 'sem_correspondencia'      -- colocado no CSPS sem pedido no evento
         when c.pn is null then 'nao_colocado'
         when c.qtd_csps < e.qtd_evento then 'parcial'
         when c.qtd_csps > e.qtd_evento then 'divergencia'
         else 'ok'
       end as situacao
from evento e full join csps c on c.rodada_id = e.rodada_id and c.dealer_codigo = e.dealer_codigo and c.pn = e.pn;

-- Exportação consolidada para o CSPS: dealer × PN × quantidade × condição (itens Stellantis fechados)
create or replace view v_exportacao_csps as
select p.rodada_id, g.marca_codigo, g.regional_codigo, p.grupo_codigo, g.nome as grupo,
       p.dealer_codigo, dl.nome as dealer, i.pn, i.descricao, c.codigo as categoria,
       sum(p.quantidade) as quantidade, i.preco_unit, i.condicao, sum(p.valor) as valor
from pedido_linha p
join item i on i.id = p.item_id
join categoria c on c.id = i.categoria_id
join grupo g on g.codigo = p.grupo_codigo
join dealer dl on dl.codigo = p.dealer_codigo
where p.status = 'fechado' and i.fornecedor_id is null
group by p.rodada_id, g.marca_codigo, g.regional_codigo, p.grupo_codigo, g.nome, p.dealer_codigo, dl.nome,
         i.pn, i.descricao, c.codigo, i.preco_unit, i.condicao;

-- Usuário de leitura para o Power BI (contingência do telão): criar fora da migration, com senha própria:
--   create role bi_leitura login password '...'; grant usage on schema rodada to bi_leitura;
--   grant select on all tables in schema rodada to bi_leitura;
