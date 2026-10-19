# CLAUDE.md — Rodada de Negócios

Idioma: português do Brasil em tudo (código, commits, docs, textos de tela).

## Leia primeiro, nesta ordem
1. `docs/decisoes.md` — decisões vigentes. Se outro texto divergir, vale este; aponte a divergência e pergunte.
2. `docs/HANDOFF.md` — estado atual, estado do banco, próximo passo.
3. `docs/cargas.md` — ao mexer em importação ou no modelo de dados.
4. `web/AGENTS.md` — Next.js 16 mudou APIs: ler o guia em `web/node_modules/next/dist/docs/` antes de usar uma API do Next.

## Regras
- Schema só via migration em `db/migrations/` (SQL puro, idempotente, numeração sequencial). Nada pelo dashboard do provedor.
  Aplicar com `npm run migrar` (dentro de `web/`), que registra em `rodada.migracao`.
- Função plpgsql que lê tabela leva `set search_path = rodada, public`; consulta no app qualifica `rodada.` (o pooler não guarda search_path).
- Front nunca lê tabela bruta de pedidos: lê as views `v_*` (`db/migrations/0001_schema.sql`).
- Regras de gravação (QME, destino do grupo, responsável × categoria, bloqueio otimista) ficam nos triggers do banco;
  o app repete a validação para dar mensagem boa, mas o banco é a última linha.
- Toda página, rota e ação confere a sessão no servidor (`exigirUsuario` / `adminDaRota`); o `proxy.ts` é só checagem otimista.
- Dado corporativo (bases da rede, extrações do CSPS, metas reais) só em `dados/`, que está no `.gitignore`.
  Modelos em `cargas/` levam linhas de exemplo fictícias. Segredos só em `web/.env.local` (fora do Git).
- Todo valor em R$ nas telas com formatação brasileira (`lib/format.ts`); em tabelas de análise, média mensal quando houver período.
- Verificação antes de todo commit, dentro de `web/`: `npm run build && npm test && npm run lint`, sem erros.
- Ao fim de cada sessão: atualizar `docs/HANDOFF.md` e fazer commit.
- Commits com `raul_chagas@hotmail.com`.
