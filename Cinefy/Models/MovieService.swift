//
//  MovieService.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 25.07.2025.
//

import Foundation

class MovieService {
    static let shared = MovieService()
    private init() {}

    //Tüm filmler
    func fetchMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let apiKey = "467c8591acfe223ce74b01442fde7853"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Yanlış URL", code: 400)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Data yok", code: 400)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //Kategoriye göre film
    func fetchMoviesByGenre(genreId: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let apiKey = "467c8591acfe223ce74b01442fde7853"
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&with_genres=\(genreId)&language=en-US&page=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Yanlış URL", code: 400)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Data yok", code: 400)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
