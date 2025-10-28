//
//  ProfileVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 13.08.2025.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //Ayarlar - gearshape
    var selectedItem: String?
    var menuNames = ["Profili Düzenle", "Yardım Merkezi", "Çıkış"]
    var menuImgs = ["person.crop.circle", "questionmark.circle", "arrow.backward.circle"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor.lightGray
        tableView.backgroundColor = UIColor.clear
        tableView.register(ProfileMenuTableViewCell.nib(), forCellReuseIdentifier: ProfileMenuTableViewCell.identifier)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        UIHelper.fetchUserInfo {
            DispatchQueue.main.async {
                self.txtName.text = UIHelper.currentName
                self.txtEmail.text = UIHelper.currentUserEmail
            }
        }
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuTableViewCell.identifier, for: indexPath) as! ProfileMenuTableViewCell
        cell.menuImg.image = UIImage(systemName: menuImgs[indexPath.row])
        cell.menuName.text = menuNames[indexPath.row]
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = menuNames[indexPath.row]
        
        switch selectedItem {
          case "Profili Düzenle":
            self.performSegue(withIdentifier: "toEditProfile", sender: nil)
        case "Yardım Merkezi":
            UIHelper.makeAlert(on: self, title: "Uyarı", message: "Bu sayfa geliştirme aşamasında..")
        case "Çıkış":
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "toLoginFromProfile", sender: nil)
            } catch {
                print("Hata!")
            }
        default:
            break
        }
    }
    
    //Gittiği sayfada geri butonunda "Geri" yazması için
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationItem.backBarButtonItem = backButton
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
