//
//  ServiceTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 20/01/22.
//

import XCTest
@testable import CinemaXXI

class ServiceTest: XCTestCase {
    var sut: Service?

    override func setUp() {
        super.setUp()
        sut = Service.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_call() {

        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/popular")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: "05621d21b45aa5eec80623c7135c38f3"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]

        let request = URLRequest(url: components.url!)

        let expect = XCTestExpectation(description: "callback")

        sut?.call(request: request) { (result: Result<MovieResponse, ApiError>) in
            expect.fulfill()

            switch result {
            case .failure( _):
                break
            case .success(let movies):
                XCTAssertNotNil(movies)
            }
        }
        wait(for: [expect], timeout: 3.1)
    }

}
