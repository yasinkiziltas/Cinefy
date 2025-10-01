//
//  CinefyModel.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 23.08.2025.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func addFavorite(movie: Movie, from viewController: UIViewController) {
        // Aynı başlıktan varsa tekrar ekleme
        if isAlreadyFavorite(title: movie.title) {
            UIHelper.makeAlert(on: viewController, title: "Uyarı!", message: "Bu film zaten favorilere eklenmiş.")
            return
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "FavMovies", in: context) else { return }

        let newFavorite = NSManagedObject(entity: entity, insertInto: context)
        newFavorite.setValue(movie.title, forKey: "title")
        newFavorite.setValue(movie.overview, forKey: "overview")

        do {
            try context.save()
            UIHelper.makeAlert(on: viewController, title: "Başarılı!", message: "Favorilere eklendi.")
        } catch {
            UIHelper.makeAlert(on: viewController, title: "Hata!", message: "Hata: \(error.localizedDescription)")
        }
    }

    func isAlreadyFavorite(title: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavMovies")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try context.fetch(fetchRequest)
            return results.count > 0
        } catch {
            print("Kontrol sırasında hata: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchFavorites() -> [FavMovies] {
        let fetchRequest: NSFetchRequest<FavMovies> = FavMovies.fetchRequest()
        
        do {
            let favorites = try context.fetch(fetchRequest)
            return favorites
        } catch {
            UIHelper.makeAlert(on: UIApplication.shared.windows.first?.rootViewController ?? UIViewController(), title: "Hata!", message: "Favoriye alırken hata: \(error.localizedDescription)")
            //print("Favoriye alırken hata: \(error.localizedDescription)")
            return []
        }
    }
}
