//
//  Persistence.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 23..
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<3 {
            let newScore = HighScore(context: viewContext)
            newScore.date = Date()
            newScore.seconds = Double.random(in: 32.2 ..< 231.3)
            newScore.level = "easy"
            newScore.id = UUID()
        }
        for _ in 0..<4 {
            let newScore = HighScore(context: viewContext)
            newScore.date = Date()
            newScore.seconds = Double.random(in: 32.2 ..< 231.3)
            newScore.level = "medium"
            newScore.id = UUID()
        }
        for _ in 0..<2 {
            let newScore = HighScore(context: viewContext)
            newScore.date = Date()
            newScore.seconds = Double.random(in: 32.2 ..< 231.3)
            newScore.level = "hard"
            newScore.id = UUID()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "HighScoresModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
