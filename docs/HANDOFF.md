# HANDOFF — Rodada de Negócios (gestão de pedidos)

> Documento de entrada no projeto. Vale para quem já está nele e para quem chega agora.
> Atualizado em 19/10/2026. Atualizar ao fim de cada sessão de trabalho (seção 14).

---

## 1. Em uma frase

Ferramenta web que **substitui a digitação de pedidos e o painel do Power BI durante a Rodada de Negócios de dezembro/2026**.
A ferramenta sugere quantidades por dealer a partir da demanda calculada pelos 21 pontos e registra os pedidos de grupos,
consultores e fornecedores. Ela mostra o atingimento ao vivo no telão e, depois do evento, exporta tudo para colocação no
CSPS e confere o que foi efetivamente colocado.

## 2. Situação hoje

| Frente | Situação |
|---|---|
| Regras de negócio | **Fechadas**: 20 decisões registradas em `docs/decisoes.md` |
| Banco de dados (Neon) | **Pronto**: schema completo, regras de gravação, rodada `2026-12` criada |
| Login por convite | **Pronto** (link de uso único, sem e-mail automático por enquanto) |
| Carga de planilhas | **Pronta**: 9 tipos de base, validação completa, tudo ou nada |
| Tela de negociação (pedidos) | **A fazer**: próximo passo |
| Painel de resultados / telão | A fazer |
| Acesso da rede e de fornecedores | A fazer (o modelo de dados já suporta) |
| Exportação CSPS e conciliação | A fazer (as consultas no banco já existem) |
| Publicação na internet (Vercel) | Aguardando decisão |
| Bases reais (21 pontos, hierarquia, carteira, metas) | **Não carregadas**: dependem do time |

**Prazo:** o evento é em dezembro/2026. Ordem de entrega pensada para que, com negociação + painel prontos, a rodada
funcione só com o time interno, mesmo que o acesso da rede atrase.

## 3. Como a rodada funciona na ferramenta

| Fase | Quem usa | O que acontece |
|---|---|---|
| **Preparação** | Admin | Carrega as bases da rodada (seção 5) e cadastra os usuários |
| **Pré-rodada** | CPV e grupo | Montam o pedido em **rascunho** a partir da sugestão |
| **Evento** | Todos os perfis | Fecham os pedidos; o telão mostra só o que está **fechado** |
| **Pós-evento** | Time interno | Ajustes com motivo, exportação para o CSPS, carga do que foi colocado e conciliação |

Datas de cada fase e quem edita em cada uma são parâmetros da rodada. A regra exata será definida perto do evento.

**Regras centrais** (detalhes em `docs/decisoes.md`):

- **Hierarquia:** Marca → Regional → Setor → CPV → Grupo → Dealer.
- **Grupo é a unidade de negociação, meta e atingimento.** Existe um grupo por marca: um grupo com Fiat e CJDR vira dois grupos.
- **Dealer é só o destino da entrega.** Quem digita escolhe o dealer em cada linha; não há rateio automático.
- **Meta por grupo × categoria**, em R$. Categorias prováveis, as mesmas de junho: Peças, Acessórios, Envios Full, Bpro,
  Circ. Autopeças, Shell, Outros DFS.
- **Sugestão** = demanda − estoque − trânsito, arredondada para cima ao múltiplo de embalagem (QME). Todo pedido é
  múltiplo de QME.
- **Potencial restante** = sugestão − pedido. É um número vivo; acima de 100% aparece como "acima da sugestão".
- **Atingimento** = pedido fechado ÷ meta. **Cobertura** = pedido ÷ sugestão.
- **Quem digita:** CPV e grupo, sem aceite formal do grupo. A ferramenta guarda quem registrou e quando.
- **Consultores por categoria:** CPV em todas; CNA em Peças; CNE em E-commerce; F&I em Acessórios. A linha do pedido tem
  um responsável, e o banco recusa responsável fora da sua categoria.
- **Fornecedores (DFS/DSH):** pedem pelo próprio login, com catálogo próprio. O pedido deles conta no atingimento do grupo.

## 4. Perfis de acesso

| Perfil | Vê | Edita |
|---|---|---|
| Admin | tudo | tudo, cargas e cadastro da rodada |
| Regional (supervisores) | a própria regional | linhas permitidas da própria regional |
| CPV / CNA / CNE / F&I | os grupos da sua carteira | linhas das categorias que conduz |
| Grupo | o próprio grupo (um ou mais, por marca) | pedidos do próprio grupo |
| Fornecedor | as próprias linhas em todos os grupos | linhas do próprio catálogo |
| Telão | painel de resultados, sem login | nada |

## 5. Bases de entrada (onde o time mais contribui)

Tudo entra por **uma planilha Excel com uma aba por base**, enviada pelo admin na tela **Cargas**. O modelo está em
`cargas/modelos_cargas.xlsx`, com cabeçalhos certos e exemplos fictícios; o layout completo, coluna a coluna, está em
`docs/cargas.md`.

| Aba | Conteúdo | Origem provável | Quando |
|---|---|---|---|
| `hierarquia` | marca, regional, setor, grupo, dealer | cadastro comercial | antes de tudo |
| `consultores` | CPV, CNA, CNE, F&I (nome, perfil, setor, e-mail) | time interno | antes da carteira |
| `carteira` | consultor × grupo da rodada | time interno | antes do evento |
| `usuarios` | e-mail, perfil e escopo de cada pessoa com acesso | time interno | antes do evento |
| `base21` | dealer × PN: demanda, estoque, trânsito, QME, preço e condição | Power BI (21 pontos) | antes da pré-rodada |
| `catalogo_fornecedor` | itens e condições de cada DFS/DSH | fornecedores | antes do evento |
| `metas` | grupo × categoria, em R$ | a calcular para dez/2026 | antes do evento |
| `metas_consultor` | metas individuais, para os rankings | a calcular | antes do evento |
| `csps` | o que foi colocado no CSPS | extração do CSPS | pós-evento |

Cuidados que mais geram erro:

- **Códigos como texto.** Um dealer `000123` não pode virar `123`; formate a coluna como Texto antes de colar.
- **Aba só com dados.** Nada de nota, total ou linha em branco com fórmula embaixo da tabela.
- **O mesmo PN tem os mesmos dados em todas as linhas.** Categoria, QME, preço e condição não podem variar entre dealers.
- **Envio é tudo ou nada.** Com qualquer erro, nada entra, e a tela mostra aba, linha e motivo. Corrija e envie de novo;
  reenviar a mesma base é seguro.

## 6. Onde está cada coisa

| Item | Onde |
|---|---|
| Código e documentação | GitHub `raulchagas/rodada-de-negocios` (privado) · pasta local `C:\Projects\rodada-de-negocios` |
| Banco de dados | Neon, projeto `rodada-de-negocios` (id `purple-pond-25577769`), região São Paulo, Postgres 17, database `rodada`, schema `rodada` |
| App publicado | ainda não publicado (Vercel, a decidir) |
| Senhas e conexão | só no arquivo `web/.env.local` de cada máquina (**nunca** no Git, e-mail ou chat) |
| Dados reais da rede | só na pasta `dados/` (fora do Git) |

Mapa do repositório:

| Pasta / arquivo | O que tem |
|---|---|
| `docs/decisoes.md` | regras de negócio vigentes; prevalecem sobre qualquer outro texto |
| `docs/HANDOFF.md` | este documento |
| `docs/cargas.md` | layout das planilhas de carga |
| `cargas/modelos_cargas.xlsx` | modelo da planilha (exemplos fictícios) |
| `db/migrations/` | estrutura do banco em SQL (`0001` schema, `0002` login e cargas, `0003` validação das cargas) |
| `db/tests/smoke.sql` | teste das regras de pedido |
| `web/` | aplicação (telas, rotas, scripts, testes) |
| `CLAUDE.md` | regras para quem desenvolve (pessoa ou IA) |

## 7. Como rodar na sua máquina (Windows)

Pré-requisitos: Git e Node.js. Recomendado: **Node 24 LTS** (a versão 25 roda o app, mas não é suportada oficialmente pela ferramenta de testes).
Também é preciso acesso ao repositório no GitHub e a string de conexão do banco, que deve ser pedida ao dono do projeto
por canal seguro.

```
git clone https://github.com/raulchagas/rodada-de-negocios.git C:\Projects\rodada-de-negocios
cd C:\Projects\rodada-de-negocios\web
copy .env.example .env.local
```

No `.env.local`, preencher `DATABASE_URL` (a string pode ser colada como vem do painel do Neon) e `APP_URL=http://localhost:3000`. Depois:

```
npm ci
npm run dev
```

Abrir http://localhost:3000, informar o e-mail cadastrado e clicar em "Abrir link de acesso". No computador local, o
link aparece na própria tela.

Comandos úteis, sempre dentro de `web/`:

| Comando | Para quê |
|---|---|
| `npm run dev` | app local em http://localhost:3000 |
| `npm run migrar` | aplica no banco as mudanças de estrutura pendentes |
| `npm run link -- email@x.com` | gera link de acesso pelo terminal (primeiro acesso em produção) |
| `npm test` | testes automatizados (dispensa Postgres instalado) |
| `npm run build` / `npm run lint` | conferência antes de todo commit |

Avisos esperados no `npm ci`: "5 high severity vulnerabilities" são de ferramentas de desenvolvimento, e o app em si
tem 0. **Não rodar `npm audit fix --force`.**

## 8. Como a aplicação funciona por dentro (resumo técnico)

- **Stack:** Next.js 16 (React), Postgres via driver `postgres`, Tailwind. Sem dependência exclusiva do provedor: dá
  para migrar para o servidor da empresa com o mesmo código.
- **Regras críticas ficam no banco** e valem para qualquer tela ou carga. São elas: QME e mínimo, dealer pertencente ao
  grupo, responsável autorizado na categoria, bloqueio de edição simultânea e trilha de auditoria de toda alteração de
  pedido.
- **Telas leem as visões do banco** (`v_atingimento_grupo`, `v_atingimento_consultor`, `v_realizado_fornecedor`,
  `v_potencial`, `v_conciliacao`, `v_exportacao_csps`). Elas nunca leem a tabela de pedidos direto.
- **Login:** o link de uso único vale 30 minutos e abre uma página com o botão "Entrar". Esse clique extra existe porque
  o antivírus do e-mail corporativo abre os links e gastaria o token. A sessão dura 14 dias. O admin gera links em
  **Usuários**.
- **Cargas:** o navegador lê o Excel e envia as linhas em lotes de 2.000. A função `rodada.aplicar_carga` valida e
  aplica tudo numa transação.
- **Telas existentes:** Entrar · Início (situação das bases) · Cargas · Usuários.

## 9. Qualidade e testes

- `npm test`: 12 testes automatizados. Cobrem a estrutura aplicada duas vezes sem erro, as regras de pedido, a carga
  completa da planilha modelo, a recarga idempotente, a planilha com erro que não aplica nada, números no formato
  "1.234,56" e o leitor da planilha.
- Teste no navegador (19/10): 15 verificações, cobrindo login, link de uso único, carga pelo navegador, bloqueio de
  perfil sem permissão, tela de celular e saída.
- Regra: nada vai para o GitHub sem `build`, `test` e `lint` passando.

## 10. Próximos passos

| # | Entrega | Depende de | Sugestão de dono |
|---|---|---|---|
| 1 | **Tela de negociação** (CPV/grupo): lista de PNs com condição, sugestão e potencial restante; digitação por dealer; totais por categoria × meta; rascunho/fechado | base de teste (decisão A) | desenvolvimento |
| 2 | **Bases reais em formato de carga**: hierarquia, consultores, carteira, usuários e extração da base 21 pontos do Power BI no layout do modelo | layout `docs/cargas.md` | **analista** |
| 3 | Publicar na Vercel | decisão B | desenvolvimento |
| 4 | Painel de resultados e telão (layout do painel de junho/2026) | 1 | desenvolvimento |
| 5 | Metas de dez/2026 (grupo × categoria e por consultor) no layout de carga | cálculo das metas | **analista** |
| 6 | Acesso da rede e de fornecedores + e-mail automático do link | 3 e alinhamento de hospedagem | desenvolvimento |
| 7 | Layout de importação no CSPS e exemplo da extração do CSPS | — | **analista** |
| 8 | Exportação CSPS e conciliação (telas) | 7 | desenvolvimento |

## 11. Decisões pendentes

| # | Decisão | Sugestão |
|---|---|---|
| A | Construir a negociação com base fictícia em tamanho real ou esperar recorte da base real | fictícia agora; a real entra pela mesma carga |
| B | Publicar na Vercel já, só com dados de teste | sim; dados reais só após o item C |
| C | Alinhamento com a liderança sobre hospedagem própria com dados da rede | necessário antes de carregar dados reais publicados |
| D | Regra de edição por fase (quem edita no pré, no evento e no pós) | definir perto do evento |
| E | O que são Bpro e Circ. Autopeças (regra própria ou só categoria com meta) | tratadas como categoria comum até haver regra |
| F | Formato do arquivo de importação no CSPS | depende do item 7 da seção 10 |

## 12. Riscos e cuidados

| Risco | Cuidado |
|---|---|
| Prazo curto até dezembro | ordem de entrega garante a rodada só com time interno se o acesso externo atrasar |
| Rede corporativa bloquear a conexão do laptop com o Neon | se `npm run dev` der erro de conexão, avisar; alternativa é usar o app publicado |
| Base 21 pontos grande demais | carga em lotes pensada para isso; testar com a base real cedo |
| Dados da rede fora da infraestrutura da empresa | decisão C antes de dados reais em produção; arquitetura portável para migrar |
| Conexão do banco vazada | só no `.env.local`; se vazar, trocar a senha no painel do Neon |
| Duas pessoas editando o mesmo pedido | bloqueio no banco avisa "alterada por outra pessoa, recarregue" |

## 13. Regras de trabalho

- **Regras de negócio novas ou mudadas** entram primeiro em `docs/decisoes.md`.
- **Estrutura do banco** muda só por arquivo novo em `db/migrations/`, aplicado com `npm run migrar`; nunca pelo painel do Neon.
- **Dado corporativo nunca vai para o Git.** Bases reais ficam em `dados/`. Senhas só no `.env.local`.
- **Commits** com o e-mail `raul_chagas@hotmail.com` (exigência da Vercel), mensagem em português.
- **Antes de commit:** `npm run build && npm test && npm run lint` dentro de `web/`, sem erros.
- **Ao fim de cada sessão:** atualizar este arquivo (seções 2, 10, 11 e 14) e fazer commit.

## 14. Histórico

| Data | O que aconteceu |
|---|---|
| 16/10/2026 | Entendimento fechado em 20 perguntas (`docs/decisoes.md`); estrutura inicial do banco; layout e modelo de cargas |
| 19/10/2026 | Repositório no GitHub; banco no Neon; login por convite; tela de cargas; testes. Correções achadas pelos testes: funções do banco sem caminho fixo de schema, meta "total" de consultor sem chave, nota dentro da aba do modelo lida como dado, string do Neon que quebrava o driver |

## 15. Glossário

| Termo | Significado |
|---|---|
| **Rodada** | Rodada de Negócios: evento de negociação de pedidos com condições promocionais |
| **21 pontos** | metodologia de cálculo da demanda por dealer × PN (pré-calculada no Power BI) |
| **PN** | part number (código da peça/item) |
| **QME** | quantidade múltipla de embalagem; todo pedido é múltiplo dela |
| **Grupo** | grupo econômico de concessionárias **dentro de uma marca**; unidade de meta e atingimento |
| **Dealer** | concessionária (CNPJ/código CSPS); destino de entrega da linha do pedido |
| **CPV** | consultor de pós-vendas; conduz todas as categorias da sua carteira |
| **CNA / CNE** | consultores de Peças (atacado) e de E-commerce |
| **F&I** | consultor de Acessórios |
| **DFS / DSH** | fornecedores (químicos, acessórios etc.) que vendem na rodada |
| **CSPS** | sistema oficial de pedidos Stellantis; recebe os pedidos só depois do evento |
| **Rascunho / fechado** | estado da linha do pedido; só "fechado" conta no atingimento e no telão |
| **Potencial restante** | sugestão − pedido; mostra o quanto ainda dá para vender por PN, dealer e grupo |
