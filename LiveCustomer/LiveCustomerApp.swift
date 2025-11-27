//
//  LiveCustomerApp.swift
//  LiveCustomer
//
//  Created by ReNote Ai on 26/11/25.
//

import SwiftUI

@main
struct LiveCustomerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
