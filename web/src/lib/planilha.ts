// Converte as abas lidas do .xlsx em linhas para carga_linha. Código puro: roda no navegador e nos testes.
// A validação de conteúdo é do banco (aplicar_carga); aqui só o formato: aba conhecida, cabeçalho e linhas não vazias.

// Valor de célula como vem da leitura (string, número, booleano, Date ou vazio).
export type Celula = unknown;
export type AbaLida = { sheet: string; data: readonly (readonly Celula[])[] };
export type LinhaCarga = { n: number; dados: Record<string, string> };

// Ordem = ordem de aplicação no banco. Colunas obrigatórias no cabeçalho (docs/cargas.md).
export const ABAS: Record<string, { titulo: string; obrigatorias: string[] }> = {
  hierarquia: { titulo: "Hierarquia", obrigatorias: ["marca_codigo", "marca_nome", "regional_codigo", "regional_nome", "setor_codigo", "grupo_codigo", "grupo_nome", "dealer_codigo", "dealer_nome"] },
  consultores: { titulo: "Consultores", obrigatorias: ["nome", "perfil"] },
  catalogo_fornecedor: { titulo: "Catálogo de fornecedores", obrigatorias: ["fornecedor_codigo", "fornecedor_nome", "pn", "categoria", "qme", "preco_unit"] },
  base21: { titulo: "Base 21 pontos", obrigatorias: ["dealer_codigo", "pn", "categoria", "qme", "preco_unit", "demanda", "estoque", "transito"] },
  carteira: { titulo: "Carteira", obrigatorias: ["grupo_codigo"] },
  usuarios: { titulo: "Usuários", obrigatorias: ["email", "nome", "perfil"] },
  metas: { titulo: "Metas por grupo", obrigatorias: ["grupo_codigo", "categoria", "valor"] },
  metas_consultor: { titulo: "Metas por consultor", obrigatorias: ["consultor_nome", "valor"] },
  csps: { titulo: "Colocado no CSPS", obrigatorias: ["dealer_codigo", "pn", "quantidade"] },
};

export type ResultadoLeitura = {
  abas: Record<string, LinhaCarga[]>;
  ignoradas: string[]; // abas que não são de carga (ex.: leia-me)
  problemas: string[]; // impedem o envio (cabeçalho faltando)
};

function chave(v: Celula): string {
  return String(v ?? "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/\s+/g, "_");
}

function texto(v: Celula): string {
  if (v === null || v === undefined) return "";
  if (v instanceof Date) return v.toISOString().slice(0, 10);
  return String(v).trim();
}

export function lerAbas(lidas: AbaLida[]): ResultadoLeitura {
  const out: ResultadoLeitura = { abas: {}, ignoradas: [], problemas: [] };
  for (const { sheet, data } of lidas) {
    const nome = chave(sheet);
    const cfg = ABAS[nome];
    if (!cfg) {
      out.ignoradas.push(sheet);
      continue;
    }
    const [cab = [], ...resto] = data;
    const colunas = cab.map(chave);
    const faltam = cfg.obrigatorias.filter((c) => !colunas.includes(c));
    if (nome === "carteira" && !colunas.includes("consultor_nome") && !colunas.includes("consultor_id")) faltam.push("consultor_nome ou consultor_id");
    if (faltam.length) {
      out.problemas.push(`Aba ${sheet}: faltam as colunas ${faltam.join(", ")}`);
      continue;
    }
    const linhas: LinhaCarga[] = [];
    resto.forEach((row, i) => {
      const dados: Record<string, string> = {};
      let algum = false;
      colunas.forEach((c, j) => {
        if (!c) return;
        const v = texto(row[j]);
        if (v !== "") algum = true;
        dados[c] = v;
      });
      if (algum) linhas.push({ n: i + 2, dados });
    });
    if (linhas.length) out.abas[nome] = linhas;
  }
  return out;
}

/** Quebra as linhas em lotes de envio (limite de corpo da Vercel: 4,5 MB por requisição). */
export function lotes<T>(itens: T[], tamanho = 2000): T[][] {
  const r: T[][] = [];
  for (let i = 0; i < itens.length; i += tamanho) r.push(itens.slice(i, i + tamanho));
  return r;
}
