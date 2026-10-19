// Lê web/.env.local (e .env) para os scripts de terminal, sem dependência extra.
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

export function carregarEnv() {
  for (const nome of [".env.local", ".env"]) {
    const p = join(import.meta.dirname, "..", nome);
    if (!existsSync(p)) continue;
    for (const linha of readFileSync(p, "utf8").split(/\r?\n/)) {
      const m = linha.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (m && process.env[m[1]] === undefined) process.env[m[1]] = m[2].replace(/^["']|["']$/g, "");
    }
  }
}

// Mesma limpeza do app (src/lib/db.ts): tira channel_binding da string do Neon.
export function urlBanco(bruta = process.env.DATABASE_URL ?? "") {
  return bruta.replace(/([?&])channel_binding=[^&]*&?/, "$1").replace(/[?&]$/, "");
}
