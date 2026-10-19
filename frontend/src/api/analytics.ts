import { apiFetch } from "@/lib/api";
import type { BreakdownResponse, DashboardResponse, EquityResponse } from "./types";

export function fetchDashboard(): Promise<DashboardResponse> {
  return apiFetch<DashboardResponse>("/api/v1/analytics/dashboard");
}

export function fetchBreakdown(dimension: string): Promise<BreakdownResponse> {
  return apiFetch<BreakdownResponse>(`/api/v1/analytics/breakdown?dimension=${dimension}`);
}

export function fetchEquity(): Promise<EquityResponse> {
  return apiFetch<EquityResponse>("/api/v1/analytics/equity");
}
