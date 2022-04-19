//
//  BeerPongARApp.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 03. 13..
//

import UIKit
import SwiftUI

@main
struct BeerPongARApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
