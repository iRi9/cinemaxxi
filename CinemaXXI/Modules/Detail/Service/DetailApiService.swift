//
//  DetailApiService.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import Foundation

protocol DetailApiServiceProtocol {
    func fetchDetail(id: Int, complete: @escaping(_ status: Bool, _ detail: Movie?, _ error: ApiError?) -> Void)
    func fetchReview(id: Int, page: Int, complete: @escaping(_ status: Bool, _ review: [Review], _ error: ApiError?) -> Void)
}

class DetailApiService: DetailApiServiceProtocol {

    // MARK: - Fetch movie detail
    func fetchDetail(id: Int, complete: @escaping(_ status: Bool, _ detail: Movie?, _ error: ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/\(id)")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: Service.shared.apiKey),
            URLQueryItem(name: "language", value: Service.shared.language)
        ]

        let request = URLRequest(url: components.url!)

        Service.shared.call(request: request) { (result: Result<Movie, ApiError>) in
            switch result {
            case .success(let movie):
                complete(true, movie, nil)
            case .failure(let error):
                complete(false, nil, error)
            }
        }
    }

    // MARK: - Fetch review
    func fetchReview(id: Int, page: Int, complete: @escaping (Bool, [Review], ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/\(id)/reviews")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: Service.shared.apiKey),
            URLQueryItem(name: "language", value: Service.shared.language),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        let request = URLRequest(url: components.url!)

        Service.shared.call(request: request) { (result: Result<ReviewResponse, ApiError>) in
            switch result {
            case .success(let reviews):
                complete(true, reviews.reviews, nil)
            case .failure(let error):
                complete(false, [Review](), error)
            }
        }

    }
}
