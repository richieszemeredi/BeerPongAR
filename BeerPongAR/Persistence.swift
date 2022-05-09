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
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
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
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
