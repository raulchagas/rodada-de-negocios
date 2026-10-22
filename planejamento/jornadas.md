# Jornadas por público

Mapa das jornadas e de quanto cada uma já foi levantada. Uma jornada só deve virar tela depois de **Validada**.

**Maturidade:** Não iniciada → Declarada (citada numa conversa) → Em levantamento (com perguntas abertas) →
Detalhada (passos, regras e exceções escritos) → Validada (aprovada por quem decide escopo, ver `P-01`).

## Visão geral

| # | Jornada | Público | Maturidade | Vigente hoje (DEC/código) | Bloqueios |
|---|---|---|---|---|---|
| J01 | Preparar a rodada: perfis, usuários, cargas | Admin | Em levantamento | Cargas e convites prontos (tela Cargas e Usuários) | `DE-01`, `P-06`, `P-48` |
| J02 | Carregar e ajustar ofertas | Fornecedor (inclui Stellantis) | Em levantamento | Admin carrega `catalogo_fornecedor`; Stellantis vem na `base21` | `MUD-05`, `MUD-08`, `P-11` a `P-16` |
| J03 | Criar pedido como fornecedor | Fornecedor | Declarada | Fornecedor digita no próprio catálogo (DEC) | `P-22` |
| J04 | Negociar com a carteira e montar o pedido | CPV, CNA, CNE, F&I | Em levantamento | Regras de linha no banco; tela não existe | `MUD-02`, `MUD-03`, `MUD-05`, `P-07`, `P-36` |
| J05 | Colocar pedidos para concessionárias | Regional | Declarada | Regional edita linhas da própria regional (DEC) | `P-07`, `P-08` |
| J06 | Colocar os próprios pedidos | Concessionária / Grupo | Declarada (decisão estrutural pendente) | Perfil Grupo previsto (DEC) | `P-08` |
| J07 | Substituir ou cancelar um pedido | Todos que editam | Em levantamento | Edição da linha com bloqueio otimista | `MUD-02`, `P-37`, `P-38` |
| J08 | Cobrir o setor de um CPV ausente | Admin ou Regional, CPVs | Em levantamento | Não existe | `MUD-12`, `P-09` |
| J09 | Acompanhar pedidos em tempo real | Central Stellantis, Regional | Declarada | Views de atingimento prontas; tela não existe | `P-05`, `P-28` |
| J10 | Ver o resultado no telão | Público do evento | Declarada | Telão sem login (DEC); tela não existe | `P-41`, `P-42`, `MUD-10` |
| J11 | Ajustar pedidos no pós-evento | Time interno | Declarada | Ajuste com motivo (DEC) | `P-07` |
| J12 | Exportar para o CSPS e conciliar | Time interno | Declarada | Views `v_exportacao_csps` e `v_conciliacao`; telas não existem | `P-39`, `P-40` |

## Detalhe das jornadas em levantamento

### J02 — Carregar e ajustar ofertas (fornecedor)

Fonte: LEV (19/10). Registro mais detalhado até agora.

1. O fornecedor carrega a oferta, preferencialmente por planilha (`DE-16`). Campos citados: código do produto,
   descrição, preço e desconto(s).
2. Pode ajustar a oferta depois da carga, até o admin bloquear (`P-11`).
3. Para a **Stellantis**, duas listas: a completa sem desconto e a promocional da rodada, da qual se usa só item e
   desconto (`DE-13`, `DE-14`). O preço efetivo por concessionária ainda não tem fonte (`P-13`).

Critérios para fechar a jornada (de LEV): layout de oferta com cada campo definido e exemplos validados; forma de
entrada e prazo; regra de bloqueio; origem do preço por concessionária; regras de preço e desconto sem ambiguidade;
valor comercial distinguível do fiscal; responsáveis pela validação comercial e fiscal identificados.

Hipóteses que **não** são regras: "1 peça com 5%, 10 peças com 15%"; São Paulo como referência de preço; "IC T" como ICMS.

### J04 — Negociar com a carteira (consultor)

Vigente (DEC): o consultor vê os grupos da carteira, a lista de PNs com condição, sugestão e potencial restante;
digita quantidades por dealer de destino; vê totais por categoria × meta; marca rascunho ou fechado.

Em aberto: se a sugestão aparece (`MUD-03`); como o preço é formado (`MUD-05`); se cada alteração vira nova versão
(`MUD-02`); quem pode fechar e substituir em cada fase (`P-07`).

Proposta de UX (CDX, não validada): "Minha carteira" → escolher grupo e dealer → buscar produtos → ver meta, sugestão
e resumo → confirmar. Estados visíveis de gravação: salvando, confirmado, falhou, conflito.

### J07 — Substituir ou cancelar um pedido

Direção (`DE-07` a `DE-10`): a alteração cria nova versão; a anterior fica substituída; se outra pessoa substituiu
antes, quem chega depois revisa a versão nova antes de seguir. Antes de confirmar, mostrar diferenças e pedir motivo.

Em aberto: granularidade (pedido ou linha, `P-36`); estados (`P-37`); pedido já exportado (`P-39`).

### J08 — Cobrir o setor de um CPV ausente

Direção (`DE-02`): o setor pode ser dividido entre vários CPVs da mesma regional, por um período. Proposta (CDX):
vínculo temporário separado da carteira oficial. Em aberto: tudo de `P-09`.

## Comportamentos transversais propostos (CDX §6.1)

Propostas para validar, não requisitos:

- Diferenciar "salvando", "confirmado", "falhou" e "conflito"; clique recebido não é pedido gravado.
- Erros com orientação de ação, sem mensagem técnica.
- Dealer de entrega visível em cada linha.
- Repetir uma gravação depois de falha de rede não pode duplicar o pedido.
- Painel deixa claro quando foi atualizado.

## Histórico deste arquivo

| Data | Registro |
|---|---|
| 22/10/2026 | Criação com 12 jornadas a partir de DEC, LEV e CDX |
