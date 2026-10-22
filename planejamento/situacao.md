# Situação do escopo

> Painel do levantamento. Atualizado em **22/10/2026**. Atualizar sempre que uma decisão, mudança ou pergunta mudar
> de estado. Detalhes nos arquivos ligados.

## Resumo

| Indicador | Hoje |
|---|---|
| Regras vigentes (`docs/decisoes.md`) | Decisões de 16/10; **9 temas em revisão** pelo levantamento (🟡 abaixo) |
| Direções do levantamento (`decisoes-de-escopo.md`) | 21 registradas (19 direções, 1 proposta, 1 hipótese), 2 descartadas, nenhuma aprovada |
| Mudanças de escopo (`mudancas-de-escopo.md`) | 16 em análise, 0 aprovadas, 0 aplicadas |
| Perguntas abertas (`perguntas-abertas.md`) | 53 abertas, das quais 18 de prioridade A (2 condicionadas a `P-29`) |
| Jornadas (`jornadas.md`) | 12 mapeadas: 0 validadas, 5 em levantamento, 7 só declaradas |
| Próximo passo de desenvolvimento no HO | Tela de negociação; **depende de MUD-02, MUD-03 e MUD-05** |

## Por tema

Legenda: ✅ definido e sem contestação · 🟡 vigente, mas em revisão · 🔵 direção nova, falta detalhe · ⚪ não definido

| Tema | Estado | O que está definido | O que falta | Ligações |
|---|---|---|---|---|
| Hierarquia e grupo por marca | ✅ | Marca → Regional → Setor → CPV → Grupo → Dealer; um grupo por marca | Estrutura da rede PSA | `P-10` |
| Dealer como destino | ✅ | Escolhido por linha, sem rateio | — | — |
| Governança do escopo | ⚪ | — | Quem aprova e promove mudanças | `MUD-01`, `P-01`, `P-02` |
| Perfis e permissões | 🟡 | Matriz de 9 perfis em DEC; mapear perfis antes de cadastrar (`DE-01`) | Central Stellantis, acesso da concessionária, permissões por fase e estado | `MUD-09`, `P-05` a `P-08` |
| Carteira e cobertura de CPV | 🔵 | Carteira por rodada (DEC); cobertura entre CPVs da regional (`DE-02`) | Recorte, vigência, autorização, retorno | `MUD-12`, `P-09` |
| Ciclo do pedido | 🟡 | Rascunho → fechado; só fechado conta (DEC); nova versão encadeada e só vigente e fechada conta (`DE-07` a `DE-10`) | Pedido ou linha; estados; pós-exportação | `MUD-02`, `P-36` a `P-39` |
| Sugestão e reposição | 🟡 | Fórmula em DEC; 21 pontos = frequência (`DE-03`); 90 dias (`DE-05`); MIRA como referência (`DE-06`) | Se a plataforma calcula; fórmula; trânsito; QME; faixas | `MUD-03`, `MUD-04`, `P-29` a `P-35` |
| Preço e desconto | 🟡 | Preço único por PN (DEC); duas listas Stellantis e desconto da promocional (`DE-13`, `DE-14`) | Preço efetivo por concessionária; regra única ou por destino; desconto progressivo | `MUD-05`, `P-13` a `P-17` |
| Valor do indicador | 🟡 | Quantidade × preço (DEC); valor sem ST (`DE-15`) | Composição e validação fiscal | `MUD-06`, `P-18` |
| Fornecedores e ofertas | 🟡 | Catálogo carregado pelo admin (DEC); fornecedor carrega e ajusta, cria pedidos (`DE-16`, `DE-17`) | Prazo, bloqueio, canal, jornada de pedido | `MUD-08`, `P-11`, `P-12`, `P-22`, `P-23` |
| Categorias e metas | 🟡 | Meta grupo × categoria em R$ (DEC) | FULL dentro ou fora do armazém; contratos; metas de CPV | `MUD-07`, `MUD-10`, `MUD-14`, `P-24` a `P-27` |
| Indicadores | 🟡 | Atingimento, cobertura, potencial (DEC) | Definição completa de cada um | `P-28` |
| Lista especial por ordem de chegada | ⚪ | — | Se existe | `MUD-15`, `P-21` |
| Painel e telão | 🔵 | Referência do painel de junho; telão sem login (DEC) | Exposição, frequência, patrocinadores, premiações | `MUD-16`, `P-41`, `P-42` |
| CSPS e conciliação | 🟡 | Exportação consolidada e conciliação por dealer × PN (DEC; views existem) | Layout, chave, responsáveis | `P-39`, `P-40` |
| Capacidade e testes | 🔵 | ~300 usuários gravando (`DE-11`); plano de testes em três frentes (`DE-12`) | Critérios numéricos, volumetria, orçamento | `MUD-11`, `P-46` a `P-48` |
| Hospedagem e dados | ⚪ | Neon + Vercel como hospedagem própria (DEC), sujeita a alinhamento | Aprovação da liderança; dados pessoais | `P-43`, `P-44`, `P-50` |
| Calendário | 🔵 | Evento na 2ª semana de dezembro; testes a partir de 16/11 (referência) | Dia exato; cortes de escopo | `MUD-13`, `P-04`, `cronograma.md` |
| Operação no dia | ⚪ | Power BI como contingência do telão (DEC) | Suporte, treinamento, plano de falha | `P-49`, `P-51` |

## Propostas técnicas em avaliação (não aprovadas)

Registradas no consolidado do Codex (§17–19). Ficam aqui para não se perderem; nenhuma está aprovada.

- Backend modular com PostgreSQL como fonte da verdade; sem microsserviços nem múltiplos bancos graváveis.
- Resumos ou consultas agregadas para o painel, sem recalcular tudo a cada atualização.
- Gravações idempotentes e controle de versão para concorrência.
- Teste de carga com k6 (ou equivalente) e navegadores reais com Playwright (ou equivalente).
- Estimativa de US$ 100 a 250 no mês do evento para aplicação e banco (não é orçamento).

## Recomendação para os próximos dias

1. Responder `P-01` (quem aprova escopo). Sem isso, nenhuma `MUD` sai de "em análise".
2. Levar ao corte 1 (`cronograma.md`) as oito perguntas prioritárias de `perguntas-abertas.md`.
3. Antes de construir a tela de negociação, decidir `MUD-02` (modelo de pedido), `MUD-03` (sugestão) e `MUD-05`
   (preço). Enquanto isso, o desenvolvimento pode avançar no que não depende delas: base fictícia em tamanho real
   (`P-45`), estrutura do painel sobre as views existentes e o roteiro dos testes de carga.

## Histórico deste arquivo

| Data | Registro |
|---|---|
| 22/10/2026 | Criação a partir da comparação entre repositório, levantamento de 19–20/10 e consolidado do Codex |
