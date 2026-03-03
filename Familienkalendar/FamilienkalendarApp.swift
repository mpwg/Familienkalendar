//
//  FamilienkalendarApp.swift
//  Familienkalender
//
//  Created by Matthias Wallner-Géhri on 27.02.26.
//

import SwiftUI
import SwiftData

@main
struct FamilienkalenderApp: App {
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersonModel.self,
            CalendarEventModel.self,
            RemoteFeedModel.self,
            TaskItemModel.self,
            ReminderRuleModel.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Konnte ModelContainer nicht erstellen: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
