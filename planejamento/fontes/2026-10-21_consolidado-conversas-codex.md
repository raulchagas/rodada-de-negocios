# Rodada de Negócios
## Documento consolidado de contexto, escopo, regras, experiência e arquitetura

**Versão:** 1.0  
**Data de corte:** 21 de outubro de 2026, horário de Curitiba (UTC−03:00)  
**Situação:** levantamento em evolução; não constitui aprovação integral de escopo, arquitetura, orçamento ou cronograma.  
**Finalidade:** preservar as discussões do projeto em uma referência única para alinhamento de negócio, produto, desenvolvimento e testes.

## Sumário

1. [Como interpretar este documento](#1-como-interpretar-este-documento)
2. [Visão executiva](#2-visão-executiva)
3. [Contexto, evento e objetivos](#3-contexto-evento-e-objetivos)
4. [O que existe e o que falta](#4-o-que-existe-e-o-que-falta)
5. [Usuários, perfis e permissões](#5-usuários-perfis-e-permissões)
6. [Necessidades e UX por usuário](#6-necessidades-e-ux-por-usuário)
7. [Jornada operacional](#7-jornada-operacional)
8. [Rede e cobertura de CPVs](#8-rede-e-cobertura-de-cpvs)
9. [As nove bases de dados](#9-as-nove-bases-de-dados)
10. [Ofertas, fornecedores e preços](#10-ofertas-fornecedores-e-preços)
11. [Tipos de pedido, objetivos e indicadores](#11-tipos-de-pedido-objetivos-e-indicadores)
12. [Regra dos 21 pontos e curvas](#12-regra-dos-21-pontos-e-curvas)
13. [Reposição, 90 dias e referência MIRA](#13-reposição-90-dias-e-referência-mira)
14. [Pedidos, histórico e concorrência](#14-pedidos-histórico-e-concorrência)
15. [CSPS, exportação e conciliação](#15-csps-exportação-e-conciliação)
16. [Painéis, telão, patrocinadores e premiações](#16-painéis-telão-patrocinadores-e-premiações)
17. [Arquitetura candidata](#17-arquitetura-candidata)
18. [Arquitetura de testes](#18-arquitetura-de-testes)
19. [Infraestrutura e custos](#19-infraestrutura-e-custos)
20. [Cronograma, dependências e riscos](#20-cronograma-dependências-e-riscos)
21. [Conflitos entre fontes](#21-conflitos-entre-fontes)
22. [Backlog consolidado](#22-backlog-consolidado)
23. [Registro de decisões e perguntas abertas](#23-registro-de-decisões-e-perguntas-abertas)
24. [Próximos passos](#24-próximos-passos)
25. [Fontes e glossário](#25-fontes-e-glossário)

## 1. Como interpretar este documento

O projeto foi discutido em momentos diferentes. Uma descrição no handoff não equivale necessariamente a uma regra comercial já validada, e uma intenção discutida não equivale a funcionalidade entregue.

As classificações usadas são:

- **Direção definida:** orientação explicitada nas conversas, especialmente em 20/10. Ainda pode exigir detalhamento para implementação.
- **Handoff de 19/10:** descrição do projeto e das premissas técnicas naquele momento. Pode ter sido questionada ou complementada depois.
- **Verificado no código em 21/10:** existência observada em leitura local. Não prova publicação, funcionamento em produção ou capacidade de carga.
- **Proposta:** desenho de UX, arquitetura ou processo sugerido para discussão. Não é decisão aprovada nem resultado de pesquisa com usuários.
- **Pendente:** ponto que precisa de resposta, dado, validação ou aprovação.
- **Estimativa:** hipótese de planejamento, sujeita a condições e verificação.

A leitura do código em 21/10 identificou como último commit local `f30571f`, de 19/10. O levantamento de escopo de 20/10 estava separado das alterações versionadas. Portanto, requisitos recentes não devem ser tratados como já implementados. Não houve, nessa leitura, revalidação do banco remoto ou execução de testes de carga.

## 2. Visão executiva

A plataforma deve apoiar uma Rodada de Negócios da rede Stellantis/Mopar: preparação de dados e acessos, negociação, criação e fechamento de pedidos, acompanhamento de objetivos e exportação/conciliação após o evento.

O requisito de capacidade mais importante é atender aproximadamente **300 usuários simultâneos operando pedidos**, e não apenas visualizando um painel. A preocupação central é não perder pedidos, não duplicar operações e não permitir que alterações concorrentes destruam o histórico.

As direções mais importantes já discutidas são:

1. Mapear os perfis de acesso antes de cadastrar os usuários.
2. Usar a estrutura regional, setor, CPV, grupo e concessionária para organizar carteira e operação.
3. Permitir cobertura temporária e personalizada de setores entre CPVs do mesmo regional.
4. Classificar a ocorrência de vendas por uma regra binária ponderada de seis meses, com máximo de 21 pontos.
5. Adotar inicialmente horizonte de reposição de 90 dias; a fórmula quantitativa completa ainda precisa ser conciliada.
6. Preservar alterações de pedidos como novas versões, mantendo o anterior e identificando a última versão válida.
7. Impedir sobrescrita silenciosa em alterações concorrentes.
8. Contar somente pedidos vigentes e fechados nos indicadores correspondentes.
9. Separar o objetivo de FULL do problema de dupla contagem com armazém, antes de fechar as regras.
10. Validar a capacidade com testes automatizados de regra, carga e navegador, em vez de assumir que 300 máquinas ou agentes de IA são necessários.

A base técnica existe, mas a plataforma de negociação completa não está pronta. As decisões de preço, metas, contratos, permissões e fórmula de reposição são tão críticas quanto o dimensionamento de infraestrutura.

## 3. Contexto, evento e objetivos

### 3.1 Problema de negócio

A operação atual envolve dados, pedidos e consolidações fragmentados. A plataforma pretende organizar a captura e o acompanhamento comercial, reduzindo retrabalho e a dependência de consolidação posterior para visualizar resultados.

Os objetivos discutidos abrangem:

- Preparar a rede, os usuários, as carteiras, as ofertas e as metas.
- Dar contexto comercial à negociação por grupo e concessionária.
- Consultar sugestão de reposição e potencial, conforme cálculo a definir.
- Registrar pedidos de diferentes categorias e fornecedores.
- Identificar quem criou, substituiu ou cancelou cada pedido e por quê.
- Acompanhar metas durante o evento.
- Apoiar a colocação posterior dos pedidos e a conciliação com o CSPS.

O projeto começou como rascunho em 16/10. O material recebido por Marcos era insumo para construção, não uma plataforma finalizada. Este projeto é distinto do projeto de equalização CurvaN; não se deve incorporar automaticamente regras daquele projeto.

### 3.2 Evento e escala

- Referência de evento: segunda semana de dezembro de 2026.
- Dia exato: pendente.
- Ordem de grandeza mencionada: cerca de 200 concessionárias.
- Discussão inicial: 200 a 300 usuários.
- Requisito posteriormente enfatizado: aproximadamente 300 usuários simultâneos criando e operando pedidos.

O número “200 milhões” foi mencionado sem unidade suficientemente definida. Não deve ser convertido em previsão de faturamento, peças ou volume de pedidos.

### 3.3 O que não está automaticamente incluído

Não estão aprovados apenas por terem sido discutidos: arquitetura distribuída com múltiplos bancos graváveis, contratação de infraestrutura, migração integral do MIRA, acesso irrestrito de concessionárias, edição exclusiva por CPV, regras fiscais definitivas ou integração transacional automática com o CSPS.

## 4. O que existe e o que falta

### 4.1 Base técnica existente

A leitura local em 21/10 encontrou:

- Aplicação em Next.js 16, React e Tailwind.
- Uso de PostgreSQL, driver `postgres`, SQL e migrações.
- Login e administração de usuários.
- Upload de planilhas Excel.
- Página inicial com situação das bases.
- Três migrações relacionadas a estrutura, acesso, cargas e aplicação/validação.
- Consultas e views para indicadores, potencial, exportação e conciliação.

O handoff registra Neon em São Paulo, PostgreSQL 17, banco/schema `rodada` e evento `2026-12` criado. Essas informações descrevem o estado documentado; o ambiente remoto não foi revalidado na leitura local de 21/10.

### 4.2 Acesso já descrito

O handoff descreve convite com token de uso único, validade de 30 minutos, confirmação por botão e sessão de 14 dias. O envio automático de e-mail de acesso ainda não estava implementado. Esses parâmetros precisam ser revisados frente à política de acesso do evento, não simplesmente assumidos como decisão final de segurança.

### 4.3 Lacunas de produto

A página inicial ainda informa que a tela de negociação está em construção. Permanecem pendentes, entre outros:

- Jornada efetiva de negociação e criação de pedidos.
- Painéis e telão.
- Jornadas externas de fornecedor e concessionária.
- Telas operacionais de exportação e conciliação, ainda que existam consultas SQL.
- Versionamento e tratamento de concorrência conforme a direção recente.
- Cobertura temporária personalizada de CPVs.
- Publicação e aprovação de hospedagem.
- E-mail automático de acesso.
- Validação com bases reais e regras comerciais finais.

O handoff reporta 12 testes automatizados e 15 verificações em navegador em 19/10. Isso não demonstra capacidade para 300 usuários nem substitui os testes descritos adiante.

## 5. Usuários, perfis e permissões

### 5.1 Ordem de preparação

A sequência orientada pelo usuário é:

1. Mapear os perfis.
2. Definir o que cada perfil pode ver e fazer.
3. Cadastrar os usuários.
4. Associar perfis e escopos aos usuários.
5. Preparar as bases operacionais.

Mapear perfis não significa que um editor dinâmico de perfis em tela já foi aprovado. A forma de administração das permissões ainda precisa ser escolhida.

### 5.2 Matriz de referência do handoff

| Perfil | Referência de alcance ou categoria | O que ainda precisa ser fechado |
|---|---|---|
| Admin | Administração e preparação da operação | Limites de alteração, congelamentos e ações por fase |
| Regional | Escopo do próprio regional | Criação em nome de dealers, cobertura e exceções |
| CPV | Carteira; todas as categorias na matriz original | Permissões sobre substituição, fechamento e pedidos de outros atores |
| CNA | Peças na matriz original | Confirmar responsabilidade e combinação de perfis |
| CNE | E-commerce na matriz original | Confirmar relação com FULL e carteira |
| F&I | Acessórios na matriz original | Confirmar regra comercial e alcance |
| Grupo | Próprios grupos | Acesso direto, dealers disponíveis e ações permitidas |
| Fornecedor | Próprias linhas | Criar pedidos, ajustar ofertas e limites de visibilidade |
| Telão | Consulta agregada, sem edição | Dados públicos, eventual autenticação e exposição |

Esta é a matriz técnica original, não uma aprovação final das permissões. A associação CPV/CNA/CNE/F&I não deve ser confundida com organogramas ou discussões de outras iniciativas.

### 5.3 Dimensões da autorização

**Proposta de detalhamento:** definir permissão como combinação de perfil, escopo territorial/comercial, categoria, fase do evento e estado do pedido. Por exemplo, poder visualizar uma carteira não implica poder substituir seus pedidos.

Também é necessário decidir se um usuário pode acumular perfis e como conflitos entre permissões serão resolvidos. A verificação deve ocorrer no servidor, não apenas escondendo botões na interface.

## 6. Necessidades e UX por usuário

As experiências abaixo consolidam o whiteboard. São **propostas de UX**, não pesquisa validada com usuários nem telas implementadas.

| Usuário | Necessidade principal | Experiência proposta | Pendência de negócio |
|---|---|---|---|
| Admin | Saber se a operação está pronta e os dados são confiáveis | Central de preparação, checklist de bases, prévia de carga, erros por aba/linha, situação de aplicação | Quem aprova bases, bloqueia ofertas e libera fases |
| CPV | Negociar rapidamente com sua carteira | “Minha carteira”, seleção de grupo/dealer, busca de produtos, metas, sugestão e resumo do pedido | Ações por categoria, fase e autoria |
| Fornecedor | Ofertar produtos e acompanhar suas linhas | Importação de catálogo com validação; lista restrita a suas linhas | Prazo para correção, congelamento e criação de pedidos |
| Concessionária | Entender oferta, destino, valor e situação | Se houver acesso direto: catálogo, carrinho por destino e confirmação clara | Aprovar ou não autosserviço e limites de ação |
| Regional/Central | Acompanhar resultado e apoiar desvios | Painel por regional, setor, grupo e categoria, com detalhamento autorizado | Quem pode colocar pedidos e visualizar carteiras |
| Telão | Comunicar resultado de forma simples | Totais agregados, leitura à distância, sem controles operacionais | Público, atualização, patrocinadores e premiações |

### 6.1 Comportamentos transversais recomendados

- Diferenciar “salvando”, “confirmado”, “falhou” e “conflito”. Um clique recebido não é confirmação de pedido persistido.
- Apresentar erros acionáveis, sem exigir que o usuário interprete mensagens técnicas.
- Mostrar a concessionária de entrega em cada linha.
- Ao substituir um pedido, exibir diferenças e motivo antes da confirmação.
- Evitar perda do trabalho em uma falha de conexão, conforme mecanismo de recuperação a desenhar.
- Não repetir uma operação de gravação de modo que gere duplicidade.
- Deixar explícito quando um painel é atualizado e se existe atraso de consolidação.

Esses pontos precisam ser prototipados e testados. Não se pressupõe uma solução offline completa.

## 7. Jornada operacional

### 7.1 Preparação

Admin e responsáveis organizam perfis, usuários, hierarquia, carteira, produtos, ofertas, histórico de vendas, estoque e metas. As cargas precisam ser validadas antes de influenciar negociações.

### 7.2 Pré-rodada

O handoff prevê preparação de rascunhos e consulta de potencial. Ainda é necessário definir quem prepara, se esses rascunhos podem ser modificados por terceiros e quando passam a ter validade comercial.

### 7.3 Durante o evento

Os usuários autorizados pesquisam, criam, substituem e fecham pedidos. Os resultados alimentam o acompanhamento conforme as regras de elegibilidade. O sistema deve suportar o pico de operação com integridade e feedback inequívoco.

### 7.4 Pós-evento

O fluxo prevê ajustes justificados, exportação, colocação dos pedidos no processo do CSPS, carga do realizado e conciliação de divergências. A janela de ajustes e a responsabilidade por cada etapa permanecem abertas.

**Pendência transversal:** definir início/fim de cada fase e permissões durante as transições. Não basta criar estados na tela sem estabelecer o significado de negócio.

## 8. Rede e cobertura de CPVs

### 8.1 Hierarquia

A referência do handoff é:

`Marca → Regional → Setor → CPV → Grupo → Dealer`

O grupo por marca é unidade de negociação/meta. A concessionária de entrega é escolhida em cada linha. Não foi aprovada distribuição automática de quantidades entre lojas.

A rede foi descrita em dois grandes conjuntos:

- FCA: Fiat, Jeep e RAM.
- PSA: Peugeot e Citroën.

Para FCA, há um Excel conhecido pelo usuário com regional, setor, grupo, lojas e códigos. A estrutura equivalente de PSA ainda precisa ser compreendida. Não se deve assumir que o modelo FCA se aplica sem adaptação.

### 8.2 Cobertura temporária

**Direção definida:** se um CPV estiver ausente ou de férias, seu setor deve poder ser distribuído de maneira personalizada entre outros CPVs do mesmo regional.

Isso não significa necessariamente transferir o setor inteiro para uma única pessoa. A necessidade é permitir múltiplos substitutos sem perder a estrutura oficial de responsabilidade.

Detalhes pendentes:

- Divisão por grupo, loja ou outro recorte.
- Data de início e fim.
- Quem autoriza e cadastra a cobertura.
- Como prorrogá-la e encerrá-la.
- Destino dos pedidos em andamento.
- Visibilidade de histórico durante e depois da cobertura.
- Retorno da responsabilidade ao titular.

**Proposta:** representar a cobertura como vínculo temporário separado da hierarquia permanente. Não houve alteração de carteiras reais nesta discussão.

## 9. As nove bases de dados

| Tipo de carga | Papel no projeto | Validação ou definição importante |
|---|---|---|
| `hierarquia` | Rede, regional, setor, grupo e dealer | Códigos, marcas, vínculos e diferenças FCA/PSA |
| `consultores` | Cadastro dos profissionais | Identidade, perfil e vínculo organizacional |
| `carteira` | Relação de atendimento | Escopo oficial e futura cobertura temporária |
| `usuarios` | Acessos à plataforma | Perfil, escopo, duplicidade e ativação |
| `base21` | Base analítica para frequência e reposição | Meses de referência, ocorrência, quantidades e estoque |
| `catalogo_fornecedor` | Produtos e ofertas | PN, descrição, preço de referência, descontos e fornecedor |
| `metas` | Objetivos comerciais | Grupo, categoria, período e unidade |
| `metas_consultor` | Objetivos dos consultores | Regra de compilação e exceções |
| `csps` | Realizado para conciliação | Chaves de comparação, layout e situação do pedido |

O modelo `cargas/modelos_cargas.xlsx` contém exemplos fictícios. Não é prova de que as bases reais estejam carregadas.

### 9.1 Qualidade e aplicação

O handoff descreve validação “tudo ou nada”, erros por aba e linha, possibilidade de correção/reenvio e processamento de lotes de 2.000 linhas no navegador. O código de importação/validação existe, mas o comportamento deve ser revalidado com os volumes e arquivos reais.

Regras essenciais de dados:

- Tratar códigos como texto quando necessário, preservando zeros à esquerda.
- Não converter silenciosamente identificadores em números.
- Validar referências entre bases antes de aplicar.
- Distinguir ausência de dado de valor zero.
- Definir política de substituição, correção e reaplicação de uma carga.

**Proposta de governança:** registrar origem, data de referência, responsável, resultado da validação e versão aplicada. A aprovação e o detalhamento desse controle continuam pendentes.

### 9.2 CSPS não é base inicial de pedido realizado

A carga de CSPS representa uma etapa posterior de acompanhamento/conciliação. Não confundir a carga inicial de referências ou sugestões com confirmação de que o pedido já foi colocado no sistema externo.

## 10. Ofertas, fornecedores e preços

### 10.1 Jornada de oferta

A intenção é que fornecedores carreguem suas ofertas inicialmente e possam ajustá-las conforme a janela permitida. O admin poderá ter mecanismo de bloqueio/congelamento, mas os detalhes ainda precisam ser definidos.

Excel aparece como caminho preferencial. Cadastro manual item a item é alternativa ainda aberta. Os campos discutidos incluem identificador do produto, descrição, preço e descontos.

Exemplos como “uma peça com 5%” ou “dez peças com 15%” são ilustrativos. Não constituem tabela comercial aprovada.

### 10.2 Duas listas Stellantis

Foram diferenciadas:

1. Lista geral, com preços completos e sem desconto promocional.
2. Lista promocional da rodada, com itens e descontos do evento.

**Direção discutida:** na lista promocional Stellantis, utilizar o identificador do item e o desconto; ignorar o preço nela indicado.

Ainda falta definir a base efetiva sobre a qual o desconto será aplicado, incluindo a relação com a lista mensal e possíveis diferenças por concessionária/destino. Não se deve assumir que existe um único preço final igual para toda a rede.

A referência a São Paulo como base de preço não está confirmada. Uma expressão ouvida como “IC T” permanece ambígua; não deve ser reinterpretada automaticamente como ICMS.

### 10.3 ST e valor comercial

Foi discutido considerar o valor do produto **sem ST** no indicador comercial do evento. Isso não define o valor fiscal da nota nem substitui validação tributária.

É necessário separar:

- Preço comercial de referência.
- Desconto aplicável.
- Valor considerado para meta e telão.
- Valor fiscal/documental.
- Valor comparado na conciliação.

### 10.4 Outros fornecedores e contratos

Foram citados óleos, acessórios, eletrônicos, periféricos, químicos e itens como líquido de arrefecimento. Essa classificação é preliminar. Óleo pode ser negociado em litros; as unidades precisam estar explícitas.

Contratos de fornecedores não são automaticamente equivalentes a linhas de pedido de peças. Também não é automático que todo contrato conte no resultado Stellantis. A inclusão depende do indicador e da categoria.

Bpro, Circular Autopeças, Shell e outros DFS foram mencionados, mas suas regras próprias ainda precisam ser detalhadas. O significado operacional de armazém/fábrica e da referência a armazém único também merece validação.

### 10.5 Ofertas limitadas

Caso haja quantidade limitada, é necessário decidir reserva, ordem de chegada, validade e desempate. Não foi aprovada uma regra de consumo de estoque promocional nem um mecanismo de reserva.

## 11. Tipos de pedido, objetivos e indicadores

### 11.1 Tipos centrais

- **Peças/armazém:** pedido de peças do armazém.
- **Acessórios:** pedido vinculado ao objetivo de acessórios.
- **FULL:** subpedido do armazém destinado ao fulfillment do Mercado Livre.

A principal pergunta em aberto é se o objetivo FULL estará dentro do objetivo de armazém ou fora dele. Essa escolha afeta tanto o cadastro de metas quanto a soma do realizado.

**Exigência de consistência:** um mesmo valor não pode ser somado duas vezes por acidente ao consolidar armazém e FULL. A decisão deve ser explícita por indicador.

### 11.2 Metas

O handoff trabalha com meta por grupo e categoria, em reais. As categorias citadas incluem Peças, Acessórios, Envios Full, Bpro, Circular Autopeças, Shell e Outros DFS.

Os objetivos dos CPVs são, em boa parte, compilação dos objetivos das concessionárias. Não foi estabelecido que todo objetivo de consultor será sempre uma soma simples, sem exceções.

É necessário fechar metas de dezembro, períodos, exceções, contratos elegíveis e relação entre FULL e armazém.

### 11.3 Indicadores do handoff

| Indicador | Relação descrita | Cuidado necessário |
|---|---|---|
| Atingimento | Pedido fechado ÷ meta | Usar a versão vigente; definir categoria e denominador zero |
| Cobertura | Pedido ÷ sugestão | Comparar medidas e unidades compatíveis |
| Potencial restante | Sugestão − pedido | Definir apresentação de excedentes/valores negativos |

A direção posterior de versionamento restringe o resultado aos pedidos **vigentes e fechados**. Rascunhos e versões substituídas não devem inflar o realizado.

Antes de implementar um painel, cada indicador precisa de definição de unidade, origem, filtros, elegibilidade, tratamento de zero e atualização.

## 12. Regra dos 21 pontos e curvas

### 12.1 Regra definida pelo usuário

A regra avalia se houve venda em cada um dos seis meses considerados. Não mede quantas unidades foram vendidas naquele mês.

| Mês relativo | Peso se houve venda | Peso se não houve venda |
|---|---:|---:|
| Mais recente | 6 | 0 |
| Segundo mais recente | 5 | 0 |
| Terceiro | 4 | 0 |
| Quarto | 3 | 0 |
| Quinto | 2 | 0 |
| Mais antigo | 1 | 0 |

`Pontuação = soma dos pesos dos meses com venda`

O máximo é 21, pois `6 + 5 + 4 + 3 + 2 + 1 = 21`.

### 12.2 Interpretação correta

A pontuação é uma medida de ocorrência de venda ponderada pela recência. Ela combina constância e presença em períodos mais recentes. Não é curva de faturamento nem curva de quantidade.

- Venda em todos os seis meses: 21 pontos.
- Venda somente no mês mais recente: 6 pontos.
- Venda somente no mês mais antigo: 1 ponto.
- Sem venda em qualquer um dos meses: 0 pontos.

Uma nota 6, porém, não identifica unicamente venda no último mês: outras combinações, como pesos 5 e 1, também somam 6. Uma nota isolada não permite reconstruir exatamente em quais meses houve venda.

### 12.3 Curvas

A intenção é usar a pontuação para classificação em curvas A, B, C, D e assim por diante, seguindo a lógica de frequência já conhecida pela rede. As faixas finais da Rodada não foram informadas nas conversas.

Ainda é preciso definir:

- Se o mês de referência é sempre fechado ou pode ser corrente.
- Data de corte e atualização.
- Tratamento de devoluções, cancelamentos e venda líquida.
- Escopo da ocorrência: loja, grupo, marca ou outro recorte.
- Faixas de pontuação de cada curva.

**Separação fundamental:** pontuação de frequência e cálculo de quantidade para reposição são conceitos independentes. Não existe uma conversão aprovada de “21 pontos” em unidades a comprar.

## 13. Reposição, 90 dias e referência MIRA

### 13.1 Direção de negócio

O usuário propôs fixar inicialmente a recomendação em **90 dias**. Alterações desse horizonte podem ser discutidas posteriormente. Isso não aprova, por si só, todas as variáveis da fórmula de reposição.

O MIRA foi indicado como referência porque já detalha o cálculo. A conclusão foi avaliar seu reaproveitamento, não transplantá-lo sem conciliar diferenças.

### 13.2 Cálculo ativo identificado no MIRA

Na leitura realizada do projeto MIRA, o motor ativo calcula, por loja:

```text
Demanda diária = máximo(0, unidades líquidas dos seis meses / divisor)
Necessidade = máximo(0, (dias-alvo + dias-trânsito) × demanda diária − estoque)
Sugestão = arredondar Necessidade para cima até a próxima unidade inteira
```

Parâmetros padrão encontrados:

- Divisor: 180 dias convencionais.
- Dias-alvo: 90.
- Dias de trânsito: 10.
- Configurações salvas podem substituir os padrões.

A janela usa seis meses consecutivos, terminando no mês selecionado. Não corresponde a dividir automaticamente pelo número real de dias de cada mês.

Exemplo meramente didático:

```text
Demanda diária = 2 unidades
Dias-alvo = 90
Dias de trânsito = 10
Estoque = 40 unidades
Sugestão = teto(máximo(0, (90 + 10) × 2 − 40)) = 160 unidades
```

### 13.3 Detalhes importantes do MIRA

- O cálculo agrega unidades líquidas dos canais considerados pelo motor.
- Devoluções negativas afetam o líquido.
- Demanda líquida não positiva resulta em demanda diária zero.
- Valores ou quantidades inválidos bloqueiam o processamento, em vez de gerar um resultado silencioso.
- O arredondamento ocorre no resultado final positivo, não em uma cobertura intermediária.
- O total do grupo soma as sugestões já arredondadas por loja.
- Um excedente de estoque em uma loja não compensa automaticamente a falta em outra.
- A base completa de estoque do CPV tem prioridade por loja; na ausência, usa-se a base Brasil/global.
- As fontes de estoque não são somadas entre si.
- PN ausente em um retrato completo pode representar zero; ausência da própria fonte não é automaticamente zero.
- “Trânsito” significa dias adicionais de cobertura/lead time nesse motor, não quantidade de mercadoria a caminho a ser abatida.
- AMZ não é tratado como estoque disponível.
- O motor ativo não aplica QME, lote mínimo ou múltiplo de compra.

### 13.4 Curvas no MIRA: referência, não decisão da Rodada

No MIRA, a classificação Lume usa ocorrência mensal líquida positiva, com pesos do mais antigo ao mais recente de 1 a 6. As faixas encontradas são:

| Curva MIRA | Pontuação |
|---|---:|
| A | 15 a 21 |
| B | 9 a 14 |
| C | 4 a 8 |
| D | 0 a 3 |

Essas faixas não foram automaticamente aprovadas para a Rodada.

O MIRA também contém análises Pareto de faturamento e quantidade, distintas da Lume. A configuração da API usa cortes 60/80; há referência legada de fallback 50/80. A classificação combinada considera A se uma das classificações for A, depois B e, caso contrário, C. Existe ainda combinação analítica com Lume, incluindo tratamento de D como C em parte dessa análise. Essas classificações não alteram diretamente a quantidade sugerida pelo motor descrito.

Cartões de perda/falta com janela de 30 dias não equivalem ao horizonte de reposição de 90 dias. O cartão de falta AMZ e a sugestão de compra têm propósitos distintos. Também há curvas DFS sem dependência de AMZ.

### 13.5 Divergência com o handoff da Rodada

| Aspecto | Handoff da Rodada | Motor ativo do MIRA |
|---|---|---|
| Necessidade | Demanda menos estoque menos trânsito em quantidade | Cobertura em dias × demanda diária menos estoque |
| Trânsito | Quantidade recebível abatida | Dias adicionais somados ao horizonte |
| Arredondamento | Para cima ao QME | Para cima à unidade inteira |
| Múltiplo obrigatório | Pedido múltiplo do QME | Não aplicado no motor ativo |
| Demanda | Método precisa ser detalhado | Seis meses líquidos, divisor padrão 180 |

Essas diferenças são materiais. É preciso escolher o comportamento da Rodada e documentar cada variável, sua unidade e origem. Não se deve usar o mesmo nome “trânsito” para grandezas diferentes.

### 13.6 Referências técnicas do MIRA

A leitura identificou o fluxo ativo de estudo de reposição em `src/App.tsx`, rota `/reposicao`, API `calculate_study` em `server/app.py` e cálculo em `server/engine.py`. O memorial está em `src/modules/study/calculation-memorial.ts`.

Existe um cálculo legado em `src/modules/replenishment/domain/calc.ts`, com dias reais e sem o mesmo acréscimo de trânsito. Ele não deve ser confundido com o motor ativo. Referências documentais: `docs/estudo-reposicao-motor.md`, `docs/implementation-contract.md` e `README.md`.

A investigação foi de leitura. Não incluiu execução de testes, mudança do MIRA ou reativação de serviços.

## 14. Pedidos, histórico e concorrência

### 14.1 Evolução da discussão

Primeiro foi considerada a possibilidade de concentrar edição de pedidos no CPV. Depois, o usuário propôs uma abordagem mais forte de rastreabilidade: uma alteração cria um novo pedido/versão e cancela ou substitui o anterior, preservando o histórico.

Portanto, “somente CPV pode editar” não deve aparecer como decisão final. A matriz de quem pode solicitar substituição continua aberta.

### 14.2 Direção de versionamento

A nova versão deve estar vinculada à anterior. É necessário preservar:

- Autor e perfil de quem realizou a ação.
- Data e hora.
- Motivo da substituição/cancelamento.
- Diferenças entre as versões.
- Vínculos entre anterior e sucessora.
- Identificação inequívoca da última versão válida.

Não há exclusão do pedido anterior como forma de edição. O histórico deve permitir responder se a alteração veio do CPV, fornecedor, concessionária ou outro ator autorizado.

### 14.3 Concorrência

Histórico, sozinho, não impede conflito. Se duas pessoas partem da mesma versão, ambas não podem produzir sucessoras vigentes independentes.

O comportamento discutido é:

1. A primeira substituição válida confirma a nova versão.
2. O sistema deixa a anterior como substituída/cancelada.
3. A segunda tentativa detecta que sua base já não é vigente.
4. O segundo usuário revisa a versão atual antes de tentar novamente.

A troca deve ser **atômica**, ou seja, tudo ou nada. Não pode existir intervalo confirmado no qual o pedido antigo foi invalidado e o novo não existe, nem duas versões vigentes.

**Proposta técnica:** controle otimista de versão, validação transacional e restrições no banco para proteger essa regra. O mecanismo exato não foi implementado/aprovado como desenho final.

### 14.4 Estados e totalização

Os conceitos centrais são rascunho, fechado, cancelado/substituído e vigente. A lista definitiva de estados e transições permanece pendente.

Regra de totalização: somente versão **vigente e fechada** contribui para os indicadores de realizado correspondentes. “Vigente” e “fechado” são condições diferentes.

Questões abertas:

- Versionamento do pedido inteiro ou de cada linha?
- Substituição de pedido fechado exige aprovação?
- Quem pode cancelar sem criar sucessor?
- Como lidar com pedidos já exportados ou colocados no CSPS?
- Como tratar rascunhos de substituição sem retirar prematuramente a validade do pedido atual?

**Recomendação:** separar estados de integração externa dos estados comerciais. Substituir localmente um pedido não cancela automaticamente algo já colocado no CSPS.

## 15. CSPS, exportação e conciliação

O fluxo discutido prevê exportar os pedidos elegíveis, efetuar sua colocação no processo externo, carregar o realizado e comparar o que foi registrado com o que foi efetivamente processado.

Já existem consultas/views voltadas à exportação e à conciliação. Isso não significa que as telas estejam prontas ou que haja integração automática de ponta a ponta.

Pendências:

- Layout e exemplos reais de exportação/importação.
- Identificadores de correspondência entre pedido, versão e realizado.
- Responsável pela exportação e colocação.
- Frequência e janela de conciliação.
- Tratamento de rejeição, atendimento parcial, divergência de preço e quantidade.
- Reexportação sem duplicidade.
- Tratamento de substituição após exportação.
- Separação por categoria, fornecedor e destino.

O usuário concordou em tratar a exportação com mais detalhe posteriormente. O tema permanece no escopo de análise, sem fechamento funcional.

## 16. Painéis, telão, patrocinadores e premiações

Há necessidade de acompanhar metas e resultados durante a rodada. Foi citado como referência um painel de junho de 2026.

O telão é uma experiência diferente da tela operacional: deve ser legível à distância, agregado e sem edição. A referência de acesso público sem login está no handoff, mas exige revisão do conteúdo que poderá ser exposto.

Direções e pendências:

- Totalizar apenas pedidos vigentes e fechados.
- Definir recortes por regional, grupo e categoria.
- Validar a regra de FULL para não duplicar resultado.
- Definir quais contratos/fornecedores entram em cada número.
- Pactuar intervalo de atualização e tolerância a atraso.
- Alinhar patrocinadores com Bruno.
- Reservar área separada para campanhas/premiações.
- Receber e detalhar as regras de premiação, ainda não explicadas.

**Proposta técnica:** painel consumir resumos/consultas agregadas apropriadas, evitando recalcular grandes volumes a cada atualização de cada tela.

## 17. Arquitetura candidata

### 17.1 Princípio de dimensionamento

Trezentos usuários simultâneos não equivalem a 300 bancos, 300 servidores ou 300 pedidos por segundo. A carga real depende de ações por minuto, linhas por pedido, buscas, importações, tamanho das bases e frequência de atualização dos painéis.

Também não é correto presumir que backend ligado a PostgreSQL necessariamente travará. Uma arquitetura convencional pode atender, desde que seja desenhada e validada para a carga efetiva. Não há garantia antes dos testes.

### 17.2 Desenho proposto

```text
Navegadores dos usuários
        |
        v
Aplicação web / backend modular
  - autenticação e autorização
  - regras comerciais
  - pedidos e versionamento
  - idempotência e validações
        |
        v
PostgreSQL: fonte de verdade transacional
        |
        +--> consultas/resumos para painéis
        +--> processamento controlado de cargas e exportações
```

Elementos candidatos:

- Backend modular, sem necessidade inicial demonstrada de microserviços.
- Transações curtas para operações de pedido.
- Índices orientados às consultas reais.
- Pool de conexões adequado ao ambiente.
- Gravações idempotentes e repetição segura diante de falhas.
- Controle de versão para concorrência.
- Processamento de importações e cálculos pesados separado do caminho de negociação, se necessário.
- Cache ou resumos para leitura, sem substituir o banco como autoridade do pedido.
- Instrumentação para entender latência, erros e saturação.

Tudo isso é proposta de engenharia. O desenho final deve resultar das regras de negócio, da aprovação de ambiente e dos testes.

### 17.3 Cópias do banco, réplicas e consolidação

A ideia trazida pelo usuário pode corresponder a diferentes tecnologias:

- **Réplica de leitura:** copia dados para atender consultas. Pode ter atraso e não distribui automaticamente as gravações.
- **Cache:** mantém resultados ou dados consultados com frequência. Precisa de política de atualização/invalidação.
- **Processamento assíncrono:** executa tarefas fora do caminho imediato do usuário. Exige saber quando a ação está apenas recebida ou concluída.
- **Múltiplos bancos graváveis e consolidação:** distribui escrita, mas aumenta complexidade de conflito, consistência e reconciliação.

Para o cenário descrito, não há evidência de que múltiplos bancos graváveis sejam necessários. Primeiro é melhor medir uma base transacional consistente. Réplica/cache eventualmente desatualizados não devem decidir qual versão do pedido é a vigente no momento de uma substituição.

### 17.4 Hospedagem, domínio e segurança

Um domínio organiza o endereço de acesso; não resolve desempenho. Vercel estava em avaliação. A hospedagem de dados corporativos depende de alinhamento/aprovação da liderança antes da publicação.

**Recomendações a validar, não requisitos já decididos:** política de backup e restauração testada, segregação de ambientes, mínimo privilégio, proteção de dados expostos em logs, monitoramento, plano de recuperação e revisão do acesso público ao telão.

## 18. Arquitetura de testes

### 18.1 Objetivo

Demonstrar, com evidência repetível, que aproximadamente 300 usuários autenticados podem executar ações diferentes e gravar pedidos sem perda, duplicidade, conflito silencioso ou totalização incorreta.

O usuário solicitou registrar esse plano para continuidade do projeto. Não houve execução do teste massivo nem aprovação de contratação de máquinas.

### 18.2 Camada 1: regras, integrações e integridade

Testar isoladamente e em conjunto:

- Pontuação dos seis meses e limites das curvas quando definidos.
- Fórmula de reposição, estoque, trânsito e QME quando definidos.
- Preços, descontos e elegibilidade de metas.
- Permissões por perfil, carteira, categoria e fase.
- Criação, fechamento, cancelamento e substituição.
- Duas substituições concorrentes da mesma versão.
- Reenvio da mesma operação após falha ou timeout.
- Apenas uma versão vigente.
- Histórico íntegro e totalização sem versões antigas.
- Validação e reaplicação de cargas.
- Exportação e conciliação sem duplicação.

### 18.3 Camada 2: teste de carga por protocolo/API

Usar ferramenta como k6 ou equivalente, com usuários virtuais independentes e sessões autenticadas próprias. A ferramenta exata ainda não foi escolhida.

O cenário deve misturar consultas, buscas, criação, substituição e fechamento, distribuindo perfis, carteiras, produtos e pedidos. Deve incluir pausas realistas e não apenas executar a mesma requisição repetidamente.

Etapas propostas:

1. Carga pequena para validar os scripts.
2. Crescimento gradual até o alvo.
3. Pico sincronizado de entrada/login e gravações.
4. Operação sustentada no patamar do evento.
5. Estresse acima de 300 para descobrir a margem e o primeiro gargalo.
6. Recuperação após a redução da carga e análise de integridade.

O volume de linhas por pedido e das bases precisa representar o evento. Dados de teste devem ser fictícios ou devidamente autorizados, sem presumir autorização para copiar dados reais para qualquer ambiente.

### 18.4 Camada 3: navegadores reais

Usar Playwright ou equivalente para testar o percurso completo: login, navegação, preenchimento, mensagens de salvamento, tratamento de conflito e confirmação.

Parte desses navegadores pode operar enquanto a carga de API está ativa. Isso verifica a experiência percebida, além da resposta do servidor. O número de navegadores reais deve ser dimensionado para a finalidade do teste, não automaticamente igualado a 300.

### 18.5 IPs, máquinas virtuais e agentes de IA

A proposta inicial do usuário foi criar várias máquinas/IPs e agentes para operar 300 janelas. Isso pode exercitar comportamentos exploratórios, mas não é necessário como arquitetura principal de carga.

- Muitos usuários virtuais podem ser gerados por poucas máquinas bem dimensionadas.
- IP diferente não significa usuário/sessão diferente; autenticação e dados precisam ser independentes.
- O evento pode ter vários usuários atrás do mesmo IP de Wi-Fi, cenário que também deve ser avaliado.
- Carga distribuída por origem é útil se localização, rede ou limites por IP forem relevantes.
- Agentes de IA podem apoiar exploração, mas introduzem variabilidade e não substituem scripts determinísticos para comparação de desempenho.

### 18.6 Métricas e aceite

Medir latência e percentis, taxa e natureza dos erros, throughput, CPU, memória, conexões/pool, bloqueios, consultas lentas e situação dos pedidos persistidos. Comparar quantidades esperadas com o banco, o histórico e os indicadores.

Critérios funcionais já coerentes com a direção discutida:

- Nenhum pedido confirmado perdido.
- Nenhuma duplicação por repetição da mesma operação.
- Uma única versão vigente por cadeia de pedido.
- Nenhuma sobrescrita silenciosa.
- Histórico auditável.
- Totais reconciliados com versões vigentes e fechadas.

**Ainda não aprovados:** valores numéricos de latência, taxa de erro, duração de teste, mistura de ações, volume por pedido, frequência do painel e margem acima de 300. Esses limites devem ser acordados antes de declarar aprovação de capacidade.

## 19. Infraestrutura e custos

### 19.1 Resposta à referência de US$ 200

A estimativa discutida em 21/10 foi de **US$ 100 a US$ 250 no mês do evento**, com **US$ 200 como reserva inicial plausível** para um pico concentrado em poucos dias. Não é orçamento aprovado, cotação fechada, limite de cobrança nem garantia de capacidade.

Não é custo total de desenvolvimento da plataforma.

| Componente | Ordem de grandeza discutida |
|---|---:|
| Aplicação | US$ 20 a US$ 50/mês |
| Banco de dados | US$ 20 a US$ 70/mês |
| Serviços auxiliares | US$ 0 a US$ 30/mês |
| Subtotal ilustrativo | US$ 40 a US$ 150/mês |
| Reserva mais ampla para consumo, testes e incerteza | Planejamento total de US$ 100 a US$ 250 |

As faixas não são componentes garantidos nem devem ser somadas como proposta comercial formal.

### 19.2 Referências pesquisadas em 21/10

- **Vercel Pro:** referência de US$ 20/mês para um assento de implantação, com US$ 20 de crédito de uso. Fonte: [Vercel Pro Plan](https://vercel.com/docs/plans/pro-plan).
- **Neon Launch:** referência de US$ 0,106 por CU-hora e US$ 0,35 por GB-mês de armazenamento. Fonte: [Neon Pricing](https://neon.com/pricing).

Os preços são referências históricas de planejamento verificadas na ocasião, não promessa de manutenção da tarifa. Planos, cobrança de recursos e extras devem ser revalidados antes da contratação.

### 19.3 Exemplo ilustrativo de banco

Com os valores de referência acima, considerar 4 CU por 72 horas e 0,25 CU nas outras 648 horas de um mês de 720 horas resulta em:

```text
4 × 72 = 288 CU-h
0,25 × 648 = 162 CU-h
Total = 450 CU-h
Compute = 450 × US$ 0,106 = US$ 47,70
10 GB × US$ 0,35 = US$ 3,50
Total ilustrativo = US$ 51,20, antes de outros recursos e extras
```

Se 4 CU permanecessem ativos durante todas as 720 horas, o compute sozinho seria US$ 305,28. O perfil de uso faz grande diferença.

Esse exemplo **não demonstra que 4 CU sejam o tamanho necessário ou suficiente**. O dimensionamento deve ser medido.

### 19.4 Exclusões e variáveis

Não estão incluídos automaticamente: desenvolvimento, trabalho humano de testes/operação, domínio anual, impostos, câmbio, todos os recursos de backup/histórico, tráfego adicional ou ambientes extras.

A ferramenta k6 pode ser usada em sua versão de código aberto, mas a infraestrutura geradora de carga ainda pode custar. O orçamento final depende de duração do pico, pedidos por minuto, linhas por pedido, volume de bases, consultas do telão, disponibilidade desejada e tempo mantido em capacidade elevada.

Não houve compra ou contratação autorizada como consequência dessa estimativa.

## 20. Cronograma, dependências e riscos

### 20.1 Referências de calendário

- Evento: segunda semana de dezembro de 2026; dia exato pendente.
- Entrada em testes em 16/11 foi discutida como referência, não prazo aprovado.
- Intenção de reservar pelo menos três semanas para correções.
- Regras comerciais e faixas de desconto podem chegar apenas na última semana de novembro.
- Havia referência a reunião de handoff em 20/10 às 16h30, horário de Curitiba; o resultado não foi confirmado nesta consolidação.

A chegada tardia das regras comerciais é um risco de retrabalho e reduz a janela de validação realista.

### 20.2 Dependências críticas

1. Fechar escopo, jornadas e permissões.
2. Receber/validar bases e layouts.
3. Definir preço, descontos, contratos e metas.
4. Conciliar fórmula de reposição, trânsito e QME.
5. Implementar núcleo de pedidos com histórico e concorrência.
6. Construir painéis e integração operacional com CSPS.
7. Aprovar ambiente e publicação.
8. Testar carga, integridade e recuperação.

### 20.3 Riscos principais

| Risco | Consequência | Tratamento proposto |
|---|---|---|
| Regras comerciais tardias | Retrabalho e testes incompletos | Separar parâmetros de regras estruturais; reservar validação final |
| Dados reais indisponíveis ou inconsistentes | Sugestões e metas incorretas | Contratos de dados e validação antecipada |
| FULL e contratos mal classificados | Dupla contagem | Definir elegibilidade por indicador |
| Alterações concorrentes | Perda de informação e disputa | Versionamento atômico e conflito explícito |
| Premissas de preço divergentes | Pedidos com valor incorreto | Validar fonte efetiva por dealer/destino |
| Carga não representativa | Falsa sensação de capacidade | Testar mistura, volumes e duração reais |
| Aprovação de hospedagem tardia | Impedimento de publicação | Alinhar ambiente corporativo antes de implantar |
| Falha de rede no evento | Reenvios e pedidos duplicados | Feedback, repetição segura e plano operacional a validar |
| Mudança após exportação | Divergência local/CSPS | Política explícita de correção e conciliação |

Os tratamentos são recomendações de planejamento, não compromissos já atribuídos a pessoas.

## 21. Conflitos entre fontes

| Tema | Premissa anterior | Discussão posterior | Tratamento no projeto |
|---|---|---|---|
| Fechamento do escopo | Handoff relativamente definido | Levantamento ainda aberto | Não tratar o handoff como aprovação total |
| Preço | Uniformidade por PN/condição | Possíveis diferenças por dealer/destino | Validar fonte efetiva e aplicação do desconto |
| Fornecedores | Inclusão ampla no atingimento | Contratos podem não contar em números Stellantis | Regra por indicador/categoria |
| Reposição | Demanda − estoque − trânsito; QME | MIRA usa dias adicionais e não QME | Decidir fórmula, unidades e arredondamentos |
| Edição | Alteração do pedido / hipótese de CPV exclusivo | Nova versão preservando anterior | Aplicar direção de histórico; fechar permissões |
| Sugestão | Cálculo dentro da plataforma | Possível captura/consolidação de sugestão externa | Definir responsabilidade do sistema |
| Escala | Usuários em geral | 300 operadores criando pedidos | Testar escrita, não apenas consultas |

Não se deve resolver essas diferenças silenciosamente. Uma decisão posterior precisa registrar o que substitui, sua justificativa e o impacto nos dados e testes.

## 22. Backlog consolidado

A ordem abaixo é uma proposta de dependências, não sprint contratado nem compromisso de entrega.

### Bloco A: definição e dados

- [ ] Confirmar evento, participantes e janelas de operação.
- [ ] Validar perfis, escopos e ações por fase.
- [ ] Mapear diferenças FCA/PSA.
- [ ] Especificar cobertura temporária de CPVs.
- [ ] Obter arquivos e dicionário das nove cargas.
- [ ] Fechar origem de preço e regras de desconto.
- [ ] Definir categorias, contratos, FULL e metas.
- [ ] Fixar regras dos 21 pontos, faixas e data de corte.
- [ ] Decidir cálculo quantitativo de reposição.

### Bloco B: núcleo da negociação

- [ ] Implementar consulta de carteira e seleção de grupo/dealer.
- [ ] Implementar busca de ofertas e montagem de pedido.
- [ ] Definir rascunho e fechamento.
- [ ] Implementar substituição com histórico completo.
- [ ] Proteger unicidade da versão vigente.
- [ ] Implementar conflito explícito e repetição segura.
- [ ] Revisar autorização no servidor.

### Bloco C: experiências e acompanhamento

- [ ] Desenhar/validar UX de admin, CPV, fornecedor e regional.
- [ ] Decidir acesso direto de concessionárias.
- [ ] Implementar painel e telão.
- [ ] Alinhar patrocinadores com Bruno.
- [ ] Detalhar campanhas de premiação.
- [ ] Implementar fluxos de exportação e conciliação CSPS.

### Bloco D: operação e capacidade

- [ ] Aprovar hospedagem e publicação.
- [ ] Definir critérios numéricos de aceite.
- [ ] Criar massa e scripts representativos.
- [ ] Executar testes funcionais, carga e navegadores.
- [ ] Reconciliar pedidos e indicadores após os testes.
- [ ] Dimensionar recursos e revisar custos com medições.
- [ ] Validar restauração, monitoramento e resposta a incidentes, se aprovados no plano operacional.

## 23. Registro de decisões e perguntas abertas

### 23.1 Direções preservadas

| ID | Direção | Estado |
|---|---|---|
| D01 | Mapear perfis antes de cadastrar usuários | Direção definida |
| D02 | Cobertura personalizada de CPVs no mesmo regional | Necessidade definida; detalhamento aberto |
| D03 | Regra binária de seis meses, pesos 6 a 1 | Regra conceitual definida |
| D04 | Horizonte inicial de 90 dias | Direção definida; fórmula completa aberta |
| D05 | Avaliar cálculo do MIRA | Referência de estudo, não adoção integral |
| D06 | Alterar por nova versão preservando a anterior | Direção definida |
| D07 | Uma versão vigente e conflito sem sobrescrita silenciosa | Direção de integridade |
| D08 | Somente vigente e fechado nos indicadores | Direção de totalização |
| D09 | Preparar para 300 operadores simultâneos | Requisito de capacidade |
| D10 | Registrar arquitetura de testes | Planejamento solicitado; execução pendente |

### 23.2 Perguntas que bloqueiam fechamento

1. Qual a data exata e duração do evento?
2. Quais atores efetivamente criam, fecham, substituem e cancelam pedidos?
3. Haverá acesso direto de concessionárias? Com quais limites?
4. Como se divide e encerra a cobertura temporária do CPV?
5. Qual é a fonte do preço efetivo por dealer e como se aplica a promoção?
6. Quais diferenças fiscais/comerciais precisam ser representadas?
7. FULL compõe o objetivo do armazém ou tem objetivo separado?
8. Quais contratos/fornecedores contam em cada indicador?
9. Quais são as faixas Lume da Rodada e a janela de meses?
10. O cálculo quantitativo será feito na plataforma ou recebido pronto?
11. Trânsito será quantidade, dias ou ambos em variáveis diferentes?
12. QME/múltiplos serão obrigatórios? De qual base virão?
13. O versionamento será por pedido inteiro ou linha?
14. Qual o tratamento de alteração após exportação/colocação no CSPS?
15. Qual o layout e a chave de conciliação do CSPS?
16. Quais dados podem ser publicados no telão e com qual frequência?
17. Quais são as regras das premiações e a participação dos patrocinadores?
18. Qual ambiente será aprovado para dados corporativos?
19. Quais limites numéricos definirão sucesso nos testes?
20. Qual orçamento e margem serão autorizados após dimensionamento?

As responsabilidades e os prazos de resposta precisam ser atribuídos. Este documento não cria compromissos em nome de pessoas ou equipes.

## 24. Próximos passos

A sequência recomendada para continuar sem perder o trabalho já feito é:

1. **Validar esta consolidação:** corrigir entendimentos de negócio e marcar decisões que realmente podem ser fechadas.
2. **Fechar o núcleo comercial:** perfis, categorias, preço, FULL, contratos e metas.
3. **Resolver a reposição:** distinguir pontuação de quantidade; definir demanda, estoque, trânsito, QME e exemplos esperados.
4. **Especificar o ciclo do pedido:** estados, permissões, substituição, conflito e efeito na exportação.
5. **Obter os dados:** arquivos representativos, dicionário, volumes e layouts CSPS.
6. **Desenhar e validar jornadas:** usar o whiteboard como mapa de conceitos, depois detalhar as telas prioritárias.
7. **Implementar o caminho essencial:** negociação interna, versionamento, indicadores e integração operacional.
8. **Medir antes de dimensionar definitivamente:** executar os testes representativos e ajustar arquitetura/custos com evidência.
9. **Fechar operação do evento:** aprovação de publicação, suporte, recuperação e responsabilidades.

O handoff sugeria negociação interna → painel → jornadas externas → CSPS. Essa sequência continua como referência, mas precisa ser revisada à luz das dependências e do escopo final.

## 25. Fontes e glossário

### 25.1 Fontes do projeto

- Conversas sobre o projeto em 20 e 21/10/2026, incluindo as direções sobre perfis, cobertura CPV, 21 pontos, 90 dias, FULL, versionamento, capacidade e testes.
- `docs/HANDOFF.md`, atualizado em 19/10/2026: [repositório Rodada de Negócios](https://github.com/raulchagas/rodada-de-negocios/blob/main/docs/HANDOFF.md). O link acompanha a versão da branch; o estado descrito neste documento corresponde à leitura de 21/10.
- `docs/LEVANTAMENTO-DE-ESCOPO-E-JORNADAS.md`, atualizado em 20/10/2026, com escopo ainda não aprovado.
- Leitura local de código em 21/10/2026: base no commit `f30571f`, de 19/10.
- Leitura do motor ativo e documentação do MIRA, realizada para comparar a sugestão de reposição.
- [Whiteboard do projeto](https://chatgpt.com/space/page_633abaf90414819181aae1ed80df034c), consolidado em 21/10: oito grupos de conceitos, com usuários/necessidades/UX, jornada, regras, dados, reposição, arquitetura, testes e decisões. A UX é proposta.
- [Apresentação anterior](https://chatgpt.com/space/page_9ac17dfc61988191abfeb62370eb8043): material histórico de organização. O usuário a considerou pouco visual e pediu o whiteboard; não representa aprovação de escopo ou de apresentação.
- Referências comerciais de infraestrutura consultadas em 21/10: [Vercel Pro](https://vercel.com/docs/plans/pro-plan) e [Neon](https://neon.com/pricing).

### 25.2 Glossário operacional

| Termo | Uso neste documento |
|---|---|
| Dealer | Concessionária/loja de destino |
| Grupo | Agrupamento comercial, considerado por marca no handoff |
| CPV | Perfil de atendimento associado a setor/carteira; expansão da sigla não validada aqui |
| FCA / PSA | Conjuntos da rede citados pelo usuário; suas estruturas precisam ser mapeadas |
| PN | Identificador do produto/peça |
| FULL | Pedido destinado ao fulfillment do Mercado Livre |
| ST | Componente tributário mencionado na distinção de valor comercial; regra fiscal pendente |
| QME | Múltiplo de embalagem/compra referido no handoff; definição operacional e origem a validar |
| Lume | Classificação baseada na ocorrência ponderada de vendas |
| MIRA | Projeto de referência para o cálculo de reposição |
| CSPS | Sistema/processo externo usado no fluxo de colocação e conciliação discutido |
| Versão vigente | Versão atualmente válida de uma cadeia de pedido |
| Fechado | Estado comercial que, em conjunto com vigência, permite contar nos indicadores aplicáveis |
| Idempotência | Repetir a mesma operação sem criar um segundo efeito indevido |
| Atomicidade | Executar a mudança completa ou não executá-la |
| Réplica de leitura | Cópia destinada a consultas, com possibilidade de atraso |
| CU-hora | Unidade de consumo computacional usada na referência de preço Neon |

**Síntese final:** o projeto já tem base técnica e direções importantes de negócio, mas ainda precisa fechar regras, dados e jornadas antes de ser tratado como especificação pronta para produção. O valor deste consolidado é preservar o que foi discutido, explicitar o que mudou e impedir que hipóteses sejam confundidas com decisões ou entregas.
