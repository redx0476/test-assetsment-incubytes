import { useQuery } from "@tanstack/react-query";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Users, Wallet, TrendingUp, Scale } from "lucide-react";
import { fetchDashboard, fetchBreakdown, fetchEquity } from "@/api/analytics";
import { KpiCard } from "@/components/KpiCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LoadingPanel } from "@/components/ui/spinner";
import { formatNumber, formatPercent, formatUsdFromCents } from "@/lib/format";

const BRAND = "#4f46e5";

export function Dashboard() {
  const dashboard = useQuery({ queryKey: ["dashboard"], queryFn: fetchDashboard });
  const byCountry = useQuery({
    queryKey: ["breakdown", "country"],
    queryFn: () => fetchBreakdown("country"),
  });
  const equity = useQuery({ queryKey: ["equity"], queryFn: fetchEquity });

  if (dashboard.isLoading) return <LoadingPanel label="Loading dashboard…" />;
  if (dashboard.isError || !dashboard.data)
    return <p className="text-sm text-red-600">Could not load dashboard.</p>;

  const data = dashboard.data;
  const countryData =
    byCountry.data?.groups.map((group) => ({
      name: group.key,
      value: Math.round(group.total_usd_cents / 100),
    })) ?? [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>
        <p className="text-sm text-slate-500">
          Compensation across the active workforce, normalized to USD.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard
          title="Headcount"
          value={formatNumber(data.headcount)}
          subtitle="Active employees"
          icon={<Users className="h-5 w-5" />}
        />
        <KpiCard
          title="Total payroll"
          value={formatUsdFromCents(data.total_usd_cents)}
          subtitle="Annualized, USD"
          icon={<Wallet className="h-5 w-5" />}
        />
        <KpiCard
          title="Average salary"
          value={formatUsdFromCents(data.average_usd_cents)}
          subtitle="Mean, USD"
          icon={<TrendingUp className="h-5 w-5" />}
        />
        <KpiCard
          title="Median salary"
          value={formatUsdFromCents(data.median_usd_cents)}
          subtitle="50th percentile, USD"
          icon={<Scale className="h-5 w-5" />}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Salary distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={data.distribution}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="bucket" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip formatter={(value: number) => [formatNumber(value), "Employees"]} />
                <Bar dataKey="headcount" radius={[4, 4, 0, 0]} fill={BRAND} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Total payroll by country (USD)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={countryData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                <YAxis
                  tick={{ fontSize: 11 }}
                  tickFormatter={(value: number) => `$${Math.round(value / 1_000_000)}M`}
                />
                <Tooltip
                  formatter={(value: number) => [
                    formatUsdFromCents(value * 100),
                    "Total payroll",
                  ]}
                />
                <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                  {countryData.map((entry) => (
                    <Cell key={entry.name} fill={BRAND} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Pay equity</CardTitle>
        </CardHeader>
        <CardContent>
          {equity.data ? (
            <div className="flex flex-wrap items-center gap-6">
              <div>
                <p className="text-xs text-slate-500">Overall gender pay gap (M vs F)</p>
                <p className="text-2xl font-semibold text-slate-900">
                  {formatPercent(equity.data.overall.gap_pct)}
                </p>
              </div>
              <div className="text-sm text-slate-500">
                Average male {formatUsdFromCents(equity.data.overall.genders.male?.average_usd_cents)} ·
                Average female{" "}
                {formatUsdFromCents(equity.data.overall.genders.female?.average_usd_cents)}
              </div>
            </div>
          ) : (
            <p className="text-sm text-slate-500">Loading…</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
