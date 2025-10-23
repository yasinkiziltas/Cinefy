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
    let db = Firestore.firestore()
    
    // MARK: - Kullanıcı İşlemleri
    func addUserData(userId: String, name: String, email: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "phone" : 0,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, completion: completion)
    }
    
    func getUserData(userId: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
            db.collection("users").document(userId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    completion(data, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    
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
    
       func updateUserData(userId: String, fields: [String: Any], completion: @escaping (Error?) -> Void) {
           db.collection("users").document(userId).updateData(fields, completion: completion)
       }
       
       func deleteUserData(userId: String, completion: @escaping (Error?) -> Void) {
           db.collection("users").document(userId).delete(completion: completion)
       }
    
    //MARK: - Favoriler
    func getFavorites(for userId: String, completion: @escaping ([Movie]) -> Void) {
        db.collection("users")
          .document(userId)
          .collection("favorites")
          .getDocuments { snapshot, error in
              if let error = error {
                  print("Favoriler alınamadı: \(error.localizedDescription)")
                  completion([])
                  return
              }
              
              var movies: [Movie] = []
              for doc in snapshot?.documents ?? [] {
                  let data = doc.data()
                  let movie = Movie(
                      id: data["id"] as? Int ?? 0,
                      title: data["title"] as? String ?? "",
                      overview: data["overview"] as? String ?? "",
                      posterPath: data["poster_path"] as? String ?? "",
                      releaseDate: data["release_date"] as? String ?? "",
                      runtime: data["runtime"] as? Int,
                      voteAverage: data["vote_average"] as? Double,
                      genreIDs: data["genre_ids"] as? [Int],
                      adult: data["adult"] as? Bool
                  )
                  movies.append(movie)
              }
              completion(movies)
          }
    }
    
    func addFavorites(userId: String, movie: Movie, from viewController: UIViewController, completion: ((Error?) -> Void)?) {
        
        isAlreadyFavorited(userId: userId, movieId: movie.id) { [weak self] isFavorited in
            guard let self = self else { return }
            
            if isFavorited {
                UIHelper.makeAlert(on: viewController, title: "Bilgi", message: "Bu film zaten favorilerinde.")
                completion?(nil)
                return
            }
        
            let documentData: [String: Any] = [
                "id": movie.id,
                "title": movie.title,
                "overview": movie.overview,
                "poster_path": movie.posterPath,
                "runtime": movie.runtime ?? 0,
                "release_date": movie.releaseDate ?? "",
                "vote_average": movie.voteAverage ?? 0,
                "adult": movie.adult ?? false
            ]
            
            db.collection("users")
                .document(userId)
                .collection("favorites")
                .addDocument(data: documentData) { error in
                    if let error = error {
                        UIHelper.makeAlert(on: viewController, title: "Hata!", message: "Favoriye eklenemedi: \(error.localizedDescription)")
                    } else {
                        UIHelper.makeAlert(on: viewController, title: "Başarılı!", message: "Favorilere eklendi.")
                        self.addNotification(userId: userId, title: movie.title, isDeletion: false)
                    }
                    completion?(error)
                }
        }
    }
    
    func isAlreadyFavorited(userId: String, movieId: Int, completion: @escaping (Bool) -> Void) {
        db.collection("users")
                .document(userId)
                .collection("favorites")
                .whereField("id", isEqualTo: movieId)
                .getDocuments { (snapshot, error) in
                    
                    if let error = error {
                        print("Favori kontrol hatası: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    // Eğer 1 veya daha fazla belge varsa, film zaten favoride
                    let alreadyFavorited = !(snapshot?.isEmpty ?? true)
                    completion(alreadyFavorited)
        }
    }
    
    func deleteFromFavorites(userId: String, movieId: Int, completion: ((Bool) -> Void)? = nil) {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .whereField("id", isEqualTo: movieId)
            .getDocuments { (snapshot, error) in
                
                if let error = error {
                    print("Favori silme hatası: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("Silinecek favori bulunamadı.")
                    completion?(false)
                    return
                }
                
                let group = DispatchGroup()
                for document in documents {
                    group.enter()
                    document.reference.delete { error in
                        if let error = error {
                            print("Belge silme hatası: \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                }
                
                let title = documents.first!.data()["title"] as? String ?? "Bilinmiyor"
                
                group.notify(queue: .main) {
                    print("Favori başarıyla silindi.")
                    self.addNotification(userId: userId, title: title, isDeletion: true)
                    completion?(true)
                }
            }
    }
    
    //MARK: - Bildirimler
    func addNotification(userId: String, title: String, isDeletion: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = formatter.string(from: Date())
        let logText = isDeletion ? "\"\(title)\" favorilerden \(dateString) tarihinde kaldırıldı." : "\"\(title)\" \(dateString) tarihinde favorilere eklendi."
        
        let data: [String : Any] = [
            "title" : title,
            "createDate" : formatter.string(from: Date()),
            "isDeletion" : isDeletion,
            "notifyText" : logText
        ]
        
        db.collection("users")
            .document(userId)
            .collection("notifications")
            .addDocument(data: data) { error in
                if let error = error {
                    print("Hata: \(error)")
                }
            }
    }
    

    func getNotifications(userId: String, completion: @escaping ([Dictionary<String, Any>]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Bildirimler alınamadı: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                // Her bildirimi sözlük (dictionary) olarak döndür
                let notifications = documents.map { $0.data() }
                completion(notifications)
            }
    }
    
    func deleteAllNotifications(userId: String, completion: @escaping (Bool) -> Void) {
        let userNotifications = db.collection("users").document(userId).collection("notifications")
        
        userNotifications.getDocuments { snapshot, error in
            if let error = error {
                print("Bildirimler alınamadı: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(true)
                return
            }
            
            let batch = self.db.batch()
            for doc in documents {
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Bildirimler silinemedi: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Tüm bildirimler başarıyla silindi.")
                    completion(true)
                }
            }
        }
    }
}
