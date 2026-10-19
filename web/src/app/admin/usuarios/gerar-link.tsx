"use client";

import { useState, useTransition } from "react";
import { gerarLink } from "./acoes";

export function GerarLink({ usuarioId }: { usuarioId: number }) {
  const [link, setLink] = useState<string | null>(null);
  const [copiado, setCopiado] = useState(false);
  const [pendente, iniciar] = useTransition();

  function gerar() {
    iniciar(async () => {
      const l = await gerarLink(usuarioId);
      setLink(l);
      try {
        await navigator.clipboard.writeText(l);
        setCopiado(true);
      } catch {
        setCopiado(false);
      }
    });
  }

  if (link)
    return (
      <span className="inline-flex items-center gap-2">
        <input readOnly value={link} onFocus={(e) => e.currentTarget.select()} className="w-48 rounded border border-borda px-2 py-1 text-xs" />
        <span className="text-xs text-ok">{copiado ? "copiado" : "copie o link"}</span>
      </span>
    );
  return (
    <button onClick={gerar} disabled={pendente} className="rounded border border-borda px-2 py-1 text-xs hover:bg-fundo disabled:opacity-60">
      {pendente ? "Gerando…" : "Gerar link"}
    </button>
  );
}
