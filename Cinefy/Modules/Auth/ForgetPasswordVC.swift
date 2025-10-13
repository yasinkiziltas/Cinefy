//
//  ForgetPasswordVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 13.10.2025.
//

import UIKit
import FirebaseAuth

class ForgetPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnResetPass(_ sender: Any) {
        if txtEmail.text != "" {
            Auth.auth().sendPasswordReset(withEmail: txtEmail.text!) { (error) in
                if let error = error as NSError? {
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        var message = ""
                        
                        switch errorCode {
                        case .invalidEmail:
                            message = "Geçersiz email!"
                        case .networkError:
                            message = "Bağlantınız yok!"
                        case .userNotFound:
                            message = "Bu e-posta adresine ait bir kullanıcı bulunmamaktadır!"
                        default:
                            message = "Error"
                        }
                        UIHelper.makeAlert(on: self, title: "Hata!", message: message)
                    }
                } else {
                    UIHelper.makeAlert(
                        on: self,
                        title: "Başarılı!",
                        message: "Lütfen e-posta adresinize gönderilen linke gidip yeni parola oluşturun!"
                    )
                }
            }
        } else {
            UIHelper.makeAlert(on: self, title: "Hata!", message: "Lütfen mail giriniz!")
        }
    }
}
