package com.sgms.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class DatabaseUtilTest {

    @Test
    void firstNonBlankPrefersFirstValue() {
        assertEquals("env", DatabaseUtil.firstNonBlank("env", "file"));
    }

    @Test
    void firstNonBlankFallsBackWhenFirstIsNullOrBlank() {
        assertEquals("file", DatabaseUtil.firstNonBlank(null, "file"));
        assertEquals("file", DatabaseUtil.firstNonBlank("   ", "file"));
    }
}
