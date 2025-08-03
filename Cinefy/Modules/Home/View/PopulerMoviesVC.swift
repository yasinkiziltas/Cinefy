//
//  PopulerMoviesVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 2.08.2025.
//

import UIKit

class PopulerMoviesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [Movie] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backButtonTitle = "Geri"
        UIHelper.backgroundColorFunc(on: self)
        
        let nib = UINib(nibName: "AllPopularMoviesCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "AllPopularMoviesCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Kaydırırken goruntu bozulmasın diye
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
               layout.estimatedItemSize = .zero
        }
        
        MovieService.shared.fetchMoviesByPopularity { result in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movies = movies
                    self.collectionView.reloadData()
                    //print(self.movies)
                }
            case .failure(let error):
                print("Veri çekme hatası: \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllPopularMoviesCell", for: indexPath) as! AllPopularMoviesCell
        
        let movie = movies[indexPath.row]
        
        if let genreIDs = movie.genreIDs {
            let genreNames = genreIDs.compactMap { genreMap[$0] }
            let firstTwo = genreNames.prefix(2)
            cell.txtGenre.text = Array(firstTwo).joined(separator: ", ")
        }
        cell.txtTitle.text = movies[indexPath.row].title
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16      // sağ + sol boşluk
           let interItemSpacing: CGFloat = 10  // iki hücre arası boşluk
           let totalSpacing = padding + interItemSpacing
           let width = (collectionView.frame.width - totalSpacing) / 2
           return CGSize(width: width, height: width * 1.5) // afişler genelde dikdörtgendir
    }
    
    // sütunlar arası boşluk
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    // satırlar arası boşluk
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    //Kenar boşlukları
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 8, bottom: 20, right: 8)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToMovieDetailVC" {
             if let destinationVC = segue.destination as? DetailVC,
             let movie = sender as? Movie {
                 destinationVC.selectedMovie = movie
             }
                
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        performSegue(withIdentifier: "ToMovieDetailVC", sender: selectedMovie)
    }

}
