import { NextResponse } from "next/server";
import { aplicarCarga } from "@/lib/cargas";
import { adminDaRota } from "../../admin";

// Base 21 pontos grande pode levar dezenas de segundos para validar e aplicar no banco.
export const maxDuration = 60;

export async function POST(_: Request, ctx: RouteContext<"/api/cargas/[id]/aplicar">) {
  const u = await adminDaRota();
  if (u instanceof NextResponse) return u;
  const id = Number((await ctx.params).id);
  try {
    return NextResponse.json(await aplicarCarga(id));
  } catch (e) {
    return NextResponse.json({ ok: false, total_erros: 1, erros: [{ aba: "-", linha: 0, erro: (e as Error).message }], abas: {} }, { status: 500 });
  }
}
