import { apiFetch } from "@/lib/api";
import type { EmployeeDetail, EmployeesResponse, Salary } from "./types";

export interface EmployeeFilters {
  q?: string;
  country?: string;
  department?: string;
  job_level?: string;
  status?: string;
  sort?: string;
  direction?: string;
  page?: number;
  per_page?: number;
}

export function fetchEmployees(filters: EmployeeFilters): Promise<EmployeesResponse> {
  const params = new URLSearchParams();
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") {
      params.set(key, String(value));
    }
  });
  return apiFetch<EmployeesResponse>(`/api/v1/employees?${params.toString()}`);
}

export function fetchEmployee(id: number | string): Promise<{ employee: EmployeeDetail }> {
  return apiFetch<{ employee: EmployeeDetail }>(`/api/v1/employees/${id}`);
}

export interface SalaryInput {
  amount_cents: number;
  currency: string;
  effective_date: string;
}

export function createSalary(
  employeeId: number | string,
  input: SalaryInput,
): Promise<{ salary: Salary }> {
  return apiFetch<{ salary: Salary }>(`/api/v1/employees/${employeeId}/salaries`, {
    method: "POST",
    body: JSON.stringify({ salary: input }),
  });
}
