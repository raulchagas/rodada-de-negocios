import { sql } from "@/lib/db";
import { dataHora, NOME_PERFIL } from "@/lib/format";
import { exigirUsuario } from "@/lib/sessao";
import { Banda, Cartao, Corpo, Moldura, Vazio } from "../../ui";
import { GerarLink } from "./gerar-link";

type Linha = { id: number; nome: string; email: string; perfil: string; escopo: string | null; ultimo_acesso: Date | null };

export default async function Page() {
  const usuario = await exigirUsuario(["admin"]);
  const linhas = await sql<Linha[]>`
    select u.id, u.nome, u.email, u.perfil, u.ultimo_acesso,
      coalesce(k.nome, f.nome, case when u.regional_codigo is not null then 'Regional ' || u.regional_codigo end,
               (select string_agg(ug.grupo_codigo, ', ') from rodada.usuario_grupo ug where ug.usuario_id = u.id)) as escopo
    from rodada.usuario u
    left join rodada.consultor k on k.id = u.consultor_id
    left join rodada.fornecedor f on f.id = u.fornecedor_id
    where u.ativo
    order by u.perfil, u.nome`;

  return (
    <Moldura usuario={usuario}>
      <Banda titulo="Usuários">
        <p className="text-sm">
          {linhas.length} com acesso. Enquanto não houver envio de e-mail, gere o link aqui e envie pelo canal de sempre. O link
          vale 30 minutos e uma única entrada.
        </p>
      </Banda>
      <Corpo>
        <Cartao>
          {linhas.length === 0 ? (
            <Vazio>Nenhum usuário. Carregue a aba usuarios da planilha.</Vazio>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="text-left text-suave">
                  <tr>
                    <th className="py-2">Nome</th>
                    <th>E-mail</th>
                    <th>Perfil</th>
                    <th>Escopo</th>
                    <th>Último acesso</th>
                    <th />
                  </tr>
                </thead>
                <tbody className="divide-y divide-borda">
                  {linhas.map((l) => (
                    <tr key={l.id}>
                      <td className="py-2 font-medium">{l.nome}</td>
                      <td>{l.email}</td>
                      <td>{NOME_PERFIL[l.perfil]}</td>
                      <td className="text-suave">{l.escopo ?? "—"}</td>
                      <td className="text-suave">{dataHora(l.ultimo_acesso)}</td>
                      <td className="text-right">
                        <GerarLink usuarioId={l.id} />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Cartao>
      </Corpo>
    </Moldura>
  );
}
