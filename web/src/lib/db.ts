import "server-only";
import postgres from "postgres";

// Conexão única por instância. Funciona com qualquer Postgres (Neon hoje, servidor da empresa depois).
// prepare: false porque o Neon usa pooler em modo transação (pgbouncer), que não aceita prepared statements nomeados.
// Todas as consultas qualificam o schema (rodada.*): o pooler não garante search_path por sessão.
// A string que o painel do Neon oferece traz channel_binding=require, que o driver repassaria ao servidor como
// parâmetro de sessão (erro "unrecognized configuration parameter"). Removido aqui para aceitar a string como vem.
export function urlBanco(bruta = process.env.DATABASE_URL ?? ""): string {
  return bruta.replace(/([?&])channel_binding=[^&]*&?/, "$1").replace(/[?&]$/, "");
}

const globalParaDb = globalThis as unknown as { sql?: postgres.Sql };

export const sql =
  globalParaDb.sql ??
  postgres(urlBanco(), {
    prepare: false,
    max: 5,
    idle_timeout: 20,
    connect_timeout: 15,
    transform: { undefined: null },
  });

if (process.env.NODE_ENV !== "production") globalParaDb.sql = sql;

export type Perfil = "admin" | "regional" | "cpv" | "cna" | "cne" | "fi" | "grupo" | "fornecedor";
