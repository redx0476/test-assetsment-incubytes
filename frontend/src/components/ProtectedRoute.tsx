import type { ReactNode } from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "@/context/auth";
import { LoadingPanel } from "@/components/ui/spinner";

export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();

  if (loading) return <LoadingPanel />;
  if (!user) return <Navigate to="/login" replace />;
  return <>{children}</>;
}
