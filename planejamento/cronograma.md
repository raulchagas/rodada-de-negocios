# Cronograma, marcos e dependências

> Nenhuma data abaixo é compromisso aprovado, exceto quando o estado disser *Aprovado*. Datas em horário de Brasília.

## Linha do tempo

| Data | Marco | Estado | Fonte |
|---|---|---|---|
| 16/10/2026 | Rascunho técnico iniciado; 20 perguntas respondidas por Raul (`docs/decisoes.md`) | Realizado | DEC, HO |
| 19/10/2026 | Repositório no GitHub, banco no Neon, login por convite, tela de cargas, testes (commit `f30571f`) | Realizado | HO |
| 19–20/10/2026 | Chamadas de levantamento de escopo com Marcos | Realizado | LEV |
| 20/10/2026, 16h30 | Reunião de handoff | Resultado não registrado | LEV, CDX |
| 21/10/2026 | Consolidado das conversas com o Codex | Realizado | CDX |
| 22/10/2026 | Pasta `planejamento/` criada; 16 mudanças de escopo e 53 perguntas registradas | Realizado | este repositório |
| a definir | **Congelamento do escopo estrutural** (modelo de pedido, preço, sugestão, perfis) | Proposta | ver abaixo |
| 16/11/2026 (segunda) | Plataforma pronta para testes | Hipótese (referência conservadora) | LEV, CDX |
| 23–27/11/2026 (última semana de novembro) | Chegada das regras de desconto progressivo ou por lote | Hipótese | LEV |
| 16/11 a 04/12/2026 | Testes massivos e correções (pelo menos três semanas) | Hipótese | LEV |
| 2ª semana de dezembro (provavelmente 07 a 11/12/2026) | **Evento** | Direção; dia exato pendente (`P-04`) | LEV |
| pós-evento | Ajustes, exportação, colocação no CSPS, conciliação | Pendente | DEC |

O intervalo 07 a 11/12 é inferência (1º/12/2026 cai numa terça); confirmar em `P-04`.

## O que a conta do calendário mostra

- **De hoje (22/10) a 16/11 são 25 dias corridos**, ou 15 dias úteis entre 23/10 e 13/11 (já sem o feriado de
  02/11; a janela de testes ainda perde o feriado de 20/11). Nesse intervalo precisam caber o fechamento das
  decisões estruturais e a construção da negociação, do versionamento e do painel (etapas 1 e 2 da sequência de
  entrega), que hoje não começaram.
- **16/11 + 3 semanas = 07/12**, a própria semana provável do evento. Se a referência de três semanas de testes for
  mantida, não sobra folga entre o fim dos testes e o evento.
- **Regras de desconto chegam no meio da janela de testes** (última semana de novembro). O que depender delas será
  testado em poucos dias. Por isso convém que o modelo de preço aceite essas regras como **parâmetro carregado**, não
  como código novo (`MUD-05`).
- **Cada semana sem decidir `MUD-02`, `MUD-03` e `MUD-05`** é uma semana em que a tela de negociação ou espera, ou é
  construída sobre o modelo atual com risco de retrabalho.

## Proposta de congelamento (a discutir)

Para controlar as mudanças, sugere-se fixar duas datas de corte. São **propostas**, não decisões:

| Corte | O que congela | Por quê |
|---|---|---|
| Corte 1 (sugestão: até 30/10) | Decisões estruturais: P-01, P-07, P-08, P-13 a P-15, P-24, P-29, P-36, P-37 | Definem o banco e a tela de negociação; mudar depois custa reescrita |
| Corte 2 (sugestão: 16/11, entrada em testes) | Todo o resto, exceto parâmetros que chegam por carga (descontos, metas, faixas de curva) | Depois disso, mudança só entra como correção ou como parâmetro, com `MUD` aprovada |

Depois do corte 2, uma mudança só entra com `MUD` aprovada que diga explicitamente o que sai ou o que atrasa.

## Dependências críticas (ordem)

1. Governança e decisões estruturais (`P-01`, corte 1).
2. Bases e layouts reais: hierarquia FCA e PSA, carteira, usuários, base de demanda ou sugestão, preços (`P-10`, `P-13`, `P-48`).
3. Núcleo de pedidos: modelo de versão, permissões e concorrência (`MUD-02`).
4. Tela de negociação interna (etapa 1 do HO).
5. Painel e telão (etapa 2 do HO).
6. Ambiente aprovado e publicação (`P-43`, `P-44`).
7. Testes de regra, carga e navegador (`DE-12`, `P-46`).
8. Acessos externos: fornecedor, concessionária (etapa 3 do HO).
9. Exportação CSPS e conciliação (etapa 4 do HO, `P-40`).

Com 4 e 5 prontos e testados, a rodada funciona só com o time interno, mesmo que 8 atrase (premissa de DEC).

## Riscos de calendário

| Risco | Efeito | Tratamento proposto |
|---|---|---|
| Decisões estruturais atrasam | Tela de negociação construída sobre modelo que vai mudar | Corte 1; priorizar as oito perguntas de `perguntas-abertas.md` |
| Regras comerciais no fim de novembro | Pouco tempo de teste sobre preço e desconto | Regras como parâmetro carregado; caso de teste pronto antes de a regra chegar |
| Bases reais tardias | Testes de carga sem volume real | Base fictícia em tamanho real (`P-45`) e volumetria estimada cedo (`P-48`) |
| Aprovação de hospedagem tardia | Publicação bloqueada | Levar `P-43` à liderança já |
| Janela de testes até a semana do evento | Sem folga para correção final | Rever a duração dos testes ou antecipar a entrada em testes |

## Histórico deste arquivo

| Data | Registro |
|---|---|
| 22/10/2026 | Criação com marcos de LEV e CDX, conta de calendário e proposta de dois cortes de escopo |
