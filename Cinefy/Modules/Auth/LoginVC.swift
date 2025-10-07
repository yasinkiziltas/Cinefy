//
//  LoginVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 8.10.2025.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromLogin", sender: nil)
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        performSegue(withIdentifier: "toRegisterFromLogin", sender: nil)
    }
}
