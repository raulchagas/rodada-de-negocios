# Registro de decisões e direções de escopo

Direções e decisões tomadas **durante o levantamento**. As regras já vigentes estão em `docs/decisoes.md` e não são
repetidas aqui; quando uma direção daqui diverge de uma regra vigente, a divergência está em `mudancas-de-escopo.md`.

Estados: **Vigente** · **Aprovado** · **Direção** · **Proposta** · **Hipótese** · **Pendente** · **Descartado**
(ver `README.md`). Nunca apagar uma linha: mudar o estado e anotar a data.

## Como registrar

Cada entrada tem: ID sequencial, enunciado curto, estado, data e fonte, o que ainda falta, e ligações
(`MUD-xx`, `P-xx`). Ao aprovar, anotar quem aprovou e a data; ao promover para `docs/decisoes.md`, anotar o commit.

## Registro

### Perfis, carteira e públicos

| ID | Direção ou decisão | Estado | Data e fonte | Falta | Ligações |
|---|---|---|---|---|---|
| DE-01 | Mapear os perfis de acesso de cada público **antes** de cadastrar usuários e associá-los a perfis | Direção | 20/10, chamada (Marcos) | Não aprova editor dinâmico de perfis; matriz de permissões aberta | `MUD-09`, `P-06`, `P-07` |
| DE-02 | Permitir cobertura personalizada do setor de um CPV ausente ou em férias por **um ou mais** CPVs da mesma regional, preservando a hierarquia oficial | Direção | 20/10, chamada (Marcos) | Recorte, vigência, quem autoriza, retorno, pedidos em andamento | `MUD-12`, `P-09` |

### Sugestão, 21 pontos e reposição

| ID | Direção ou decisão | Estado | Data e fonte | Falta | Ligações |
|---|---|---|---|---|---|
| DE-03 | 21 pontos: em seis meses, cada mês com venda recebe o peso do mês (6 o mais recente … 1 o mais antigo), sem venda recebe 0; máximo 21. Mede **frequência**, não volume | Direção | 20/10, chamada (Marcos) | Mês de referência, data de corte, escopo (loja/grupo), devoluções; guardar as ocorrências mensais além da nota | `MUD-04`, `P-30` |
| DE-04 | A pontuação define a **curva** do produto (A, B, C, D…), por frequência, como a rede já conhece | Direção | 20/10, chamada (Marcos) | Faixas de cada curva (o MIRA usa A 15–21, B 9–14, C 4–8, D 0–3, não aprovadas para a Rodada) | `P-31` |
| DE-05 | Horizonte da recomendação: **90 dias**, fixo por enquanto | Direção | 20/10, chamada (Marcos) | Fórmula da quantidade; sentido de "mudar essa classificação" | `MUD-04`, `P-32`, `P-35` |
| DE-06 | Avaliar o cálculo de reposição do **MIRA** como referência, sem adoção integral | Direção | 20/10, chamada; leitura do MIRA em 21/10 (Codex) | Critério de adoção ou adaptação; trânsito em dias × quantidade; QME | `MUD-04`, `P-32`, `P-33`, `P-34` |
| DE-19 | Preferência por plataforma mais simples: receber, carregar e consolidar pedidos; sugestão possivelmente em planilha | Proposta (preferência de Marcos) | 19/10, chamada | Conciliar com DEC, que manda a plataforma calcular a sugestão | `MUD-03`, `P-29` |

### Pedido, histórico e concorrência

| ID | Direção ou decisão | Estado | Data e fonte | Falta | Ligações |
|---|---|---|---|---|---|
| DE-07 | Alteração de pedido cria **nova versão vinculada** à anterior; a anterior fica cancelada/substituída, sem exclusão | Direção | 20/10, chamada (Marcos) | Por pedido inteiro ou por linha; quem pode substituir em cada fase | `MUD-02`, `P-36`, `P-07` |
| DE-08 | Uma única versão vigente; substituição **atômica** (tudo ou nada); duas substituições da mesma versão não passam: o segundo revisa a nova versão antes, sem sobrescrita silenciosa | Direção | 20/10, chamada | Como mostrar a diferença e a revisão | `MUD-02`, `P-38` |
| DE-09 | Só a versão **vigente e fechada** entra em totais, metas e telão | Direção | 20/10, chamada | Regra do potencial restante (hoje desconta rascunho) | `MUD-02`, `P-28` |
| DE-10 | Histórico guarda autor e perfil, data e hora, motivo, diferenças, vínculo entre versões e a última versão válida | Direção | 20/10, chamada | — | `MUD-02` |
| DE-22 | Edição de pedido exclusiva pelo CPV | **Descartado** em 20/10 | Ideia exploratória de 20/10, substituída por DE-07 | — | `DE-07` |

### Ofertas, preços e fornecedores

| ID | Direção ou decisão | Estado | Data e fonte | Falta | Ligações |
|---|---|---|---|---|---|
| DE-13 | Lista **promocional** Stellantis da rodada: usar só a identificação do item e o desconto, **ignorando o preço** nela; o desconto se aplica à concessionária que pede | Direção | 19/10, chamada (Marcos) | Base de preço sobre a qual o desconto incide | `MUD-05`, `P-13`, `P-14` |
| DE-14 | Serão carregadas **duas listas Stellantis**: preços sem desconto de todos os itens e a lista promocional da rodada | Direção | 19/10, chamada | Relação entre a lista completa e o preço efetivo por concessionária | `MUD-05`, `P-13` |
| DE-15 | O valor do pedido no evento é o valor do produto **sem ST** (custo do cliente), separado do valor fiscal da nota | Direção | 19/10, chamada (Marcos) | Composição, validação fiscal e conciliação | `MUD-06`, `P-18` |
| DE-16 | Fornecedor carrega ofertas, preferencialmente por **planilha**, e pode ajustá-las; o admin pode **bloquear** ajustes | Direção | 19/10, chamada | Prazo, momento e regra do bloqueio, correções depois; cadastro item a item como alternativa | `MUD-08`, `P-11`, `P-12` |
| DE-17 | Fornecedor também poderá **criar pedidos** | Direção | 19/10, chamada | Jornada inteira | `MUD-08`, `P-22` |
| DE-18 | A própria Stellantis é o principal fornecedor (ofertas do armazém/fábrica) e haverá **um único armazém** | Direção | 19/10, chamada | Nomenclatura; significado operacional do armazém único | `P-19`, `P-20` |

### Capacidade, testes e calendário

| ID | Direção ou decisão | Estado | Data e fonte | Falta | Ligações |
|---|---|---|---|---|---|
| DE-11 | Preparar para cerca de **300 usuários simultâneos criando e editando pedidos** (≈ 200 concessionárias) | Direção (requisito declarado) | 20/10, chamada | Volumetria e mistura de ações | `MUD-11`, `P-48` |
| DE-12 | Validar com três frentes de teste: regras e integridade, carga com 300 sessões autenticadas e navegadores reais sob carga; ambiente isolado com dados fictícios | Direção (plano registrado, sem execução) | 20/10, chamada; detalhado em 21/10 | Critérios numéricos, ferramentas, mistura de fluxos | `P-46` |
| DE-23 | Simular os 300 usuários com 300 máquinas, IPs ou agentes de IA | **Descartado** em 20/10 como arquitetura principal de carga | 20/10, chamada | IA pode apoiar teste exploratório | `DE-12` |
| DE-20 | Evento na **segunda semana de dezembro de 2026** | Direção | 19/10, chamada | Dia exato e duração | `P-04` |
| DE-21 | Plataforma pronta para testes em **16/11/2026**, com pelo menos **três semanas** de testes e correções | Hipótese (referência de planejamento) | 19/10, chamada | Aprovação como prazo | `MUD-13`, `cronograma.md` |

## Histórico deste arquivo

| Data | Registro |
|---|---|
| 22/10/2026 | Criação a partir do levantamento de 19–20/10 e do consolidado do Codex de 21/10. Números DE-01 a DE-23 (a ordem por tema não segue a numeração) |
