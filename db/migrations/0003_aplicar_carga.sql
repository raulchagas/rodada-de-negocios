-- Rodada de Negócios — 0003: validação e aplicação das cargas (docs/cargas.md).
-- aplicar_carga(carga_id): lê carga_linha, valida todas as abas, e só aplica se não houver erro (tudo ou nada).
set search_path to rodada, public;

-- Conversões tolerantes: devolvem null quando o texto não é válido (vira erro na validação)
create or replace function txt(j jsonb, k text) returns text language sql immutable as $$
  select nullif(btrim(j ->> k), '')
$$;

create or replace function num(v text) returns numeric language plpgsql immutable as $$
declare s text := btrim(coalesce(v, ''));
begin
  if s = '' then return null; end if;
  s := replace(replace(s, 'R$', ''), ' ', '');
  if s ~ ',' then s := replace(replace(s, '.', ''), ',', '.'); end if;   -- 1.234,56 -> 1234.56
  return s::numeric;
exception when others then return null;
end $$;

create or replace function inteiro(v text) returns int language plpgsql immutable as $$
declare n numeric := num(v);
begin
  if n is null or n <> trunc(n) then return null; end if;
  return n::int;
exception when others then return null;
end $$;

create or replace function data_br(v text) returns date language plpgsql immutable as $$
declare s text := btrim(coalesce(v, ''));
begin
  if s = '' then return null; end if;
  if s ~ '^\d{2}/\d{2}/\d{4}$' then return to_date(s, 'DD/MM/YYYY'); end if;
  return left(s, 10)::date;                                            -- 2026-12-15 ou 2026-12-15T00:00:00Z
exception when others then return null;
end $$;

create or replace function aplicar_carga(p_carga int) returns jsonb language plpgsql
  set search_path = rodada, public as $$
declare
  v_rodada int;
  v_usuario int;
  v_total int;
  v_resumo jsonb;
  v_erros jsonb;
begin
  select rodada_id, usuario_id into v_rodada, v_usuario from carga where id = p_carga and status = 'recebendo' for update;
  if not found then
    raise exception 'Carga % não existe ou já foi processada', p_carga;
  end if;

  create temp table if not exists _erro (aba text, n int, msg text) on commit drop;
  truncate _erro;

  -- Linhas por aba, com campos já extraídos (uma temp table por aba simplifica a validação e a aplicação)
  -- ---------------------------------------------------------------- hierarquia
  create temp table _h on commit drop as
  select n, txt(dados,'marca_codigo') marca_codigo, txt(dados,'marca_nome') marca_nome,
         txt(dados,'regional_codigo') regional_codigo, txt(dados,'regional_nome') regional_nome,
         txt(dados,'setor_codigo') setor_codigo, txt(dados,'setor_nome') setor_nome,
         txt(dados,'grupo_codigo') grupo_codigo, txt(dados,'grupo_nome') grupo_nome,
         txt(dados,'dealer_codigo') dealer_codigo, txt(dados,'dealer_nome') dealer_nome,
         txt(dados,'cidade') cidade, upper(txt(dados,'uf')) uf
  from carga_linha where carga_id = p_carga and aba = 'hierarquia';

  insert into _erro select 'hierarquia', n, 'Campo obrigatório vazio: ' || array_to_string(array_remove(array[
      case when marca_codigo is null then 'marca_codigo' end, case when marca_nome is null then 'marca_nome' end,
      case when regional_codigo is null then 'regional_codigo' end, case when regional_nome is null then 'regional_nome' end,
      case when setor_codigo is null then 'setor_codigo' end, case when grupo_codigo is null then 'grupo_codigo' end,
      case when grupo_nome is null then 'grupo_nome' end, case when dealer_codigo is null then 'dealer_codigo' end,
      case when dealer_nome is null then 'dealer_nome' end], null), ', ')
  from _h where marca_codigo is null or marca_nome is null or regional_codigo is null or regional_nome is null
             or setor_codigo is null or grupo_codigo is null or grupo_nome is null or dealer_codigo is null or dealer_nome is null;
  insert into _erro select 'hierarquia', min(n), 'Dealer ' || dealer_codigo || ' repetido na planilha'
  from _h where dealer_codigo is not null group by dealer_codigo having count(*) > 1;
  insert into _erro select 'hierarquia', min(n), 'Grupo ' || grupo_codigo || ' aparece em mais de uma marca/regional (é um grupo por marca)'
  from _h where grupo_codigo is not null group by grupo_codigo having count(distinct (marca_codigo, regional_codigo)) > 1;
  insert into _erro select 'hierarquia', min(n), 'Regional ' || regional_codigo || ' aparece em mais de uma marca'
  from _h where regional_codigo is not null group by regional_codigo having count(distinct marca_codigo) > 1;
  insert into _erro select 'hierarquia', min(n), 'Setor ' || setor_codigo || ' aparece em mais de uma regional'
  from _h where setor_codigo is not null group by setor_codigo having count(distinct regional_codigo) > 1;

  -- ---------------------------------------------------------------- consultores
  create temp table _c on commit drop as
  select n, inteiro(txt(dados,'consultor_id')) consultor_id, txt(dados,'consultor_id') consultor_id_txt,
         txt(dados,'nome') nome, lower(txt(dados,'perfil')) perfil,
         txt(dados,'setor_codigo') setor_codigo, txt(dados,'regional_codigo') regional_codigo, lower(txt(dados,'email')) email
  from carga_linha where carga_id = p_carga and aba = 'consultores';

  insert into _erro select 'consultores', n, 'nome vazio' from _c where nome is null;
  insert into _erro select 'consultores', n, 'perfil inválido: ' || coalesce(perfil,'(vazio)') || ' (use cpv, cna, cne ou fi)'
  from _c where perfil is null or perfil not in ('cpv','cna','cne','fi');
  insert into _erro select 'consultores', n, 'consultor_id inválido ou inexistente: ' || consultor_id_txt
  from _c where consultor_id_txt is not null and (consultor_id is null or not exists (select 1 from consultor k where k.id = _c.consultor_id));
  insert into _erro select 'consultores', min(n), 'Consultor repetido: ' || nome || ' (' || perfil || ')'
  from _c where consultor_id is null and nome is not null group by nome, perfil having count(*) > 1;
  insert into _erro select 'consultores', n, 'e-mail inválido: ' || email from _c where email is not null and email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';

  -- ---------------------------------------------------------------- catálogo de fornecedor
  create temp table _f on commit drop as
  select n, txt(dados,'fornecedor_codigo') fornecedor_codigo, txt(dados,'fornecedor_nome') fornecedor_nome,
         txt(dados,'pn') pn, txt(dados,'descricao') descricao, upper(txt(dados,'categoria')) categoria,
         txt(dados,'qme') qme_txt, inteiro(txt(dados,'qme')) qme,
         txt(dados,'preco_unit') preco_txt, num(txt(dados,'preco_unit')) preco_unit,
         txt(dados,'condicao') condicao, inteiro(txt(dados,'minimo_qtd')) minimo_qtd, txt(dados,'minimo_qtd') minimo_txt,
         num(txt(dados,'qtd_secundaria')) qtd_secundaria
  from carga_linha where carga_id = p_carga and aba = 'catalogo_fornecedor';

  -- ---------------------------------------------------------------- base 21 pontos
  create temp table _b on commit drop as
  select n, txt(dados,'dealer_codigo') dealer_codigo, txt(dados,'pn') pn, txt(dados,'descricao') descricao,
         upper(txt(dados,'categoria')) categoria, txt(dados,'familia') familia,
         txt(dados,'qme') qme_txt, inteiro(txt(dados,'qme')) qme,
         txt(dados,'preco_unit') preco_txt, num(txt(dados,'preco_unit')) preco_unit,
         txt(dados,'condicao') condicao, num(txt(dados,'desconto_pct')) desconto_pct,
         inteiro(txt(dados,'minimo_qtd')) minimo_qtd, txt(dados,'minimo_qtd') minimo_txt,
         txt(dados,'demanda') demanda_txt, num(txt(dados,'demanda')) demanda,
         txt(dados,'estoque') estoque_txt, num(txt(dados,'estoque')) estoque,
         txt(dados,'transito') transito_txt, num(txt(dados,'transito')) transito,
         num(txt(dados,'qtd_secundaria')) qtd_secundaria
  from carga_linha where carga_id = p_carga and aba = 'base21';

  if exists (select 1 from _b union all select 1 from _f) and v_rodada is null then
    insert into _erro values ('base21', 0, 'Não há rodada ativa: crie a rodada antes de carregar base ou catálogo');
  end if;

  -- validações comuns de item (base21 e catálogo)
  insert into _erro select 'base21', n, 'pn vazio' from _b where pn is null;
  insert into _erro select 'base21', n, 'dealer_codigo vazio' from _b where dealer_codigo is null;
  insert into _erro select 'base21', n, 'Dealer ' || dealer_codigo || ' não está no cadastro nem nesta planilha'
  from _b where dealer_codigo is not null
    and not exists (select 1 from dealer d where d.codigo = _b.dealer_codigo)
    and not exists (select 1 from _h where _h.dealer_codigo = _b.dealer_codigo);
  insert into _erro select 'base21', n, 'categoria ' || coalesce(categoria,'(vazia)') || ' não existe na rodada'
  from _b where not exists (select 1 from categoria c where c.rodada_id = v_rodada and c.codigo = _b.categoria);
  insert into _erro select 'base21', n, 'qme inválido: ' || coalesce(qme_txt,'(vazio)') || ' (inteiro ≥ 1)' from _b where qme is null or qme < 1;
  insert into _erro select 'base21', n, 'preco_unit inválido: ' || coalesce(preco_txt,'(vazio)') from _b where preco_unit is null or preco_unit < 0;
  insert into _erro select 'base21', n, 'minimo_qtd inválido: ' || minimo_txt from _b where minimo_txt is not null and minimo_qtd is null;
  insert into _erro select 'base21', n, 'demanda, estoque e transito são obrigatórios e numéricos'
  from _b where demanda is null or estoque is null or transito is null;
  insert into _erro select 'base21', min(n), 'Dealer ' || dealer_codigo || ' × PN ' || pn || ' repetido'
  from _b where pn is not null and dealer_codigo is not null group by dealer_codigo, pn having count(*) > 1;
  insert into _erro select 'base21', min(n), 'PN ' || pn || ' com valores de item diferentes entre linhas (categoria, qme, preço, condição ou mínimo)'
  from _b where pn is not null group by pn
  having count(distinct (categoria, qme, preco_unit, coalesce(condicao,''), coalesce(minimo_qtd,-1), coalesce(desconto_pct,-1))) > 1;

  insert into _erro select 'catalogo_fornecedor', n, 'fornecedor_codigo, fornecedor_nome e pn são obrigatórios'
  from _f where fornecedor_codigo is null or fornecedor_nome is null or pn is null;
  insert into _erro select 'catalogo_fornecedor', n, 'categoria ' || coalesce(categoria,'(vazia)') || ' não existe na rodada'
  from _f where not exists (select 1 from categoria c where c.rodada_id = v_rodada and c.codigo = _f.categoria);
  insert into _erro select 'catalogo_fornecedor', n, 'qme inválido: ' || coalesce(qme_txt,'(vazio)') from _f where qme is null or qme < 1;
  insert into _erro select 'catalogo_fornecedor', n, 'preco_unit inválido: ' || coalesce(preco_txt,'(vazio)') from _f where preco_unit is null or preco_unit < 0;
  insert into _erro select 'catalogo_fornecedor', n, 'minimo_qtd inválido: ' || minimo_txt from _f where minimo_txt is not null and minimo_qtd is null;
  insert into _erro select 'catalogo_fornecedor', min(n), 'Fornecedor ' || fornecedor_codigo || ' × PN ' || pn || ' repetido'
  from _f where pn is not null group by fornecedor_codigo, pn having count(*) > 1;

  -- ---------------------------------------------------------------- carteira
  create temp table _w on commit drop as
  select n, txt(dados,'consultor_nome') consultor_nome, inteiro(txt(dados,'consultor_id')) consultor_id, txt(dados,'grupo_codigo') grupo_codigo
  from carga_linha where carga_id = p_carga and aba = 'carteira';

  if exists (select 1 from _w) and v_rodada is null then
    insert into _erro values ('carteira', 0, 'Não há rodada ativa: a carteira é por rodada');
  end if;
  insert into _erro select 'carteira', n, 'Informe consultor_nome ou consultor_id' from _w where consultor_nome is null and consultor_id is null;
  insert into _erro select 'carteira', n, 'Grupo ' || coalesce(grupo_codigo,'(vazio)') || ' não está no cadastro nem nesta planilha'
  from _w where grupo_codigo is null or (not exists (select 1 from grupo g where g.codigo = _w.grupo_codigo)
                                     and not exists (select 1 from _h where _h.grupo_codigo = _w.grupo_codigo));
  insert into _erro select 'carteira', n, 'Consultor não encontrado: ' || coalesce(consultor_nome, consultor_id::text)
  from _w where (consultor_id is not null and not exists (select 1 from consultor k where k.id = _w.consultor_id))
             or (consultor_id is null and consultor_nome is not null
                 and not exists (select 1 from consultor k where upper(k.nome) = upper(_w.consultor_nome))
                 and not exists (select 1 from _c where upper(_c.nome) = upper(_w.consultor_nome)));
  insert into _erro select 'carteira', min(n), 'Nome de consultor ambíguo (mais de um cadastro): ' || consultor_nome
  from _w where consultor_id is null and consultor_nome is not null
    and (select count(*) from consultor k where upper(k.nome) = upper(_w.consultor_nome)) > 1
  group by consultor_nome;

  -- ---------------------------------------------------------------- usuários
  create temp table _u on commit drop as
  select n, lower(txt(dados,'email')) email, txt(dados,'nome') nome, lower(txt(dados,'perfil')) perfil,
         txt(dados,'regional_codigo') regional_codigo, txt(dados,'consultor_nome') consultor_nome,
         txt(dados,'fornecedor_codigo') fornecedor_codigo, txt(dados,'grupos') grupos
  from carga_linha where carga_id = p_carga and aba = 'usuarios';

  insert into _erro select 'usuarios', n, 'e-mail inválido: ' || coalesce(email,'(vazio)') from _u where email is null or email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';
  insert into _erro select 'usuarios', n, 'nome vazio' from _u where nome is null;
  insert into _erro select 'usuarios', n, 'perfil inválido: ' || coalesce(perfil,'(vazio)')
  from _u where perfil is null or perfil not in ('admin','regional','cpv','cna','cne','fi','grupo','fornecedor');
  insert into _erro select 'usuarios', min(n), 'E-mail repetido: ' || email from _u where email is not null group by email having count(*) > 1;
  insert into _erro select 'usuarios', n, 'Perfil regional exige regional_codigo existente'
  from _u where perfil = 'regional' and (regional_codigo is null or (not exists (select 1 from regional r where r.codigo = _u.regional_codigo)
                                                                    and not exists (select 1 from _h where _h.regional_codigo = _u.regional_codigo)));
  insert into _erro select 'usuarios', n, 'Perfil ' || perfil || ' exige consultor_nome de um consultor cadastrado com esse perfil'
  from _u where perfil in ('cpv','cna','cne','fi')
    and (consultor_nome is null or (not exists (select 1 from consultor k where upper(k.nome) = upper(_u.consultor_nome) and k.perfil::text = _u.perfil)
                                    and not exists (select 1 from _c where upper(_c.nome) = upper(_u.consultor_nome) and _c.perfil = _u.perfil)));
  insert into _erro select 'usuarios', n, 'Perfil fornecedor exige fornecedor_codigo existente'
  from _u where perfil = 'fornecedor' and (fornecedor_codigo is null or (not exists (select 1 from fornecedor f where f.codigo = _u.fornecedor_codigo)
                                                                         and not exists (select 1 from _f where _f.fornecedor_codigo = _u.fornecedor_codigo)));
  insert into _erro select 'usuarios', n, 'Perfil grupo exige a coluna grupos (códigos separados por ;)' from _u where perfil = 'grupo' and grupos is null;
  insert into _erro select 'usuarios', u.n, 'Grupo ' || g || ' não está no cadastro nem nesta planilha'
  from _u u, lateral unnest(string_to_array(u.grupos, ';')) as gg(g0), lateral (select btrim(gg.g0) g) x
  where u.perfil = 'grupo' and x.g <> '' and not exists (select 1 from grupo where codigo = x.g) and not exists (select 1 from _h where _h.grupo_codigo = x.g);

  -- ---------------------------------------------------------------- metas
  create temp table _m on commit drop as
  select n, txt(dados,'grupo_codigo') grupo_codigo, upper(txt(dados,'categoria')) categoria, txt(dados,'valor') valor_txt, num(txt(dados,'valor')) valor
  from carga_linha where carga_id = p_carga and aba = 'metas';
  insert into _erro select 'metas', n, 'Grupo ' || coalesce(grupo_codigo,'(vazio)') || ' não está no cadastro nem nesta planilha'
  from _m where grupo_codigo is null or (not exists (select 1 from grupo g where g.codigo = _m.grupo_codigo) and not exists (select 1 from _h where _h.grupo_codigo = _m.grupo_codigo));
  insert into _erro select 'metas', n, 'categoria ' || coalesce(categoria,'(vazia)') || ' não existe na rodada'
  from _m where not exists (select 1 from categoria c where c.rodada_id = v_rodada and c.codigo = _m.categoria);
  insert into _erro select 'metas', n, 'valor inválido: ' || coalesce(valor_txt,'(vazio)') from _m where valor is null or valor < 0;
  insert into _erro select 'metas', min(n), 'Grupo ' || grupo_codigo || ' × ' || categoria || ' repetido' from _m group by grupo_codigo, categoria having count(*) > 1;

  create temp table _mc on commit drop as
  select n, txt(dados,'consultor_nome') consultor_nome, upper(txt(dados,'categoria')) categoria, txt(dados,'valor') valor_txt, num(txt(dados,'valor')) valor
  from carga_linha where carga_id = p_carga and aba = 'metas_consultor';
  insert into _erro select 'metas_consultor', n, 'Consultor não encontrado: ' || coalesce(consultor_nome,'(vazio)')
  from _mc where consultor_nome is null or (not exists (select 1 from consultor k where upper(k.nome) = upper(_mc.consultor_nome))
                                            and not exists (select 1 from _c where upper(_c.nome) = upper(_mc.consultor_nome)));
  insert into _erro select 'metas_consultor', n, 'categoria ' || categoria || ' não existe na rodada'
  from _mc where categoria is not null and not exists (select 1 from categoria c where c.rodada_id = v_rodada and c.codigo = _mc.categoria);
  insert into _erro select 'metas_consultor', n, 'valor inválido: ' || coalesce(valor_txt,'(vazio)') from _mc where valor is null or valor < 0;

  -- ---------------------------------------------------------------- colocado no CSPS
  create temp table _s on commit drop as
  select n, txt(dados,'dealer_codigo') dealer_codigo, txt(dados,'pn') pn, txt(dados,'quantidade') qtd_txt,
         inteiro(txt(dados,'quantidade')) quantidade, txt(dados,'numero_pedido') numero_pedido, data_br(txt(dados,'data_pedido')) data_pedido
  from carga_linha where carga_id = p_carga and aba = 'csps';
  insert into _erro select 'csps', n, 'dealer_codigo e pn são obrigatórios' from _s where dealer_codigo is null or pn is null;
  insert into _erro select 'csps', n, 'quantidade inválida: ' || coalesce(qtd_txt,'(vazia)') from _s where quantidade is null;
  if exists (select 1 from _s union all select 1 from _m union all select 1 from _mc) and v_rodada is null then
    insert into _erro values ('metas', 0, 'Não há rodada ativa: metas e colocado no CSPS são por rodada');
  end if;

  -- ---------------------------------------------------------------- resultado da validação
  select count(*) into v_total from _erro;
  select coalesce(jsonb_object_agg(aba, qt), '{}'::jsonb) into v_resumo
  from (select aba, count(*) qt from carga_linha where carga_id = p_carga group by aba) x;

  if v_total > 0 then
    select jsonb_agg(jsonb_build_object('aba', aba, 'linha', n, 'erro', msg) order by aba, n) into v_erros
    from (select * from _erro order by aba, n limit 500) e;
    update carga set status = 'rejeitada', erros = v_erros, abas = v_resumo, linhas = (select count(*) from carga_linha where carga_id = p_carga)
    where id = p_carga;
    delete from carga_linha where carga_id = p_carga;
    return jsonb_build_object('ok', false, 'total_erros', v_total, 'erros', v_erros, 'abas', v_resumo);
  end if;

  -- ================================================================= APLICAÇÃO (sem erros)
  -- hierarquia: upsert do cadastro mestre (não desativa o que ficou fora da planilha)
  insert into marca (codigo, nome) select distinct on (marca_codigo) marca_codigo, marca_nome from _h order by marca_codigo, n
    on conflict (codigo) do update set nome = excluded.nome;
  insert into regional (codigo, nome, marca_codigo) select distinct on (regional_codigo) regional_codigo, regional_nome, marca_codigo from _h order by regional_codigo, n
    on conflict (codigo) do update set nome = excluded.nome, marca_codigo = excluded.marca_codigo;
  insert into setor (codigo, nome, regional_codigo) select distinct on (setor_codigo) setor_codigo, setor_nome, regional_codigo from _h order by setor_codigo, n
    on conflict (codigo) do update set nome = coalesce(excluded.nome, setor.nome), regional_codigo = excluded.regional_codigo;
  insert into grupo (codigo, nome, marca_codigo, regional_codigo, setor_codigo)
    select distinct on (grupo_codigo) grupo_codigo, grupo_nome, marca_codigo, regional_codigo, setor_codigo from _h order by grupo_codigo, n
    on conflict (codigo) do update set nome = excluded.nome, marca_codigo = excluded.marca_codigo,
      regional_codigo = excluded.regional_codigo, setor_codigo = excluded.setor_codigo, ativo = true;
  insert into dealer (codigo, nome, grupo_codigo, cidade, uf) select dealer_codigo, dealer_nome, grupo_codigo, cidade, uf from _h
    on conflict (codigo) do update set nome = excluded.nome, grupo_codigo = excluded.grupo_codigo,
      cidade = excluded.cidade, uf = excluded.uf, ativo = true;

  -- consultores (por id, ou por nome + perfil)
  update consultor k set nome = c.nome, perfil = c.perfil::perfil, setor_codigo = c.setor_codigo, regional_codigo = c.regional_codigo, ativo = true
    from _c c where c.consultor_id = k.id;
  update consultor k set setor_codigo = c.setor_codigo, regional_codigo = c.regional_codigo, ativo = true
    from _c c where c.consultor_id is null and upper(k.nome) = upper(c.nome) and k.perfil::text = c.perfil;
  insert into consultor (nome, perfil, setor_codigo, regional_codigo)
    select c.nome, c.perfil::perfil, c.setor_codigo, c.regional_codigo from _c c
    where c.consultor_id is null and not exists (select 1 from consultor k where upper(k.nome) = upper(c.nome) and k.perfil::text = c.perfil);
  insert into usuario (email, nome, perfil, consultor_id, regional_codigo)
    select c.email, c.nome, c.perfil::perfil, k.id, c.regional_codigo from _c c
    join consultor k on upper(k.nome) = upper(c.nome) and k.perfil::text = c.perfil
    where c.email is not null
    on conflict (email) do update set nome = excluded.nome, perfil = excluded.perfil, consultor_id = excluded.consultor_id, ativo = true;

  -- fornecedores e catálogo
  insert into fornecedor (codigo, nome) select distinct on (fornecedor_codigo) fornecedor_codigo, fornecedor_nome from _f order by fornecedor_codigo, n
    on conflict (codigo) do update set nome = excluded.nome, ativo = true;
  insert into item (rodada_id, pn, descricao, categoria_id, fornecedor_id, qme, preco_unit, condicao, minimo_qtd, qtd_secundaria)
    select v_rodada, f.pn, f.descricao, c.id, fo.id, f.qme, f.preco_unit, f.condicao, f.minimo_qtd, f.qtd_secundaria
    from _f f join categoria c on c.rodada_id = v_rodada and c.codigo = f.categoria join fornecedor fo on fo.codigo = f.fornecedor_codigo
    on conflict (rodada_id, pn, fornecedor_id) do update set descricao = excluded.descricao, categoria_id = excluded.categoria_id,
      qme = excluded.qme, preco_unit = excluded.preco_unit, condicao = excluded.condicao, minimo_qtd = excluded.minimo_qtd,
      qtd_secundaria = excluded.qtd_secundaria;

  -- base 21 pontos: itens Stellantis (upsert) e demanda da rodada (substitui)
  if exists (select 1 from _b) then
    -- item Stellantis tem fornecedor_id nulo: o unique não pega null, então atualiza e insere em dois passos
    update item i set descricao = b.descricao, categoria_id = c.id, familia = b.familia, qme = b.qme, preco_unit = b.preco_unit,
                      condicao = b.condicao, desconto_pct = b.desconto_pct, minimo_qtd = b.minimo_qtd, qtd_secundaria = b.qtd_secundaria
      from (select distinct on (pn) * from _b order by pn, n) b
      join categoria c on c.rodada_id = v_rodada and c.codigo = b.categoria
      where i.rodada_id = v_rodada and i.fornecedor_id is null and i.pn = b.pn;
    insert into item (rodada_id, pn, descricao, categoria_id, familia, qme, preco_unit, condicao, desconto_pct, minimo_qtd, qtd_secundaria)
      select v_rodada, b.pn, b.descricao, c.id, b.familia, b.qme, b.preco_unit, b.condicao, b.desconto_pct, b.minimo_qtd, b.qtd_secundaria
      from (select distinct on (pn) * from _b order by pn, n) b
      join categoria c on c.rodada_id = v_rodada and c.codigo = b.categoria
      where not exists (select 1 from item i where i.rodada_id = v_rodada and i.fornecedor_id is null and i.pn = b.pn);
    delete from demanda where rodada_id = v_rodada;
    insert into demanda (rodada_id, dealer_codigo, item_id, demanda, estoque, transito)
      select v_rodada, b.dealer_codigo, i.id, b.demanda, b.estoque, b.transito
      from _b b join item i on i.rodada_id = v_rodada and i.fornecedor_id is null and i.pn = b.pn;
    -- itens Stellantis que saíram da base e não têm pedido: removidos
    delete from item i where i.rodada_id = v_rodada and i.fornecedor_id is null
      and not exists (select 1 from _b where _b.pn = i.pn)
      and not exists (select 1 from pedido_linha p where p.item_id = i.id);
  end if;

  -- carteira da rodada (substitui)
  if exists (select 1 from _w) then
    delete from carteira where rodada_id = v_rodada;
    insert into carteira (rodada_id, consultor_id, grupo_codigo)
      select distinct v_rodada, coalesce(w.consultor_id, k.id), w.grupo_codigo
      from _w w left join consultor k on w.consultor_id is null and upper(k.nome) = upper(w.consultor_nome);
  end if;

  -- usuários (upsert por e-mail; grupos do perfil grupo substituídos para os e-mails da planilha)
  insert into usuario (email, nome, perfil, regional_codigo, consultor_id, fornecedor_id)
    select u.email, u.nome, u.perfil::perfil,
           case when u.perfil = 'regional' then u.regional_codigo end,
           (select k.id from consultor k where upper(k.nome) = upper(u.consultor_nome) and k.perfil::text = u.perfil limit 1),
           (select f.id from fornecedor f where f.codigo = u.fornecedor_codigo)
    from _u u
    on conflict (email) do update set nome = excluded.nome, perfil = excluded.perfil, regional_codigo = excluded.regional_codigo,
      consultor_id = excluded.consultor_id, fornecedor_id = excluded.fornecedor_id, ativo = true;
  delete from usuario_grupo ug using usuario us, _u u where ug.usuario_id = us.id and us.email = u.email;
  insert into usuario_grupo (usuario_id, grupo_codigo)
    select distinct us.id, btrim(g) from _u u join usuario us on us.email = u.email, unnest(string_to_array(u.grupos, ';')) g
    where u.perfil = 'grupo' and btrim(g) <> '';

  -- metas (substituem as da rodada)
  if exists (select 1 from _m) then
    delete from meta_grupo where rodada_id = v_rodada;
    insert into meta_grupo (rodada_id, grupo_codigo, categoria_id, valor)
      select v_rodada, m.grupo_codigo, c.id, m.valor from _m m join categoria c on c.rodada_id = v_rodada and c.codigo = m.categoria;
  end if;
  if exists (select 1 from _mc) then
    delete from meta_consultor where rodada_id = v_rodada;
    insert into meta_consultor (rodada_id, consultor_id, categoria_id, valor)
      select distinct on (k.id, c.id) v_rodada, k.id, c.id, m.valor
      from _mc m join consultor k on upper(k.nome) = upper(m.consultor_nome)
      left join categoria c on c.rodada_id = v_rodada and c.codigo = m.categoria;
  end if;

  -- colocado no CSPS (acumula; mesma chave atualiza a quantidade)
  insert into csps_colocado (rodada_id, carga_id, dealer_codigo, pn, quantidade, numero_pedido, data_pedido)
    select v_rodada, p_carga, dealer_codigo, pn, sum(quantidade), coalesce(numero_pedido, ''), max(data_pedido)
    from _s group by dealer_codigo, pn, coalesce(numero_pedido, '')
    on conflict (rodada_id, dealer_codigo, pn, numero_pedido) do update set quantidade = excluded.quantidade,
      data_pedido = excluded.data_pedido, carga_id = excluded.carga_id;

  update carga set status = 'aplicada', erros = null, abas = v_resumo, linhas = (select count(*) from carga_linha where carga_id = p_carga)
  where id = p_carga;
  delete from carga_linha where carga_id = p_carga;
  return jsonb_build_object('ok', true, 'total_erros', 0, 'abas', v_resumo);
end $$;

-- Cria uma rodada com as categorias e a matriz perfil × categoria padrão (editáveis depois).
-- Categorias padrão = as da rodada de junho/2026 (docs/decisoes.md).
create or replace function criar_rodada(p_codigo text, p_nome text, p_ativar boolean default true) returns int language plpgsql
  set search_path = rodada, public as $$
declare v_id int;
begin
  if p_ativar then update rodada set ativa = false where ativa; end if;
  insert into rodada (codigo, nome, ativa) values (p_codigo, p_nome, p_ativar) returning id into v_id;
  insert into categoria (rodada_id, codigo, nome, ordem, unidade_secundaria) values
    (v_id, 'PECAS', 'Peças', 1, null), (v_id, 'ACESSORIOS', 'Acessórios', 2, null),
    (v_id, 'ENVIOS_FULL', 'Envios Full', 3, null), (v_id, 'BPRO', 'Bpro', 4, null),
    (v_id, 'CIRC_AUTOPECAS', 'Circ. Autopeças', 5, null), (v_id, 'SHELL', 'Shell', 6, 'litros'),
    (v_id, 'OUTROS_DFS', 'Outros DFS', 7, null);
  -- CPV, regional e admin conduzem tudo; CNA peças; CNE e-commerce; F&I acessórios
  insert into perfil_categoria select c.id, p from categoria c, unnest(array['cpv','regional','admin']::perfil[]) p where c.rodada_id = v_id;
  insert into perfil_categoria select id, 'cna' from categoria where rodada_id = v_id and codigo = 'PECAS';
  insert into perfil_categoria select id, 'cne' from categoria where rodada_id = v_id and codigo = 'ENVIOS_FULL';
  insert into perfil_categoria select id, 'fi'  from categoria where rodada_id = v_id and codigo = 'ACESSORIOS';
  return v_id;
end $$;
