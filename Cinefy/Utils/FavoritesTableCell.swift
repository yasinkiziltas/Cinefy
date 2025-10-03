//
//  FavoritesTableCell.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 2.10.2025.
//

import UIKit

protocol FavoritesTableCellDelegate: AnyObject {
    func didTapDeleteButton(cell: FavoritesTableCell)
}

class FavoritesTableCell: UITableViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: FavoritesTableCellDelegate?

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.didTapDeleteButton(cell: self)
    }
    
}
