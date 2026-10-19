import type { NextConfig } from "next";

// App interno, todo autenticado e com dados ao vivo: sem Cache Components (cada página lê a sessão).
const nextConfig: NextConfig = {
  cacheComponents: false,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
