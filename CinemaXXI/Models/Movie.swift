//
//  Movie.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let posterPath: String
    let title: String
    let overview: String
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
        case overview
        case releaseDate = "release_date"
    }
}

struct MovieResponse: Decodable {
    let page: Int
    let totalResults: Int
    let totalPages: Int

    let movies: [Movie]

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case movies = "results"
    }
}
