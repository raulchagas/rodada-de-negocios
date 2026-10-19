import { NextResponse } from "next/server";
import { receberLinhas } from "@/lib/cargas";
import { ABAS } from "@/lib/planilha";
import { adminDaRota } from "../../admin";

export async function POST(req: Request, ctx: RouteContext<"/api/cargas/[id]/linhas">) {
  const u = await adminDaRota();
  if (u instanceof NextResponse) return u;
  const id = Number((await ctx.params).id);
  const { aba, linhas } = (await req.json()) as { aba: string; linhas: { n: number; dados: Record<string, string> }[] };
  if (!ABAS[aba] || !Array.isArray(linhas) || linhas.length > 5000) {
    return NextResponse.json({ erro: "Lote inválido" }, { status: 400 });
  }
  await receberLinhas(id, aba, linhas);
  return NextResponse.json({ ok: true });
}
