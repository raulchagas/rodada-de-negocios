import { historicoCargas } from "@/lib/cargas";
import { dataHora, inteiro } from "@/lib/format";
import { ABAS } from "@/lib/planilha";
import { exigirUsuario } from "@/lib/sessao";
import { Banda, Cartao, Corpo, Moldura, Pilula, Vazio } from "../../ui";
import { Envio } from "./envio";

export default async function Page() {
  const usuario = await exigirUsuario(["admin"]);
  const historico = await historicoCargas();

  return (
    <Moldura usuario={usuario}>
      <Banda titulo="Cargas">
        <p className="text-sm">
          Uma planilha com uma aba por base (modelo em cargas/modelos_cargas.xlsx). Cada envio é tudo ou nada: com qualquer erro,
          nada é aplicado e a lista de erros aparece abaixo.
        </p>
      </Banda>
      <Corpo>
        <Cartao titulo="Enviar planilha">
          <Envio />
        </Cartao>
        <Cartao titulo="Últimos envios">
          {historico.length === 0 ? (
            <Vazio>Nenhuma carga ainda.</Vazio>
          ) : (
            <ul className="divide-y divide-borda text-sm">
              {historico.map((c) => (
                <li key={c.id} className="py-3">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-medium">{c.arquivo}</span>
                    <Pilula tom={c.status === "aplicada" ? "ok" : c.status === "rejeitada" ? "erro" : "neutro"}>{c.status}</Pilula>
                    <span className="ml-auto text-suave">
                      {dataHora(c.em)} · {c.usuario ?? "—"}
                    </span>
                  </div>
                  {c.abas && (
                    <p className="mt-1 text-suave">
                      {Object.keys(ABAS)
                        .filter((aba) => c.abas?.[aba])
                        .map((aba) => [aba, c.abas![aba]] as const)
                        .map(([aba, qt]) => `${ABAS[aba]?.titulo ?? aba}: ${inteiro(qt)}`)
                        .join(" · ")}
                    </p>
                  )}
                  {c.erros && c.erros.length > 0 && (
                    <details className="mt-1">
                      <summary className="cursor-pointer text-erro">{c.erros.length} erro(s)</summary>
                      <ul className="mt-1 max-h-60 overflow-auto text-xs">
                        {c.erros.map((e, i) => (
                          <li key={i}>
                            {e.aba} linha {e.linha}: {e.erro}
                          </li>
                        ))}
                      </ul>
                    </details>
                  )}
                </li>
              ))}
            </ul>
          )}
        </Cartao>
      </Corpo>
    </Moldura>
  );
}
