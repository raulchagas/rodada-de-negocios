import { Confirmar } from "./confirmar";

// O link não loga direto: o antivírus de e-mail corporativo (ex.: Outlook Safe Links) abre os links para
// verificá-los e consumiria o token de uso único. A entrada só acontece no clique do botão.
export default async function Page({ params }: PageProps<"/entrar/[token]">) {
  const { token } = await params;
  return (
    <main className="flex flex-1 items-center justify-center bg-noite px-4">
      <div className="w-full max-w-sm rounded-lg bg-white p-6 text-center shadow-lg">
        <h1 className="text-lg font-semibold">Rodada de Negócios</h1>
        <p className="mt-1 text-sm text-suave">Confirme para entrar neste dispositivo.</p>
        <Confirmar token={token} />
      </div>
    </main>
  );
}
