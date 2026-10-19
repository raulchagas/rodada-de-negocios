// Formatação brasileira. Centavos só abaixo de R$ 1.000 (R$ 12,90; R$ 1.290; R$ 12.900).
export function brl(v: number | string | null | undefined): string {
  const n = Number(v ?? 0);
  const casas = Math.abs(n) < 1000 ? 2 : 0;
  return n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", minimumFractionDigits: casas, maximumFractionDigits: casas });
}

export function inteiro(v: number | string | null | undefined): string {
  return Number(v ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });
}

export function pct(v: number | string | null | undefined): string {
  if (v === null || v === undefined) return "—";
  return `${Number(v).toLocaleString("pt-BR", { minimumFractionDigits: 1, maximumFractionDigits: 1 })}%`;
}

export function dataHora(v: Date | string | null | undefined): string {
  if (!v) return "—";
  return new Date(v).toLocaleString("pt-BR", { timeZone: "America/Sao_Paulo", dateStyle: "short", timeStyle: "short" });
}

export const NOME_PERFIL: Record<string, string> = {
  admin: "Admin",
  regional: "Regional",
  cpv: "CPV",
  cna: "CNA",
  cne: "CNE",
  fi: "F&I",
  grupo: "Grupo",
  fornecedor: "Fornecedor",
};
