# Rodada de Negócios — gestão de pedidos

Ferramenta unificada para a Rodada de Negócios Stellantis (Mopar atacado): registro dos pedidos
durante o evento, sugestão de quantidade por dealer e grupo (base 21 pontos), painel de resultados
em tempo real (telão e acessos individuais), acesso da rede e de fornecedores (DFS/DSH), exportação
para o CSPS e conciliação pós-evento.

## Comece aqui

1. `docs/decisoes.md` — decisões vigentes (prevalecem sobre qualquer outro texto).
2. `docs/HANDOFF.md` — estado atual e próximo passo.
3. `docs/cargas.md` — layout das planilhas de entrada; modelo em `cargas/modelos_cargas.xlsx`.
4. `db/migrations/` — schema Postgres puro (schema `rodada`), numeração sequencial.

## Mapa

| Pasta | O que tem |
|---|---|
| `docs/` | Decisões, handoff, layouts de carga |
| `db/migrations/` | Schema SQL (portável: qualquer Postgres 15+) |
| `cargas/` | Modelos de planilha (sem dados corporativos) |
| `app/` | Aplicação web (a criar) |
| `dados/` | **Fora do Git.** Bases brutas, extrações do CSPS, planilhas com dado da rede |

## Stack (decisão pendente, ver HANDOFF)

Postgres + app web na Vercel, login por convite. Arquitetura portável para a infra da empresa.
