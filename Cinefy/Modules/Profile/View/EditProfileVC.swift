//
//  EditProfileVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 19.10.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileVC: UIViewController {
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "Geri"
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmisKeyboard))
        view.addGestureRecognizer(tap)
        getUserData()
    }
    
    func getUserData() {
        if let user = Auth.auth().currentUser {
            txtEmail.text = user.email
            db.collection("users").document(user.uid).getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    self.txtName.text = data["name"] as? String ?? ""
                    self.txtPhone.text = data["phone"] as? String ?? ""
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // View sadece bir kere yukarı kaydırılsın
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardFrame.height / 3
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // View eski konumuna dönsün
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dissmisKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func btnUpdate(_ sender: Any) {
           guard let user = Auth.auth().currentUser else { return }
           let newPhone = txtPhone.text ?? ""
           guard let newName = txtName.text, !newName.isEmpty,
                 let newEmail = txtEmail.text, !newEmail.isEmpty else {
               UIHelper.makeAlert(on: self, title: "Uyarı!", message: "Ad soyad ve email boş olamaz.")
               return
           }
               
        //MARK: - 1. Ad Soyad ve Telefon Firestore'da güncelleniyor
           let userRef = db.collection("users").document(user.uid)
           userRef.updateData([
               "name": newName,
               "phone": newPhone
           ]) { error in
               if let error = error {
                   UIHelper.makeAlert(on: self, title: "Hata!", message: error.localizedDescription)
                   return
               }
               print("Firestore kullanıcı bilgileri güncellendi.")
           }
           
           //MARK: - 2. Email Firebase Authentication’da güncelleniyor
           if user.email != newEmail {
               let actionCodeSettings = ActionCodeSettings()
               actionCodeSettings.handleCodeInApp = true
               actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
               actionCodeSettings.url = URL(string: "https://cinefy.page.link/email-update")

               user.sendEmailVerification(beforeUpdatingEmail: newEmail, actionCodeSettings: actionCodeSettings) { error in
                   if let error = error as NSError? {
                       if AuthErrorCode(rawValue: error.code) == .requiresRecentLogin {
                           UIHelper.makeAlert(on: self, title: "Uyarı!", message: "Lütfen yeniden giriş yaparak emailinizi güncelleyiniz.")
                           return
                       }
                       UIHelper.makeAlert(on: self, title: "Hata!", message: "E-posta güncelleme bağlantısı gönderilemedi: \(error.localizedDescription)")
                       return
                   }

                   UIHelper.makeAlert(on: self, title: "E-posta Gönderildi", message: "Yeni e-posta adresinize doğrulama linki gönderildi. Onayladıktan sonra uygulamayı yeniden açın.")
               }
           } else {
               UIHelper.makeAlert(on: self, title: "Başarılı!", message: "Profil başarıyla güncellendi!")
           }
       }
}
