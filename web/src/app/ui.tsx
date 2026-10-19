import Link from "next/link";
import type { ReactNode } from "react";
import { NOME_PERFIL } from "@/lib/format";
import type { Usuario } from "@/lib/sessao";
import { sair } from "./entrar/acoes";

// Estrutura de toda tela interna: barra superior, banda azul-noite (título + número principal) e corpo em cartões.
export function Moldura({ usuario, children }: { usuario: Usuario; children: ReactNode }) {
  const admin = usuario.perfil === "admin";
  return (
    <div className="flex min-h-full flex-1 flex-col">
      <header className="bg-noite text-white">
        <div className="mx-auto flex max-w-6xl items-center gap-4 px-4 py-3 text-sm">
          <Link href="/" className="font-semibold tracking-tight">
            Rodada de Negócios
          </Link>
          {admin && (
            <nav className="flex gap-3 text-white/80">
              <Link href="/admin/cargas" className="hover:text-white">Cargas</Link>
              <Link href="/admin/usuarios" className="hover:text-white">Usuários</Link>
            </nav>
          )}
          <div className="ml-auto flex items-center gap-3 text-white/80">
            <span className="hidden sm:inline">
              {usuario.nome} · {NOME_PERFIL[usuario.perfil]}
            </span>
            <form action={sair}>
              <button className="rounded border border-white/30 px-2 py-1 hover:bg-white/10">Sair</button>
            </form>
          </div>
        </div>
      </header>
      {children}
    </div>
  );
}

export function Banda({ titulo, children }: { titulo: string; children?: ReactNode }) {
  return (
    <section className="bg-noite-2 text-white">
      <div className="mx-auto max-w-6xl px-4 py-6">
        <h1 className="text-xl font-semibold">{titulo}</h1>
        {children && <div className="mt-3 text-white/85">{children}</div>}
      </div>
    </section>
  );
}

export function Corpo({ children }: { children: ReactNode }) {
  return <main className="mx-auto w-full max-w-6xl flex-1 space-y-4 px-4 py-6">{children}</main>;
}

export function Cartao({ titulo, children, acao }: { titulo?: string; children: ReactNode; acao?: ReactNode }) {
  return (
    <section className="rounded-lg border border-borda bg-white p-4 shadow-sm">
      {(titulo || acao) && (
        <div className="mb-3 flex items-center gap-3">
          {titulo && <h2 className="font-semibold">{titulo}</h2>}
          {acao && <div className="ml-auto">{acao}</div>}
        </div>
      )}
      {children}
    </section>
  );
}

export function Pilula({ tom, children }: { tom: "ok" | "erro" | "alerta" | "neutro"; children: ReactNode }) {
  const cores = {
    ok: "bg-green-50 text-ok border-green-200",
    erro: "bg-red-50 text-erro border-red-200",
    alerta: "bg-amber-50 text-alerta border-amber-200",
    neutro: "bg-slate-50 text-suave border-borda",
  }[tom];
  return <span className={`inline-block rounded-full border px-2 py-0.5 text-xs font-medium ${cores}`}>{children}</span>;
}

export function Vazio({ children }: { children: ReactNode }) {
  return <p className="rounded border border-dashed border-borda p-4 text-center text-sm text-suave">{children}</p>;
}
