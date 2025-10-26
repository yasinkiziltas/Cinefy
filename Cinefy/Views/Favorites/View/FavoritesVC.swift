//
//  ViewController.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import UIKit
import Lottie
import FirebaseCore
import FirebaseAuth


class FavoritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let firebaseModel = FirebaseModel()
    var favorites = [Movie]()
    let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId = Auth.auth().currentUser?.uid
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = darkColor
        view.backgroundColor = darkColor
        
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        emptyLabel.text = "Henüz favori yok.."
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        tableView.backgroundView = emptyLabel
        tableView.backgroundView?.isHidden = true
        
        
        fetchMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMovies()
        updateEmptyState()
        
        if let tabBar = tabBarController?.tabBar {
                tabBar.isTranslucent = false
                tabBar.backgroundImage = UIImage()
                tabBar.shadowImage = UIImage()
                tabBar.barTintColor = darkColor // veya darkColor, hangisi senin temana uyuyorsa
                tabBar.backgroundColor = darkColor
            }
    }
    
    func updateEmptyState() {
        if favorites.isEmpty {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        }
    }
    
    func fetchMovies() {
       
        firebaseModel.getFavorites(for: userId ?? "") {[weak self] movies in
            self?.favorites = movies
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableCell
        let movie = favorites[indexPath.row]
       
        let fullPath = "https://image.tmdb.org/t/p/w500" + movie.posterPath
        if let url = URL(string: fullPath) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.movieImageView.image = image
                    }
                }
            }.resume()
        } else {
            cell.movieImageView.image = UIImage(named: "placeholder")
        }
        
        cell.movieTitleLabel.text = movie.title
        cell.movieTitleLabel.textColor = .white
        cell.selectionStyle = .none
        cell.backgroundColor = darkColor
        //cell.delegate = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVCFromFavorites" {
            if let destinationVC = segue.destination as? DetailVC,
               let movie = sender as? Movie {
                destinationVC.selectedMovie = movie
                destinationVC.isFromFavorites = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = self.favorites[indexPath.row]

        let movie = Movie(
            id: 0,
            title: selectedMovie.title,
            overview: selectedMovie.overview,
            posterPath: selectedMovie.posterPath,
            releaseDate: selectedMovie.releaseDate ?? "",
            runtime: Int(selectedMovie.runtime ?? 0),
            voteAverage: selectedMovie.voteAverage ?? 0,
            genreIDs: [],
            adult: selectedMovie.adult ?? false
        )
        performSegue(withIdentifier: "toDetailVCFromFavorites", sender: movie)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UIHelper.makeConfirmAlert(on: self, title: "Uyarı", message: "Silmek istediğinize emin misiniz?") {
                let movieToDelete = self.favorites[indexPath.row]
                
                self.firebaseModel.deleteFromFavorites(userId: self.userId ?? "", movieId: movieToDelete.id) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.favorites.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.updateEmptyState()
                            print("Favoriden silindi ✅")
                        }
                    } else {
                        print("❌ Silme başarısız")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Kaldır"
    }
    
//    func didTapDeleteButton(cell: FavoritesTableCell) {
//        if let indexPath = tableView.indexPath(for: cell) {
//            let movieToDelete = favorites[indexPath.row]
//            firebaseModel.deleteFromFavorites(userId: userId ?? "", movieId: movieToDelete.id) { succes in
//                if succes {
//                    print("Silindi")
//                }
//            }
//            favorites.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
