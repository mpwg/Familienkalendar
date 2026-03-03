import Foundation
import SwiftData

@Model
final class PersonModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var role: String

    init(id: UUID = UUID(), name: String, colorHex: String = "#6A4E7A", role: String = "parent") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.role = role
    }
}

@Model
final class CalendarEventModel {
    @Attribute(.unique) var id: String
    var title: String
    var startDate: Date
    var endDate: Date
    var sourceID: String
    var isAllDay: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        startDate: Date,
        endDate: Date,
        sourceID: String,
        isAllDay: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.sourceID = sourceID
        self.isAllDay = isAllDay
    }
}

@Model
final class RemoteFeedModel {
    @Attribute(.unique) var id: String
    var name: String
    var urlString: String
    var isEnabled: Bool
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        urlString: String,
        isEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}

@Model
final class TaskItemModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date?
    var isDone: Bool
    var assigneeID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date? = nil,
        isDone: Bool = false,
        assigneeID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
        self.assigneeID = assigneeID
    }
}

@Model
final class ReminderRuleModel {
    @Attribute(.unique) var id: UUID
    var targetID: String
    var minutesBefore: Int
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        targetID: String,
        minutesBefore: Int,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.targetID = targetID
        self.minutesBefore = minutesBefore
        self.isEnabled = isEnabled
    }
}
