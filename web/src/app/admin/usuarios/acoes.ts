"use server";

import { criarLinkAcesso, exigirUsuario, urlBase } from "@/lib/sessao";

export async function gerarLink(usuarioId: number): Promise<string> {
  const admin = await exigirUsuario(["admin"]);
  const token = await criarLinkAcesso(usuarioId, admin.id);
  return `${await urlBase()}/entrar/${token}`;
}
