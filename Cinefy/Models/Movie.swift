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
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}
