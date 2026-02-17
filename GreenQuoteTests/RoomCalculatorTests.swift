//
//  RoomCalculatorTests.swift
//  GreenQuoteTests
//

import XCTest
@testable import GreenQuote

final class RoomCalculatorTests: XCTestCase {

    // MARK: - Wall Area Tests

    func testWallAreaBasic() {
        // Test basic wall area calculation without ceiling
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 12,
            height: 8,
            finishCoats: 2,
            primerCoats: 1,
            paintCeiling: false
        )

        // Formula: (finishCoats + primerCoats) * 2 * height * (width + depth)
        // = (2 + 1) * 2 * 8 * (10 + 12)
        // = 3 * 2 * 8 * 22
        // = 1056
        XCTAssertEqual(area, 1056, "Wall area should be 1056 sq ft")
    }

    func testWallAreaWithCeiling() {
        // Test wall area calculation with ceiling
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 12,
            height: 8,
            finishCoats: 2,
            primerCoats: 1,
            paintCeiling: true
        )

        // Formula: (finishCoats + primerCoats) * [2 * height * (width + depth) + width * depth]
        // = 3 * [2 * 8 * 22 + 10 * 12]
        // = 3 * [352 + 120]
        // = 3 * 472
        // = 1416
        XCTAssertEqual(area, 1416, "Wall area with ceiling should be 1416 sq ft")
    }

    func testWallAreaZeroCoats() {
        // Test with zero coats
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 12,
            height: 8,
            finishCoats: 0,
            primerCoats: 0,
            paintCeiling: false
        )

        XCTAssertEqual(area, 0, "Wall area should be 0 when there are no coats")
    }

    func testWallAreaOnlyPrimer() {
        // Test with only primer coats
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 12,
            height: 8,
            finishCoats: 0,
            primerCoats: 2,
            paintCeiling: false
        )

        // = 2 * 2 * 8 * 22 = 704
        XCTAssertEqual(area, 704, "Wall area with only primer should be 704 sq ft")
    }

    func testWallAreaOnlyFinish() {
        // Test with only finish coats
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 12,
            height: 8,
            finishCoats: 3,
            primerCoats: 0,
            paintCeiling: false
        )

        // = 3 * 2 * 8 * 22 = 1056
        XCTAssertEqual(area, 1056, "Wall area with only finish should be 1056 sq ft")
    }

    func testWallAreaSmallRoom() {
        // Test with small room dimensions
        let area = RoomCalculator.wallArea(
            width: 5,
            depth: 6,
            height: 8,
            finishCoats: 1,
            primerCoats: 1,
            paintCeiling: false
        )

        // = 2 * 2 * 8 * 11 = 352
        XCTAssertEqual(area, 352, "Small room wall area should be 352 sq ft")
    }

    func testWallAreaLargeRoom() {
        // Test with large room dimensions
        let area = RoomCalculator.wallArea(
            width: 20,
            depth: 25,
            height: 10,
            finishCoats: 2,
            primerCoats: 1,
            paintCeiling: true
        )

        // = 3 * [2 * 10 * 45 + 20 * 25]
        // = 3 * [900 + 500]
        // = 3 * 1400
        // = 4200
        XCTAssertEqual(area, 4200, "Large room wall area should be 4200 sq ft")
    }

    // MARK: - Edge Cases

    func testWallAreaDecimalDimensions() {
        // Test with decimal dimensions
        let area = RoomCalculator.wallArea(
            width: 10.5,
            depth: 12.5,
            height: 8.5,
            finishCoats: 1,
            primerCoats: 1,
            paintCeiling: false
        )

        // = 2 * 2 * 8.5 * 23 = 782
        XCTAssertEqual(area, 782, "Wall area with decimal dimensions should be 782 sq ft")
    }

    func testWallAreaMaxCoats() {
        // Test with maximum coats (10 each)
        let area = RoomCalculator.wallArea(
            width: 10,
            depth: 10,
            height: 8,
            finishCoats: 10,
            primerCoats: 10,
            paintCeiling: false
        )

        // = 20 * 2 * 8 * 20 = 6400
        XCTAssertEqual(area, 6400, "Wall area with max coats should be 6400 sq ft")
    }

    // MARK: - Performance Tests

    func testWallAreaPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = RoomCalculator.wallArea(
                    width: 10,
                    depth: 12,
                    height: 8,
                    finishCoats: 2,
                    primerCoats: 1,
                    paintCeiling: true
                )
            }
        }
    }
}
