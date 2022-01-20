//
//  ApiServiceTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 19/01/22.
//

import XCTest
@testable import CinemaXXI

class HomeApiServiceTest: XCTestCase {

    var sut: HomeApiService?

    override func setUp() {
        super.setUp()
        sut = HomeApiService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_fetch_popular_movies() {
        let sut = self.sut!

        let expect = XCTestExpectation(description: "callback")

        sut.fetchMovie(category: "popular", page: 1) { status, movies, error in
            expect.fulfill()
            XCTAssertEqual(movies.count, 20)

            for movie in movies {
                XCTAssertNotNil(movie.id)
            }
        }
        wait(for: [expect], timeout: 3.1)
    }

}
