export interface User {
  id: number;
  email: string;
  role: string;
}

export interface Salary {
  id: number;
  amount_cents: number;
  amount: number;
  currency: string;
  amount_usd_cents: number;
  effective_date: string;
  current: boolean;
}

export interface EmployeeSummary {
  id: number;
  employee_number: string;
  full_name: string;
  email: string;
  country_code: string;
  department: string;
  job_title: string;
  job_level: string;
  employment_status: string;
  current_salary: Salary | null;
}

export interface BandAssessment {
  status: "within_band" | "below_min" | "above_max" | "no_band" | "no_salary";
  compa_ratio: number | null;
  band: {
    currency: string;
    min_cents: number;
    mid_cents: number;
    max_cents: number;
  } | null;
}

export interface EmployeeDetail extends EmployeeSummary {
  first_name: string;
  last_name: string;
  gender: string | null;
  hire_date: string;
  salaries: Salary[];
  band_assessment: BandAssessment;
}

export interface PaginationMeta {
  page: number;
  per_page: number;
  total_count: number;
  total_pages: number;
}

export interface EmployeesResponse {
  employees: EmployeeSummary[];
  meta: PaginationMeta;
}

export interface DistributionBucket {
  bucket: string;
  headcount: number;
}

export interface DashboardResponse {
  headcount: number;
  total_usd_cents: number;
  average_usd_cents: number;
  median_usd_cents: number;
  distribution: DistributionBucket[];
}

export interface BreakdownGroup {
  key: string;
  headcount: number;
  total_usd_cents: number;
  average_usd_cents: number;
  median_usd_cents: number;
}

export interface BreakdownResponse {
  dimension: string;
  groups: BreakdownGroup[];
}

export interface GenderStat {
  headcount: number;
  average_usd_cents: number;
}

export interface EquityEntry {
  genders: Record<string, GenderStat>;
  gap_pct: number | null;
  department?: string;
}

export interface EquityResponse {
  overall: EquityEntry;
  by_department: EquityEntry[];
}
