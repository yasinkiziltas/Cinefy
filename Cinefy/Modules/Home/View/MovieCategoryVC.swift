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
    
    // DARK RENK (Global sabit gibi)
    let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safe Area dışı alanlar da dahil tüm view boyanır
        self.view.backgroundColor = darkColor
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = [.top, .bottom]

        // TableView ayarları
        dataTable.dataSource = self
        dataTable.delegate = self
        dataTable.backgroundColor = darkColor
        dataTable.tableFooterView = UIView()
        
        // Navigation bar rengi (eğer varsa)
        navigationController?.navigationBar.barTintColor = darkColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Tab bar arka planını da koyu yap
        tabBarController?.tabBar.barTintColor = darkColor
        tabBarController?.tabBar.backgroundColor = darkColor
        tabBarController?.tabBar.isTranslucent = false

        // Veri çekme
        if let genreId = selectedGenreId {
            MovieService.shared.fetchMoviesByGenre(genreId: genreId) { result in
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

    // Üst saat, pil gibi şeylerin açık görünmesi için (beyaz yapar)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MovieCategoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row].title
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear // hücrenin arkası da koyu olsun
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tıkladın")
    }
}
