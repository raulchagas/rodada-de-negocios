import { describe, expect, it, vi } from "vitest";

vi.mock("server-only", () => ({}));
vi.mock("postgres", () => ({ default: () => ({}) }));

describe("urlBanco", async () => {
  const { urlBanco } = await import("./db");
  it("tira channel_binding da string do Neon", () => {
    expect(urlBanco("postgresql://u:p@h/db?channel_binding=require&sslmode=require")).toBe("postgresql://u:p@h/db?sslmode=require");
    expect(urlBanco("postgresql://u:p@h/db?sslmode=require&channel_binding=require")).toBe("postgresql://u:p@h/db?sslmode=require");
    expect(urlBanco("postgresql://u:p@h/db?channel_binding=require")).toBe("postgresql://u:p@h/db");
    expect(urlBanco("postgresql://u:p@h/db?sslmode=require")).toBe("postgresql://u:p@h/db?sslmode=require");
  });
});
