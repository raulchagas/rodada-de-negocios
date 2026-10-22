# Comparativo: repositório × conversas com o Codex

> Retrato de 22/10/2026. Compara o que está no repositório (commit `f30571f`, de 19/10) com o levantamento das
> chamadas de 19–20/10 e com o consolidado das conversas com o Codex (21/10). Este arquivo não é atualizado: as
> consequências dele vivem em `mudancas-de-escopo.md`, `perguntas-abertas.md` e `situacao.md`.

## Fontes comparadas

| Sigla | Fonte | Natureza |
|---|---|---|
| **DEC** | `docs/decisoes.md` (Raul, 16 e 19/10) | Regras dadas como fechadas; o código implementa |
| **HO** | `docs/HANDOFF.md` (19/10) | Estado técnico e próximos passos |
| **COD** | Migrations `0001`–`0003` e app em `web/` (`f30571f`) | O que o banco e o app fazem hoje |
| **LEV** | Levantamento de escopo e jornadas (19–20/10) | Declarações de Marcos; escopo não aprovado; estava fora do Git |
| **CDX** | Consolidado das conversas com o Codex (21/10) | Síntese de LEV + leitura do código + MIRA + arquitetura, testes e custos |

Cópias de LEV e CDX estão em [`fontes/`](fontes/).

## 1. Conclusão em uma leitura

1. **O repositório e as conversas descrevem dois momentos diferentes do projeto.** DEC e HO tratam as regras como
   "fechadas" (decisões de 16/10). LEV e CDX, feitos depois, reabrem boa parte delas. Nada do que foi discutido em
   19–21/10 chegou a `docs/decisoes.md` nem ao código. São 16 divergências, registradas como `MUD-01` a `MUD-16`.
2. **O consolidado do Codex cobre bem o levantamento.** Quase tudo de LEV está em CDX. O que CDX acrescenta é
   análise (MIRA, arquitetura, testes, custos, UX), não novas declarações de negócio. Três pontos de LEV ficaram
   diluídos em CDX e foram resgatados aqui (seção 4).
3. **As divergências mais caras de mudar depois** são o modelo de pedido (`MUD-02`: editar a linha × criar nova
   versão encadeada), o preço (`MUD-05`: preço único por PN × preço por concessionária com desconto) e o papel da
   plataforma na sugestão (`MUD-03`: calcular × receber pronta). As três mexem no banco, nas cargas e na tela de
   negociação, que é exatamente o próximo passo do HO.
4. **O banco já tem alguns "ganchos" sem regra** (fases com perfis que editam, categoria que conta ou não no total,
   motivo de ajuste). Eles parecem resolver pontos do levantamento, mas hoje nada os aplica (seção 6).
5. **Falta uma regra de governança:** quem aprova uma mudança de escopo e a promove para `docs/decisoes.md`
   (`P-01`). Sem isso, as duas fontes continuam valendo em paralelo e o código segue a mais antiga.

## 2. Onde as fontes concordam

Pontos que aparecem em DEC/HO e não foram contestados em LEV/CDX. Podem ser tratados como base estável.

| Tema | Entendimento comum |
|---|---|
| Hierarquia | Marca → Regional → Setor → CPV → Grupo → Dealer |
| Grupo | Um grupo por marca; unidade de negociação e meta |
| Dealer | Destino da entrega escolhido em cada linha; sem rateio automático |
| Meta | Por grupo × categoria, em R$ (com a ressalva de FULL, `MUD-10`) |
| Contagem | Só pedido fechado conta no telão e no atingimento (LEV/CDX acrescentam "e vigente", `MUD-02`) |
| CSPS | Nenhum pedido vai ao CSPS durante o evento; exportação e conciliação depois |
| Cargas | Entrada por planilha, validação tudo ou nada, erros por aba e linha |
| Códigos | Códigos como texto, preservando zeros à esquerda |
| Acesso | Login por convite, link de uso único, sem cadastro aberto; checagem no servidor |
| Banco | PostgreSQL como fonte da verdade; arquitetura portável |
| Sequência | Negociação interna → painel → acessos externos → CSPS (CDX pede revisão à luz das dependências) |
| Bpro e Circ. Autopeças | Regra própria desconhecida; tratadas como categoria comum por enquanto |
| Litros | Unidade secundária opcional (óleo) já prevista em DEC e no banco; LEV acrescenta campanhas de óleo |

## 3. O que já foi analisado com o Codex e não está no repositório

Conteúdo que só existe em CDX (e em parte em LEV). Agora está guardado em `fontes/` e referenciado nesta pasta.

| Tema | O que CDX traz | Onde virou registro |
|---|---|---|
| Regra dos 21 pontos | Pontuação binária por mês, pesos 6 a 1, máximo 21; mede frequência, não volume | `DE-03`, `DE-04`, `MUD-04` |
| MIRA | Motor ativo: demanda diária = unidades líquidas de 6 meses ÷ 180; necessidade = (90 + 10 dias) × demanda diária − estoque; arredonda à unidade; sem QME. Faixas Lume: A 15–21, B 9–14, C 4–8, D 0–3 | `DE-06`, `MUD-04`, `P-30` a `P-35` |
| Versionamento | Nova versão encadeada, anterior preservada, troca atômica, conflito explícito | `DE-07` a `DE-10`, `MUD-02` |
| Capacidade | ~300 usuários simultâneos **gravando** pedidos | `DE-11`, `MUD-11` |
| Arquitetura de testes | Regras e integridade, carga (k6 ou equivalente), navegadores reais (Playwright ou equivalente), métricas e reconciliação | `DE-12`, `P-46` |
| Arquitetura candidata | Backend modular + PostgreSQL; resumos para o painel; sem múltiplos bancos graváveis | `situacao.md` (Proposta) |
| Infraestrutura e custos | US$ 100 a 250 no mês do evento (estimativa, não orçamento) | `P-47` |
| UX por público | Central de preparação, "minha carteira", estados salvando/confirmado/falhou/conflito | `jornadas.md` (Proposta) |
| Autorização | Permissão = perfil × escopo × categoria × fase × estado do pedido | `P-06`, `MUD-09` |
| Estados de integração | Separar estado comercial do estado no CSPS | `P-39` |
| Riscos e backlog | Backlog A–D e tabela de riscos | `situacao.md`, `cronograma.md` |

Itens citados em CDX que **não estão acessíveis** a partir do repositório: o whiteboard e a apresentação no ChatGPT
e o código do MIRA (`src/App.tsx`, `server/engine.py`, `docs/estudo-reposicao-motor.md` etc.). Se forem referência do
projeto, vale guardar uma exportação em `fontes/`.

## 4. O que está no levantamento e o consolidado tratou pouco

Pontos de LEV que CDX menciona de passagem ou dilui. Mantidos explicitamente aqui para não se perderem.

| Ponto de LEV | Como aparece em CDX | Registro |
|---|---|---|
| **Central Stellantis** como público que acompanha pedidos em tempo real | Fundida com "Regional/Central" | `MUD-09`, `P-05` |
| **Lista especial com prioridade por ordem de chegada** (uma das três decisões estruturais) | Vira "ofertas limitadas" (10.5), sem o peso de decisão estrutural | `MUD-15`, `P-21` |
| **Preferência de Marcos** por só receber, carregar e consolidar pedidos, com sugestão em planilha | Aparece só na tabela de conflitos | `MUD-03`, `P-29` |
| Nomenclatura final das ofertas da própria Stellantis (armazém/fábrica) | Citada como validação | `P-19` |
| Armazém único da Stellantis: significado operacional | Citado | `P-20` |
| Prazo de envio das ofertas e regra de bloqueio pelo admin | Citado | `P-11` |
| Planilha como canal único ou também cadastro item a item | Citado | `P-12` |

## 5. O que está no repositório e as conversas não discutiram

Regras que existem em DEC/COD e que LEV/CDX não confirmaram nem contestaram. Hoje valem por omissão; convém
confirmá-las explicitamente, porque cada uma já é comportamento do sistema.

| Regra hoje vigente | Onde | Por que confirmar |
|---|---|---|
| Matriz consultor × categoria (CPV todas; CNA Peças; CNE E-commerce; F&I Acessórios), com trava no banco | DEC, COD (`perfil_categoria`, trigger de `pedido_linha`) | CDX chama de "matriz técnica original", não aprovada |
| Uma linha por grupo × PN × dealer, com **um** responsável | COD (`unique` em `pedido_linha`) | Se CPV e CNA negociarem o mesmo PN para o mesmo dealer, só cabe uma linha: o segundo edita a linha do primeiro e o responsável continua sendo um só; o ranking por consultor depende disso |
| Não existe "pedido" como cabeçalho: o pedido do grupo é a soma das linhas | COD (comentário em `0001`) | Versionar "o pedido inteiro" (`P-36`) exige criar essa entidade |
| Perfil **Grupo** digita os próprios pedidos (acesso direto da rede) | DEC | LEV trata o acesso direto da concessionária como decisão estrutural pendente (`MUD-09`, `P-08`) |
| Um usuário tem **um** perfil | COD (`usuario.perfil`) | CDX pergunta se um usuário pode acumular perfis (`P-06`) |
| Status `rascunho → fechado` e `cancelado` | COD | Lista definitiva de estados está pendente (`P-37`) |
| Potencial restante desconta rascunho **e** fechado | COD (`v_potencial`) | O atingimento só conta fechado; confirmar se o potencial deve seguir a mesma regra (`P-28`) |
| Pós-evento: ajustes do time interno **com motivo** | DEC | Combina com o versionamento, mas falta definir quem e até quando (`P-07`) |
| Telão sem login | DEC | CDX pede revisar o que pode ser exposto (`P-41`) |
| Usuário de leitura para o Power BI como contingência do telão | DEC, COD (comentário) | É o único plano de contingência registrado (`P-49`) |
| Link de acesso de 30 minutos e sessão de 14 dias | HO, COD (`token.ts`) | CDX pede revisar frente à política de acesso do evento (`P-53`) |
| Carteira de CNA/CNE própria ou herdada do CPV | `docs/cargas.md` | Relaciona-se com a cobertura temporária (`MUD-12`) |
| Metas por consultor carregadas prontas (`metas_consultor`) | `docs/cargas.md` | LEV: metas do CPV compiladas dos objetivos das concessionárias (`MUD-14`) |
| Sem perfis novos antes da primeira rodada | DEC | Conflita com Central Stellantis e cobertura de CPV (`MUD-09`) |

## 6. Ganchos no banco que ainda não têm regra

Estruturas criadas em `0001` que sugerem uma solução, mas que hoje nenhum trigger, view ou tela aplica. Não devem
ser lidas como "já resolvido".

| Estrutura | O que parece resolver | O que acontece hoje |
|---|---|---|
| `rodada_fase.perfis_editam` | Quem edita em cada fase (`P-07`) | Nada consulta a coluna; qualquer fase aceita gravação |
| `categoria.conta_no_total` | Categoria que não entra no total (FULL, contratos: `MUD-07`, `MUD-10`) | Nenhuma view usa a coluna; e ela é por categoria, não por indicador |
| `pedido_linha.motivo_ajuste` | Motivo obrigatório no pós-evento | Comentado como obrigatório, mas o trigger não exige |
| `pedido_linha.versao` | Controle de concorrência | É bloqueio otimista da mesma linha, não versão de pedido; a linha é sobrescrita (o antes fica só na `auditoria`) |
| `auditoria` (antes/depois em JSON) | Histórico de alterações | Guarda quem e quando, mas não motivo nem vínculo entre versões, e não preserva a versão anterior como registro consultável |
| `item.desconto_pct` | Desconto da condição | Informativo: o valor do pedido usa `preco_unit` (preço já com condição), sem aplicar desconto |

## 7. Divergências

Resumo; o detalhe, o impacto e o estado de cada uma estão em `mudancas-de-escopo.md`.

| ID | Tema | Repositório (DEC/HO/COD) | Conversas (LEV/CDX) |
|---|---|---|---|
| MUD-01 | Status do escopo | Regras "fechadas" | Levantamento aberto, não aprovado |
| MUD-02 | Alteração de pedido | Edita a linha; `versao` como bloqueio otimista; auditoria | Nova versão encadeada; anterior substituída; só vigente e fechada conta |
| MUD-03 | Papel da plataforma na sugestão | Plataforma calcula e mostra sugestão e potencial | Preferência por só receber e consolidar; sugestão talvez em planilha |
| MUD-04 | Fórmula da sugestão | Demanda − estoque − trânsito (quantidades), arredonda ao QME | 21 pontos = frequência; horizonte 90 dias; MIRA usa dias e não QME |
| MUD-05 | Preço | Um preço e uma condição por PN para toda a rede | Lista mensal + lista promocional (só item e desconto); preço por concessionária; desconto progressivo possível |
| MUD-06 | Valor do indicador | Quantidade × preço da condição | Valor do produto sem ST, separado do valor fiscal |
| MUD-07 | Fornecedor no atingimento | Pedido de fornecedor sempre conta na categoria | Contratos podem não contar nos números Stellantis |
| MUD-08 | Entrada do catálogo de fornecedor | Admin carrega a planilha | Fornecedor carrega e ajusta ofertas até o bloqueio do admin; fornecedor também cria pedidos |
| MUD-09 | Públicos e perfis | Perfis fechados; Grupo com acesso direto | Central Stellantis; acesso da concessionária em aberto; mapear perfis antes |
| MUD-10 | FULL | "Envios Full" é categoria com meta própria | Pendente se o objetivo FULL está dentro do armazém (risco de dupla contagem) |
| MUD-11 | Capacidade | Não especificada | ~300 usuários simultâneos gravando, com testes de carga |
| MUD-12 | Cobertura de CPV | Carteira carregada por rodada | Cobertura temporária e personalizada entre CPVs da mesma regional |
| MUD-13 | Cronograma | Sequência de entrega sem datas | Pronto para testes em 16/11 (referência); 3 semanas de testes; descontos só no fim de novembro |
| MUD-14 | Metas de consultor | Carga direta | Compiladas dos objetivos das concessionárias, com exceções |
| MUD-15 | Lista especial / ofertas limitadas | Não existe | Possível prioridade por ordem de chegada, reserva e desempate |
| MUD-16 | Painel | Painel de junho/2026 como referência | Patrocinadores (com Bruno) e espaço de campanhas de premiação |

## 8. Observações sobre o consolidado do Codex

Conferência de CDX contra o repositório. Nada abaixo invalida o consolidado; são ajustes de precisão.

- **Confirmado:** o levantamento de 20/10 não estava no Git (só na pasta local); o último commit é `f30571f`, de
  19/10; a página inicial diz "tela de negociação em construção"; existem as views de exportação e conciliação.
- **CPV:** CDX diz que a expansão da sigla "não foi validada". O glossário do HO define CPV como consultor de pós-vendas.
- **"Trânsito" no handoff:** CDX descreve como quantidade recebível abatida. Confere com DEC e COD ("pedido em
  trânsito / backorder", em unidades). A divergência com o MIRA (dias) é real (`MUD-04`, `P-33`).
- **Unicidade de item:** CDX não menciona, mas a carga já recusa o mesmo PN com preço ou condição diferentes entre
  dealers. Isso torna `MUD-05` uma mudança de modelo, não só de carga.
- **Reunião de handoff de 20/10, 16h30:** LEV diz horário de Brasília, CDX diz horário de Curitiba (mesmo fuso).
  O resultado da reunião não está registrado em nenhuma fonte.

## 9. Lacunas que nenhuma fonte cobre

Temas ausentes tanto do repositório quanto das conversas. Ficam como perguntas para não serem descobertos tarde.

- Quem aprova escopo e quem responde cada pergunta (`P-01`, `P-02`).
- O material original que Marcos recebeu para construir a plataforma: LEV diz que não foi localizado (`P-03`).
- Volumetria real: quantos PNs × dealers na base, linhas por pedido, número de fornecedores e de itens (`P-48`).
- Operação no dia: suporte, treinamento, comunicação com a rede, plano se a plataforma cair (`P-49`).
- Dados pessoais de usuários da rede e alinhamento com a política da empresa, além da hospedagem (`P-50`).
- Uso em celular e tablet no evento: o HO testou tela de celular, mas não há requisito (`P-51`).
- Data de congelamento do escopo antes da entrada em testes (`cronograma.md`).
