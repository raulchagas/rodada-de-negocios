-- Teste de fumaça das regras do 0001 (rodar em banco limpo após a migration).
-- psql -v ON_ERROR_STOP=1 -f db/tests/smoke.sql
set search_path to rodada, public;
begin;
truncate rodada, marca, consultor, fornecedor, usuario, auditoria, carga restart identity cascade;

insert into rodada (codigo, nome, ativa) values ('2026-12', 'Rodada Dez/2026', true);
insert into categoria (rodada_id, codigo, nome, ordem, unidade_secundaria) values
  (1,'PECAS','Peças',1,null),(1,'ACESSORIOS','Acessórios',2,null),(1,'SHELL','Shell',6,'litros'),(1,'OUTROS_DFS','Outros DFS',7,null);
insert into perfil_categoria select id, p from categoria, unnest(array['cpv','admin','regional']::perfil[]) p where rodada_id = 1;
insert into perfil_categoria select id, 'cna' from categoria where codigo = 'PECAS';
insert into perfil_categoria select id, 'fi'  from categoria where codigo = 'ACESSORIOS';

insert into marca values ('FIAT','Fiat',1),('CJDR','Jeep/Dodge/RAM',2);
insert into regional values ('13','Regional 13','FIAT'),('23','Regional 23','CJDR');
insert into setor values ('132','Setor 132','13'),('231','Setor 231','23');
insert into grupo (codigo,nome,marca_codigo,regional_codigo,setor_codigo) values
  ('G0001','GRUPO EXEMPLO','FIAT','13','132'),('G0002','GRUPO EXEMPLO CJDR','CJDR','23','231');
insert into dealer (codigo,nome,grupo_codigo) values ('000123','MATRIZ','G0001'),('000124','FILIAL','G0001'),('000987','JEEP','G0002');
insert into consultor (nome,perfil,setor_codigo,regional_codigo) values ('CPV EX','cpv','132','13'),('FI EX','fi',null,'13'),('CNA EX','cna','132','13');
insert into fornecedor (codigo,nome) values ('FORN01','FORNECEDOR X');
insert into usuario (email,nome,perfil) values ('admin@x','ADMIN','admin');

insert into item (rodada_id,pn,descricao,categoria_id,qme,preco_unit,condicao) values
  (1,'77366001','FILTRO',(select id from categoria where codigo='PECAS'),12,18.90,'15%'),
  (1,'52033120','OLEO',(select id from categoria where codigo='SHELL'),24,32.50,'10%'),
  (1,'ACC-1','TAPETE',(select id from categoria where codigo='ACESSORIOS'),1,120,null);
update item set qtd_secundaria = 1 where pn = '52033120';
insert into item (rodada_id,pn,descricao,categoria_id,fornecedor_id,qme,preco_unit) values
  (1,'FX-100','ADITIVO',(select id from categoria where codigo='OUTROS_DFS'),1,12,24.90);

-- Sugestão: (120-30-12)=78 -> QME 12 -> 84; (60-10-0)=50 -> 60; negativa -> 0
insert into demanda (rodada_id,dealer_codigo,item_id,demanda,estoque,transito) values
  (1,'000123',1,120,30,12),(1,'000124',1,60,10,0),(1,'000123',2,10,100,0);
do $$ begin
  assert (select sugestao from demanda where dealer_codigo='000123' and item_id=1) = 84, 'sugestão 84';
  assert (select sugestao from demanda where dealer_codigo='000124' and item_id=1) = 60, 'sugestão 60';
  assert (select sugestao from demanda where dealer_codigo='000123' and item_id=2) = 0,  'sugestão 0';
end $$;

insert into meta_grupo values (1,'G0001',(select id from categoria where codigo='PECAS'),2000),
                              (1,'G0001',(select id from categoria where codigo='ACESSORIOS'),500);

-- Linha válida (CPV, PECAS, múltiplo de 12)
insert into pedido_linha (rodada_id,grupo_codigo,item_id,dealer_codigo,quantidade,preco_unit,responsavel_id,fase,criado_por)
  values (1,'G0001',1,'000123',48,18.90,1,'evento',1);

-- Quantidade fora do QME -> erro
do $$ begin
  insert into pedido_linha (rodada_id,grupo_codigo,item_id,dealer_codigo,quantidade,preco_unit,responsavel_id,fase,criado_por)
    values (1,'G0001',1,'000124',50,18.90,1,'evento',1);
  raise exception 'deveria ter falhado (QME)';
exception when others then
  if sqlerrm like '%deveria%' then raise; end if;
  raise notice 'ok QME: %', sqlerrm;
end $$;

-- Destino de outro grupo -> erro
do $$ begin
  insert into pedido_linha (rodada_id,grupo_codigo,item_id,dealer_codigo,quantidade,preco_unit,responsavel_id,fase,criado_por)
    values (1,'G0001',1,'000987',12,18.90,1,'evento',1);
  raise exception 'deveria ter falhado (destino)';
exception when others then
  if sqlerrm like '%deveria%' then raise; end if;
  raise notice 'ok destino: %', sqlerrm;
end $$;

-- F&I conduzindo PECAS -> erro; F&I conduzindo ACESSORIOS -> ok
do $$ begin
  insert into pedido_linha (rodada_id,grupo_codigo,item_id,dealer_codigo,quantidade,preco_unit,responsavel_id,fase,criado_por)
    values (1,'G0001',1,'000124',12,18.90,2,'evento',1);
  raise exception 'deveria ter falhado (F&I em peças)';
exception when others then
  if sqlerrm like '%deveria%' then raise; end if;
  raise notice 'ok perfil: %', sqlerrm;
end $$;
insert into pedido_linha (rodada_id,grupo_codigo,item_id,dealer_codigo,quantidade,preco_unit,responsavel_id,fase,criado_por)
  values (1,'G0001',3,'000123',2,120,2,'evento',1);

-- Bloqueio otimista: update sem incrementar versão -> erro; com versão certa -> ok
do $$ begin
  update pedido_linha set quantidade = 60, atualizado_por = 1 where id = 1;
  raise exception 'deveria ter falhado (versão)';
exception when others then
  if sqlerrm like '%deveria%' then raise; end if;
  raise notice 'ok versão: %', sqlerrm;
end $$;
update pedido_linha set quantidade = 60, versao = versao + 1, atualizado_por = 1 where id = 1;

-- Potencial vivo: sugestão 84, pedido 60 -> restante 24 (rascunho conta no potencial)
do $$ begin
  assert (select restante from v_potencial where dealer_codigo='000123' and item_id=1) = 24, 'restante 24';
end $$;

-- Atingimento: só fechado conta. Antes de fechar: realizado 0.
do $$ begin
  assert (select realizado from v_atingimento_grupo where grupo_codigo='G0001' and categoria='PECAS') = 0, 'realizado 0 antes de fechar';
end $$;
update pedido_linha set status='fechado', versao = versao + 1, atualizado_por = 1 where rodada_id = 1;  -- inserts rejeitados consomem id
do $$ begin
  assert (select realizado from v_atingimento_grupo where grupo_codigo='G0001' and categoria='PECAS') = 1134.00, 'realizado 60*18.90';
  assert (select pct from v_atingimento_grupo where grupo_codigo='G0001' and categoria='PECAS') = 56.7, 'pct 56,7';
  assert (select realizado from v_atingimento_consultor where consultor_id = 2) = 240, 'F&I 240';
  assert (select count(*) from auditoria where tabela='pedido_linha') >= 4, 'auditoria';
end $$;

-- Conciliação: CSPS colocou 48 de 60 -> parcial; PN estranho -> sem_correspondencia
insert into csps_colocado (rodada_id,dealer_codigo,pn,quantidade,numero_pedido) values (1,'000123','77366001',48,'C1'),(1,'000123','ZZZ',5,'C2');
do $$ begin
  assert (select situacao from v_conciliacao where pn='77366001') = 'parcial', 'parcial';
  assert (select situacao from v_conciliacao where pn='ZZZ') = 'sem_correspondencia', 'sem correspondência';
  assert (select count(*) from v_exportacao_csps) = 2, 'exportação: filtro + tapete (itens Stellantis fechados)';
end $$;

select 'SMOKE_OK' as resultado;
rollback;
