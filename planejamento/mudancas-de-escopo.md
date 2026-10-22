# Log de mudanças de escopo

Toda vez que algo já registrado muda, ou que uma nova direção diverge do que está vigente, abre-se uma `MUD-xx`.
É o controle de mudança do projeto: o que era, o que passa a ser, por quê, e o que isso custa.

## Estados de uma mudança

| Estado | Significado |
|---|---|
| **Em análise** | Registrada; impacto e perguntas sendo levantados |
| **Aguardando decisão** | Impacto conhecido; falta quem aprova decidir |
| **Aprovada** | Decidida; ainda não está em `docs/decisoes.md` nem no código |
| **Aplicada** | Promovida para `docs/decisoes.md` (e código, se for o caso); aponta o commit ou PR |
| **Rejeitada** | Decidiu-se manter o que era; fica o motivo |

## Modelo de entrada

```
### MUD-xx — Título curto
- Aberta em: dd/mm/aaaa · Fonte: (chamada, conversa, documento, pessoa)
- Estado: Em análise
- Antes (vigente): o que `docs/decisoes.md` ou o código dizem hoje
- Proposto: o que passa a valer se aprovada
- Motivo: por que mudar
- Impacto: regras · dados e cargas · banco · telas · testes · prazo
- Perguntas ligadas: P-xx
- Decisão: (quem, quando, o quê)
```

## Painel

| ID | Tema | Estado | Impacto | Bloqueia a tela de negociação? |
|---|---|---|---|---|
| MUD-01 | Status do escopo: "fechado" × em levantamento | Em análise | Governança | Sim, indiretamente |
| MUD-02 | Pedido versionado em vez de linha editada | Em análise | **Alto** | **Sim** |
| MUD-03 | Papel da plataforma na sugestão | Em análise | **Alto** | **Sim** |
| MUD-04 | Fórmula da sugestão (21 pontos, 90 dias, MIRA, QME) | Em análise | Alto | Sim, se MUD-03 mantiver o cálculo na plataforma |
| MUD-05 | Preço por concessionária e desconto sobre lista | Em análise | **Alto** | **Sim** |
| MUD-06 | Valor do indicador sem ST | Em análise | Médio | Parcial (valor exibido) |
| MUD-07 | Contratos de fornecedor fora dos números Stellantis | Em análise | Médio | Não |
| MUD-08 | Fornecedor carrega e ajusta ofertas e cria pedidos | Em análise | Médio | Não (etapa 3 da entrega) |
| MUD-09 | Públicos e perfis (Central Stellantis, concessionária) | Em análise | Médio | Parcial (quem digita) |
| MUD-10 | FULL dentro ou fora do armazém | Em análise | Médio | Não (afeta metas e painel) |
| MUD-11 | Capacidade de 300 usuários gravando | Em análise | Alto | Não, mas orienta o desenho |
| MUD-12 | Cobertura temporária de CPV | Em análise | Médio | Não |
| MUD-13 | Datas: testes em 16/11 e regras tardias | Em análise | Alto | — |
| MUD-14 | Metas de consultor compiladas | Em análise | Baixo | Não |
| MUD-15 | Lista especial por ordem de chegada | Em análise | Alto se existir | Sim, se existir |
| MUD-16 | Patrocinadores e premiações no painel | Em análise | Baixo | Não |

## Mudanças

### MUD-01 — Status do escopo: "fechado" × em levantamento
- Aberta em: 22/10/2026 · Fonte: comparação entre `docs/decisoes.md`, `docs/HANDOFF.md` e o levantamento de 19–20/10
- Estado: Em análise
- Antes (vigente): o HO diz "Regras de negócio: **Fechadas**: 20 decisões registradas em `docs/decisoes.md`". O
  `CLAUDE.md` manda que `docs/decisoes.md` prevaleça sobre qualquer outro texto.
- Proposto: tratar o escopo como **em levantamento** até a aprovação das mudanças abaixo; `docs/decisoes.md` continua
  valendo para o código, mas cada regra contestada fica marcada como "em revisão" em `situacao.md`.
- Motivo: o levantamento com Marcos (19–20/10) e o consolidado do Codex (21/10) reabrem regras centrais.
- Impacto: governança. Sem isso, o próximo passo do HO (tela de negociação) seria construído sobre regras que podem mudar.
- Perguntas ligadas: P-01, P-02, P-03
- Decisão: —

### MUD-02 — Pedido versionado em vez de linha editada
- Aberta em: 22/10/2026 · Fonte: LEV (20/10), CDX §14
- Estado: Em análise
- Antes (vigente): uma linha por grupo × PN × dealer, editada no lugar; `versao` serve de bloqueio otimista (quem
  grava com versão velha recebe "alterada por outra pessoa, recarregue"); a `auditoria` guarda antes e depois em JSON;
  status `rascunho`, `fechado`, `cancelado`; não há cabeçalho de pedido.
- Proposto (DE-07 a DE-10): cada alteração cria uma **nova versão vinculada** à anterior, que fica substituída; uma
  só versão vigente; troca atômica; conflito explícito; histórico com autor, perfil, motivo, diferenças e vínculo; só
  versão **vigente e fechada** conta.
- Motivo: rastreabilidade de quem mudou o quê (CPV, fornecedor, concessionária) e proteção contra sobrescrita entre
  ~300 usuários simultâneos.
- Impacto:
  - Banco: nova estrutura (cadeia de versões; talvez cabeçalho de pedido), novas views de "vigente", trigger de troca
    atômica, revisão do `unique` atual.
  - Telas: tela de negociação precisa mostrar diferença e revisão em conflito.
  - Testes: `smoke.sql` e testes de banco; teste de concorrência.
  - Indicadores: todas as views `v_*` passam a filtrar "vigente e fechado".
  - Prazo: é a mudança de maior custo se feita **depois** da tela de negociação.
- Observação: parte do objetivo já é atendida hoje (conflito explícito e trilha), mas a versão anterior não continua
  existindo como registro e não há motivo por alteração.
- Perguntas ligadas: P-07, P-36, P-37, P-38, P-39
- Decisão: —

### MUD-03 — Papel da plataforma na sugestão
- Aberta em: 22/10/2026 · Fonte: LEV (decisão estrutural nº 3), CDX §21
- Estado: Em análise
- Antes (vigente): a plataforma recebe a base dealer × PN (demanda, estoque, trânsito, QME) e **calcula** sugestão e
  potencial restante no banco; a tela de negociação parte da sugestão.
- Proposto: duas alternativas em aberto. (a) Manter o cálculo na plataforma, com a fórmula de `MUD-04`. (b) Preferência
  declarada de Marcos: plataforma só recebe, carrega e consolida pedidos; a sugestão fica em planilha ou chega pronta.
- Motivo: simplicidade e prazo (b) × apoio à negociação e indicador de cobertura (a).
- Impacto: (b) reduz escopo do motor, mas a tela de negociação perde "sugestão" e "potencial restante" ou passa a
  exibir um número externo; o indicador de cobertura depende disso. Uma terceira via é carregar a **sugestão pronta**
  como coluna da base (o cálculo fica fora, a tela continua mostrando).
- Perguntas ligadas: P-29
- Decisão: —

### MUD-04 — Fórmula da sugestão
- Aberta em: 22/10/2026 · Fonte: LEV (20/10), CDX §12–13
- Estado: Em análise (depende de MUD-03)
- Antes (vigente): sugestão = (demanda − estoque − trânsito), arredondada para cima ao QME, nunca negativa; "demanda"
  vem pronta da "base 21 pontos" do Power BI; trânsito é quantidade; todo pedido é múltiplo de QME.
- Proposto: em discussão. 21 pontos é **pontuação de frequência** (DE-03), não demanda; horizonte de 90 dias
  (DE-05); MIRA como referência (DE-06): demanda diária = unidades líquidas de 6 meses ÷ 180; necessidade =
  (90 + 10 dias) × demanda diária − estoque; arredonda à unidade, sem QME; trânsito em **dias**.
- Motivo: o termo "base 21 pontos" do repositório mistura duas coisas (classificação por frequência e demanda em
  quantidade).
- Impacto: layout da aba `base21` em `docs/cargas.md` (talvez colunas de ocorrência mensal e curva), função
  `calc_sugestao`, validação de QME, testes. Renomear "base21" pode ser necessário para evitar confusão.
- Perguntas ligadas: P-30, P-31, P-32, P-33, P-34, P-35
- Decisão: —

### MUD-05 — Preço por concessionária e desconto sobre lista
- Aberta em: 22/10/2026 · Fonte: LEV (19/10), CDX §10
- Estado: Em análise
- Antes (vigente): cada PN tem **um** `preco_unit` (preço da condição da rodada) igual para toda a rede; a carga
  recusa o mesmo PN com preço ou condição diferentes entre dealers; `desconto_pct` é só informativo; o pedido grava
  uma foto do preço.
- Proposto: lista completa sem desconto + lista promocional da qual se usa só item e desconto (DE-13, DE-14); preço
  efetivo possivelmente diferente por concessionária ou destino; possíveis descontos progressivos por quantidade,
  conhecidos só na última semana de novembro.
- Motivo: é como a Stellantis forma o preço da rodada, segundo Marcos.
- Impacto: modelo de preço (por item × dealer, ou regra de cálculo), cargas novas, valor da linha calculado e não só
  copiado, testes de preço; risco de prazo porque parte das regras chega depois de 16/11.
- Perguntas ligadas: P-13, P-14, P-15, P-16, P-17
- Decisão: —

### MUD-06 — Valor do indicador sem ST
- Aberta em: 22/10/2026 · Fonte: LEV (19/10), CDX §10.3
- Estado: Em análise
- Antes (vigente): valor = quantidade × preço da condição; não há distinção entre valor comercial e fiscal.
- Proposto (DE-15): o número do evento é o valor do produto **sem ST**; valores fiscais ficam separados.
- Impacto: definir de qual base vem o valor sem ST; colunas separadas se o fiscal precisar aparecer na conciliação.
- Perguntas ligadas: P-17, P-18
- Decisão: —

### MUD-07 — Contratos de fornecedor fora dos números Stellantis
- Aberta em: 22/10/2026 · Fonte: LEV (19/10), CDX §10.4
- Estado: Em análise
- Antes (vigente): "Pedidos de fornecedor **contam** no atingimento do grupo, dentro da sua categoria".
- Proposto: distinguir **pedido** de **contrato**; definir por indicador o que entra (atingimento do grupo, total do
  evento, números Stellantis, ranking de fornecedor).
- Impacto: possível novo tipo de registro (contrato); regra de elegibilidade por indicador. O campo
  `categoria.conta_no_total` existe, mas não é usado e é por categoria, não por indicador.
- Perguntas ligadas: P-25
- Decisão: —

### MUD-08 — Fornecedor carrega e ajusta ofertas e cria pedidos
- Aberta em: 22/10/2026 · Fonte: LEV (19/10)
- Estado: Em análise
- Antes (vigente): o **admin** carrega `catalogo_fornecedor`; fornecedor "digita" pedidos com login próprio (ou o time
  Stellantis digita por ele) e vê as próprias linhas.
- Proposto (DE-16, DE-17): o fornecedor carrega e ajusta as próprias ofertas até o bloqueio do admin; campos de
  descrição, preço e descontos (talvez progressivos); fornecedor também cria pedidos (jornada a detalhar).
- Impacto: tela de oferta para o fornecedor, carga por fornecedor com escopo restrito, estado de bloqueio, regras de
  correção após o bloqueio.
- Perguntas ligadas: P-11, P-12, P-16, P-22, P-23
- Decisão: —

### MUD-09 — Públicos e perfis
- Aberta em: 22/10/2026 · Fonte: LEV (19–20/10), CDX §5
- Estado: Em análise
- Antes (vigente): perfis Admin, Regional, CPV, CNA, CNE, F&I, Grupo, Fornecedor e Telão; "sem perfis novos antes da
  primeira rodada"; perfil Grupo digita os próprios pedidos; um perfil por usuário.
- Proposto: mapear perfis antes de associar usuários (DE-01); possível perfil **Central Stellantis** (acompanha em tempo
  real); acesso direto da concessionária vira decisão estrutural (pode ficar só com as regionais); permissões por fase
  e estado do pedido; possível acúmulo de perfis.
- Impacto: matriz de permissões, enum de perfis, checagens no servidor, carga de usuários.
- Perguntas ligadas: P-05, P-06, P-07, P-08
- Decisão: —

### MUD-10 — FULL dentro ou fora do armazém
- Aberta em: 22/10/2026 · Fonte: LEV (20/10), CDX §11
- Estado: Em análise
- Antes (vigente): "Envios Full" é uma das sete categorias, com meta própria; o total soma todas as categorias.
- Proposto: em aberto se o objetivo FULL está **dentro** do objetivo do armazém (peças) ou é **separado**. FULL é
  descrito como subpedido do armazém para o fulfillment do Mercado Livre.
- Impacto: se estiver dentro, o total atual conta FULL duas vezes (como categoria e dentro de peças) ou exige outra
  forma de meta; afeta carga de metas, views de atingimento e o telão.
- Perguntas ligadas: P-24
- Decisão: —

### MUD-11 — Capacidade de 300 usuários gravando
- Aberta em: 22/10/2026 · Fonte: LEV (20/10), CDX §17–19
- Estado: Em análise
- Antes (vigente): sem requisito de capacidade; hospedagem Neon + Vercel; HO cita só lotes de 2.000 linhas na carga.
- Proposto (DE-11, DE-12): ~300 usuários simultâneos criando e editando pedidos; teste de carga e integridade antes do
  evento; estimativa de US$ 100 a 250 no mês do evento (não aprovada).
- Impacto: desenho do caminho de gravação (transações curtas, pool, idempotência), plano de testes, ambiente de teste
  isolado, orçamento.
- Perguntas ligadas: P-43, P-46, P-47, P-48
- Decisão: —

### MUD-12 — Cobertura temporária de CPV
- Aberta em: 22/10/2026 · Fonte: LEV (20/10), CDX §8.2
- Estado: Em análise
- Antes (vigente): carteira consultor × grupo carregada por planilha, por rodada; não há conceito de cobertura temporária.
- Proposto (DE-02): distribuir o setor de um CPV ausente entre um ou mais CPVs da mesma regional, com vigência.
- Impacto: vínculo temporário separado da carteira oficial, telas ou carga para cadastrar, regra de responsável na
  linha, histórico e rankings (a quem conta a venda feita na cobertura).
- Perguntas ligadas: P-09, P-10
- Decisão: —

### MUD-13 — Datas: testes em 16/11 e regras tardias
- Aberta em: 22/10/2026 · Fonte: LEV (19/10), CDX §20
- Estado: Em análise
- Antes (vigente): sequência de entrega em quatro etapas, sem datas; evento em dezembro.
- Proposto: plataforma pronta para testes em 16/11 (referência), três semanas de testes e correções; regras de
  desconto progressivo só na última semana de novembro.
- Impacto: de 22/10 a 16/11 são 25 dias corridos para fechar escopo e construir negociação, versionamento e painel;
  16/11 + 3 semanas chega a 07/12, a própria semana provável do evento. Ver `cronograma.md`.
- Perguntas ligadas: P-04, P-16
- Decisão: —

### MUD-14 — Metas de consultor compiladas
- Aberta em: 22/10/2026 · Fonte: LEV (20/10)
- Estado: Em análise
- Antes (vigente): `metas_consultor` é carregada pronta (consultor × categoria ou total).
- Proposto: metas do CPV compiladas em boa parte dos objetivos das concessionárias, com exceções.
- Impacto: baixo se a compilação for feita fora e chegar pronta na carga; médio se a plataforma tiver de compor.
- Perguntas ligadas: P-26
- Decisão: —

### MUD-15 — Lista especial por ordem de chegada
- Aberta em: 22/10/2026 · Fonte: LEV (decisão estrutural nº 2), CDX §10.5
- Estado: Em análise (a existência da lista não está aprovada)
- Antes (vigente): não existe; não há limite de quantidade por oferta.
- Proposto: possível lista com prioridade por ordem de chegada (quantidade limitada), exigindo reserva, confirmação,
  desempate e definição do momento que conta como chegada.
- Impacto: se existir, é o ponto de maior concorrência do sistema (todos disputando o mesmo saldo) e muda o teste de carga.
- Perguntas ligadas: P-21
- Decisão: —

### MUD-16 — Patrocinadores e premiações no painel
- Aberta em: 22/10/2026 · Fonte: LEV (checklist de 19/10), CDX §16
- Estado: Em análise
- Antes (vigente): painel de junho/2026 como referência visual (cards por categoria, rankings).
- Proposto: espaço para patrocinadores (a discutir com Bruno) e área separada de campanhas de premiação.
- Impacto: baixo no modelo de dados se forem conteúdo estático; maior se premiação depender de regra de cálculo.
- Perguntas ligadas: P-42
- Decisão: —

## Histórico deste arquivo

| Data | Registro |
|---|---|
| 22/10/2026 | Criação com MUD-01 a MUD-16, a partir da comparação descrita em `comparativo-fontes.md` |
