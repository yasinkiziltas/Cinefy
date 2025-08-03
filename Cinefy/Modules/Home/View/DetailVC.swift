//
//  DetailVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 4.08.2025.
//

import UIKit

class DetailVC: UIViewController {

    var selectedMovie: Movie?
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtGenre: UILabel!
    @IBOutlet weak var txtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieImg.contentMode = .scaleAspectFit
        movieImg.clipsToBounds = true
        movieImg.layer.contentsRect = CGRect(x: 0, y: 0.1, width: 1, height: 0.9)
        
        txtTitle.adjustsFontSizeToFitWidth = true
        txtTitle.minimumScaleFactor = 0.7
        
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
            txtTitle.text = movie.title
            txtView.text = movie.overview
            
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
}
