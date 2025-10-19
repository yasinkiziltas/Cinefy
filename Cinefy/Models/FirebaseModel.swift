//
//  FirebaseModel.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 16.10.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirebaseModel {
    private let db = Firestore.firestore()
    
    // MARK: - Create User Info
    func addUserData(userId: String, name: String, email: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "phone" : 0,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, completion: completion)
    }
    
    // MARK: - Read User Info
    func getUserData(userId: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
            db.collection("users").document(userId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    completion(data, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    
    // MARK: - Get User Name
    func getUserName(userId: String, completion: @escaping (String?, Error?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else if let snapshot = snapshot, snapshot.exists, let name = snapshot.data()?["name"] as? String {
                completion(name, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    // MARK: - Update User Info
       func updateUserData(userId: String, fields: [String: Any], completion: @escaping (Error?) -> Void) {
           db.collection("users").document(userId).updateData(fields, completion: completion)
       }
       
       // MARK: - Delete User Info
       func deleteUserData(userId: String, completion: @escaping (Error?) -> Void) {
           db.collection("users").document(userId).delete(completion: completion)
       }
}
