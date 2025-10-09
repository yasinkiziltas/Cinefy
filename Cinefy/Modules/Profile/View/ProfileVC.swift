//
//  ProfileVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 13.08.2025.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toLoginFromProfile", sender: nil)
        } catch {
            print("Hata!")
        }
    }
}
