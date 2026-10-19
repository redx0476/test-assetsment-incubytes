export const COUNTRIES: { code: string; name: string }[] = [
  { code: "US", name: "United States" },
  { code: "GB", name: "United Kingdom" },
  { code: "DE", name: "Germany" },
  { code: "FR", name: "France" },
  { code: "IN", name: "India" },
  { code: "CA", name: "Canada" },
  { code: "AU", name: "Australia" },
  { code: "SG", name: "Singapore" },
  { code: "BR", name: "Brazil" },
  { code: "ZA", name: "South Africa" },
];

export const DEPARTMENTS = [
  "Engineering",
  "Sales",
  "Marketing",
  "Finance",
  "People",
  "Operations",
  "Product",
  "Customer Support",
  "Legal",
  "Design",
];

export const JOB_LEVELS = [
  "junior",
  "mid",
  "senior",
  "staff",
  "principal",
  "manager",
  "director",
];

export const EMPLOYMENT_STATUSES = ["active", "on_leave", "terminated"];

export const BREAKDOWN_DIMENSIONS = [
  { value: "country", label: "Country" },
  { value: "department", label: "Department" },
  { value: "level", label: "Job level" },
];
