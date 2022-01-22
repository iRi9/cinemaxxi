//
//  FavoriteProvider.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 21/01/22.
//

import Foundation
import CoreData

class FavoriteProvider {

    private let backgroundContext: NSManagedObjectContext
    private let favoriteEntity = "FavoriteMovie"

    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        self.backgroundContext = backgroundContext
    }

    private func getMaxId(completion: @escaping(_ maxId: Int) -> ()) {
        let taskContext = backgroundContext

        taskContext.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: favoriteEntity)
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchLimit = 1

            do {
                let lastFavoriteMovie = try taskContext.fetch(fetchRequest)
                if let favoriteMovie = lastFavoriteMovie.first, let position = favoriteMovie.value(forKey: "id") as? Int {
                    completion(position)
                } else {
                    completion(0)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func createFavorite(_ favorite: Favorite, completion: @escaping(_ status: Bool) -> Void) {
        let taskContext = backgroundContext
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: favoriteEntity, in: taskContext) {
                let favoriteMovie = NSManagedObject(entity: entity, insertInto: taskContext)
                favoriteMovie.setValue(favorite.id, forKeyPath: "id")
                favoriteMovie.setValue(favorite.title, forKeyPath: "title")
                favoriteMovie.setValue(favorite.releaseDate, forKeyPath: "releaseDate")
                favoriteMovie.setValue(favorite.overview, forKeyPath: "overview")
                favoriteMovie.setValue(favorite.poster, forKeyPath: "poster")
                favoriteMovie.setValue(favorite.posterUrl, forKeyPath: "posterUrl")

                do {
                    try taskContext.save()
                    completion(true)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    completion(false)
                }

            }
        }
    }

    func getFavoriteMovies( _ complete: @escaping (_ favoriteMovies: [Favorite]) -> Void) {
        let taskContext = backgroundContext
        taskContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.favoriteEntity)

            do {
                let results = try taskContext.fetch(fetchRequest)
                var favoriteMovies = [Favorite]()

                for result in results {
                    let favorite = Favorite(
                        id: result.value(forKeyPath: "id") as? Int64,
                        poster: result.value(forKeyPath: "poster") as? Data,
                        title: result.value(forKeyPath: "title") as? String,
                        overview: result.value(forKeyPath: "overview") as? String,
                        releaseDate: result.value(forKeyPath: "releaseDate") as? String,
                        posterUrl: result.value(forKeyPath: "posterUrl") as? String)
                    favoriteMovies.append(favorite)
                }
                complete(favoriteMovies)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func getFavoriteMovie(_ title: String, completion: @escaping(_ favoriteMovie: Favorite?) -> Void) {
        let taskContext = backgroundContext
        taskContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.favoriteEntity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)

            do {

                if let result = try taskContext.fetch(fetchRequest).first {
                    let favoriteMovie = Favorite(id: result.value(forKeyPath: "id") as? Int64,
                                                 poster: result.value(forKeyPath: "poster") as? Data,
                                                 title: result.value(forKeyPath: "title") as? String,
                                                 overview: result.value(forKeyPath: "overview") as? String,
                                                 releaseDate: result.value(forKeyPath: "releaseDate") as? String,
                                                 posterUrl: result.value(forKeyPath: "posterUrl") as? String)
                    
                    completion(favoriteMovie)
                } else {
                    completion(nil)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }

        }
    }

    func deleteFavoriteMovie(_ id: Int64, completion: @escaping(_ status: Bool) -> Void) {
        let taskContext = backgroundContext
        taskContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.favoriteEntity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeCount

            if let batchDeleteResult = try? taskContext.execute(deleteRequest) as? NSBatchDeleteResult, batchDeleteResult.result != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

}
