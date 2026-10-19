# Cargas — layout das planilhas de entrada

Toda entrada entra por planilha (.xlsx), pelo admin, na tela de cargas. Uma aba por tipo; o modelo com
cabeçalhos e linhas de exemplo está em `cargas/modelos_cargas.xlsx`. Regras gerais:

- Primeira linha = cabeçalho, nomes exatamente como abaixo (minúsculas, sem acento).
- Códigos são texto (dealer `000123` não vira `123`): formatar as colunas de código como texto no Excel.
- Carga **substitui** o conjunto do mesmo tipo na rodada (ex.: recarregar a base 21 pontos apaga a anterior),
  exceto `csps`, que acumula por `numero_pedido`.
- Linha com erro não entra; o relatório da carga lista linha e motivo. A carga só é aplicada se não houver erro
  (tudo ou nada), para não deixar base pela metade.

## 1. `hierarquia` (cadastro mestre, vale entre rodadas)

| coluna | tipo | obrigatória | observação |
|---|---|---|---|
| marca_codigo | texto | sim | FIAT, CJDR, PSA |
| marca_nome | texto | sim | |
| regional_codigo | texto | sim | 11..15, 21..24 |
| regional_nome | texto | sim | |
| setor_codigo | texto | sim | ex.: 132 |
| setor_nome | texto | não | |
| grupo_codigo | texto | sim | **um grupo por marca** |
| grupo_nome | texto | sim | |
| dealer_codigo | texto | sim | código no CSPS |
| dealer_nome | texto | sim | |
| cidade | texto | não | |
| uf | texto | não | |

Uma linha por dealer. Marca, regional, setor e grupo são deduzidos das linhas.

## 2. `consultores`

| coluna | tipo | obrigatória | observação |
|---|---|---|---|
| consultor_id | inteiro | não | vazio = novo |
| nome | texto | sim | |
| perfil | texto | sim | cpv, cna, cne, fi |
| setor_codigo | texto | não | |
| regional_codigo | texto | não | |
| email | texto | não | cria o usuário com o perfil do consultor |

## 3. `carteira` (por rodada)

| coluna | tipo | obrigatória |
|---|---|---|
| consultor_nome ou consultor_id | texto/inteiro | sim |
| grupo_codigo | texto | sim |

Carteira própria de CNA/CNE: linhas próprias. Herdada do CPV: repetir as linhas do CPV.

## 4. `usuarios` (convites)

| coluna | tipo | obrigatória | observação |
|---|---|---|---|
| email | texto | sim | |
| nome | texto | sim | |
| perfil | texto | sim | admin, regional, cpv, cna, cne, fi, grupo, fornecedor |
| regional_codigo | texto | perfil regional | |
| consultor_nome | texto | perfis cpv/cna/cne/fi | |
| fornecedor_codigo | texto | perfil fornecedor | |
| grupos | texto | perfil grupo | códigos separados por `;` (um por marca) |

## 5. `base21` — base 21 pontos (por rodada, dealer × PN)

| coluna | tipo | obrigatória | observação |
|---|---|---|---|
| dealer_codigo | texto | sim | |
| pn | texto | sim | |
| descricao | texto | não | |
| categoria | texto | sim | código da categoria da rodada (PECAS, ACESSORIOS, …) |
| familia | texto | não | |
| qme | inteiro | sim | múltiplo de embalagem (≥ 1) |
| preco_unit | número | sim | preço da condição da rodada |
| condicao | texto | não | descrição da condição |
| desconto_pct | número | não | |
| minimo_qtd | inteiro | não | mínimo da condição |
| demanda | número | sim | |
| estoque | número | sim | |
| transito | número | sim | pedido em trânsito / backorder |
| qtd_secundaria | número | não | ex.: litros por unidade |

O item (PN, categoria, QME, preço, condição) é deduzido das linhas; valores de item devem ser iguais em
todas as linhas do mesmo PN (divergência = erro na carga).

## 6. `catalogo_fornecedor` (por rodada)

| coluna | tipo | obrigatória |
|---|---|---|
| fornecedor_codigo | texto | sim |
| fornecedor_nome | texto | sim |
| pn | texto | sim |
| descricao | texto | não |
| categoria | texto | sim |
| qme | inteiro | sim |
| preco_unit | número | sim |
| condicao | texto | não |
| minimo_qtd | inteiro | não |
| qtd_secundaria | número | não |

Sem colunas de demanda: fornecedor não tem sugestão.

## 7. `metas` (por rodada)

| coluna | tipo | obrigatória | observação |
|---|---|---|---|
| grupo_codigo | texto | sim | |
| categoria | texto | sim | |
| valor | número | sim | R$ |

E `metas_consultor` (opcional, para os rankings): `consultor_nome`, `categoria` (vazio = total), `valor`.

## 8. `csps` — colocado no CSPS (pós-evento)

| coluna | tipo | obrigatória |
|---|---|---|
| dealer_codigo | texto | sim |
| pn | texto | sim |
| quantidade | inteiro | sim |
| numero_pedido | texto | não |
| data_pedido | data | não |

Layout exato da extração do CSPS a confirmar quando houver exemplo; a carga aceita colunas extras e ignora.
