"use server";

import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { consumirLink, criarLinkAcesso, encerrarSessao, urlBase } from "@/lib/sessao";

export type EstadoPedido = { msg: string; link?: string } | null;

// Sem serviço de e-mail configurado, o link só aparece na tela em desenvolvimento ou com LINK_NA_TELA=1
// (nunca deixar ligado em produção aberta: qualquer um que soubesse um e-mail cadastrado entraria).
function linkNaTela() {
  return process.env.NODE_ENV !== "production" || process.env.LINK_NA_TELA === "1";
}

export async function pedirLink(_: EstadoPedido, form: FormData): Promise<EstadoPedido> {
  const email = String(form.get("email") ?? "").trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return { msg: "Informe um e-mail válido." };

  const [u] = await sql<{ id: number }[]>`select id from rodada.usuario where email = ${email} and ativo`;
  if (u && linkNaTela()) {
    const token = await criarLinkAcesso(u.id, null);
    return { msg: "Link gerado (modo sem e-mail).", link: `${await urlBase()}/entrar/${token}` };
  }
  // Mesma resposta para e-mail cadastrado ou não: não revela quem tem acesso.
  return { msg: "Se este e-mail tiver acesso, peça o link de entrada ao administrador da rodada." };
}

export async function confirmarEntrada(token: string): Promise<{ erro: string }> {
  const ok = await consumirLink(token);
  if (ok) redirect("/");
  return { erro: "Este link expirou ou já foi usado. Peça um novo link." };
}

export async function sair() {
  await encerrarSessao();
  redirect("/entrar");
}
