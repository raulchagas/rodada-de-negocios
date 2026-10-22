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
5. `planejamento/` — levantamento de escopo em andamento (comece por `planejamento/situacao.md`).

## Mapa

| Pasta | O que tem |
|---|---|
| `docs/` | Decisões, handoff, layouts de carga |
| `planejamento/` | Levantamento de escopo: situação, decisões e mudanças de escopo, perguntas abertas, jornadas, cronograma |
| `db/migrations/` | Schema SQL (portável: qualquer Postgres 15+) |
| `db/tests/` | Teste das regras de pedido (roda dentro do `npm test`) |
| `cargas/` | Modelo de planilha (sem dados corporativos) |
| `web/` | Aplicação (Next.js 16 + Postgres), scripts e testes |
| `dados/` | **Fora do Git.** Bases brutas, extrações do CSPS, planilhas com dado da rede |

## Rodar na sua máquina

```
cd web
copy .env.example .env.local      (preencher DATABASE_URL e APP_URL)
npm ci
npm run migrar                    (aplica migrations pendentes no banco do .env.local)
npm run dev                       (http://localhost:3000)
```

Primeiro acesso: em desenvolvimento, a tela de entrada mostra o link. Em produção, sem e-mail configurado:
`npm run link -- seu@email.com` gera o link pelo terminal; depois disso, o admin gera links em `/admin/usuarios`.

Antes de todo commit: `npm run build && npm test && npm run lint` (dentro de `web/`), sem erros.

## Stack

Next.js 16 (App Router, sem Cache Components) · Postgres (Neon, projeto `rodada-de-negocios`, São Paulo) via driver
`postgres` · login por convite com link mágico de uso único · testes com Vitest + PGlite (Postgres dentro do Node,
dispensa Postgres instalado). Arquitetura portável: SQL puro e app Node comum, sem recurso exclusivo do provedor.
