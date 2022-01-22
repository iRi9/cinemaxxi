//
//  Review.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import Foundation

struct ReviewResponse: Decodable {
    let id, page: Int
    let reviews: [Review]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case id, page
        case reviews = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Review
struct Review: Decodable {
    let content, createdAt, id: String
    let author: String?

    enum CodingKeys: String, CodingKey {
        case content
        case createdAt = "created_at"
        case id, author
    }
}
