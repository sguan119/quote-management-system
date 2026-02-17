//
//  FormattingTests.swift
//  GreenQuoteTests
//
//  OQ-D11 fix: Tests for configurable special labour rate

import XCTest
@testable import GreenQuote

final class FormattingTests: XCTestCase {

    // MARK: - Currency Formatting Tests

    func testCurrencyFormattingPositive() {
        let result = Formatting.currency(1234.56)
        // Should format as currency with 2 decimal places
        XCTAssertTrue(result.contains("1,234.56") || result.contains("1234.56"),
                     "Currency should format correctly: \(result)")
    }

    func testCurrencyFormattingZero() {
        let result = Formatting.currency(0)
        XCTAssertTrue(result.contains("0.00") || result.contains("0"),
                     "Zero should format as $0.00: \(result)")
    }

    func testCurrencyFormattingNegative() {
        let result = Formatting.currency(-500.00)
        XCTAssertTrue(result.contains("500.00"),
                     "Negative currency should format correctly: \(result)")
    }

    func testCurrencyFormattingLargeNumber() {
        let result = Formatting.currency(1000000.00)
        XCTAssertTrue(result.contains("1,000,000.00") || result.contains("1000000.00"),
                     "Large currency should format correctly: \(result)")
    }

    // MARK: - Area Formatting Tests

    func testAreaFormatting() {
        let result = Formatting.areaWithUnit(1500.0)
        XCTAssertTrue(result.contains("1,500") || result.contains("1500"),
                     "Area should format correctly: \(result)")
        XCTAssertTrue(result.lowercased().contains("ft"),
                     "Area should include ft² unit: \(result)")
    }

    func testAreaFormattingZero() {
        let result = Formatting.areaWithUnit(0)
        XCTAssertTrue(result.contains("0"),
                     "Zero area should format correctly: \(result)")
    }

    // MARK: - Dimensions Formatting Tests

    func testDimensionsFormatting() {
        let result = Formatting.dimensions(length: 12.0, width: 10.0, height: 8.0)
        XCTAssertTrue(result.contains("12"),
                     "Dimensions should include length: \(result)")
        XCTAssertTrue(result.contains("10"),
                     "Dimensions should include width: \(result)")
        XCTAssertTrue(result.contains("8"),
                     "Dimensions should include height: \(result)")
    }

    func testDimensionsFormattingWithDecimals() {
        let result = Formatting.dimensions(length: 12.5, width: 10.5, height: 8.5)
        XCTAssertTrue(result.contains("12"),
                     "Dimensions should handle decimals: \(result)")
    }

    // MARK: - Decimal Conversion Tests

    func testDoubleFromDecimal() {
        let decimal: Decimal = 123.456
        let result = Formatting.double(from: decimal)
        XCTAssertEqual(result, 123.456, accuracy: 0.001,
                      "Double conversion should be accurate")
    }

    func testDoubleFromDecimalZero() {
        let decimal: Decimal = 0
        let result = Formatting.double(from: decimal)
        XCTAssertEqual(result, 0.0, accuracy: 0.001,
                      "Zero decimal should convert to 0.0")
    }

    func testDoubleFromDecimalNegative() {
        let decimal: Decimal = -500.25
        let result = Formatting.double(from: decimal)
        XCTAssertEqual(result, -500.25, accuracy: 0.001,
                      "Negative decimal should convert correctly")
    }

    // MARK: - Price Calculation Tests (OQ-D11 fix)

    func testDefaultSpecialLabourRate() {
        // Verify the default special labour rate is 65 CAD/hr
        XCTAssertEqual(Formatting.defaultSpecialLabourCadPerHour, 65,
                      "Default special labour rate should be 65 CAD/hr")
    }

    // MARK: - Performance Tests

    func testCurrencyFormattingPerformance() {
        measure {
            for i in 0..<1000 {
                _ = Formatting.currency(Decimal(i) * 1.5)
            }
        }
    }

    func testAreaFormattingPerformance() {
        measure {
            for i in 0..<1000 {
                _ = Formatting.areaWithUnit(Double(i) * 10)
            }
        }
    }
}
