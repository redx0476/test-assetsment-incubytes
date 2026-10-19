import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { fetchBreakdown, fetchEquity } from "@/api/analytics";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select } from "@/components/ui/select";
import { Table, Tbody, Td, Th, Thead, Tr } from "@/components/ui/table";
import { LoadingPanel } from "@/components/ui/spinner";
import { BREAKDOWN_DIMENSIONS } from "@/lib/constants";
import { formatNumber, formatPercent, formatUsdFromCents } from "@/lib/format";

const BRAND = "#4f46e5";

export function Analytics() {
  const [dimension, setDimension] = useState("country");

  const breakdown = useQuery({
    queryKey: ["breakdown", dimension],
    queryFn: () => fetchBreakdown(dimension),
  });
  const equity = useQuery({ queryKey: ["equity"], queryFn: fetchEquity });

  const chartData =
    breakdown.data?.groups.map((group) => ({
      name: group.key,
      median: Math.round(group.median_usd_cents / 100),
    })) ?? [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-slate-900">Analytics</h1>
        <p className="text-sm text-slate-500">How the organization pays people.</p>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Compensation breakdown</CardTitle>
          <Select
            className="w-44"
            value={dimension}
            onChange={(event) => setDimension(event.target.value)}
          >
            {BREAKDOWN_DIMENSIONS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </Select>
        </CardHeader>
        <CardContent>
          {breakdown.isLoading ? (
            <LoadingPanel />
          ) : (
            <>
              <ResponsiveContainer width="100%" height={280}>
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                  <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                  <YAxis
                    tick={{ fontSize: 11 }}
                    tickFormatter={(value: number) => `$${Math.round(value / 1000)}k`}
                  />
                  <Tooltip
                    formatter={(value: number) => [formatUsdFromCents(value * 100), "Median"]}
                  />
                  <Bar dataKey="median" radius={[4, 4, 0, 0]} fill={BRAND} />
                </BarChart>
              </ResponsiveContainer>

              <div className="mt-4">
                <Table>
                  <Thead>
                    <Tr>
                      <Th className="capitalize">{breakdown.data?.dimension}</Th>
                      <Th className="text-right">Headcount</Th>
                      <Th className="text-right">Total</Th>
                      <Th className="text-right">Average</Th>
                      <Th className="text-right">Median</Th>
                    </Tr>
                  </Thead>
                  <Tbody>
                    {breakdown.data?.groups.map((group) => (
                      <Tr key={group.key}>
                        <Td className="font-medium capitalize">{group.key}</Td>
                        <Td className="text-right">{formatNumber(group.headcount)}</Td>
                        <Td className="text-right">{formatUsdFromCents(group.total_usd_cents)}</Td>
                        <Td className="text-right">{formatUsdFromCents(group.average_usd_cents)}</Td>
                        <Td className="text-right">{formatUsdFromCents(group.median_usd_cents)}</Td>
                      </Tr>
                    ))}
                  </Tbody>
                </Table>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Gender pay gap by department</CardTitle>
        </CardHeader>
        <CardContent>
          {equity.isLoading ? (
            <LoadingPanel />
          ) : (
            <Table>
              <Thead>
                <Tr>
                  <Th>Department</Th>
                  <Th className="text-right">Avg (male)</Th>
                  <Th className="text-right">Avg (female)</Th>
                  <Th className="text-right">Gap</Th>
                </Tr>
              </Thead>
              <Tbody>
                {equity.data?.by_department.map((entry) => (
                  <Tr key={entry.department}>
                    <Td className="font-medium">{entry.department}</Td>
                    <Td className="text-right">
                      {formatUsdFromCents(entry.genders.male?.average_usd_cents)}
                    </Td>
                    <Td className="text-right">
                      {formatUsdFromCents(entry.genders.female?.average_usd_cents)}
                    </Td>
                    <Td className="text-right">{formatPercent(entry.gap_pct)}</Td>
                  </Tr>
                ))}
              </Tbody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
