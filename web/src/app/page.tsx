import Link from "next/link";
import { sql } from "@/lib/db";
import { inteiro } from "@/lib/format";
import { exigirUsuario } from "@/lib/sessao";
import { Banda, Cartao, Corpo, Moldura, Pilula, Vazio } from "./ui";

type Resumo = {
  rodada: string | null;
  categorias: number;
  dealers: number;
  grupos: number;
  consultores: number;
  carteira: number;
  itens: number;
  itens_fornecedor: number;
  demanda: number;
  metas: number;
  usuarios: number;
};

export default async function Page({ searchParams }: PageProps<"/">) {
  const usuario = await exigirUsuario();
  const semPermissao = (await searchParams)["sem-permissao"];
  const [r] = await sql<Resumo[]>`
    with ro as (select id, nome from rodada.rodada where ativa)
    select (select nome from ro) as rodada,
      (select count(*)::int from rodada.categoria where rodada_id = (select id from ro)) as categorias,
      (select count(*)::int from rodada.dealer where ativo) as dealers,
      (select count(*)::int from rodada.grupo where ativo) as grupos,
      (select count(*)::int from rodada.consultor where ativo) as consultores,
      (select count(*)::int from rodada.carteira where rodada_id = (select id from ro)) as carteira,
      (select count(*)::int from rodada.item where rodada_id = (select id from ro) and fornecedor_id is null) as itens,
      (select count(*)::int from rodada.item where rodada_id = (select id from ro) and fornecedor_id is not null) as itens_fornecedor,
      (select count(*)::int from rodada.demanda where rodada_id = (select id from ro)) as demanda,
      (select count(*)::int from rodada.meta_grupo where rodada_id = (select id from ro)) as metas,
      (select count(*)::int from rodada.usuario where ativo) as usuarios`;

  const etapas: [string, number, string][] = [
    ["Hierarquia (dealers)", r.dealers, "hierarquia"],
    ["Grupos", r.grupos, "hierarquia"],
    ["Consultores", r.consultores, "consultores"],
    ["Carteira da rodada", r.carteira, "carteira"],
    ["PNs da base 21 pontos", r.itens, "base21"],
    ["Linhas dealer × PN", r.demanda, "base21"],
    ["Itens de fornecedor", r.itens_fornecedor, "catalogo_fornecedor"],
    ["Metas grupo × categoria", r.metas, "metas"],
    ["Usuários ativos", r.usuarios, "usuarios"],
  ];

  return (
    <Moldura usuario={usuario}>
      <Banda titulo={r.rodada ?? "Nenhuma rodada ativa"}>
        <p className="text-sm">
          {r.categorias} categorias · {inteiro(r.grupos)} grupos · {inteiro(r.itens)} PNs na base
        </p>
      </Banda>
      <Corpo>
        {semPermissao && <Vazio>Seu perfil não tem acesso àquela tela.</Vazio>}
        {usuario.perfil === "admin" ? (
          <Cartao titulo="Bases da rodada" acao={<Link href="/admin/cargas" className="text-sm font-medium text-acento">Carregar planilha →</Link>}>
            <ul className="divide-y divide-borda text-sm">
              {etapas.map(([nome, qt, aba]) => (
                <li key={nome} className="flex items-center gap-3 py-2">
                  <span className="flex-1">{nome}</span>
                  <span className="num w-20 text-right font-medium">{inteiro(qt)}</span>
                  <span className="w-28 text-right">
                    {qt > 0 ? <Pilula tom="ok">carregado</Pilula> : <Pilula tom="alerta">falta: {aba}</Pilula>}
                  </span>
                </li>
              ))}
            </ul>
          </Cartao>
        ) : (
          <Cartao titulo="Negociação">
            <Vazio>A tela de negociação está em construção. Você será avisado quando abrir.</Vazio>
          </Cartao>
        )}
      </Corpo>
    </Moldura>
  );
}
