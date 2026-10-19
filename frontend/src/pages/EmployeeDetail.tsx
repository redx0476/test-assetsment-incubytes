import { Link, useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ArrowLeft } from "lucide-react";
import { createSalary, fetchEmployee } from "@/api/employees";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, Tbody, Td, Th, Thead, Tr } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { BandStatusBadge, EmploymentStatusBadge } from "@/components/StatusBadge";
import { LoadingPanel } from "@/components/ui/spinner";
import { formatMoneyFromCents, formatPercent, formatUsdFromCents } from "@/lib/format";

const schema = z.object({
  amount: z.coerce.number().positive("Amount must be greater than 0"),
  currency: z.string().length(3, "Use a 3-letter currency code"),
  effective_date: z.string().min(1, "Pick a date"),
});

type FormValues = z.input<typeof schema>;

export function EmployeeDetail() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();

  const { data, isLoading, isError } = useQuery({
    queryKey: ["employee", id],
    queryFn: () => fetchEmployee(id!),
    enabled: Boolean(id),
  });

  const employee = data?.employee;

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    values: {
      amount: "" as unknown as number,
      currency: employee?.current_salary?.currency ?? "USD",
      effective_date: new Date().toISOString().slice(0, 10),
    },
  });

  const mutation = useMutation({
    mutationFn: (values: FormValues) =>
      createSalary(id!, {
        amount_cents: Math.round(Number(values.amount) * 100),
        currency: String(values.currency).toUpperCase(),
        effective_date: String(values.effective_date),
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["employee", id] });
      queryClient.invalidateQueries({ queryKey: ["dashboard"] });
      reset();
    },
  });

  if (isLoading) return <LoadingPanel label="Loading employee…" />;
  if (isError || !employee)
    return <p className="text-sm text-red-600">Could not load this employee.</p>;

  const assessment = employee.band_assessment;

  return (
    <div className="space-y-6">
      <Link to="/employees" className="inline-flex items-center gap-1 text-sm text-slate-500 hover:text-slate-800">
        <ArrowLeft className="h-4 w-4" /> Back to employees
      </Link>

      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold text-slate-900">{employee.full_name}</h1>
          <p className="text-sm text-slate-500">
            {employee.job_title} · {employee.department} · {employee.country_code}
          </p>
        </div>
        <EmploymentStatusBadge status={employee.employment_status} />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>Current salary</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-semibold text-slate-900">
              {employee.current_salary
                ? formatMoneyFromCents(
                    employee.current_salary.amount_cents,
                    employee.current_salary.currency,
                  )
                : "—"}
            </p>
            <p className="mt-1 text-xs text-slate-500">
              {formatUsdFromCents(employee.current_salary?.amount_usd_cents)} USD
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Compa-ratio</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-semibold text-slate-900">
              {assessment.compa_ratio != null ? formatPercent(assessment.compa_ratio * 100) : "—"}
            </p>
            <div className="mt-2">
              <BandStatusBadge status={assessment.status} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Pay band</CardTitle>
          </CardHeader>
          <CardContent>
            {assessment.band ? (
              <p className="text-sm text-slate-600">
                {formatMoneyFromCents(assessment.band.min_cents, assessment.band.currency)} –{" "}
                {formatMoneyFromCents(assessment.band.max_cents, assessment.band.currency)}
                <span className="mt-1 block text-xs text-slate-400">
                  Midpoint {formatMoneyFromCents(assessment.band.mid_cents, assessment.band.currency)}
                </span>
              </p>
            ) : (
              <p className="text-sm text-slate-500">No band defined.</p>
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Salary history</CardTitle>
          </CardHeader>
          <CardContent className="px-0">
            <Table>
              <Thead>
                <Tr>
                  <Th>Effective date</Th>
                  <Th className="text-right">Amount</Th>
                  <Th className="text-right">USD</Th>
                  <Th />
                </Tr>
              </Thead>
              <Tbody>
                {employee.salaries.map((salary) => (
                  <Tr key={salary.id}>
                    <Td>{salary.effective_date}</Td>
                    <Td className="text-right">
                      {formatMoneyFromCents(salary.amount_cents, salary.currency)}
                    </Td>
                    <Td className="text-right text-slate-500">
                      {formatUsdFromCents(salary.amount_usd_cents)}
                    </Td>
                    <Td>{salary.current ? <Badge tone="green">current</Badge> : null}</Td>
                  </Tr>
                ))}
              </Tbody>
            </Table>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Record new salary</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit((values) => mutation.mutate(values))} className="space-y-3">
              <div>
                <Label htmlFor="amount">Amount</Label>
                <Input id="amount" type="number" step="0.01" {...register("amount")} />
                {errors.amount ? (
                  <p className="mt-1 text-xs text-red-600">{errors.amount.message}</p>
                ) : null}
              </div>
              <div>
                <Label htmlFor="currency">Currency</Label>
                <Input id="currency" maxLength={3} {...register("currency")} />
                {errors.currency ? (
                  <p className="mt-1 text-xs text-red-600">{errors.currency.message}</p>
                ) : null}
              </div>
              <div>
                <Label htmlFor="effective_date">Effective date</Label>
                <Input id="effective_date" type="date" {...register("effective_date")} />
                {errors.effective_date ? (
                  <p className="mt-1 text-xs text-red-600">{errors.effective_date.message}</p>
                ) : null}
              </div>
              {mutation.isError ? (
                <p className="text-xs text-red-600">Could not save. Check the values and try again.</p>
              ) : null}
              <Button type="submit" className="w-full" disabled={mutation.isPending}>
                {mutation.isPending ? "Saving…" : "Save salary"}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
