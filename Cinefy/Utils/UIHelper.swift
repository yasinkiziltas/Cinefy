//
//  UIHelper.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

class UIHelper {
    
    static var currentUserName: String = ""
    static var currentName: String = ""
    static var currentUserEmail: String = ""
    
    //Kullanıcı bilgilerini çekme
    static func fetchUserInfo(completion: @escaping () -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı giriş yapmadı.")
            return
        }
        
        self.currentUserEmail = currentUser.email ?? "Email yok"
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Kullanıcı verisi bulunamadı\(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.currentName = data?["name"] as? String ?? "Ad yok"
                self.currentUserName = data?["username"] as? String ?? "Kullanıcı Adı yok"
                completion()
            }
            else {
                print("Sistemde kullanıcı yok")
            }
        }
    }
    
    //Alert
    static func makeAlert(on controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    //Onaylama Alert
    static func makeConfirmAlert(on controller: UIViewController, title: String, message: String, confirmHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction (
            title: "Sil",
            style: .destructive,
            handler: { _ in
                confirmHandler?()
            }
        ))
        alert.addAction(UIAlertAction (
            title: "İptal",
            style: .cancel,
            handler: nil
        ))
        
        controller.present(alert,
                animated: true,
                completion: nil
        )
    }
    
    //Arkaplan renk ayarı
    static func backgroundColorFunc(on controller: UIViewController) {
        let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)
        controller.view.backgroundColor = darkBackground
        controller.extendedLayoutIncludesOpaqueBars = true
        controller.edgesForExtendedLayout = [.top, .bottom]
    }
    
    static func navBarColorFunc(on controller: UIViewController) {
        let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)
         controller.view.backgroundColor = darkColor

           // iOS 15+ navigation bar appearance
           let appearance = UINavigationBarAppearance()
           appearance.configureWithOpaqueBackground()
           appearance.backgroundColor = darkColor
           appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        controller.navigationController?.navigationBar.standardAppearance = appearance
        controller.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        controller.navigationController?.navigationBar.tintColor = .white // back ok/üç çizgi rengi vs.
    }
    
    static func setButtonTitle(_ button: UIButton, title: String, fontSize: CGFloat = 12.0, fontName: String = "Helvetica Neue") {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white // veya istediğin renk
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
    }

}
