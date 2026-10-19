import { apiFetch } from "@/lib/api";
import type { User } from "./types";

export interface LoginResponse {
  token: string;
  user: User;
}

export function login(email: string, password: string): Promise<LoginResponse> {
  return apiFetch<LoginResponse>("/api/v1/session", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

export function fetchCurrentUser(): Promise<{ user: User }> {
  return apiFetch<{ user: User }>("/api/v1/session");
}

export function logout(): Promise<void> {
  return apiFetch<void>("/api/v1/session", { method: "DELETE" });
}
