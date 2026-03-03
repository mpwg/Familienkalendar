import Foundation
import SwiftData

@MainActor
struct RemoteFeedStore {
    private let modelContext: ModelContext
    private let legacyKey = "remoteICSFeeds"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func migrateLegacyIfNeeded() throws {
        let existing = try modelContext.fetch(FetchDescriptor<RemoteFeedModel>())
        guard existing.isEmpty else {
            return
        }

        guard
            let data = UserDefaults.standard.data(forKey: legacyKey),
            let feeds = try? JSONDecoder().decode([RemoteFeed].self, from: data)
        else {
            return
        }

        for feed in feeds {
            modelContext.insert(
                RemoteFeedModel(
                    id: feed.id,
                    name: feed.name,
                    urlString: feed.urlString,
                    isEnabled: feed.isEnabled
                )
            )
        }

        try modelContext.save()
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }

    func loadFeeds() throws -> [RemoteFeed] {
        let descriptor = FetchDescriptor<RemoteFeedModel>(
            sortBy: [SortDescriptor(\RemoteFeedModel.createdAt)]
        )
        let persisted = try modelContext.fetch(descriptor)
        return persisted.map { model in
            RemoteFeed(id: model.id, name: model.name, urlString: model.urlString, isEnabled: model.isEnabled)
        }
    }

    func saveFeeds(_ feeds: [RemoteFeed]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<RemoteFeedModel>())
        var existingByID: [String: RemoteFeedModel] = [:]
        existing.forEach { existingByID[$0.id] = $0 }

        let incomingIDs = Set(feeds.map(\.id))

        for feed in feeds {
            if let model = existingByID[feed.id] {
                model.name = feed.name
                model.urlString = feed.urlString
                model.isEnabled = feed.isEnabled
            } else {
                modelContext.insert(
                    RemoteFeedModel(
                        id: feed.id,
                        name: feed.name,
                        urlString: feed.urlString,
                        isEnabled: feed.isEnabled
                    )
                )
            }
        }

        for model in existing where !incomingIDs.contains(model.id) {
            modelContext.delete(model)
        }

        try modelContext.save()
    }
}
