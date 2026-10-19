import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { KpiCard } from "@/components/KpiCard";
import { EmploymentStatusBadge, BandStatusBadge } from "@/components/StatusBadge";

describe("presentational components", () => {
  it("renders a KPI card with its title and value", () => {
    render(<KpiCard title="Headcount" value="10,000" subtitle="Active employees" />);
    expect(screen.getByText("Headcount")).toBeInTheDocument();
    expect(screen.getByText("10,000")).toBeInTheDocument();
    expect(screen.getByText("Active employees")).toBeInTheDocument();
  });

  it("humanizes employment status labels", () => {
    render(<EmploymentStatusBadge status="on_leave" />);
    expect(screen.getByText("on leave")).toBeInTheDocument();
  });

  it("humanizes band status labels", () => {
    render(<BandStatusBadge status="within_band" />);
    expect(screen.getByText("within band")).toBeInTheDocument();
  });
});
