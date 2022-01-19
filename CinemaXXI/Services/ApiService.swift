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

enum ApiError: String, Error {
    case invalidApiKey = "Invalid API key: You must be granted a valid key"
    case invalidService = "Invalid service: this service does not exist"
    case noData = "Data not found"
    case failDecodeResponse = "Failed decode JSON"
}

protocol ApiServiceProtocol {
    func fetchMovie(category: String, page: Int, complete: @escaping(_ status: Bool, _ movies: [Movie], _ error: ApiError?) -> Void)
}

class ApiService: ApiServiceProtocol {

    let apiKey = "05621d21b45aa5eec80623c7135c38f3"
    let language = "en-US"
    let page = "1"

    func fetchMovie(category: String, page: Int, complete: @escaping(_ status: Bool, _ movies: [Movie], _ error: ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/\(category)")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        let request = URLRequest(url: components.url!)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                complete(false, [Movie](), .invalidService)
                return
            }

            guard let data = data else {
                complete(false, [Movie](), .noData)
                return
            }

            do {
                let dataObject = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(true, dataObject.movies, nil)
                }
            } catch {
                complete(false, [Movie](), .failDecodeResponse)
            }
        }
        task.resume()
    }

    // MARK: - Image downloader
    func downloadImage(url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }

            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                completion(data, nil)
            }
        }.resume()
    }

}
