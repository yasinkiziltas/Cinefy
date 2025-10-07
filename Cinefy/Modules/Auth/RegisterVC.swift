//
//  RegisterVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 8.10.2025.
//

import UIKit

class RegisterVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        performSegue(withIdentifier: "toLoginFromRegister", sender: nil)
    }
}
