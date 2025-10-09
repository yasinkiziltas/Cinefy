//
//  RegisterVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 8.10.2025.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        if txtName.text != "" && txtEmail.text != "" && txtPassword.text != "" {
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { auth, error in
                if error != nil {
                    UIHelper.makeAlert(on: self, title: "Hata!", message: error?.localizedDescription ?? "")
                } else {
                    self.performSegue(withIdentifier: "toHomeFromRegister", sender: nil)
                }
            }
        } else {
            UIHelper.makeAlert(on: self, title: "Hata!", message: "Lütfen tüm alanları doldurun!")
        }
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        performSegue(withIdentifier: "toLoginFromRegister", sender: nil)
    }
}
