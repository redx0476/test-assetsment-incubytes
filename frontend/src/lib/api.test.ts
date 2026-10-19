import { beforeEach, describe, expect, it, vi } from "vitest";
import { apiFetch, ApiError, setToken, UNAUTHORIZED_EVENT } from "./api";

describe("apiFetch", () => {
  beforeEach(() => {
    setToken(null);
    vi.restoreAllMocks();
  });

  it("attaches the bearer token when one is stored", async () => {
    setToken("abc123");
    const fetchMock = vi
      .fn()
      .mockResolvedValue(new Response(JSON.stringify({ ok: true }), { status: 200 }));
    vi.stubGlobal("fetch", fetchMock);

    await apiFetch("/api/v1/thing");

    const init = fetchMock.mock.calls[0][1] as RequestInit;
    const headers = init.headers as Headers;
    expect(headers.get("Authorization")).toBe("Bearer abc123");
  });

  it("throws an ApiError carrying the server message on failure", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue(new Response(JSON.stringify({ error: "boom" }), { status: 422 })),
    );

    await expect(apiFetch("/x")).rejects.toMatchObject({ status: 422, message: "boom" });
  });

  it("clears the token and emits an unauthorized event on 401", async () => {
    setToken("tok");
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(new Response("", { status: 401 })));
    const handler = vi.fn();
    window.addEventListener(UNAUTHORIZED_EVENT, handler);

    await expect(apiFetch("/x")).rejects.toBeInstanceOf(ApiError);

    expect(handler).toHaveBeenCalled();
    window.removeEventListener(UNAUTHORIZED_EVENT, handler);
  });
});
