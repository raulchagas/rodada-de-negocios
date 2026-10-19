// Aplica as migrations de db/migrations que ainda não estão em rodada.migracao, em ordem, cada uma numa transação.
// Uso: npm run migrar   (lê DATABASE_URL de web/.env.local ou do ambiente)
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import postgres from "postgres";
import { carregarEnv, urlBanco } from "./env.mjs";

carregarEnv();
const url = process.env.DATABASE_URL;
if (!url) {
  console.error("DATABASE_URL não definida (web/.env.local).");
  process.exit(1);
}

const dir = join(import.meta.dirname, "..", "..", "db", "migrations");
const sql = postgres(urlBanco(url), { prepare: false, max: 1, onnotice: () => {} });

try {
  await sql`create schema if not exists rodada`;
  await sql`create table if not exists rodada.migracao (nome text primary key, aplicada_em timestamptz not null default now())`;
  const feitas = new Set((await sql`select nome from rodada.migracao`).map((r) => r.nome));
  const pendentes = readdirSync(dir).filter((f) => /^\d{4}_.*\.sql$/.test(f) && !feitas.has(f)).sort();
  if (!pendentes.length) console.log("Nada a aplicar.");
  for (const f of pendentes) {
    await sql.begin(async (tx) => {
      await tx.unsafe(readFileSync(join(dir, f), "utf8"));
      await tx`insert into rodada.migracao (nome) values (${f})`;
    });
    console.log("aplicada:", f);
  }
} finally {
  await sql.end();
}
