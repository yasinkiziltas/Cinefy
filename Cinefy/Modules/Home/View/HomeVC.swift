//
//  ViewController.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import UIKit
import Lottie
import HSCycleGalleryView

class HomeVC: UIViewController, HSCycleGalleryViewDelegate {

    @IBOutlet weak var pagerContainer: UIView!
    var movies: [Movie] = []
    let pager = HSCycleGalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
    
    let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = "Geri"

        
        // Arka plan ayarları
        view.backgroundColor = darkBackground
        pagerContainer.backgroundColor = darkBackground
        pager.backgroundColor = darkBackground
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = [.top, .bottom]

        // Navigation bar koyu renk
        navigationController?.navigationBar.barTintColor = darkBackground
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        // CollectionView arka planını da koyu yap
        if let collectionView = pager.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            collectionView.backgroundColor = darkBackground
        }
        
        // CollectionView arka plan rengini değiştir
        if let collectionView = pager.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            collectionView.backgroundColor = darkBackground
        }

        // ✅ PagerCell.xib'i kaydet (XIB dosyasının adı doğru olmalı)
        let nib = UINib(nibName: "PagerCell", bundle: nil)
        pager.register(nib: nib, forCellReuseIdentifier: "PagerCell")

        pager.delegate = self
        pagerContainer.addSubview(pager)
        
        MovieService.shared.fetchMovies { result in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movies = movies
                    self.pager.reloadData()
                    //print(movies)
                }
            case .failure(let error):
                print("Hata: \(error)")
            }
        }
    }

    //Görsel sayısı
    func numberOfItemInCycleGalleryView(_ cycleGalleryView: HSCycleGalleryView) -> Int {
        return movies.count
    }

    //Hücre oluşturma ve görsel atama
    func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, cellForItemAtIndex index: Int) -> UICollectionViewCell {
        guard let cell = cycleGalleryView.dequeueReusableCell(withIdentifier: "PagerCell", for: IndexPath(item: index, section: 0)) as? PagerCell else {
            return UICollectionViewCell()
        }

        let movie = movies[index]
        let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")

        //Basit image loader
        URLSession.shared.dataTask(with: imageUrl!) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }.resume()

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategory",
           let destination = segue.destination as? MovieCategoryVC,
           let genreId = sender as? Int {
            destination.selectedGenreId = genreId
        }
    }

    @IBAction func btnAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCategory", sender: 28)
    }
    
    @IBAction func btnHorror(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCategory", sender: 27)
    }
    @IBAction func btnComedy(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCategory", sender: 35)
    }
    @IBAction func btnRomance(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCategory", sender: 10749)
    }
    
}
