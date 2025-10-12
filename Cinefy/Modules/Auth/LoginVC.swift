//
//  LoginVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 8.10.2025.
//

import UIKit
import FirebaseAuth
import Lottie

class LoginVC: UIViewController {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    private var animationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.delegate = self
        txtPassword.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func showWaitingAnimation() {
        // Eski animasyon varsa kaldır
           animationView?.removeFromSuperview()
           animationView = LottieAnimationView(name: "waiting")
           animationView?.translatesAutoresizingMaskIntoConstraints = false
           animationView?.loopMode = .loop
           animationView?.contentMode = .scaleAspectFit
           animationView?.play()
        
        view.addSubview(animationView!)
        
        //Ortaya yerleştir - Auto Layout
        NSLayoutConstraint.activate([
            animationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView!.widthAnchor.constraint(equalToConstant: 100),
            animationView!.heightAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard let email = txtEmail.text, !email.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            UIHelper.makeAlert(on: self, title: "Hata", message: "Lütfen tüm alanları doldurun!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    var message = ""
                    switch errorCode {
                    
                    case.invalidEmail:
                        message = "Geçersiz e-posta!"
                    case .wrongPassword:
                        message = "Geçersiz parola!"
                    case .userNotFound:
                        message = "Bu e-posta ile hesap yok!"
                    case.networkError:
                        message = "Ağ bağlantınız yok!"
                    default:
                       message = "Bir hata meydana geldi!"
                    }
                    UIHelper.makeAlert(on: self, title: "Hata!", message: message)
                }
            }
            else {
                self.showWaitingAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    self.animationView?.stop()
                    self.animationView?.removeFromSuperview()
                    self.performSegue(withIdentifier: "toHomeFromLogin", sender: nil)
                }
            }
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        performSegue(withIdentifier: "toRegisterFromLogin", sender: nil)
    }
}


//Klavye kapatır
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
