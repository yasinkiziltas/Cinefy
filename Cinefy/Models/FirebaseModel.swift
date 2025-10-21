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
                
                group.notify(queue: .main) {
                    print("Favori başarıyla silindi.")
                    completion?(true)
                }
            }
    }
}
