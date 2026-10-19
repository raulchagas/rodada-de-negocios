import { NextResponse, type NextRequest } from "next/server";

// Checagem otimista: sem cookie de sessão, vai para /entrar. A validação real da sessão é feita no servidor
// (usuarioAtual/exigirUsuario) em toda página, rota e ação.
export function proxy(request: NextRequest) {
  if (!request.cookies.has("rodada_sessao")) {
    const url = new URL("/entrar", request.url);
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!entrar|_next/static|_next/image|favicon.ico).*)"],
};
