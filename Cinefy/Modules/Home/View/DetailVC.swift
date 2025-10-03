//
//  DetailVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 4.08.2025.
//

import UIKit

class DetailVC: UIViewController {

    var selectedMovie: Movie?
    var isFromFavorites: Bool = false
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtGenre: UILabel!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var txtAge: UIButton!
    @IBOutlet weak var txtYear: UIButton!
    @IBOutlet weak var txtStar: UIButton!
    @IBOutlet weak var txtTime: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromFavorites {
            btnFav.isHidden = true
        }
        
        movieImg.contentMode = .scaleAspectFit
        movieImg.clipsToBounds = true
        movieImg.layer.contentsRect = CGRect(x: 0, y: 0.1, width: 1, height: 0.9)
        
        //Navbar ayarı
        UIHelper.navBarColorFunc(on: self)
        
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
        
        if let genreIDs = selectedMovie?.genreIDs {
            let genreNames = genreIDs.compactMap { genreMap[$0] }
            let firstTwo = genreNames.prefix(2)
            txtGenre.text = Array(firstTwo).joined(separator: ", ")
        }
        
        if let movie = selectedMovie {
            let fullTitle = movie.title
            let shortTitle = fullTitle.count > 30 ? String(fullTitle.prefix(20)) + "..." : fullTitle
            
            txtTitle.text = shortTitle
            txtView.text = movie.overview
            
            UIHelper.setButtonTitle(txtAge, title: movie.adult == true ? "18+" : "16+")
            UIHelper.setButtonTitle(txtYear, title: movie.releaseDate?.split(separator: "-").first.map { String($0) } ?? "")
            UIHelper.setButtonTitle(txtStar, title: "⭐ \(String(format: "%.1f", movie.voteAverage ?? 0.0))")
            UIHelper.setButtonTitle(txtTime, title: "🕒 Bilinmiyor")
            
            MovieService.shared.fetchMovieDetail(movieId: selectedMovie?.id ?? 0) { result in
                DispatchQueue.main.async {
                        switch result {
                        case .success(let detailMovie):
                            if let runtime = detailMovie.runtime {
                                let hours = runtime / 60
                                let minutes = runtime % 60
                                let runtimeText = hours > 0 ? "\(hours)s \(minutes)dk" : "\(minutes)dk"
                                UIHelper.setButtonTitle(self.txtTime, title: "🕒 \(runtimeText)")
                            }
                        case .failure(let error):
                            print("Hata: \(error.localizedDescription)")
                        }
                    }
            }
            
            let buttons = [txtAge, txtYear, txtStar, txtTime]
                buttons.forEach {
                    $0?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                }
            
            let imageUrlString = "https://image.tmdb.org/t/p/w500\(movie.posterPath)"
            if let url = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.movieImg.image = image
                        }
                    }
                }.resume()
            }
        }

    }
    
    @IBAction func addFavorite(_ sender: Any) {
        guard let movie = selectedMovie else { return }
        CoreDataManager.shared.addFavorite(movie: movie, from: self)
    }
}
