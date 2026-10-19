// Gera um link de acesso de uso único para um usuário cadastrado, pelo terminal.
// Uso: npm run link -- email@dominio.com
// Serve para o primeiro acesso do admin em produção, antes de existir envio de e-mail.
import { createHash, randomBytes } from "node:crypto";
import postgres from "postgres";
import { carregarEnv, urlBanco } from "./env.mjs";

carregarEnv();
const email = (process.argv[2] ?? "").trim().toLowerCase();
if (!email || !process.env.DATABASE_URL) {
  console.error("Uso: npm run link -- email@dominio.com   (com DATABASE_URL e APP_URL em web/.env.local)");
  process.exit(1);
}

const sql = postgres(urlBanco(), { prepare: false, max: 1 });
try {
  const [u] = await sql`select id, nome from rodada.usuario where email = ${email} and ativo`;
  if (!u) {
    console.error("Usuário não encontrado ou inativo:", email);
    process.exitCode = 1;
  } else {
    const token = randomBytes(32).toString("base64url");
    const hash = createHash("sha256").update(token).digest("hex");
    await sql`insert into rodada.token_login (hash, usuario_id, expira_em) values (${hash}, ${u.id}, now() + interval '30 minutes')`;
    const base = (process.env.APP_URL ?? "http://localhost:3000").replace(/\/$/, "");
    console.log(`Link para ${u.nome} (vale 30 min, uso único):\n${base}/entrar/${token}`);
  }
} finally {
  await sql.end();
}
