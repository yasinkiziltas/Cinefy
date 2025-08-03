//
//  AllPopularMoviesCell.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 3.08.2025.
//

import UIKit

class AllPopularMoviesCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtGenre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 15
        imgView.layer.masksToBounds = true
        
    }
    
    func configure(with movie: Movie) {
        if let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
