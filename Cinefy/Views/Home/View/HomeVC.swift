//
//  ViewController.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import UIKit
import Lottie
import HSCycleGalleryView
import FirebaseAuth
import FirebaseFirestore


class HomeVC: UIViewController, HSCycleGalleryViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var pagerContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtName: UILabel!
    
    var movies: [Movie] = []
    var populerMovies: [Movie] = []
    
    let pager = HSCycleGalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
    let firebaseModel = FirebaseModel()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = "Geri"
        
        // Arka plan ayarları
        UIHelper.backgroundColorFunc(on: self)

        // Navbar ayarları
        UIHelper.navBarColorFunc(on: self)

        // CollectionView arka plan
        let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)
        if let collectionView = pager.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            collectionView.backgroundColor = darkBackground
        }

        //Nib ayarlama (.xib çağırma)
        let nib = UINib(nibName: "PagerCell", bundle: nil)
        pager.register(nib: nib, forCellReuseIdentifier: "PagerCell")
        pager.delegate = self
        pagerContainer.addSubview(pager)
        
        let nibPopular = UINib(nibName: "PopularMoviesCard", bundle: nil)
        collectionView.register(nibPopular, forCellWithReuseIdentifier: "PopularMoviesCard")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getMovies()
        
    }
    
    //Random filmler
    func getMovies() {
        MovieService.shared.fetchRandomMovies { result in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movies = movies
                    self.pager.reloadData()
                }
            case .failure(let error):
                print("Hata: \(error)")
            }
        }
        
        MovieService.shared.fetchSomeMoviesByPopularity { result in
            switch result {
            case .success(let populerMovies):
                DispatchQueue.main.async {
                    self.populerMovies = populerMovies
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Hata: \(error)")
            }
        }
    }
 
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        firebaseModel.getUserName(userId: userId) { name ,error in
            if let error = error {
                print("Ad alınamadı: \(error.localizedDescription)")
            } else if let name = name {
                self.txtName.text = name
            }
        }
    }

    //Rastgele filmler kısmı
    func numberOfItemInCycleGalleryView(_ cycleGalleryView: HSCycleGalleryView) -> Int {
        return movies.count
    }

    func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, cellForItemAtIndex index: Int) -> UICollectionViewCell {
        guard let cell = cycleGalleryView.dequeueReusableCell(withIdentifier: "PagerCell", for: IndexPath(item: index, section: 0)) as? PagerCell else {
            return UICollectionViewCell()
        }

        let movie = movies[index]
        let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")

        URLSession.shared.dataTask(with: imageUrl!) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }.resume()

        return cell
    }
    
    //Tıklanınca
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategory",
           let destination = segue.destination as? MovieCategoryVC,
           let genreId = sender as? Int {
            destination.selectedGenreId = genreId
            
        } else if segue.identifier == "toDetailFromHome",
                  let destinationPopuler = segue.destination as? DetailVC,
                  let movie = sender as? Movie  {
                  destinationPopuler.selectedMovie = movie
        }
    }
    
    //Kategori butonları
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
    
    //Populer filmler kısmı
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return populerMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularMoviesCard", for: indexPath) as! PopularMoviesCard
              cell.configure(with: populerMovies[indexPath.row])
              return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = populerMovies[indexPath.row]
        performSegue(withIdentifier: "toDetailFromHome", sender: selectedMovie)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    @IBAction func btnAllPopularMovies(_ sender: Any) {
        self.performSegue(withIdentifier: "toAllPopularMovies", sender: nil)
    }
}
