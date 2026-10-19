"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { ABAS, lerAbas, lotes, type ResultadoLeitura } from "@/lib/planilha";

type Resultado = { ok: boolean; total_erros: number; erros?: { aba: string; linha: number; erro: string }[]; abas: Record<string, number> };

async function postar<T>(url: string, corpo: unknown): Promise<T> {
  const r = await fetch(url, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(corpo) });
  const json = await r.json().catch(() => ({}));
  if (!r.ok && !("ok" in json)) throw new Error(json.erro ?? `Falha (${r.status})`);
  return json as T;
}

export function Envio() {
  const router = useRouter();
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [leitura, setLeitura] = useState<ResultadoLeitura | null>(null);
  const [etapa, setEtapa] = useState<string | null>(null);
  const [resultado, setResultado] = useState<Resultado | null>(null);
  const [erro, setErro] = useState<string | null>(null);

  async function escolher(f: File | undefined) {
    setLeitura(null);
    setResultado(null);
    setErro(null);
    setArquivo(f ?? null);
    if (!f) return;
    try {
      setEtapa("Lendo a planilha…");
      const { default: lerExcel } = await import("read-excel-file/browser");
      // parseNumber mantém o número como texto: o banco converte sem perder precisão.
      const abas = await lerExcel(f, { parseNumber: (s: string) => s });
      setLeitura(lerAbas(abas));
    } catch (e) {
      setErro(`Não consegui ler o arquivo: ${(e as Error).message}`);
    } finally {
      setEtapa(null);
    }
  }

  async function enviar() {
    if (!arquivo || !leitura) return;
    setErro(null);
    setResultado(null);
    try {
      setEtapa("Abrindo a carga…");
      const { id } = await postar<{ id: number }>("/api/cargas", { arquivo: arquivo.name });
      const total = Object.values(leitura.abas).reduce((s, l) => s + l.length, 0);
      let enviadas = 0;
      for (const [aba, linhas] of Object.entries(leitura.abas)) {
        for (const lote of lotes(linhas)) {
          await postar(`/api/cargas/${id}/linhas`, { aba, linhas: lote });
          enviadas += lote.length;
          setEtapa(`Enviando linhas… ${Math.round((enviadas / total) * 100)}%`);
        }
      }
      setEtapa("Validando e aplicando no banco…");
      setResultado(await postar<Resultado>(`/api/cargas/${id}/aplicar`, {}));
      router.refresh();
    } catch (e) {
      setErro((e as Error).message);
    } finally {
      setEtapa(null);
    }
  }

  const contagem = leitura ? Object.entries(leitura.abas) : [];
  const podeEnviar = !!leitura && contagem.length > 0 && leitura.problemas.length === 0 && !etapa;

  return (
    <div className="space-y-3 text-sm">
      <input
        type="file"
        accept=".xlsx"
        onChange={(e) => escolher(e.target.files?.[0])}
        className="block w-full text-sm file:mr-3 file:rounded file:border-0 file:bg-noite file:px-3 file:py-2 file:text-white"
      />

      {leitura && (
        <div className="rounded border border-borda p-3">
          {contagem.length === 0 && leitura.problemas.length === 0 && <p>Nenhuma aba de carga com linhas neste arquivo.</p>}
          {contagem.length > 0 && (
            <ul className="space-y-1">
              {contagem.map(([aba, linhas]) => (
                <li key={aba} className="flex">
                  <span className="flex-1">{ABAS[aba].titulo}</span>
                  <span className="num font-medium">{linhas.length.toLocaleString("pt-BR")} {linhas.length === 1 ? "linha" : "linhas"}</span>
                </li>
              ))}
            </ul>
          )}
          {leitura.ignoradas.length > 0 && <p className="mt-2 text-suave">Abas ignoradas: {leitura.ignoradas.join(", ")}</p>}
          {leitura.problemas.map((p) => (
            <p key={p} className="mt-2 text-erro">
              {p}
            </p>
          ))}
        </div>
      )}

      <button onClick={enviar} disabled={!podeEnviar} className="rounded bg-noite px-4 py-2 font-medium text-white disabled:opacity-50">
        Enviar e aplicar
      </button>

      {etapa && <p className="text-suave">{etapa}</p>}
      {erro && <p className="text-erro">{erro}</p>}
      {resultado &&
        (resultado.ok ? (
          <p className="rounded bg-green-50 p-3 text-ok">Carga aplicada.</p>
        ) : (
          <div className="rounded bg-red-50 p-3 text-erro">
            <p className="font-medium">
              {resultado.total_erros} erro(s). Nada foi aplicado. Corrija a planilha e envie de novo.
            </p>
            <ul className="mt-2 max-h-72 overflow-auto text-xs">
              {resultado.erros?.map((e, i) => (
                <li key={i}>
                  {ABAS[e.aba]?.titulo ?? e.aba}, linha {e.linha}: {e.erro}
                </li>
              ))}
            </ul>
            {resultado.total_erros > (resultado.erros?.length ?? 0) && <p className="mt-1 text-xs">Mostrando os primeiros 500.</p>}
          </div>
        ))}
    </div>
  );
}
