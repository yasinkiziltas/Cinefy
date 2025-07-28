//
//  Movie.swift
//  Cinefy
//
//  Created by Yasin on 4.06.2025.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double?
    let genreIDs: [Int]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case genreIDs = "genre_ids"
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct MovieResponse: Codable {
    let results: [Movie]
}
