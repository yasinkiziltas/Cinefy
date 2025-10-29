//
//  cell.swift
//  Cinefy
//
//  Created by Yasin on 3.06.2025.
//

import UIKit

class PagerCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
        
    }
}
