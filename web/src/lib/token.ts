// Tokens aleatórios e hash. Sem dependência de Next: usado também pelos scripts e pelos testes.
import { createHash, randomBytes } from "node:crypto";

export function novoToken(): string {
  return randomBytes(32).toString("base64url");
}

export function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export const VALIDADE_LINK_MIN = 30; // link de acesso vale 30 minutos e uma única vez
export const VALIDADE_SESSAO_DIAS = 14; // cobre pré-rodada + evento sem pedir login de novo
