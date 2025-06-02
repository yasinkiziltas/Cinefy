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

}
