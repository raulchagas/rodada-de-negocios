import { NextResponse } from "next/server";
import { abrirCarga } from "@/lib/cargas";
import { adminDaRota } from "./admin";

export async function POST(req: Request) {
  const u = await adminDaRota();
  if (u instanceof NextResponse) return u;
  const { arquivo } = (await req.json()) as { arquivo?: string };
  const id = await abrirCarga(u.id, String(arquivo ?? "planilha.xlsx").slice(0, 200));
  return NextResponse.json({ id });
}
