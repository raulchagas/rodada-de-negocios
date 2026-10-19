import { FormEntrar } from "./form";

export default function Page() {
  return (
    <main className="flex flex-1 items-center justify-center bg-noite px-4">
      <div className="w-full max-w-sm rounded-lg bg-white p-6 shadow-lg">
        <h1 className="text-lg font-semibold">Rodada de Negócios</h1>
        <p className="mt-1 text-sm text-suave">Acesso por convite. Informe o e-mail cadastrado.</p>
        <FormEntrar />
      </div>
    </main>
  );
}
