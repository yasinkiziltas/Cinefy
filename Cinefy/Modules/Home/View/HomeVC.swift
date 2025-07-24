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

    let images = ["mov1", "mov2", "mov3"]
    let pager = HSCycleGalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()

        let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)

        view.backgroundColor = darkBackground
        pagerContainer.backgroundColor = darkBackground
        pager.backgroundColor = darkBackground

        // CollectionView arka plan rengini değiştir
        if let collectionView = pager.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            collectionView.backgroundColor = darkBackground
        }

        // ✅ PagerCell.xib'i kaydet (XIB dosyasının adı doğru olmalı)
        let nib = UINib(nibName: "PagerCell", bundle: nil)
        pager.register(nib: nib, forCellReuseIdentifier: "PagerCell")

        pager.delegate = self
        pagerContainer.addSubview(pager)
        pager.reloadData()
    }

    // ✅ Görsel sayısı
    func numberOfItemInCycleGalleryView(_ cycleGalleryView: HSCycleGalleryView) -> Int {
        return images.count
    }

    // ✅ Hücre oluşturma ve görsel atama
    func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, cellForItemAtIndex index: Int) -> UICollectionViewCell {
        guard let cell = cycleGalleryView.dequeueReusableCell(withIdentifier: "PagerCell", for: IndexPath(item: index, section: 0)) as? PagerCell else {
            fatalError("PagerCell could not be dequeued or casted.")
        }
        cell.imageView.image = UIImage(named: images[index])
        return cell
    }
    
    
    @IBAction func btnAction(_ sender: Any) {
        
    }
    
    @IBAction func btnHorror(_ sender: Any) {
        
    }
    @IBAction func btnComedy(_ sender: Any) {
        
    }
    @IBAction func btnRomance(_ sender: Any) {
        
    }
    
}
