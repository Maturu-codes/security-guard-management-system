package com.sgms.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class PayrollCalculatorTest {

    private static BigDecimal bd(String v) {
        return new BigDecimal(v);
    }

    /** Compares money by value, ignoring scale (so 900 equals 900.00). */
    private static void assertMoney(String expected, BigDecimal actual) {
        assertEquals(0, bd(expected).compareTo(actual),
                "expected " + expected + " but was " + actual);
    }

    private static PayrollCalculator.PayrollResult calc(String basic) {
        return PayrollCalculator.calculate(bd(basic), null, null, null, null);
    }

    @Test
    @DisplayName("Mid-range salary: NSSF tiers, NHIF, PAYE and net pay")
    void midRangeSalary() {
        PayrollCalculator.PayrollResult r = calc("30000");
        assertMoney("30000", r.grossPay);
        assertMoney("360.00", r.nssfTier1);
        assertMoney("720.00", r.nssfTier2);
        assertMoney("900", r.nhifDeduction);
        assertMoney("1230.00", r.payeTax);
        assertMoney("26790.00", r.netPay);
    }

    @Test
    @DisplayName("Low salary pays no tier II NSSF and no PAYE (personal relief wipes it out)")
    void lowSalaryNoTaxNoTier2() {
        PayrollCalculator.PayrollResult r = calc("5000");
        assertMoney("300.00", r.nssfTier1);
        assertMoney("0", r.nssfTier2);
        assertMoney("0", r.payeTax);
        assertMoney("4550.00", r.netPay);
    }

    @Test
    @DisplayName("Gross pay is basic + allowances + overtime")
    void grossIncludesAllowancesAndOvertime() {
        PayrollCalculator.PayrollResult r = PayrollCalculator.calculate(
                bd("20000"), bd("5000"), bd("3000"), null, null);
        assertMoney("28000", r.grossPay);
        assertMoney("850", r.nhifDeduction);
        assertMoney("730.00", r.payeTax);
        assertMoney("25340.00", r.netPay);
    }

    @Test
    @DisplayName("Null optional amounts are treated as zero")
    void nullOptionalsTreatedAsZero() {
        PayrollCalculator.PayrollResult r = calc("30000");
        assertMoney("0", r.allowances);
        assertMoney("0", r.overtimePay);
        assertMoney("0", r.liabilityDeduction);
        assertMoney("0", r.otherDeductions);
    }

    @Test
    @DisplayName("Liability deduction is capped at 30% of net pay before liability")
    void liabilityDeductionCappedAtThirtyPercent() {
        PayrollCalculator.PayrollResult r = PayrollCalculator.calculate(
                bd("30000"), null, null, bd("10000"), null);
        assertMoney("8037.00", r.liabilityDeduction);
        assertMoney("18753.00", r.netPay);
    }

    @Test
    @DisplayName("Liability deduction below the cap is applied in full")
    void liabilityDeductionBelowCapUnchanged() {
        PayrollCalculator.PayrollResult r = PayrollCalculator.calculate(
                bd("30000"), null, null, bd("1000"), null);
        assertMoney("1000", r.liabilityDeduction);
        assertMoney("25790.00", r.netPay);
    }

    @Test
    @DisplayName("Other deductions reduce net pay")
    void otherDeductionsReduceNet() {
        PayrollCalculator.PayrollResult r = PayrollCalculator.calculate(
                bd("30000"), null, null, null, bd("500"));
        assertMoney("26290.00", r.netPay);
    }

    @Test
    @DisplayName("High earner crosses into the 30% PAYE band; NSSF stays capped")
    void highEarnerUsesHigherPayeBand() {
        PayrollCalculator.PayrollResult r = calc("100000");
        assertMoney("360.00", r.nssfTier1);
        assertMoney("720.00", r.nssfTier2);
        assertMoney("1700", r.nhifDeduction);
        assertMoney("22059.35", r.payeTax);
        assertMoney("75160.65", r.netPay);
    }

    @ParameterizedTest(name = "gross {0} -> NHIF {1}")
    @CsvSource({
            "5999, 150",
            "6000, 300",
            "7999, 300",
            "8000, 400",
            "29999, 850",
            "30000, 900",
            "99999, 1600",
            "100000, 1700",
            "250000, 1700"
    })
    @DisplayName("NHIF bracket boundaries")
    void nhifBracketBoundaries(String gross, String expectedNhif) {
        assertMoney(expectedNhif, calc(gross).nhifDeduction);
    }

    @ParameterizedTest(name = "gross {0} -> NSSF tier I {1}, tier II {2}")
    @CsvSource({
            "3000, 180.00, 0",
            "6000, 360.00, 0",
            "6001, 360.00, 0.06",
            "18000, 360.00, 720.00",
            "50000, 360.00, 720.00"
    })
    @DisplayName("NSSF tier thresholds")
    void nssfTierThresholds(String gross, String tier1, String tier2) {
        PayrollCalculator.PayrollResult r = calc(gross);
        assertMoney(tier1, r.nssfTier1);
        assertMoney(tier2, r.nssfTier2);
    }

    @Test
    @DisplayName("Net pay never exceeds gross pay")
    void netNeverExceedsGross() {
        for (String salary : new String[] {"1000", "6000", "24000", "45000", "250000"}) {
            PayrollCalculator.PayrollResult r = calc(salary);
            assertEquals(true, r.netPay.compareTo(r.grossPay) <= 0, "salary " + salary);
        }
    }
}
