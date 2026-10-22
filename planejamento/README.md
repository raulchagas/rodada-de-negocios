# Planejamento — levantamento de escopo da Rodada de Negócios

Pasta viva onde documentamos a jornada de planejamento: o que já está decidido, o que está em discussão, o que mudou
e por quê. Nesta primeira etapa o escopo muda com frequência; a pasta existe para que nenhuma mudança se perca e
nenhuma hipótese seja confundida com decisão.

> **Relação com `docs/decisoes.md`.** `docs/decisoes.md` continua sendo a fonte das regras **vigentes** (as que o
> código implementa). Esta pasta guarda o levantamento **em andamento**. Uma regra só passa a valer para o código
> quando é promovida para `docs/decisoes.md` por uma mudança de escopo aprovada (ver "Como uma mudança anda" abaixo).

## Arquivos

| Arquivo | Para que serve | Quando mexer |
|---|---|---|
| [`situacao.md`](situacao.md) | Painel: o que está definido e o que está pendente, por tema | Sempre que algo mudar de estado |
| [`decisoes-de-escopo.md`](decisoes-de-escopo.md) | Registro de decisões e direções (`DE-xx`) com origem e estado | Quando uma direção é declarada ou aprovada |
| [`mudancas-de-escopo.md`](mudancas-de-escopo.md) | Log de mudanças de escopo (`MUD-xx`): antes, depois, motivo e impacto | Quando algo já registrado muda ou diverge |
| [`perguntas-abertas.md`](perguntas-abertas.md) | Perguntas que bloqueiam o fechamento (`P-xx`), com dono e prazo | Ao surgir ou responder uma pergunta |
| [`jornadas.md`](jornadas.md) | Jornadas por público e o quanto cada uma está levantada | Ao detalhar uma jornada |
| [`cronograma.md`](cronograma.md) | Datas, marcos e dependências de calendário | Ao mudar data ou dependência |
| [`comparativo-fontes.md`](comparativo-fontes.md) | Comparação entre o repositório e as conversas com o Codex (21/10) | Retrato de 22/10; não atualizar, criar outro se necessário |
| [`fontes/`](fontes/) | Cópias congeladas dos documentos de origem | Só acrescentar; nunca editar uma fonte |

## Legenda de estado

Use sempre um destes estados. Eles separam o que foi dito do que foi aprovado.

| Estado | Significado |
|---|---|
| **Vigente** | Está em `docs/decisoes.md` e vale para o código |
| **Aprovado** | Aprovado no levantamento, aguardando entrar em `docs/decisoes.md` |
| **Direção** | Orientação declarada numa conversa; ainda precisa de detalhe ou aprovação |
| **Proposta** | Sugestão (de UX, arquitetura, processo) para discutir; não é decisão |
| **Hipótese** | Exemplo ou suposição de trabalho; não pode virar requisito sem confirmação |
| **Pendente** | Falta resposta, dado ou validação |
| **Descartado** | Foi considerado e abandonado; fica registrado com o motivo |

## Como uma mudança anda

1. **Registrar.** Algo novo ou diferente apareceu numa conversa, reunião ou documento: abrir uma `MUD-xx` em
   `mudancas-de-escopo.md` com estado *Em análise*, citando a fonte e o que já estava registrado antes.
2. **Analisar o impacto.** Preencher o que a mudança afeta: regras, dados/cargas, banco, telas, testes e prazo.
   Se faltar informação, abrir a `P-xx` correspondente.
3. **Decidir.** Quem aprova escopo decide (ver P-01). A `MUD` fica *Aprovada* ou *Rejeitada*, com data e quem decidiu.
4. **Promover.** Mudança aprovada que altera regra entra em `docs/decisoes.md` (e, se for o caso, em
   `docs/cargas.md`, migrations e testes). A `MUD` passa a *Aplicada* e aponta o commit ou PR.
5. **Atualizar o painel.** Ajustar `situacao.md` e, se mudou data, `cronograma.md`.

Regras práticas:

- Nunca apagar uma linha de registro: mudar o estado e anotar a data. O histórico é o valor da pasta.
- Toda entrada leva **data** e **fonte** (chamada, conversa, documento, pessoa).
- Exemplos numéricos ficam marcados como *Hipótese* até alguém confirmar.
- Dado corporativo (bases, extrações, metas reais) não entra aqui; vai para `dados/`, fora do Git.
- Numeração é sequencial e não se reaproveita (`DE-01`, `MUD-01`, `P-01`…).

## Fontes usadas até agora

| Fonte | Data | Onde |
|---|---|---|
| Decisões vigentes (Raul) | 16 e 19/10/2026 | `docs/decisoes.md` |
| Handoff técnico | 19/10/2026 | `docs/HANDOFF.md` |
| Levantamento de escopo e jornadas (chamadas com Marcos) | 19 e 20/10/2026 | [`fontes/2026-10-20_levantamento-escopo-e-jornadas.md`](fontes/2026-10-20_levantamento-escopo-e-jornadas.md) |
| Consolidado das conversas com o Codex | 21/10/2026 | [`fontes/2026-10-21_consolidado-conversas-codex.md`](fontes/2026-10-21_consolidado-conversas-codex.md) |
| Código no commit `f30571f` | 19/10/2026 | `db/`, `web/` |

O levantamento de 19–20/10 existia só na pasta local do projeto, fora do Git; a cópia em `fontes/` é a primeira
versão dele no repositório. Daqui em diante, o levantamento continua nos arquivos desta pasta, não naquele documento.
