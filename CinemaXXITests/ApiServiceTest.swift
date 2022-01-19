//
//  ApiServiceTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 19/01/22.
//

import XCTest
@testable import CinemaXXI

class ApiServiceTest: XCTestCase {

    var sut: ApiService?

    override func setUp() {
        super.setUp()
        sut = ApiService()
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

    func test_download_image() {
        let sut = self.sut!
        let imgUrl = URL(string: "https://image.tmdb.org/t/p/w185/aWeKITRFbbwY8txG5uCj4rMCfSP.jpg")!

        let expect = XCTestExpectation(description: "callback")

        sut.downloadImage(url: imgUrl) { data, error in
            expect.fulfill()

            XCTAssertNotNil(data)
        }
        wait(for: [expect], timeout: 3.1)
    }

}
