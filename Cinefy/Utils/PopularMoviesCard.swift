//
//  PopularMoviesCard.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 2.08.2025.
//

import UIKit

class PopularMoviesCard: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
    
    func configure(with movie: Movie) {
           if let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)") {
               URLSession.shared.dataTask(with: url) { data, _, _ in
                   if let data = data {
                       DispatchQueue.main.async {
                           self.imageView.image = UIImage(data: data)
                       }
                   }
               }.resume()
           }
       }
}
