import { describe, expect, it } from "vitest";
import { lerAbas, lotes } from "./planilha";

describe("lerAbas", () => {
  it("normaliza cabeçalho, ignora linhas vazias e abas desconhecidas", () => {
    const r = lerAbas([
      { sheet: "leia-me", data: [["texto"]] },
      { sheet: "Metas", data: [["Grupo_Codigo", "Categoria", "Valor"], ["G1", "PECAS", "100"], [null, "", null], ["G2", "PECAS", "200"]] },
    ]);
    expect(r.ignoradas).toEqual(["leia-me"]);
    expect(r.abas.metas).toEqual([
      { n: 2, dados: { grupo_codigo: "G1", categoria: "PECAS", valor: "100" } },
      { n: 4, dados: { grupo_codigo: "G2", categoria: "PECAS", valor: "200" } },
    ]);
  });

  it("aponta coluna obrigatória faltando", () => {
    const r = lerAbas([{ sheet: "metas", data: [["grupo_codigo", "valor"], ["G1", "1"]] }]);
    expect(r.problemas[0]).toMatch(/categoria/);
    expect(r.abas.metas).toBeUndefined();
  });

  it("carteira aceita consultor_nome ou consultor_id", () => {
    expect(lerAbas([{ sheet: "carteira", data: [["consultor_id", "grupo_codigo"], ["1", "G1"]] }]).problemas).toEqual([]);
    expect(lerAbas([{ sheet: "carteira", data: [["grupo_codigo"], ["G1"]] }]).problemas).toHaveLength(1);
  });

  it("data vira AAAA-MM-DD", () => {
    const r = lerAbas([{ sheet: "csps", data: [["dealer_codigo", "pn", "quantidade", "data_pedido"], ["1", "P", "2", new Date("2026-12-15T00:00:00Z")]] }]);
    expect(r.abas.csps[0].dados.data_pedido).toBe("2026-12-15");
  });
});

it("lotes", () => {
  expect(lotes([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
});
