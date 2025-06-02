//
//  ViewController.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import UIKit
import Lottie


class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let images = ["mov1", "mov2", "mov3"]
    var timer: Timer?
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(moveToNextSlide), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
   @objc func moveToNextSlide() {
        currentIndex += 1
        if currentIndex >= images.count {
            currentIndex = 0
        }
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = currentIndex
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageView = cell.contentView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.image = UIImage(named: images[indexPath.item])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        currentIndex = Int(pageIndex)
        pageControl.currentPage = currentIndex
    }
}


