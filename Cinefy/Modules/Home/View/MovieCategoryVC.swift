//
//  MovieCategoryVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 25.07.2025.
//

import UIKit

class MovieCategoryVC: UIViewController {
    
    @IBOutlet weak var dataTable: UITableView!
    var selectedGenreId: Int?
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable.dataSource = self
        dataTable.delegate = self
        
        if let genreId = selectedGenreId {
            MovieService.shared.fetchMoviesByGenre(genreId: genreId) {result in
                switch result {
                case .success(let movies):
                    DispatchQueue.main.async {
                        self.movies = movies
                        self.dataTable.reloadData()
                    }
                case .failure(let error):
                    print("Hata: \(error)")
                }
            }
        }
    }
}

extension MovieCategoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //Kaç data var?
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Ne gösterilecek?
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Tıklayınca ne yapılacak?
        print("Tıkladın")
    }
}
