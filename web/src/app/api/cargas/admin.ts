import "server-only";
import { NextResponse } from "next/server";
import { usuarioAtual, type Usuario } from "@/lib/sessao";

/** Rotas de carga são só do admin. Devolve o usuário ou uma resposta 403 pronta. */
export async function adminDaRota(): Promise<Usuario | NextResponse> {
  const u = await usuarioAtual();
  if (!u || u.perfil !== "admin") return NextResponse.json({ erro: "Sem permissão" }, { status: 403 });
  return u;
}
