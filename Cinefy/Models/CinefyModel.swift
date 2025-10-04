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
    
    
    //Favori listeleme
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

    //Favori ekleme
    func addFavorite(movie: Movie, from viewController: UIViewController) {
        if isAlreadyFavorite(title: movie.title) {
            UIHelper.makeAlert(on: viewController, title: "Uyarı!", message: "Bu film zaten favorilere eklenmiş.")
            return
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "FavMovies", in: context) else { return }

        let newFavorite = NSManagedObject(entity: entity, insertInto: context)
        newFavorite.setValue(movie.title, forKey: "title")
        newFavorite.setValue(movie.overview, forKey: "overview")
        newFavorite.setValue(movie.posterPath, forKey: "posterPath")
        newFavorite.setValue(movie.releaseDate, forKey: "releaseDate")
        newFavorite.setValue(movie.runtime, forKey: "runtime")
        newFavorite.setValue(movie.voteAverage, forKey: "voteAverage")
        newFavorite.setValue(movie.adult, forKey: "adult")

        do {
            try context.save()
            CoreDataManager.shared.logFavoriteMovie(movieName: movie.title, isDeletion: false)
            UIHelper.makeAlert(on: viewController, title: "Başarılı!", message: "Favorilere eklendi.")
        } catch {
            UIHelper.makeAlert(on: viewController, title: "Hata!", message: "Hata: \(error.localizedDescription)")
        }
    }

    //Eğer aynı filmi eklersem
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
    
    //Favori silme
    func deleteFavorite(movie: FavMovies, from viewController: UIViewController) {
        let movieTitle = movie.title ?? ""
        context.delete(movie)
        
        do {
            try context.save()
            CoreDataManager.shared.logFavoriteMovie(movieName: movieTitle, isDeletion: true)
            UIHelper.makeAlert(on: viewController, title: "Başarılı!", message: "Silme işlemi başarılı!")
        }
        catch {
            UIHelper.makeAlert(on: viewController, title: "Hata!", message: "Silme işlemi sırasında hata: \(error.localizedDescription)")
        }
    }
    
    //Movie Log Ekleme
    func logFavoriteMovie(movieName: String, isDeletion: Bool = false) {
        guard let entity = NSEntityDescription.entity(forEntityName: "MoviesLogs", in: context) else { return }
        
        let log = NSManagedObject(entity: entity, insertInto: context)
        log.setValue(UUID(), forKey: "id")
        log.setValue(Date(), forKey: "createDate")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = formatter.string(from: Date())
        let logText = isDeletion ? "\"\(movieName)\" favorilerden \(dateString) tarihinde kaldırıldı." : "\"\(movieName)\" \(dateString) tarihinde favorilere eklendi."
        log.setValue(logText, forKey: "movieName")

        do {
            try context.save()
            print("Log eklendi")
        }
        catch {
            print("Log eklenemedi: \(error.localizedDescription)")
        }
    }
    
    //Movie Log Listeleme
    func getFavoriteMovieLogs() -> [MoviesLogs] {
        let request: NSFetchRequest<MoviesLogs> = MoviesLogs.fetchRequest()
        do {
            return try context.fetch(request)
        }
        catch {
            print("Loglar listelenemedi: \(error.localizedDescription)")
            return []
        }
    }
    
    //Movie Log Silme
    func deleteAllFavoriteMovieLogs(from viewController: UIViewController) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MoviesLogs")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            UIHelper.makeAlert(on: viewController, title: "Başarılı!", message: "Tüm loglar silindi.")
        } catch {
            UIHelper.makeAlert(on: viewController, title: "Hata", message: "Logları silerken bir hata oluştu.")
        }
    }
}
