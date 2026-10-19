"use client";

import Link from "next/link";
import { useActionState } from "react";
import { confirmarEntrada } from "../acoes";

export function Confirmar({ token }: { token: string }) {
  const [estado, acao, pendente] = useActionState(async () => confirmarEntrada(token), null);
  return (
    <form action={acao} className="mt-4 space-y-3">
      <button disabled={pendente} className="w-full rounded bg-noite py-2 font-medium text-white disabled:opacity-60">
        {pendente ? "Entrando…" : "Entrar"}
      </button>
      {estado?.erro && (
        <p className="text-sm text-erro">
          {estado.erro}{" "}
          <Link href="/entrar" className="underline">
            Voltar
          </Link>
        </p>
      )}
    </form>
  );
}
