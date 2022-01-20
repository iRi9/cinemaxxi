//
//  ApiService.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import Foundation

enum MovieCategory: Int, CaseIterable {
    case nowplaying
    case toprated
    case popular
    case upcoming

    var display: String {
        switch self {
        case .nowplaying:
            return "Now Playing"
        case .toprated:
            return "Top Rated"
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        }
    }

    var path: String {
        switch self {
        case .nowplaying:
            return "now_playing"
        case .toprated:
            return "top_rated"
        case .popular:
            return "popular"
        case .upcoming:
            return "upcoming"
        }
    }
}

protocol HomeApiServiceProtocol {
    func fetchMovie(category: String, page: Int, complete: @escaping(_ status: Bool, _ movies: [Movie], _ error: ApiError?) -> Void)
}

class HomeApiService: HomeApiServiceProtocol {

    func fetchMovie(category: String, page: Int, complete: @escaping(_ status: Bool, _ movies: [Movie], _ error: ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/\(category)")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: Service.shared.apiKey),
            URLQueryItem(name: "language", value: Service.shared.language),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        let request = URLRequest(url: components.url!)

        Service.shared.call(request: request) { (result: Result<MovieResponse, ApiError>) in
            switch result {
            case .success(let data):
                complete(true, data.movies, nil)
            case .failure(let error):
                complete(false, [Movie](), error)
            }
        }
    }

}
