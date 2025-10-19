//
//  ProfileMenuTableViewCell.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 19.10.2025.
//

import UIKit

class ProfileMenuTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileMenuTableViewCell"
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuImg: UIImageView!
    
    //.xib dosyası yüklendikten sonra ilk çalıştırılan metot
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    //TableView’de bu hücreyi kullanmadan önce .xib dosyası olarak kaydetmek için kullanılır
    static func nib() -> UINib {
        return UINib(nibName: "ProfileMenuTableViewCell", bundle: nil)
    }

    //Hücre seçildiğinde çağrılır
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
