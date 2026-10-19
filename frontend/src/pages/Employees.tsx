import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { keepPreviousData, useQuery } from "@tanstack/react-query";
import { Search } from "lucide-react";
import { fetchEmployees, type EmployeeFilters } from "@/api/employees";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Table, Tbody, Td, Th, Thead, Tr } from "@/components/ui/table";
import { EmploymentStatusBadge } from "@/components/StatusBadge";
import { LoadingPanel } from "@/components/ui/spinner";
import { COUNTRIES, DEPARTMENTS, EMPLOYMENT_STATUSES, JOB_LEVELS } from "@/lib/constants";
import { formatMoneyFromCents, formatNumber, formatUsdFromCents } from "@/lib/format";

const PER_PAGE = 25;

export function Employees() {
  const [searchInput, setSearchInput] = useState("");
  const [filters, setFilters] = useState<EmployeeFilters>({ page: 1, per_page: PER_PAGE });

  useEffect(() => {
    const timer = setTimeout(() => {
      setFilters((prev) => ({ ...prev, q: searchInput, page: 1 }));
    }, 300);
    return () => clearTimeout(timer);
  }, [searchInput]);

  const { data, isLoading, isError } = useQuery({
    queryKey: ["employees", filters],
    queryFn: () => fetchEmployees(filters),
    placeholderData: keepPreviousData,
  });

  const updateFilter = (key: keyof EmployeeFilters, value: string) => {
    setFilters((prev) => ({ ...prev, [key]: value || undefined, page: 1 }));
  };

  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-semibold text-slate-900">Employees</h1>
        <p className="text-sm text-slate-500">
          {meta ? `${formatNumber(meta.total_count)} employees` : "Loading…"}
        </p>
      </div>

      <Card>
        <CardContent className="pt-5">
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-5">
            <div className="relative lg:col-span-1">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
              <Input
                className="pl-9"
                placeholder="Search name, email, ID"
                value={searchInput}
                onChange={(event) => setSearchInput(event.target.value)}
              />
            </div>
            <Select value={filters.country ?? ""} onChange={(e) => updateFilter("country", e.target.value)}>
              <option value="">All countries</option>
              {COUNTRIES.map((country) => (
                <option key={country.code} value={country.code}>
                  {country.name}
                </option>
              ))}
            </Select>
            <Select
              value={filters.department ?? ""}
              onChange={(e) => updateFilter("department", e.target.value)}
            >
              <option value="">All departments</option>
              {DEPARTMENTS.map((department) => (
                <option key={department} value={department}>
                  {department}
                </option>
              ))}
            </Select>
            <Select
              value={filters.job_level ?? ""}
              onChange={(e) => updateFilter("job_level", e.target.value)}
            >
              <option value="">All levels</option>
              {JOB_LEVELS.map((level) => (
                <option key={level} value={level} className="capitalize">
                  {level}
                </option>
              ))}
            </Select>
            <Select value={filters.status ?? ""} onChange={(e) => updateFilter("status", e.target.value)}>
              <option value="">All statuses</option>
              {EMPLOYMENT_STATUSES.map((status) => (
                <option key={status} value={status}>
                  {status.replace("_", " ")}
                </option>
              ))}
            </Select>
          </div>
        </CardContent>
      </Card>

      <Card>
        {isLoading ? (
          <LoadingPanel />
        ) : isError ? (
          <p className="p-6 text-sm text-red-600">Could not load employees.</p>
        ) : (
          <Table>
            <Thead>
              <Tr>
                <Th>Employee</Th>
                <Th>Country</Th>
                <Th>Department</Th>
                <Th>Level</Th>
                <Th>Status</Th>
                <Th className="text-right">Current salary</Th>
                <Th className="text-right">USD</Th>
              </Tr>
            </Thead>
            <Tbody>
              {data?.employees.map((employee) => (
                <Tr key={employee.id}>
                  <Td>
                    <Link
                      to={`/employees/${employee.id}`}
                      className="font-medium text-brand-700 hover:underline"
                    >
                      {employee.full_name}
                    </Link>
                    <div className="text-xs text-slate-400">{employee.employee_number}</div>
                  </Td>
                  <Td>{employee.country_code}</Td>
                  <Td>{employee.department}</Td>
                  <Td className="capitalize">{employee.job_level}</Td>
                  <Td>
                    <EmploymentStatusBadge status={employee.employment_status} />
                  </Td>
                  <Td className="text-right">
                    {employee.current_salary
                      ? formatMoneyFromCents(
                          employee.current_salary.amount_cents,
                          employee.current_salary.currency,
                        )
                      : "—"}
                  </Td>
                  <Td className="text-right text-slate-500">
                    {formatUsdFromCents(employee.current_salary?.amount_usd_cents)}
                  </Td>
                </Tr>
              ))}
            </Tbody>
          </Table>
        )}
      </Card>

      {meta ? (
        <div className="flex items-center justify-between text-sm text-slate-500">
          <span>
            Page {meta.page} of {meta.total_pages || 1}
          </span>
          <div className="flex gap-2">
            <Button
              variant="secondary"
              size="sm"
              disabled={meta.page <= 1}
              onClick={() => setFilters((prev) => ({ ...prev, page: (prev.page ?? 1) - 1 }))}
            >
              Previous
            </Button>
            <Button
              variant="secondary"
              size="sm"
              disabled={meta.page >= meta.total_pages}
              onClick={() => setFilters((prev) => ({ ...prev, page: (prev.page ?? 1) + 1 }))}
            >
              Next
            </Button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
