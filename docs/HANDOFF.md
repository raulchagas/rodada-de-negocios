# HANDOFF — Rodada de Negócios

## Estado atual (16/10/2026)

Sessão 1: entendimento fechado com o Raul (20 perguntas, registradas em `docs/decisoes.md`) e base do projeto criada.

Pronto:
- `db/migrations/0001_schema.sql` — schema `rodada` completo: rodada, fases, categorias, matriz perfil × categoria,
  hierarquia (marca → regional → setor → grupo → dealer), consultores e carteira, fornecedores, usuários e escopo,
  itens e base 21 pontos (sugestão calculada por trigger), metas (grupo × categoria, consultor), `pedido_linha` com
  validações (QME, destino do grupo, responsável × categoria, bloqueio otimista por `versao`), auditoria, cargas,
  colocado no CSPS e as views `v_atingimento_grupo`, `v_atingimento_consultor`, `v_realizado_fornecedor`,
  `v_potencial`, `v_conciliacao`, `v_exportacao_csps`.
  Aplicada duas vezes num Postgres 16 limpo (idempotente). Teste de regras: `db/tests/smoke.sql` (SMOKE_OK).
- `docs/cargas.md` + `cargas/modelos_cargas.xlsx` — layout das planilhas de entrada, com exemplos fictícios.

Banco: nenhum provisionado ainda. Nada em produção.

## Decisão pendente do Raul

Provedor do Postgres e autenticação (ver sugestão na conversa de 16/10): Neon + Next.js com Auth.js (link mágico por
Resend) **ou** Supabase (Auth com link mágico já pronto). O schema é o mesmo nos dois; muda só `app/` e o deploy.

## Próximo passo

1. Raul cria o repositório privado `rodada-de-negocios` no GitHub e faz o primeiro push (comandos no README).
2. Provisionar o Postgres e aplicar `0001`.
3. `app/`: esqueleto (Next.js), login por convite, tela de cargas (admin) com os validadores de `docs/cargas.md`.
4. Tela de negociação (CPV/grupo): lista de PNs com sugestão e potencial restante, digitação com destino por linha,
   totais por categoria contra a meta.
5. Painel de resultados e telão (réplica do layout de junho/2026).

## Regras de trabalho

- Schema só por migration; views são a interface do front.
- Dado corporativo só em `dados/` (fora do Git).
- Ao fim de cada sessão: atualizar este arquivo e fazer commit.
