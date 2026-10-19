import { Badge } from "@/components/ui/badge";

const employmentTone: Record<string, "green" | "amber" | "red" | "neutral"> = {
  active: "green",
  on_leave: "amber",
  terminated: "red",
};

const bandTone: Record<string, "green" | "amber" | "blue" | "neutral"> = {
  within_band: "green",
  below_min: "amber",
  above_max: "blue",
  no_band: "neutral",
  no_salary: "neutral",
};

export function EmploymentStatusBadge({ status }: { status: string }) {
  return <Badge tone={employmentTone[status] ?? "neutral"}>{status.replace("_", " ")}</Badge>;
}

export function BandStatusBadge({ status }: { status: string }) {
  return <Badge tone={bandTone[status] ?? "neutral"}>{status.replace(/_/g, " ")}</Badge>;
}
