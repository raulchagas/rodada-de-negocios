# HANDOFF — Rodada de Negócios

## Estado atual (19/10/2026)

**Banco (Neon, projeto `rodada-de-negocios` / `purple-pond-25577769`, região São Paulo, Postgres 17, database `rodada`):**
migrations 0001–0003 aplicadas e registradas em `rodada.migracao`; rodada `2026-12` criada e ativa com as 7 categorias
e a matriz perfil × categoria padrão; um usuário admin (Raul). Nenhuma base carregada ainda.

**App (`web/`, Next.js 16.4):** roda local; ainda **não publicado** na Vercel.
- Login por convite: link de uso único (30 min) → página de confirmação → sessão de 14 dias (cookie httpOnly).
  Sem e-mail configurado: link aparece na tela em desenvolvimento (ou com `LINK_NA_TELA=1`), sai pelo terminal
  (`npm run link -- email`) ou é gerado pelo admin em `/admin/usuarios`.
- `/admin/cargas`: envio de planilha com uma ou várias abas; leitura no navegador, lotes de 2.000 linhas,
  validação e aplicação no banco (`rodada.aplicar_carga`), tudo ou nada, histórico com erros por linha.
- Início: estado das bases da rodada (o que já foi carregado). Perfis não admin veem aviso de negociação em construção.

**Testes:** `npm test` (12 testes em PGlite: migrations idempotentes, regras de pedido, cargas com o modelo, erros,
número brasileiro, parser da planilha, limpeza da URL do Neon). Ponta a ponta no navegador (15 verificações: login,
link de uso único, carga, permissões, celular, sair) rodado em 19/10; o roteiro ficou fora do repositório.

## Sessões

- 16/10: entendimento fechado (20 perguntas, `docs/decisoes.md`), schema 0001, layouts e modelo de carga.
- 19/10: repositório no GitHub, Neon provisionado, migrations 0002 (login, controle de migrations, staging de carga)
  e 0003 (aplicar_carga, criar_rodada), app com login e cargas. Correções achadas pelos testes: `search_path` nas
  funções, meta de consultor "total" (categoria nula) não cabia na chave primária, nota dentro de aba do modelo era lida
  como dado (notas foram para a aba leia-me), `channel_binding` da string do Neon quebrava o driver.

## Decisões técnicas desta fase

- Next.js sem Cache Components (`cacheComponents: false`): app interno, todo autenticado e com dado ao vivo.
- Driver `postgres` (porsager) com `prepare: false` (pooler do Neon), consultas sempre com `rodada.` qualificado.
- Fonte do sistema (Segoe UI no Windows): Google Fonts não carrega em rede restrita.
- Leitura de planilha: `read-excel-file` 9 (mantida; `exceljs` parado desde 2023; SheetJS do npm parado na 0.18).

## Próximo passo

1. Tela de negociação (CPV/grupo): grupo → lista de PNs com condição, sugestão e potencial restante, digitação por
   destino, totais por categoria contra a meta, rascunho/fechado. Depende de base real ou de uma base fictícia maior.
2. Publicar na Vercel (variáveis `DATABASE_URL`, `APP_URL`), depois do alinhamento com a liderança sobre hospedagem.
3. Painel de resultados e telão (layout de junho/2026).
4. Envio de e-mail do link (Resend) antes de abrir para a rede.

## Regras de trabalho

- Schema só por migration (`npm run migrar`); views são a interface do front.
- Dado corporativo só em `dados/` (fora do Git); segredos só em `web/.env.local`.
- Ao fim de cada sessão: atualizar este arquivo e fazer commit.
