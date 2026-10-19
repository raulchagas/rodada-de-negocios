import "server-only";
import type postgres from "postgres";
import { sql } from "./db";

export type ResultadoCarga = {
  ok: boolean;
  total_erros: number;
  erros?: { aba: string; linha: number; erro: string }[];
  abas: Record<string, number>;
};

export async function abrirCarga(usuarioId: number, arquivo: string): Promise<number> {
  const [c] = await sql<{ id: number }[]>`
    insert into rodada.carga (rodada_id, tipo, arquivo, usuario_id)
    values ((select id from rodada.rodada where ativa), 'planilha', ${arquivo}, ${usuarioId})
    returning id`;
  return c.id;
}

export async function receberLinhas(cargaId: number, aba: string, linhas: { n: number; dados: Record<string, string> }[]) {
  const [c] = await sql<{ status: string }[]>`select status from rodada.carga where id = ${cargaId}`;
  if (!c || c.status !== "recebendo") throw new Error("Carga fechada ou inexistente");
  await sql`
    insert into rodada.carga_linha (carga_id, aba, n, dados)
    select ${cargaId}, ${aba}, x.n, x.dados
    from jsonb_to_recordset(${sql.json(linhas as unknown as postgres.JSONValue)}) as x(n int, dados jsonb)
    on conflict (carga_id, aba, n) do update set dados = excluded.dados`;
}

export async function aplicarCarga(cargaId: number): Promise<ResultadoCarga> {
  const [r] = await sql<{ r: ResultadoCarga }[]>`select rodada.aplicar_carga(${cargaId}) as r`;
  return r.r;
}

export type CargaHistorico = {
  id: number;
  arquivo: string | null;
  status: string;
  linhas: number | null;
  abas: Record<string, number> | null;
  erros: ResultadoCarga["erros"] | null;
  em: Date;
  usuario: string | null;
};

export async function historicoCargas(limite = 15): Promise<CargaHistorico[]> {
  return sql<CargaHistorico[]>`
    select c.id, c.arquivo, c.status, c.linhas, c.abas, c.erros, c.em, u.nome as usuario
    from rodada.carga c left join rodada.usuario u on u.id = c.usuario_id
    order by c.id desc limit ${limite}`;
}
