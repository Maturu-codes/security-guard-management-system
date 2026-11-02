package com.sgms.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Kenya-compliant payroll calculations.
 * NSSF (Act No. 45 of 2013), NHIF, and PAYE as per KRA bands.
 */
public class PayrollCalculator {

    // ---- NSSF (NSSF Act 2013) ----
    // Tier I: 6% on Lower Earnings Limit (LEL) = KES 6,000
    // Tier II: 6% on next (Upper Earnings Limit - LEL) = KES 6,000 to KES 18,000
    private static final BigDecimal NSSF_LEL = new BigDecimal("6000");
    private static final BigDecimal NSSF_UEL = new BigDecimal("18000");
    private static final BigDecimal NSSF_RATE = new BigDecimal("0.06");

    // ---- NHIF Brackets (per month) ----
    private static final int[][] NHIF_BRACKETS = {
        {0, 5999, 150},
        {6000, 7999, 300},
        {8000, 11999, 400},
        {12000, 14999, 500},
        {15000, 19999, 600},
        {20000, 24999, 750},
        {25000, 29999, 850},
        {30000, 34999, 900},
        {35000, 39999, 950},
        {40000, 44999, 1000},
        {45000, 49999, 1100},
        {50000, 59999, 1200},
        {60000, 69999, 1300},
        {70000, 79999, 1400},
        {80000, 89999, 1500},
        {90000, 99999, 1600},
        {100000, Integer.MAX_VALUE, 1700}
    };

    // ---- PAYE Bands (monthly, KES) as per KRA ----
    private static final BigDecimal PERSONAL_RELIEF = new BigDecimal("2400");
    private static final BigDecimal INSURANCE_RELIEF_MAX = new BigDecimal("5000"); // 15% of premium, max 5000

    public static class PayrollResult {
        public BigDecimal basicSalary;
        public BigDecimal allowances;
        public BigDecimal overtimePay;
        public BigDecimal grossPay;
        public BigDecimal nssfTier1;
        public BigDecimal nssfTier2;
        public BigDecimal nhifDeduction;
        public BigDecimal payeTax;
        public BigDecimal totalStatutoryDeductions;
        public BigDecimal netBeforeLiability;
        public BigDecimal liabilityDeduction;
        public BigDecimal otherDeductions;
        public BigDecimal netPay;
    }

    public static PayrollResult calculate(
            BigDecimal basicSalary,
            BigDecimal allowances,
            BigDecimal overtimePay,
            BigDecimal liabilityDeduction,
            BigDecimal otherDeductions) {

        PayrollResult result = new PayrollResult();
        result.basicSalary = basicSalary;
        result.allowances = allowances != null ? allowances : BigDecimal.ZERO;
        result.overtimePay = overtimePay != null ? overtimePay : BigDecimal.ZERO;
        result.liabilityDeduction = liabilityDeduction != null ? liabilityDeduction : BigDecimal.ZERO;
        result.otherDeductions = otherDeductions != null ? otherDeductions : BigDecimal.ZERO;

        result.grossPay = basicSalary.add(result.allowances).add(result.overtimePay);

        // NSSF
        result.nssfTier1 = calculateNSSFTier1(result.grossPay);
        result.nssfTier2 = calculateNSSFTier2(result.grossPay);

        // NHIF
        result.nhifDeduction = calculateNHIF(result.grossPay);

        // Taxable pay = Gross - NSSF
        BigDecimal nssfTotal = result.nssfTier1.add(result.nssfTier2);
        BigDecimal taxablePay = result.grossPay.subtract(nssfTotal);

        // PAYE
        result.payeTax = calculatePAYE(taxablePay);

        result.totalStatutoryDeductions = nssfTotal.add(result.nhifDeduction).add(result.payeTax);
        result.netBeforeLiability = result.grossPay.subtract(result.totalStatutoryDeductions);

        // Cap liability deduction at 30% of net
        BigDecimal maxLiabilityDeduction = result.netBeforeLiability
                .multiply(new BigDecimal("0.30")).setScale(2, RoundingMode.HALF_UP);
        if (result.liabilityDeduction.compareTo(maxLiabilityDeduction) > 0) {
            result.liabilityDeduction = maxLiabilityDeduction;
        }

        result.netPay = result.netBeforeLiability
                .subtract(result.liabilityDeduction)
                .subtract(result.otherDeductions)
                .setScale(2, RoundingMode.HALF_UP);

        return result;
    }

    private static BigDecimal calculateNSSFTier1(BigDecimal grossPay) {
        if (grossPay.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;
        BigDecimal pensionableTier1 = grossPay.min(NSSF_LEL);
        return pensionableTier1.multiply(NSSF_RATE).setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal calculateNSSFTier2(BigDecimal grossPay) {
        if (grossPay.compareTo(NSSF_LEL) <= 0) return BigDecimal.ZERO;
        BigDecimal tier2Base = grossPay.min(NSSF_UEL).subtract(NSSF_LEL);
        if (tier2Base.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;
        return tier2Base.multiply(NSSF_RATE).setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal calculateNHIF(BigDecimal grossPay) {
        int salary = grossPay.intValue();
        for (int[] bracket : NHIF_BRACKETS) {
            if (salary >= bracket[0] && salary <= bracket[1]) {
                return new BigDecimal(bracket[2]);
            }
        }
        return new BigDecimal("1700");
    }

    /**
     * PAYE calculation as per KRA monthly bands (FY 2024/2025):
     * 0 - 24,000:      10%
     * 24,001 - 32,333: 25%
     * 32,334 - 500,000: 30%
     * 500,001 - 800,000: 32.5%
     * 800,001+:         35%
     * Less: Personal Relief KES 2,400/month
     */
    private static BigDecimal calculatePAYE(BigDecimal taxableIncome) {
        BigDecimal tax = BigDecimal.ZERO;
        BigDecimal remaining = taxableIncome;

        if (remaining.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;

        // Band 1: 0 - 24,000 @ 10%
        BigDecimal band1 = new BigDecimal("24000");
        if (remaining.compareTo(band1) > 0) {
            tax = tax.add(band1.multiply(new BigDecimal("0.10")));
            remaining = remaining.subtract(band1);
        } else {
            return applyRelief(tax.add(remaining.multiply(new BigDecimal("0.10"))));
        }

        // Band 2: 24,001 - 32,333 @ 25%
        BigDecimal band2 = new BigDecimal("8333");
        if (remaining.compareTo(band2) > 0) {
            tax = tax.add(band2.multiply(new BigDecimal("0.25")));
            remaining = remaining.subtract(band2);
        } else {
            return applyRelief(tax.add(remaining.multiply(new BigDecimal("0.25"))));
        }

        // Band 3: 32,334 - 500,000 @ 30%
        BigDecimal band3 = new BigDecimal("467667");
        if (remaining.compareTo(band3) > 0) {
            tax = tax.add(band3.multiply(new BigDecimal("0.30")));
            remaining = remaining.subtract(band3);
        } else {
            return applyRelief(tax.add(remaining.multiply(new BigDecimal("0.30"))));
        }

        // Band 4: 500,001 - 800,000 @ 32.5%
        BigDecimal band4 = new BigDecimal("300000");
        if (remaining.compareTo(band4) > 0) {
            tax = tax.add(band4.multiply(new BigDecimal("0.325")));
            remaining = remaining.subtract(band4);
        } else {
            return applyRelief(tax.add(remaining.multiply(new BigDecimal("0.325"))));
        }

        // Band 5: 800,001+ @ 35%
        tax = tax.add(remaining.multiply(new BigDecimal("0.35")));
        return applyRelief(tax);
    }

    private static BigDecimal applyRelief(BigDecimal tax) {
        BigDecimal afterRelief = tax.subtract(PERSONAL_RELIEF);
        return afterRelief.compareTo(BigDecimal.ZERO) < 0
                ? BigDecimal.ZERO
                : afterRelief.setScale(2, RoundingMode.HALF_UP);
    }
}
