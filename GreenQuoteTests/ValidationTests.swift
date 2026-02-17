//
//  ValidationTests.swift
//  GreenQuoteTests
//

import XCTest
@testable import GreenQuote

final class ValidationTests: XCTestCase {

    // MARK: - Room Validation Tests

    func testValidRoom() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 12,
            width: 10,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.isEmpty, "Valid room should have no validation errors")
    }

    func testEmptyName() {
        let errors = Validation.validateRoom(
            name: "",
            length: 12,
            width: 10,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.emptyName), "Empty name should produce validation error")
        XCTAssertEqual(errors.count, 1, "Should have exactly one validation error")
    }

    func testWhitespaceName() {
        let errors = Validation.validateRoom(
            name: "   ",
            length: 12,
            width: 10,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.emptyName), "Whitespace-only name should produce validation error")
    }

    func testInvalidLength() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 0,
            width: 10,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.invalidLength), "Zero length should produce validation error")
    }

    func testNegativeLength() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: -5,
            width: 10,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.invalidLength), "Negative length should produce validation error")
    }

    func testInvalidWidth() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 12,
            width: 0,
            height: 8,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.invalidWidth), "Zero width should produce validation error")
    }

    func testInvalidHeight() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 12,
            width: 10,
            height: 0,
            unitPrice: 5.50
        )

        XCTAssertTrue(errors.contains(.invalidHeight), "Zero height should produce validation error")
    }

    func testNegativeUnitPrice() {
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 12,
            width: 10,
            height: 8,
            unitPrice: -5
        )

        XCTAssertTrue(errors.contains(.invalidUnitPrice), "Negative unit price should produce validation error")
    }

    func testZeroUnitPrice() {
        // Zero unit price should be valid
        let errors = Validation.validateRoom(
            name: "Living Room",
            length: 12,
            width: 10,
            height: 8,
            unitPrice: 0
        )

        XCTAssertFalse(errors.contains(.invalidUnitPrice), "Zero unit price should be valid")
    }

    func testMultipleErrors() {
        let errors = Validation.validateRoom(
            name: "",
            length: 0,
            width: -5,
            height: 0,
            unitPrice: -10
        )

        XCTAssertEqual(errors.count, 5, "Should have 5 validation errors")
        XCTAssertTrue(errors.contains(.emptyName))
        XCTAssertTrue(errors.contains(.invalidLength))
        XCTAssertTrue(errors.contains(.invalidWidth))
        XCTAssertTrue(errors.contains(.invalidHeight))
        XCTAssertTrue(errors.contains(.invalidUnitPrice))
    }

    // MARK: - Email Validation Tests

    func testValidEmail() {
        XCTAssertTrue(Validation.isValidEmail("user@example.com"), "Valid email should pass")
        XCTAssertTrue(Validation.isValidEmail("test.user@domain.co.uk"), "Valid email with subdomain should pass")
        XCTAssertTrue(Validation.isValidEmail("user+tag@example.com"), "Valid email with + should pass")
    }

    func testInvalidEmail() {
        XCTAssertFalse(Validation.isValidEmail(""), "Empty string should fail")
        XCTAssertFalse(Validation.isValidEmail("notanemail"), "String without @ should fail")
        XCTAssertFalse(Validation.isValidEmail("@example.com"), "Email without username should fail")
        XCTAssertFalse(Validation.isValidEmail("user@"), "Email without domain should fail")
        XCTAssertFalse(Validation.isValidEmail("user@domain"), "Email without TLD should fail")
    }

    // MARK: - Room Dimensions Tests

    func testPositiveDimensions() {
        XCTAssertTrue(Validation.roomDimensionsPositive(length: 12, width: 10, height: 8),
                     "All positive dimensions should return true")
    }

    func testZeroDimension() {
        XCTAssertFalse(Validation.roomDimensionsPositive(length: 0, width: 10, height: 8),
                      "Zero length should return false")
        XCTAssertFalse(Validation.roomDimensionsPositive(length: 12, width: 0, height: 8),
                      "Zero width should return false")
        XCTAssertFalse(Validation.roomDimensionsPositive(length: 12, width: 10, height: 0),
                      "Zero height should return false")
    }

    func testNegativeDimension() {
        XCTAssertFalse(Validation.roomDimensionsPositive(length: -5, width: 10, height: 8),
                      "Negative length should return false")
        XCTAssertFalse(Validation.roomDimensionsPositive(length: 12, width: -3, height: 8),
                      "Negative width should return false")
        XCTAssertFalse(Validation.roomDimensionsPositive(length: 12, width: 10, height: -2),
                      "Negative height should return false")
    }

    // MARK: - ValidationError Description Tests

    func testErrorDescriptions() {
        XCTAssertEqual(ValidationError.emptyName.errorDescription, "Room name is required")
        XCTAssertEqual(ValidationError.invalidLength.errorDescription, "Length must be greater than 0")
        XCTAssertEqual(ValidationError.invalidWidth.errorDescription, "Width must be greater than 0")
        XCTAssertEqual(ValidationError.invalidHeight.errorDescription, "Height must be greater than 0")
        XCTAssertEqual(ValidationError.invalidUnitPrice.errorDescription, "Unit price must be greater than or equal to 0")
    }
}
