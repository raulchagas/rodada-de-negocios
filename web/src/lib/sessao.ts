import "server-only";
import { cookies, headers } from "next/headers";
import { redirect } from "next/navigation";
import { cache } from "react";
import { sql, type Perfil } from "./db";
import { hashToken, novoToken, VALIDADE_LINK_MIN, VALIDADE_SESSAO_DIAS } from "./token";

export const COOKIE_SESSAO = "rodada_sessao";

export type Usuario = {
  id: number;
  email: string;
  nome: string;
  perfil: Perfil;
  consultor_id: number | null;
  fornecedor_id: number | null;
  regional_codigo: string | null;
};

/** Gera um link de acesso de uso único. Devolve o token cru (só existe aqui; o banco guarda o hash). */
export async function criarLinkAcesso(usuarioId: number, geradoPor: number | null): Promise<string> {
  const token = novoToken();
  await sql`
    insert into rodada.token_login (hash, usuario_id, expira_em, gerado_por)
    values (${hashToken(token)}, ${usuarioId}, now() + make_interval(mins => ${VALIDADE_LINK_MIN}), ${geradoPor})`;
  return token;
}

export async function urlBase(): Promise<string> {
  if (process.env.APP_URL) return process.env.APP_URL.replace(/\/$/, "");
  const h = await headers();
  const host = h.get("x-forwarded-host") ?? h.get("host") ?? "localhost:3000";
  const proto = h.get("x-forwarded-proto") ?? (host.startsWith("localhost") ? "http" : "https");
  return `${proto}://${host}`;
}

/** Troca o token do link por uma sessão. Devolve false se o link expirou, já foi usado ou não existe. */
export async function consumirLink(token: string): Promise<boolean> {
  const [t] = await sql<{ usuario_id: number }[]>`
    update rodada.token_login tl set usado_em = now()
    from rodada.usuario u
    where tl.hash = ${hashToken(token)} and tl.usado_em is null and tl.expira_em > now()
      and u.id = tl.usuario_id and u.ativo
    returning tl.usuario_id`;
  if (!t) return false;

  const sessao = novoToken();
  await sql`
    insert into rodada.sessao (hash, usuario_id, expira_em)
    values (${hashToken(sessao)}, ${t.usuario_id}, now() + make_interval(days => ${VALIDADE_SESSAO_DIAS}))`;
  await sql`update rodada.usuario set ultimo_acesso = now() where id = ${t.usuario_id}`;

  (await cookies()).set(COOKIE_SESSAO, sessao, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: VALIDADE_SESSAO_DIAS * 24 * 3600,
  });
  return true;
}

/** Usuário da sessão atual (uma leitura por requisição). */
export const usuarioAtual = cache(async (): Promise<Usuario | null> => {
  const valor = (await cookies()).get(COOKIE_SESSAO)?.value;
  if (!valor) return null;
  const [u] = await sql<Usuario[]>`
    select u.id, u.email, u.nome, u.perfil, u.consultor_id, u.fornecedor_id, u.regional_codigo
    from rodada.sessao s join rodada.usuario u on u.id = s.usuario_id
    where s.hash = ${hashToken(valor)} and s.expira_em > now() and u.ativo`;
  return u ?? null;
});

/** Exige login (e, se informado, um dos perfis). Redireciona em vez de devolver null. */
export async function exigirUsuario(perfis?: Perfil[]): Promise<Usuario> {
  const u = await usuarioAtual();
  if (!u) redirect("/entrar");
  if (perfis && !perfis.includes(u.perfil)) redirect("/?sem-permissao=1");
  return u;
}

export async function encerrarSessao(): Promise<void> {
  const jar = await cookies();
  const valor = jar.get(COOKIE_SESSAO)?.value;
  if (valor) await sql`delete from rodada.sessao where hash = ${hashToken(valor)}`;
  jar.delete(COOKIE_SESSAO);
}
