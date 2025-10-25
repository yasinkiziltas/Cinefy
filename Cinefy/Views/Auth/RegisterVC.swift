//
//  RegisterVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 8.10.2025.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Lottie

class RegisterVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    private var registerAnimationView: LottieAnimationView?
    
    let firebaseModel = FirebaseModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
        
        txtName.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    func showRegisterAnimation() {
        registerAnimationView?.removeFromSuperview()
        registerAnimationView = LottieAnimationView(name: "success")
        registerAnimationView?.translatesAutoresizingMaskIntoConstraints = false
        registerAnimationView?.loopMode = .loop
        registerAnimationView?.contentMode = .scaleAspectFit
        registerAnimationView?.play()
        
        view.addSubview(registerAnimationView!)
        
        NSLayoutConstraint.activate([
            registerAnimationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerAnimationView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            registerAnimationView!.widthAnchor.constraint(equalToConstant: 100),
            registerAnimationView!.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        if txtName.text != "" && txtEmail.text != "" && txtPassword.text != "" {
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { authResult, error in
                if let error = error as NSError? {
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        var message = ""
                        
                        switch errorCode {
                        case .emailAlreadyInUse:
                            message = "Bu e-posta adresi zaten kullanımda!"
                        case .invalidEmail:
                            message = "Geçersiz e-posta adresi!"
                        case .weakPassword:
                            message = "Şifre en az 6 karakter olmalı!"
                        case .networkError:
                            message = "Ağ bağlantınız yok!"
                        default:
                            message = error.localizedDescription
                        }
                        UIHelper.makeAlert(on: self, title: "Hata!", message: message)
                    }
                } else if let user = authResult?.user {
                    
                    self.firebaseModel.addUserData(
                        userId: user.uid,
                        name: self.txtName.text!,
                        email: self.txtEmail.text!) { error in
                            
                        if let error = error {
                            print("Firestore kayıt hatası: \(error.localizedDescription)")
                        } else {
                            print("Kullanıcı Firestore'a kaydedildi.")
                        }
                    }
                    
                    self.showRegisterAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.registerAnimationView?.stop()
                        self.registerAnimationView?.removeFromSuperview()
                        self.performSegue(withIdentifier: "toHomeFromRegister", sender: nil)
                    }
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

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
