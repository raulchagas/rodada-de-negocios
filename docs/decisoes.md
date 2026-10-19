# Rodada de Negócios — decisões vigentes

Registro das decisões do Raul na sessão de 16/10/2026 (rodada de perguntas antes de construir).
Se qualquer outro texto do módulo divergir deste arquivo, vale este arquivo.

## O que a ferramenta é

- Sistema de registro dos pedidos da Rodada de Negócios. Durante o evento, **nenhum pedido vai ao CSPS**
  (sistema oficial da Stellantis): o pedido nasce e vive aqui.
- Pós-evento: exportação consolidada para colocação no CSPS e conciliação **pedido do evento × pedido colocado**.
- Substitui o Power BI no telão e nos acessos individuais durante o evento. O painel de junho/2026
  (Power BI) é a referência visual: cards por categoria, rankings de regionais, consultores,
  fornecedores e F&I, desempenho por marca.

## Hierarquia e unidades

| Decisão | Valor |
|---|---|
| Hierarquia comercial | Marca → Regional → Setor → CPV → Grupo → Dealer |
| Unidade de negociação, meta e atingimento | **Grupo** |
| Grupo multimarca | É **um grupo por marca** (grupo com Fiat e CJDR = dois grupos). O mesmo login pode ter acesso a vários grupos |
| Dealer | Só **destino de entrega** da linha do pedido. Escolhido manualmente pelo CPV ou pelo grupo. **Sem rateio automático** |
| Carteira | Cadastro consultor × grupo por rodada, carregado por planilha (cobre carteira própria ou herdada do CPV) |

## Categorias e metas

- Meta do grupo = vetor **grupo × categoria**, em R$. Atingimento por categoria e no total.
- Categorias são **cadastro da rodada** (nome, ordem, ícone, unidade secundária opcional — ex.: litros).
  Prováveis em dez/2026, iguais a jun/2026: Peças, Acessórios, Envios Full, Bpro, Circ. Autopeças, Shell, Outros DFS.
- Categoria é atributo do PN/item na carga (não se classifica na ferramenta).
- Pedidos de fornecedor **contam** no atingimento do grupo, dentro da sua categoria.
- Metas de dez/2026 ainda serão calculadas; os valores do painel de junho não servem de meta.

## Sugestão de quantidade

- Base dos 21 pontos (pré-calculada no Power BI) traz, por dealer × PN: demanda, estoque, pedido em trânsito,
  QME (múltiplo de embalagem) e condição promocional.
- Sugestão = (demanda − estoque − trânsito), arredondada para cima ao QME, nunca negativa.
- Toda quantidade pedida é múltiplo de QME (validação na gravação).
- **Potencial restante** vivo = sugestão − pedido já feito na rodada, por PN, dealer e grupo.
  Acima de 100% aparece como "acima da sugestão", não como erro.

## Indicadores

| Indicador | Cálculo |
|---|---|
| Atingimento | pedido **fechado** ÷ meta, por categoria e total, em todo nível da hierarquia |
| Cobertura da sugestão | pedido ÷ sugestão, por PN e agregado |
| Conciliação | evento × colocado no CSPS, por dealer × PN; exceções: não colocado, parcial, divergência, PN sem correspondência |

## Quem digita e quando

- CPV e grupo digitam o pedido. **Sem aceite formal do grupo**: muitas vezes o CPV fecha sentado à mesa com ele.
  A ferramenta guarda quem registrou e quando (trilha), não aprovação.
- Pedido de fornecedor: digitado pelo fornecedor (login próprio) ou pelo time Stellantis.
- Status da linha: `rascunho` → `fechado`. O telão conta só o fechado.
- Fases da rodada (datas e quem edita em cada uma são **parâmetros da rodada**; regra exata a definir perto do evento):
  pré-rodada (CPV e grupo rascunham) → evento (todos digitam) → pós-evento (ajustes do time interno, com motivo, antes da exportação).

## Consultores e categorias

| Consultor | Conduz |
|---|---|
| CPV | todas as categorias |
| CNA | Peças |
| CNE | E-commerce (Envios Full) |
| F&I | Acessórios |

Matriz perfil × categoria é cadastro da rodada. A linha do pedido carrega **um** responsável, e a gravação só
aceita responsável com permissão na categoria da linha. Rankings (CPV, CNA, CNE, F&I) saem dessa coluna.

## Perfis de acesso

| Perfil | Vê | Edita |
|---|---|---|
| Admin | tudo | tudo, cargas e cadastro da rodada |
| Regional (supervisores regionais) | a própria regional | linhas permitidas da própria regional |
| CPV / CNA / CNE / F&I | os próprios grupos (carteira) | linhas das categorias permitidas, nos próprios grupos |
| Grupo | o próprio grupo (um ou mais, por marca) | pedidos do próprio grupo, todas as categorias |
| Fornecedor | as próprias linhas em todos os grupos | linhas do próprio catálogo |
| Telão | painel de resultados, sem login | nada |

Sem perfis novos antes da primeira rodada.

## Cargas (entrada) e saídas

- Entrada, por planilha, pelo admin: hierarquia, carteiras, usuários, base 21 pontos, catálogo de fornecedores
  (mesmo formato, colunas de demanda vazias), metas, colocado no CSPS (extração do CSPS em planilha, dealer × PN × quantidade).
- Saída para o CSPS: **arquivo consolidado** dealer × PN × quantidade × condição; o time interno coloca no CSPS.
  Pedidos de fornecedor: relatório por fornecedor.

## Arquitetura

- Hospedagem própria do Raul agora (Postgres + app na Vercel), com arquitetura portável (schema SQL puro, app em container)
  para a infra da empresa depois. Login por convite (link mágico), nunca cadastro aberto.
- Postgres com usuário de leitura para o Power BI como contingência do telão.
- Repositório próprio (`rodada-de-negocios`, privado), pasta local `C:\Projects\rodada-de-negocios`. Fora do monorepo
  `mopar-boost` (decisão do Raul, 16/10/2026). Bases brutas e dados corporativos ficam fora do Git.

## Sequência de entrega

1. Modelo de dados, cargas e tela de negociação interna (CPV).
2. Painel de resultados e telão.
3. Perfis externos: grupo e fornecedor.
4. Exportação CSPS e conciliação.

Com 1 e 2 prontos, a rodada roda com o time interno mesmo que 3 atrase.

## Pendências fora do código

- Alinhar com a liderança o uso de hospedagem própria com dados da rede nesta rodada.
- Exemplos do layout de extração do CSPS e das planilhas de base e metas, quando existirem.
- Bpro e Circular Autopeças: tratados como categorias comuns até que se saiba de regra própria.
