//
//  DetailApiServiceTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 20/01/22.
//

import XCTest
@testable import CinemaXXI

class DetailApiServiceTest: XCTestCase {
    var sut: DetailApiService?

    override func setUp() {
        super.setUp()
        sut = DetailApiService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_fetch_detail() {
        let sut = self.sut!

        let expect = XCTestExpectation(description: "callback")

        sut.fetchDetail(id: 524434) { status, detail, error in
            expect.fulfill()
            XCTAssertEqual(detail?.id, 524434)
        }
        wait(for: [expect], timeout: 3.1)
    }

    func test_fetch_reviews() {
        let sut = self.sut!

        let expect = XCTestExpectation(description: "callback")

        sut.fetchReview(id: 524434, page: 1) { status, reviews, error in
            expect.fulfill()
            XCTAssertTrue(reviews.count > 1)
        }

        wait(for: [expect], timeout: 3.1)
    }
}
