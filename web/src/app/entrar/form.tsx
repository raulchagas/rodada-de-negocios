"use client";

import { useActionState } from "react";
import { pedirLink, type EstadoPedido } from "./acoes";

export function FormEntrar() {
  const [estado, acao, pendente] = useActionState<EstadoPedido, FormData>(pedirLink, null);
  return (
    <form action={acao} className="mt-4 space-y-3">
      <input
        name="email"
        type="email"
        required
        autoComplete="email"
        placeholder="seu@email.com"
        className="w-full rounded border border-borda px-3 py-2 outline-none focus:border-acento"
      />
      <button disabled={pendente} className="w-full rounded bg-noite py-2 font-medium text-white disabled:opacity-60">
        {pendente ? "Gerando…" : "Receber link de acesso"}
      </button>
      {estado && (
        <div className="rounded bg-fundo p-3 text-sm">
          <p>{estado.msg}</p>
          {estado.link && (
            <a href={estado.link} className="mt-2 block break-all font-medium text-acento underline">
              Abrir link de acesso
            </a>
          )}
        </div>
      )}
    </form>
  );
}
