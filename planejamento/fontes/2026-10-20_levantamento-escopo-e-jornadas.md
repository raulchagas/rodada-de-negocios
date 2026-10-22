# Levantamento de escopo e jornadas

> **LEVANTAMENTO EM ANDAMENTO — NÃO É ESCOPO APROVADO.**
> Registro incremental para discussão. Não altera as decisões vigentes nem autoriza implementação.
> Fonte: declarações de Marcos nas chamadas de 19 e 20/10/2026, transmitidas para documentação. Atualizado em 20/10/2026.

## Contexto e condução do projeto

- Marcos recebeu material para construir a plataforma. O desenvolvedor começou o rascunho na sexta-feira, 16/10. Não se trata de avaliação de entrega de sistema pronto.
- A prioridade é a gestão do projeto: levantar jornadas, depois definir acessos e permissões e, a partir do escopo discutido, detalhar o cronograma de desenvolvimento.
- O material original recebido não foi localizado nesta cópia do projeto. Os documentos técnicos existentes não comprovam, por si, a origem dos requisitos.
- Este documento preserva separadamente as declarações da chamada. Divergências com `decisoes.md` ou `HANDOFF.md` precisam ser discutidas; esses arquivos não foram alterados.

## Datas e dimensão esperada

| Item | Registro | Situação |
|---|---|---|
| Evento | Segunda semana de dezembro de 2026 | Dia exato pendente |
| Plataforma pronta para testes | 16/11/2026: referência conservadora discutida, quatro semanas desde a chamada | Referência de planejamento, não compromisso aprovado |
| Testes e correções | Preservar pelo menos três semanas para testes massivos e correções | Detalhar após levantamento |
| Reunião de handoff | 20/10/2026 às 16h30, horário de Brasília | Informado na chamada; este registro não agenda a reunião |
| Uso simultâneo | Expectativa de 200–300 usuários e cerca de 200 concessionárias | Validar dimensionamento e cenários de carga |
| “200 milhões” | Unidade não confirmada | Não interpretar como quantidade de pedidos, transações ou valor financeiro |

## Públicos e jornadas iniciais

Os públicos abaixo descrevem atividades pretendidas; não constituem uma matriz de permissões aprovada.

| Público | Atividade declarada | Pontos a detalhar |
|---|---|---|
| Fornecedores | Cadastrar e ajustar ofertas, preços e condições; também criar pedidos | Forma de entrada, prazo, bloqueio de alterações e regras comerciais; jornada de criação de pedidos será detalhada depois |
| Central Stellantis | Acompanhar pedidos em tempo real | Indicadores, atualização e visão operacional |
| Regionais | Colocar pedidos para concessionárias | Seleção da concessionária, registro, revisão e fechamento |
| Concessionárias | Potencialmente colocar os próprios pedidos | Acesso direto ainda é decisão estrutural pendente |

## Decisões estruturais pendentes

1. **Acesso direto das concessionárias:** haverá colocação própria ou operação pelas regionais?
2. **Lista especial:** existirá uma lista com prioridade por ordem de chegada? Se existir, definir reserva, confirmação, desempate e o momento que caracteriza a chegada. A existência da lista não está aprovada.
3. **Responsabilidade da plataforma:** apenas receber/carregar/consolidar pedidos ou também calcular sugestões?

**Preferência de Marcos:** a solução mais simples de receber, carregar e consolidar pedidos. Sugestões possivelmente seriam tratadas em planilha. É uma preferência e uma alternativa em discussão, não uma decisão fechada. O papel das sugestões precisa ser conciliado com o registro técnico existente sobre a base dos 21 pontos.

## Jornada do fornecedor — etapa 1: carregar ofertas

### Declarações

- O fornecedor carrega ofertas, com prazo ainda a definir.
- Após a carga inicial, o fornecedor pode fazer ajustes. O administrador poderá bloquear alterações; o momento e a regra desse bloqueio ainda precisam ser definidos.
- O fornecedor também poderá criar pedidos. Essa jornada será detalhada depois, sem definição de fluxo ou permissões nesta etapa.
- Campos mencionados: código de produto, descrição, preço e desconto(s).
- Foi citada a possibilidade de desconto progressivo por quantidade.
- Foram mencionadas tanto regras por concessionária/destino quanto uma regra única para o evento. A relação entre essas alternativas permanece ambígua.

### Particularidades das ofertas da Stellantis

- Segundo Marcos, a própria Stellantis é o principal fornecedor, com ofertas do armazém/fábrica. A nomenclatura final para essa origem está aberta.
- Há uma lista total de itens do mês e uma lista promocional específica da rodada.
- Para a **lista promocional da Stellantis da rodada**, a orientação declarada é ignorar os preços contidos nela e usar somente a identificação do item e o desconto, a aplicar à concessionária que faz o pedido.
- Essa orientação é específica dessa lista; não foi generalizada às ofertas de outros fornecedores.
- A base de preço efetiva por concessionária e sua relação com a lista mensal ainda precisam de esclarecimento. Não há fórmula definida nem pressuposto de preço uniforme entre concessionárias.

### Preferências e alternativas

- Preferência por carregamento via planilha.
- Cadastro item a item permanece como alternativa aberta.
- A lista de preços pode ter São Paulo como referência; confirmar esse entendimento.

### Hipóteses e exemplos — não são regras aprovadas

- Exemplos de desconto: 1 peça com 5% e 10 peças com 15%.
- Esses números ilustram uma possibilidade; não definem faixas, cumulatividade, base de cálculo nem fórmula.
- A fala sobre imposto foi entendida como “IC T”, com incerteza. Não interpretar automaticamente como ICMS.

### Indicador comercial e tratamento fiscal

- Critério comercial declarado por Marcos: o valor de pedido/venda considerado para o evento é o valor do produto sem ST, entendida por ele como custo do cliente.
- Esse indicador comercial deve ser separado do total legal da nota fiscal. O registro não afirma que a nota fiscal exclui ST.
- Tratamento fiscal, composição dos valores e conciliação permanecem sujeitos a validação. Nenhuma fórmula fiscal foi definida nesta etapa.

### Perguntas abertas

1. Qual será o prazo para envio das ofertas e em que momento/regra o administrador bloqueará os ajustes? Como serão tratadas correções após o bloqueio?
2. A planilha será o único canal ou haverá também cadastro item a item?
3. Qual é a referência exata do preço informado e quais componentes estão incluídos?
4. O que significa o termo ouvido como “IC T”?
5. Haverá regra única para o evento, regras por concessionária/destino ou combinação? Qual prevalece?
6. Se houver descontos progressivos, como funcionam os limites das faixas e a aplicação do desconto? Os descontos se acumulam?
7. Como representar separadamente o valor comercial do evento, ST e os valores fiscais, e como conciliá-los?
8. Quem validará as condições comerciais e o tratamento fiscal antes do uso?
9. Qual é a fonte da base de preço efetiva de cada concessionária e qual a relação dessa base com a lista total de itens do mês?
10. Como relacionar os itens e descontos da lista promocional Stellantis à concessionária que faz o pedido, sem usar os preços dessa lista?
11. Qual será a nomenclatura final das ofertas da própria Stellantis (armazém/fábrica)?

### Critérios a validar antes de fechar esta jornada

- Layout de oferta compreensível, com definição inequívoca de cada campo e exemplos validados pelo negócio.
- Forma de entrada e prazo definidos, incluindo o tratamento de correções.
- Regra de bloqueio de ajustes pelo administrador definida.
- Origem do preço por concessionária esclarecida e tratamento da lista promocional Stellantis validado: somente identificação do item e desconto, desconsiderando os preços nela contidos.
- Regras de preço/desconto documentadas sem ambiguidades sobre quantidade, destino ou concessionária.
- Indicador comercial do evento distinguível dos valores fiscais e conciliável com os registros posteriores.
- Responsáveis pela validação comercial e fiscal identificados.

## Continuidade do levantamento

### Plano de arquitetura de testes para continuidade — chamada de 20/10/2026

**Status:** plano discutido e autorizado para registro, dentro do levantamento de escopo não aprovado. Não autoriza execução de testes, implementação, contratação ou publicação. As ferramentas e os critérios numéricos ainda precisam ser definidos.

#### Preparação

- Preparar um ambiente isolado semelhante à produção, com dados fictícios representativos do volume e da distribuição esperados. Não se pressupõe autorização para usar dados reais.
- Preparar sessões independentes autenticadas, com perfis, carteiras e dados distintos, incluindo conjuntos que permitam provocar conflitos controlados sobre o mesmo pedido.
- Pactuar tempos aceitáveis, taxas de erro, duração dos cenários e margem de capacidade. Nenhum limite numérico de aprovação foi definido nesta discussão.

#### Três frentes de validação

1. **Regras e integridade:** validar cálculos, permissões e versionamento, incluindo substituições concorrentes da mesma versão de um pedido. Verificar as regras que forem efetivamente definidas no escopo, sem preencher as lacunas atuais por inferência.
2. **Carga controlada:** simular 300 sessões independentes autenticadas, com mistura realista dos fluxos pesquisar, criar, substituir e fechar pedidos. Incluir aumento gradual de carga, pico sincronizado de entrada/login e gravação, atividade sustentada e estresse acima de 300 para descobrir a margem. A quantidade acima de 300, a duração e a distribuição dos fluxos precisam ser pactuadas.
3. **Experiência ponta a ponta:** executar navegadores reais em paralelo à carga para validar a experiência de uso enquanto a aplicação está sob pressão.

**Ferramentas candidatas:** k6 ou equivalente para carga; Playwright ou equivalente para navegadores reais. São opções a avaliar, não escolhas finais aprovadas.

#### Rede e geração de carga

- Incluir sessões compartilhando IP, como no Wi-Fi do evento, para avaliar esse cenário de acesso.
- Avaliar distribuição entre geradores de carga quando pertinente ao cenário e à capacidade de geração.
- Não são necessários 300 IPs, 300 máquinas virtuais ou 300 agentes de IA para representar 300 sessões. IA pode apoiar exploração; a medição principal deve ser repetível e controlada.

#### Observabilidade e conferência dos resultados

- Monitorar percentis de latência, erros e consumo de recursos, além de pool, conexões e bloqueios, na aplicação e no banco.
- Após os testes, reconciliar pedidos, totais e auditoria: nenhum pedido confirmado perdido ou duplicado; apenas uma versão vigente; conflitos tratados sem sobrescrita silenciosa.
- Conferir a consistência dos indicadores com a regra registrada de considerar somente a versão vigente e fechada.
- Registrar cenários, configuração, dados utilizados, resultados e falhas para permitir repetição e comparação após correções.

#### Critérios de aprovação a pactuar

- Definir os limites numéricos de latência e erro, a duração da atividade sustentada e a margem exigida acima de 300 sessões.
- Definir a mistura e o volume dos fluxos, os perfis envolvidos e a distribuição dos dados fictícios.
- Validar os critérios de integridade e a experiência ponta a ponta junto dos resultados de capacidade; volume de requisições isolado não comprova que os pedidos foram preservados corretamente.

**Execução nesta atualização:** somente documentação. Nenhum teste foi executado, nenhum ambiente foi contratado ou publicado e nenhuma implementação foi realizada.

### Versionamento de pedidos e concorrência — chamada de 20/10/2026

**Direção declarada por Marcos, com registro autorizado após discussão das salvaguardas:** uma alteração cria um novo pedido/versão vinculado ao anterior. O anterior é preservado como cancelado/substituído, sem exclusão, para manter o histórico e identificar o último pedido válido. O registro dessa direção não constitui aprovação global do escopo nem autorização de implementação.

**Histórico a registrar:** autor da alteração e seu perfil (CPV, fornecedor ou concessionária), data/hora, motivo, diferenças em relação à versão anterior, vínculo entre versões e identificação do último pedido válido. Os perfis mencionados identificam a autoria a rastrear; não definem, por si, as permissões de cada ator.

**Salvaguardas discutidas:**

- Substituição atômica, tudo ou nada: a criação da nova versão e a substituição da anterior precisam ocorrer como uma única operação consistente.
- Somente uma versão vigente para o pedido.
- Proteção contra duas substituições concorrentes da mesma versão: após a primeira substituição, o segundo ator precisa revisar a nova versão antes de prosseguir, sem sobrescrita silenciosa.
- Somente a versão **vigente e fechada** entra em totais, metas e telão. Versões canceladas/substituídas e versões ainda em rascunho não entram nesses valores.

**Questões ainda abertas:**

1. A substituição/versionamento será do pedido inteiro ou por linha?
2. Quais atores poderão criar ou substituir pedidos em cada fase do evento?
3. Como apresentar as diferenças e a revisão exigida quando outro ator já tiver substituído a versão?

A ideia anterior de edição exclusiva pelo CPV foi exploratória, não uma decisão final. As permissões por ator e fase continuam a ser levantadas.

**Requisito de capacidade informado nesta discussão:** cerca de 300 usuários simultâneos criando/editando pedidos. Esse cenário dá concretude à expectativa de 200–300 usuários registrada anteriormente e precisa orientar a avaliação de concorrência e integridade.

**Propostas técnicas a avaliar, sem aprovação de arquitetura final:** backend com PostgreSQL; resumo separado para o telão; testes de carga com dados realistas, incluindo conflitos entre atores e verificação de integridade dos pedidos e indicadores. A existência de PostgreSQL no rascunho técnico não equivale à aprovação definitiva dessas propostas para o cenário discutido.

**Situação:** direção e salvaguardas registradas para o levantamento. Código, produção, bases reais e permissões não foram alterados.

### Tipos de pedido, objetivos e referência de reposição — chamada de 20/10/2026

**Distinções declaradas por Marcos:**

- **Peças/armazém:** pedido de peças, referido como pedido do armazém.
- **Acessórios:** pedido relacionado ao objetivo de acessórios.
- **FULL:** uma espécie de subpedido do armazém, destinado ao envio para o fulfillment do Mercado Livre. Essa descrição não define, por si, o tratamento do seu objetivo.

**DECISÃO PENDENTE — O OBJETIVO FULL ESTÁ DENTRO DO OBJETIVO ARMAZÉM OU É SEPARADO?** Marcos destacou que essa regra precisa ser estabelecida depois. Nenhuma das alternativas foi assumida neste levantamento.

**Risco analítico a tratar:** sem uma regra explícita de inclusão e agregação, FULL pode ser contado duas vezes nos objetivos e no atingimento do armazém/total. É necessário definir futuramente como os objetivos e os valores realizados de FULL se relacionam com armazém, acessórios e totais, antes de consolidar esses indicadores.

**Metas dos CPVs:** em boa parte compilam objetivos das concessionárias, mas não representam necessariamente uma soma simples universal. A regra de composição e suas possíveis exceções ainda precisam ser detalhadas; não se presume uma fórmula única para todos os CPVs.

**Cálculo de reposição MIRA:** Marcos indicou que pode ser usado e será avaliado. É uma referência candidata, sem aprovação definitiva, fórmula adotada ou autorização para implementação. A avaliação deve esclarecer sua adequação à recomendação discutida, sem preencher por inferência as lacunas de cálculo já registradas.

**Perguntas abertas:**

1. O objetivo FULL integra o objetivo armazém ou é separado?
2. Como FULL entra no atingimento e nos totais, evitando dupla contagem?
3. Como se compõem as metas de CPV a partir dos objetivos das concessionárias e quais são as exceções?
4. Qual cálculo MIRA será avaliado e quais critérios determinarão sua adoção ou adaptação?

**Situação:** levantamento não aprovado; nenhuma mudança em código, carteiras ou bases reais decorre deste registro.

### Regra de 21 pontos — explicação inicial de Marcos em 20/10/2026

**Declaração de Marcos:** em uma janela de seis meses, cada mês contribui conforme houve ou não venda do produto. A ocorrência é binária: havendo venda, recebe o peso daquele mês; não havendo, recebe zero. Os pesos são 6 para o mês mais recente, depois 5, 4, 3, 2 e 1 para o mais antigo. O máximo é 21 pontos (6 + 5 + 4 + 3 + 2 + 1).

É uma pontuação de ocorrência/constância de vendas, com maior peso para meses recentes. Não representa volume vendido nem quantidade de demanda. **A conversão dessa pontuação em demanda ou sugestão ainda não foi explicada por Marcos.** Não se deduz aqui uma fórmula de demanda a partir dos pontos nem se altera o registro anterior sobre sugestões.

**Perguntas abertas:**

1. O mês mais recente é o mês corrente ou o último mês fechado?
2. Qual é a data de corte e como se define a janela de seis meses?
3. Como a pontuação será convertida ou utilizada no cálculo de demanda/sugestão, se essa etapa fizer parte do escopo?

**Cautela analítica nossa, separada da explicação de Marcos:** a nota isolada não identifica exatamente em quais meses houve venda, pois combinações diferentes de meses podem produzir a mesma soma. Para identificar os meses, é necessário preservar as ocorrências mensais, além da pontuação.

**Situação:** explicação inicial registrada para discussão; não constitui aprovação de escopo ou autorização de implementação.

#### Continuação: curvas por frequência e horizonte da recomendação

- **Explicação de Marcos:** a pontuação dos 21 pontos determina a curva do produto, familiar à rede. São curvas por ocorrência/frequência de vendas, não por faturamento nem por quantidade vendida.
- Foram mencionadas curvas A/B/C/D etc. As faixas de pontuação e seus limites ainda não foram informados; nenhum corte de curva foi definido neste levantamento.
- **Direção declarada para a recomendação/sugestão:** horizonte inicial de **90 dias, fixo por enquanto**. Uma revisão futura poderá ser discutida. Esse horizonte não define, por si só, como calcular a quantidade sugerida.
- Continuam sem explicação a fórmula da demanda e a conversão em quantidade. Não foram definidas médias, fórmulas de conversão de pontos ou outras regras de cálculo.
- **Ambiguidade a esclarecer:** a expressão final “mudar essa classificação” não permite concluir se Marcos se referia à curva, ao horizonte ou a outro aspecto. Não se presume alteração da classificação por curvas nem política futura fechada.

**Perguntas adicionais abertas:** quais são as faixas e limites de cada curva? Como será calculada a quantidade recomendada para os 90 dias? A que se refere exatamente “mudar essa classificação” em uma eventual discussão futura? Permanecem também abertas as perguntas anteriores sobre mês de referência e data de corte.

Este complemento registra a direção declarada na chamada, mantendo o status de levantamento em andamento e não aprovado.

### Gestão de carteiras e perfis — chamada de 20/10/2026

**Contexto declarado:** Marcos possui um Excel da rede FCA com regional, setor, grupo, lojas e códigos. Cada CPV atende um setor. Marcos distingue FCA (Fiat/Jeep/RAM) e PSA (Peugeot/Citroën) e ainda não conhece bem a organização PSA. A planilha mencionada não foi examinada nesta atualização; não se presume que a estrutura PSA seja igual à FCA.

**Primeira tarefa registrada:** mapear os perfis de acesso de cada público antes de associar usuários aos perfis. O mapeamento deve considerar as jornadas levantadas. Isso não aprova perfis dinâmicos para implementação nem fecha a matriz de permissões.

**Necessidade em gestão de carteiras:** permitir cobertura personalizada do setor de um CPV ausente ou em férias por outros CPVs da mesma regional. A distribuição pode envolver mais de um CPV; não pressupor um substituto único. Trata-se de cobertura operacional a detalhar, preservando a hierarquia oficial. Nenhuma carteira real foi modificada.

**Perguntas abertas para detalhar a cobertura:**

1. A divisão será feita por grupo, por loja ou por outro recorte? Como representar a distribuição personalizada entre os CPVs da mesma regional?
2. Qual será a vigência da cobertura e como serão registrados início, término e eventuais prorrogações?
3. Como ocorrerá o retorno da carteira ao CPV titular e o tratamento dos pedidos em andamento?
4. Quem será o responsável autorizado a definir, alterar e encerrar essa cobertura?
5. Quais acessos e ações cada CPV terá durante a cobertura, conforme o mapeamento de perfis ainda a realizar?
6. Como se organiza a rede PSA e quais diferenças precisam ser consideradas na gestão de carteiras?

**Situação:** necessidade mapeada para discussão; regras e critérios de validação ainda pendentes. Este registro não altera a hierarquia oficial, os perfis existentes ou as decisões técnicas vigentes e não autoriza implementação.

### Checklist de assuntos a retomar

- [ ] **PATROCINADORES NO PAINEL — discutir com Bruno.** Pedido expresso de Marcos para não esquecer; formato, conteúdo e regras ainda a discutir.
- [ ] **ESPAÇO SEPARADO PARA CAMPANHAS DE PREMIAÇÃO.** As regras serão explicadas depois; não há fluxo ou critérios definidos.
- [ ] **FORNECEDOR QUE TAMBÉM CRIA PEDIDO.** Detalhar essa jornada em conversa posterior.

Este checklist é um registro para retomada; não foi agendado lembrete, pois não houve horário definido.

### Complementos comerciais da chamada

- **Armazém Stellantis:** haverá um único armazém. O significado operacional dessa informação ainda precisa ser esclarecido, sem inferir regras de estoque, entrega ou reserva.
- **Duas listas Stellantis:** será carregada uma lista de preços sem desconto de todos os itens e outra lista promocional específica da rodada. Para a segunda, permanece a orientação de usar identificação do item e desconto e ignorar os preços nela contidos. A relação entre a primeira lista e a base efetiva por concessionária continua pendente; não foi definida fórmula nem preço uniforme.
- **Descontos progressivos ou por lote:** sua existência e suas regras permanecem incertas e só serão conhecidas na última semana de novembro. Os exemplos registrados anteriormente continuam ilustrativos.
- **Dependência tardia e risco de planejamento:** essa definição comercial virá depois da referência de 16/11 para entrada em testes. Pode exigir ajustes e validação adicional durante a janela de testes/correções. Registrar e discutir como tratar essa dependência; nenhum prazo foi alterado e nenhuma regra foi presumida.
- **Óleo:** costuma ser pedido em litros e pode ter campanhas específicas ainda desconhecidas. Confirmar unidades e regras dessas campanhas.
- **Tipos de fornecedor e pedidos a mapear:** óleo, acessórios, eletrônicos, periféricos e químicos, como fluido de arrefecimento. Lista preliminar, não exaustiva; não estabelece categorias definitivas da plataforma.
- **Pedidos e contratos:** outros fornecedores fecham contratos cujos valores não necessariamente entram nos números Stellantis. Definir inclusão/exclusão por indicador, distinguindo pedido e contrato, sem presumir que todo valor integra o resultado do evento ou da Stellantis. Conciliar esse ponto com os registros técnicos existentes sobre atingimento.

### Perguntas adicionais abertas

1. O que significa operacionalmente o armazém único da Stellantis para esta plataforma?
2. Como será validada a dependência comercial que só se resolve na última semana de novembro, considerando a janela de testes discutida?
3. Quais tipos de fornecedor, unidades de pedido e campanhas precisam ser contemplados na primeira versão?
4. Quais valores de pedidos e contratos entram ou ficam fora de cada indicador, especialmente dos números Stellantis?
5. O que Bruno e Marcos definirão para patrocinadores no painel e para o espaço separado de campanhas de premiação?

### Próximas atividades de levantamento

- Detalhar as demais jornadas com Marcos antes de fechar perfis e permissões.
- Resolver as três decisões estruturais e explicitar o que ficará dentro e fora da primeira versão.
- A partir dessas definições, detalhar responsáveis, dependências, cronograma e testes para a carga simultânea esperada.
- Preservar neste registro a distinção entre declaração, preferência, hipótese e decisão aprovada, sem transformar exemplos em requisitos.

## Histórico do documento

| Data | Registro |
|---|---|
| 19/10/2026 | Criação a partir da chamada: contexto, marcos, públicos, decisões estruturais pendentes e primeira etapa da jornada do fornecedor |
| 19/10/2026 | Complemento da chamada: ajustes de ofertas e bloqueio administrativo; criação de pedidos pelo fornecedor a detalhar; Stellantis como principal fornecedor; distinção entre lista mensal e lista promocional, com preço por concessionária ainda a esclarecer |
| 19/10/2026 | Complemento da chamada: checklist de patrocinadores, premiações e pedidos do fornecedor; armazém único e duas listas Stellantis; dependência tardia de descontos; óleo e demais tipos de fornecedor; distinção entre pedidos, contratos e inclusão nos indicadores |
| 20/10/2026 | Contexto da planilha FCA e organização PSA a esclarecer; primeira tarefa de mapear perfis antes de associar usuários; cobertura personalizada de setor de CPV ausente por outros CPVs da mesma regional, com divisão, vigência, retorno e responsável autorizado pendentes |
| 20/10/2026 | Explicação inicial de Marcos sobre 21 pontos: ocorrência binária mensal com pesos 6 a 1; conversão em demanda/sugestão e definição da janela pendentes; cautela analítica sobre ambiguidade da nota isolada registrada separadamente |
| 20/10/2026 | Continuação dos 21 pontos: curvas por ocorrência/frequência, com faixas pendentes; recomendação inicialmente com horizonte fixo de 90 dias; fórmula de quantidade e sentido de “mudar essa classificação” ainda a esclarecer |
| 20/10/2026 | Distinção entre pedidos de peças/armazém, acessórios e FULL; relação do objetivo FULL com armazém pendente e risco de dupla contagem; composição de metas CPV a detalhar; cálculo MIRA registrado como referência candidata a avaliação |
| 20/10/2026 | Direção de versionamento de pedidos, histórico e salvaguardas de substituição concorrente; somente versão vigente e fechada nos indicadores; granularidade e permissões pendentes; requisito de cerca de 300 usuários simultâneos e propostas técnicas a avaliar |
| 20/10/2026 | Plano de arquitetura de testes registrado: regras/integridade, carga com 300 sessões e navegadores reais; ambiente isolado e dados fictícios; cenários, observabilidade, reconciliação e critérios numéricos a pactuar; ferramentas candidatas, sem execução |
