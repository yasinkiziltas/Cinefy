//
//  UIHelper.swift
//  Cinefy
//
//  Created by Yasin on 2.06.2025.
//

import Foundation
import UIKit

class UIHelper {
    static func makeAlert(on controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    //Arkaplan renk ayarı
    static func backgroundColorFunc(on controller: UIViewController) {
        let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)
        controller.view.backgroundColor = darkBackground
        controller.extendedLayoutIncludesOpaqueBars = true
        controller.edgesForExtendedLayout = [.top, .bottom]
    }
    
    //Navbar rengi
    static func navBarFunc(on controller: UIViewController) {
        //let darkBackground = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)
        //controller.navigationController?.navigationBar.barTintColor = darkBackground
        //controller.navigationController?.navigationBar.isTranslucent = false
        //controller.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        controller.navigationController?.navigationBar.barTintColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1.0)
        controller.navigationController?.navigationBar.tintColor = .white
        controller.navigationController?.navigationBar.titleTextAttributes
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
