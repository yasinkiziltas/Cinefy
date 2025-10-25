//
//  MovieCategoryVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 25.07.2025.
//

import UIKit

class MovieCategoryVC: UIViewController {
    
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtSubTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedGenreId: Int?
    
    var movies: [Movie] = []
    var filterData : [Movie] = []
    var currentMovie: [Movie] {
        return searchBar.text?.isEmpty == false ? filterData : movies
    }
    
    let genreMap: [Int: String] = [
          28: "Aksiyon",
          12: "Macera",
          16: "Animasyon",
          35: "Komedi",
          80: "Suç",
          18: "Dram",
          14: "Fantastik",
          27: "Korku",
          10749: "Romantik",
          53: "Gerilim",
          10751: "Aile",
          878: "Bilim Kurgu"
      ]
    
    let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.backButtonTitle = "Geri"
        searchBar.delegate = self
        filterData = movies
        txtTitle.text = "Sonuçlar"
        txtSubTitle.text = "şu kategori için: " + (genreMap[selectedGenreId ?? 0] ?? "Kategori")
        
        //Searchbar yazı rengi
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
        }
        
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

        // İlgili kategorideki verileri çekme
        if let genreId = selectedGenreId {
            MovieService.shared.fetchMoviesByGenre(genreId: genreId) { result in
                switch result {
                case .success(let movies):
                    DispatchQueue.main.async {
                        self.movies = movies
                        self.filterData = movies
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

extension MovieCategoryVC: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMovie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        let movie = currentMovie[indexPath.row]
         
         // Cell ayarları
         cell.titleLabel?.text = movie.title
         cell.titleLabel?.textColor = .white
         cell.selectionStyle = .none
        
        //Tür
        if let genreIDs = movie.genreIDs {
            let genreNames = genreIDs.compactMap { genreMap[$0] }
            cell.movieType.text = genreNames.joined(separator: ", ")
        } else {
            cell.movieType.text = "Tür bilgisi yok"
        }
        
        //Resim
        let imageUrlString = "https://image.tmdb.org/t/p/w500\(movie.posterPath)"
           if let imageUrl = URL(string: imageUrlString) {
               URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                   if let data = data, let image = UIImage(data: data) {
                       DispatchQueue.main.async {
                           if let visibleCell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
                               visibleCell.iconImageView.image = image
                           }
                       }
                   }
               }.resume()
           }
        cell.backgroundColor = .clear // hücrenin arkası da koyu olsun
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCategoryFilms" {
             if let destinationVC = segue.destination as? DetailVC,
             let movie = sender as? Movie {
                 destinationVC.selectedMovie = movie
             }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = self.currentMovie[indexPath.row]
        performSegue(withIdentifier: "toCategoryFilms", sender: selectedMovie)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //SearchBar ayarları
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterData = movies
        } else {
            filterData = movies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        dataTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterData = movies
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        dataTable.reloadData()
    }

    //Kullanıcı “Search”e basınca klavyeyi kapatır
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

 
