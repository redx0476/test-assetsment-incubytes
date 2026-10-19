import { describe, expect, it } from "vitest";
import { formatUsdFromCents, formatPercent, formatNumber } from "./format";

describe("format helpers", () => {
  it("formats USD cents as whole-dollar currency", () => {
    expect(formatUsdFromCents(12_345_600)).toBe("$123,456");
    expect(formatUsdFromCents(null)).toBe("—");
  });

  it("formats percentages to one decimal", () => {
    expect(formatPercent(10)).toBe("10.0%");
    expect(formatPercent(null)).toBe("—");
  });

  it("formats large numbers with separators", () => {
    expect(formatNumber(10000)).toBe("10,000");
  });
});
