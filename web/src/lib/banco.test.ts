// Testes do banco em PGlite (Postgres dentro do Node): migrations, regras de pedido e cargas.
// Rodam com `npm test`, sem Postgres instalado.
import { PGlite } from "@electric-sql/pglite";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import readExcelFile from "read-excel-file/node";
import { beforeAll, describe, expect, it } from "vitest";
import { lerAbas, type LinhaCarga } from "./planilha";

const RAIZ = join(__dirname, "..", "..", "..");
const MIGRATIONS = join(RAIZ, "db", "migrations");
const MODELO = join(RAIZ, "cargas", "modelos_cargas.xlsx");

let db: PGlite;
const um = async <T = Record<string, unknown>>(q: string, p: unknown[] = []) => (await db.query<T>(q, p)).rows[0];

async function migrar(alvo: PGlite) {
  for (const f of readdirSync(MIGRATIONS).filter((f) => f.endsWith(".sql")).sort()) {
    await alvo.exec(readFileSync(join(MIGRATIONS, f), "utf8"));
  }
}

async function carregar(abas: Record<string, LinhaCarga[]>) {
  const { id } = (await um<{ id: number }>(
    "insert into rodada.carga (rodada_id, tipo, arquivo) values ((select id from rodada.rodada where ativa), 'planilha', 't.xlsx') returning id",
  ))!;
  for (const [aba, linhas] of Object.entries(abas)) {
    await db.query(
      "insert into rodada.carga_linha (carga_id, aba, n, dados) select $1, $2, x.n, x.dados from jsonb_to_recordset($3::jsonb) as x(n int, dados jsonb)",
      [id, aba, JSON.stringify(linhas)],
    );
  }
  return (await um<{ r: { ok: boolean; total_erros: number; erros: { aba: string; linha: number; erro: string }[] } }>(
    "select rodada.aplicar_carga($1) as r",
    [id],
  ))!.r;
}

const conta = async (q: string) => Number((await um<{ n: number }>(`select count(*)::int as n from ${q}`))!.n);

describe("migrations", () => {
  it("aplicam duas vezes sem erro (idempotentes)", async () => {
    const outro = new PGlite();
    await migrar(outro);
    await migrar(outro);
    const r = await outro.query<{ n: number }>("select count(*)::int n from information_schema.tables where table_schema = 'rodada'");
    expect(r.rows[0].n).toBeGreaterThan(25);
    await outro.close();
  });

  it("regras de pedido (db/tests/smoke.sql)", async () => {
    const outro = new PGlite();
    await migrar(outro);
    const res = await outro.exec(readFileSync(join(RAIZ, "db", "tests", "smoke.sql"), "utf8"));
    expect(res.some((r) => r.rows.some((x) => (x as { resultado?: string }).resultado === "SMOKE_OK"))).toBe(true);
    await outro.close();
  });
});

describe("cargas pela planilha modelo", () => {
  let abas: Record<string, LinhaCarga[]>;

  beforeAll(async () => {
    db = new PGlite();
    await migrar(db);
    await db.query("select rodada.criar_rodada('2026-12', 'Rodada Dez/2026')");
    const lidas = await readExcelFile(MODELO, { parseNumber: (s: string) => s });
    const leitura = lerAbas(lidas);
    expect(leitura.problemas).toEqual([]);
    expect(leitura.ignoradas).toEqual(["leia-me"]);
    abas = leitura.abas;
  });

  it("aplica o modelo inteiro", async () => {
    const r = await carregar(abas);
    expect(r.erros ?? []).toEqual([]);
    expect(r.ok).toBe(true);
    expect(await conta("rodada.dealer")).toBe(3);
    expect(await conta("rodada.grupo")).toBe(2);
    expect(await conta("rodada.carteira")).toBe(3);
    expect(await conta("rodada.usuario")).toBe(6);
    expect(await conta("rodada.usuario_grupo")).toBe(2);
    expect(await conta("rodada.meta_grupo")).toBe(3);
    expect(await conta("rodada.meta_consultor")).toBe(2);
    expect(await conta("rodada.item where fornecedor_id is not null")).toBe(1);
    expect(await conta("rodada.carga_linha")).toBe(0);
    // dealer com zero à esquerda preservado; sugestão (120-30-12)=78 -> QME 12 -> 84
    const s = await um<{ sugestao: number }>(
      "select sugestao from rodada.demanda d join rodada.item i on i.id = d.item_id where d.dealer_codigo = '000123' and i.pn = '77366001'",
    );
    expect(s?.sugestao).toBe(84);
  });

  it("recarregar é idempotente", async () => {
    expect((await carregar(abas)).ok).toBe(true);
    expect(await conta("rodada.dealer")).toBe(3);
    expect(await conta("rodada.demanda")).toBe(3);
  });

  it("planilha com erro não aplica nada", async () => {
    const b = abas.base21;
    const r = await carregar({
      base21: [
        { n: 2, dados: { ...b[0].dados, qme: "0" } },
        { n: 3, dados: { ...b[1].dados, categoria: "XYZ" } },
        { n: 4, dados: { ...b[2].dados, dealer_codigo: "999999" } },
      ],
      metas: [{ n: 2, dados: { grupo_codigo: "G0001", categoria: "PECAS", valor: "abc" } }],
    });
    expect(r.ok).toBe(false);
    expect(r.erros.map((e) => e.erro).join(" | ")).toMatch(/qme inválido.*XYZ.*999999|qme/);
    expect(r.total_erros).toBeGreaterThanOrEqual(4);
    expect(await conta("rodada.demanda")).toBe(3);
    expect(await conta("rodada.meta_grupo where valor = 250000")).toBe(1);
  });

  it("aceita número no formato brasileiro", async () => {
    const r = await carregar({ metas: [{ n: 2, dados: { grupo_codigo: "G0001", categoria: "PECAS", valor: "1.234,56" } }] });
    expect(r.ok).toBe(true);
    expect(Number((await um<{ v: string }>("select valor as v from rodada.meta_grupo"))!.v)).toBe(1234.56);
  });
});
