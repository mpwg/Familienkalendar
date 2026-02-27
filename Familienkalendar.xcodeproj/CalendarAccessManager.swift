import Foundation
import EventKit

@MainActor
final class CalendarAccessManager: ObservableObject {
    enum AuthorizationState: Equatable {
        case notDetermined
        case authorized
        case denied
        case restricted
    }

    @Published private(set) var authorizationState: AuthorizationState = .notDetermined

    private let eventStore = EKEventStore()

    init() {
        refreshAuthorizationState()
    }

    func refreshAuthorizationState() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            authorizationState = .notDetermined
        case .authorized, .fullAccess:
            authorizationState = .authorized
        case .denied:
            authorizationState = .denied
        case .restricted, .writeOnly:
            authorizationState = .restricted
        @unknown default:
            authorizationState = .restricted
        }
    }

    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run { self.refreshAuthorizationState() }
            return granted
        } catch {
            await MainActor.run { self.refreshAuthorizationState() }
            return false
        }
    }

    // MARK: - Sample operations

    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return eventStore.events(matching: predicate)
    }

    func createEvent(title: String, startDate: Date, endDate: Date, notes: String? = nil, calendar: EKCalendar? = nil) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}

// MARK: - SwiftUI helper demo (optional)
#if canImport(SwiftUI)
import SwiftUI

struct CalendarPermissionView: View {
    @StateObject private var manager = CalendarAccessManager()
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 16) {
            switch manager.authorizationState {
            case .authorized:
                Text("Kalenderzugriff: Erteilt")
                    .foregroundStyle(.green)
            case .denied:
                Text("Kalenderzugriff: Verweigert. Bitte in den Einstellungen erlauben.")
                Button("Einstellungen öffnen") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            case .restricted:
                Text("Kalenderzugriff: Eingeschränkt")
            case .notDetermined:
                VStack(spacing: 8) {
                    Text("Diese App benötigt Zugriff auf deinen Kalender.")
                    Button(action: request) {
                        if isRequesting { ProgressView() } else { Text("Zugriff anfragen") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequesting)
                }
            }
        }
        .padding()
        .task { manager.refreshAuthorizationState() }
    }

    private func request() {
        isRequesting = true
        Task {
            _ = await manager.requestAccess()
            isRequesting = false
        }
    }
}

#Preview("Kalender-Berechtigung") {
    CalendarPermissionView()
}
#endif
