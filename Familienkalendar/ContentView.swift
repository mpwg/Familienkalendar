//
//  ContentView.swift
//  Familienkalender
//
//  Created by Matthias Wallner-Géhri on 27.02.26.
//

import SwiftUI
import EventKit
import SwiftData
import Combine

struct ContentView: View {
    @StateObject private var viewModel: FamilyCalendarViewModel
    @State private var showSettings = false

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FamilyCalendarViewModel(modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.94, blue: 0.98),
                    Color(red: 0.93, green: 0.89, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topHeader
                toolbar
                monthTable
            }
            .padding()
        }
        .task {
            await viewModel.bootstrapIfNeeded()
        }
        .sheet(isPresented: $showSettings) {
            CalendarSettingsView(viewModel: viewModel)
        }
        .alert("Fehler", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        ), actions: {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var topHeader: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.monthAndYearShort)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(viewModel.yearText)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.92, green: 0.20, blue: 0.38))
            }
            .frame(width: 170, height: 140, alignment: .bottomLeading)
            .padding(.leading, 16)
            .background(Color(red: 0.74, green: 0.67, blue: 0.79))

            VStack(alignment: .leading, spacing: 0) {
                Text("FAMILIEN")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.97, green: 0.95, blue: 0.84))
                Text("PLANER")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.84, green: 0.78, blue: 0.90))
            }
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, maxHeight: 140, alignment: .leading)
            .background(Color(red: 0.62, green: 0.45, blue: 0.71))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 0.45, green: 0.31, blue: 0.54), lineWidth: 2)
        )
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.previousMonth) {
                Label("Zurück", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)

            Text(viewModel.monthAndYearLong)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)

            Button(action: viewModel.nextMonth) {
                Label("Weiter", systemImage: "chevron.right")
            }
            .buttonStyle(.bordered)

            Button {
                showSettings = true
            } label: {
                Label("Kalender", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 10)
    }

    private var monthTable: some View {
        VStack(spacing: 0) {
            headerRow

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.daysInMonth, id: \.day) { day in
                        DayRowView(
                            day: day,
                            columns: viewModel.columns,
                            eventsByColumn: viewModel.eventsTextByColumnAndDay
                        )
                    }
                }
            }
            .background(Color.white.opacity(0.65))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.35), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Tag")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(width: 110, height: 42)
                .background(Color.white.opacity(0.85))
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.25), lineWidth: 0.7)
                )

            ForEach(viewModel.columns) { column in
                Text(column.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 42)
                    .background(column.tint.opacity(0.25))
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.25), lineWidth: 0.7)
                    )
            }
        }
    }
}

private struct DayRowView: View {
    let day: MonthDay
    let columns: [CalendarColumn]
    let eventsByColumn: [String: [Int: [String]]]

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("\(day.day)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(day.isSunday ? .red : .primary)
                Text(day.weekdayShort)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(day.isSunday ? .red : .secondary)
            }
            .frame(width: 110, height: 74)
            .background(dayBackground.opacity(0.55))
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.25), lineWidth: 0.7)
            )

            ForEach(columns) { column in
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(eventsByColumn[column.id]?[day.day] ?? [], id: \.self) { entry in
                        Text("• \(entry)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                .padding(.horizontal, 6)
                .padding(.top, 6)
                .background(dayBackground.opacity(0.35))
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.25), lineWidth: 0.7)
                )
            }
        }
    }

    private var dayBackground: Color {
        day.isWeekend ? Color(red: 0.88, green: 0.82, blue: 0.91) : Color.white
    }
}

private struct CalendarSettingsView: View {
    @ObservedObject var viewModel: FamilyCalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newFeedName = ""
    @State private var newFeedURL = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Gerätekalender (inkl. iCloud)") {
                    if viewModel.localCalendars.isEmpty {
                        Text("Keine lokalen Kalender gefunden oder Zugriff verweigert.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(viewModel.localCalendars) { cal in
                        Toggle(
                            isOn: Binding(
                                get: { viewModel.selectedLocalIDs.contains(cal.id) },
                                set: { enabled in
                                    viewModel.setLocalCalendar(cal.id, enabled: enabled)
                                }
                            ),
                            label: {
                                HStack {
                                    Circle()
                                        .fill(cal.tint)
                                        .frame(width: 10, height: 10)
                                    Text(cal.name)
                                }
                            }
                        )
                    }
                }

                Section(".ics-Feeds") {
                    TextField("Name (z.B. Schule)", text: $newFeedName)
                    TextField("https://.../calendar.ics oder webcal://...", text: $newFeedURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    Button("Feed hinzufügen") {
                        viewModel.addRemoteFeed(name: newFeedName, url: newFeedURL)
                        newFeedName = ""
                        newFeedURL = ""
                    }
                    .disabled(newFeedURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    ForEach(viewModel.remoteFeeds) { feed in
                        HStack {
                            Toggle(feed.name, isOn: Binding(
                                get: { feed.isEnabled },
                                set: { enabled in viewModel.setRemoteFeed(feed.id, enabled: enabled) }
                            ))
                            Button(role: .destructive) {
                                viewModel.removeRemoteFeed(feed.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kalender auswählen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MonthDay {
    let day: Int
    let date: Date
    let weekdayShort: String
    let isWeekend: Bool
    let isSunday: Bool
}

struct CalendarColumn: Identifiable {
    let id: String
    let name: String
    let tint: Color
}

struct DeviceCalendar: Identifiable {
    let id: String
    let name: String
    let tint: Color
}

struct RemoteFeed: Identifiable, Codable {
    let id: String
    var name: String
    var urlString: String
    var isEnabled: Bool
}

struct CalendarEntry {
    let start: Date
    let end: Date
    let title: String
}

@MainActor
final class FamilyCalendarViewModel: ObservableObject {
    @Published var monthDate = Calendar.current.startOfMonth(for: Date())
    @Published var localCalendars: [DeviceCalendar] = []
    @Published var selectedLocalIDs: Set<String> = []
    @Published var remoteFeeds: [RemoteFeed] = []
    @Published var eventsTextByColumnAndDay: [String: [Int: [String]]] = [:]
    @Published var errorMessage: String?

    private let eventStore = EKEventStore()
    private let remoteFeedStore: RemoteFeedStore
    private var didBootstrap = false
    private let localSelectionKey = "selectedLocalCalendarIDs"
    private let palette: [Color] = [
        Color(red: 0.90, green: 0.72, blue: 0.78),
        Color(red: 0.75, green: 0.84, blue: 0.72),
        Color(red: 0.73, green: 0.78, blue: 0.92),
        Color(red: 0.95, green: 0.82, blue: 0.66),
        Color(red: 0.74, green: 0.88, blue: 0.87),
        Color(red: 0.88, green: 0.77, blue: 0.93),
        Color(red: 0.91, green: 0.78, blue: 0.71)
    ]

    init(modelContext: ModelContext) {
        self.remoteFeedStore = RemoteFeedStore(modelContext: modelContext)
    }

    var columns: [CalendarColumn] {
        let local = localCalendars
            .filter { selectedLocalIDs.contains($0.id) }
            .map { CalendarColumn(id: $0.id, name: $0.name, tint: $0.tint) }

        let remote = remoteFeeds
            .filter(\.isEnabled)
            .enumerated()
            .map { index, feed in
                CalendarColumn(
                    id: feed.id,
                    name: feed.name,
                    tint: palette[(index + local.count) % palette.count]
                )
            }

        return local + remote
    }

    var monthAndYearShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "M-yyyy"
        return formatter.string(from: monthDate)
    }

    var monthAndYearLong: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: monthDate).capitalized
    }

    var yearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: monthDate)
    }

    var daysInMonth: [MonthDay] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: monthDate) else { return [] }
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "de_DE")
        weekdayFormatter.dateFormat = "EEEEEE"

        return range.compactMap { day in
            guard let date = cal.date(byAdding: .day, value: day - 1, to: monthDate) else { return nil }
            let weekday = cal.component(.weekday, from: date)
            return MonthDay(
                day: day,
                date: date,
                weekdayShort: weekdayFormatter.string(from: date),
                isWeekend: cal.isDateInWeekend(date),
                isSunday: weekday == 1
            )
        }
    }

    func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true

        loadPersisted()
        await requestCalendarAccess()
        await reloadEvents()
    }

    func previousMonth() {
        monthDate = Calendar.current.date(byAdding: .month, value: -1, to: monthDate) ?? monthDate
        Task { await reloadEvents() }
    }

    func nextMonth() {
        monthDate = Calendar.current.date(byAdding: .month, value: 1, to: monthDate) ?? monthDate
        Task { await reloadEvents() }
    }

    func setLocalCalendar(_ id: String, enabled: Bool) {
        if enabled {
            selectedLocalIDs.insert(id)
        } else {
            selectedLocalIDs.remove(id)
        }
        persistLocalSelection()
        Task { await reloadEvents() }
    }

    func addRemoteFeed(name: String, url: String) {
        let cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let resolvedURL = normalizedRemoteFeedURL(from: cleanURL) else {
            errorMessage = "Ungültige URL für den .ics-Feed."
            return
        }
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = cleanName.isEmpty ? "ICS \(remoteFeeds.count + 1)" : cleanName

        remoteFeeds.append(RemoteFeed(
            id: UUID().uuidString,
            name: resolvedName,
            urlString: resolvedURL.absoluteString,
            isEnabled: true
        ))
        persistRemoteFeeds()
        Task { await reloadEvents() }
    }

    func setRemoteFeed(_ id: String, enabled: Bool) {
        guard let index = remoteFeeds.firstIndex(where: { $0.id == id }) else { return }
        remoteFeeds[index].isEnabled = enabled
        persistRemoteFeeds()
        Task { await reloadEvents() }
    }

    func removeRemoteFeed(_ id: String) {
        remoteFeeds.removeAll { $0.id == id }
        persistRemoteFeeds()
        Task { await reloadEvents() }
    }

    private func requestCalendarAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            guard granted else {
                errorMessage = "Kalenderzugriff wurde nicht erlaubt. Bitte in den Systemeinstellungen für Familienkalender aktivieren."
                return
            }
            let calendars = eventStore.calendars(for: .event)
            localCalendars = calendars.map { cal in
                DeviceCalendar(
                    id: cal.calendarIdentifier,
                    name: cal.title,
                    tint: Color(cal.cgColor ?? UIColor.systemBlue.cgColor)
                        .opacity(0.9)
                )
            }
            if selectedLocalIDs.isEmpty {
                selectedLocalIDs = Set(localCalendars.prefix(4).map(\.id))
                persistLocalSelection()
            }
            if localCalendars.isEmpty {
                errorMessage = "Es wurden keine Kalender gefunden. Prüfe, ob in Apple Kalender mindestens ein lokaler oder iCloud-Kalender vorhanden ist."
            }
        } catch {
            errorMessage = "Kalenderzugriff nicht möglich: \(error.localizedDescription)"
        }
    }

    private func loadPersisted() {
        if let data = UserDefaults.standard.data(forKey: localSelectionKey),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            selectedLocalIDs = Set(array)
        }

        do {
            try remoteFeedStore.migrateLegacyIfNeeded()
            remoteFeeds = try remoteFeedStore.loadFeeds()
        } catch {
            errorMessage = "Gespeicherte Feed-Daten konnten nicht geladen werden."
        }
    }

    private func persistLocalSelection() {
        if let data = try? JSONEncoder().encode(Array(selectedLocalIDs)) {
            UserDefaults.standard.set(data, forKey: localSelectionKey)
        }
    }

    private func persistRemoteFeeds() {
        do {
            try remoteFeedStore.saveFeeds(remoteFeeds)
        } catch {
            errorMessage = "Feed-Änderungen konnten nicht gespeichert werden."
        }
    }

    private func reloadEvents() async {
        var result: [String: [Int: [String]]] = [:]
        let monthRange = Calendar.current.monthDateRange(for: monthDate)

        if !selectedLocalIDs.isEmpty {
            let selectedCalendars = eventStore
                .calendars(for: .event)
                .filter { selectedLocalIDs.contains($0.calendarIdentifier) }
            let predicate = eventStore.predicateForEvents(
                withStart: monthRange.start,
                end: monthRange.end,
                calendars: selectedCalendars
            )
            let events = eventStore.events(matching: predicate)
            for event in events {
                addEntry(
                    CalendarEntry(start: event.startDate, end: event.endDate, title: event.title),
                    to: &result,
                    columnID: event.calendar.calendarIdentifier,
                    monthDate: monthDate
                )
            }
        }

        for feed in remoteFeeds where feed.isEnabled {
            guard let url = normalizedRemoteFeedURL(from: feed.urlString) else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let entries = ICSParser.parse(data: data)
                for entry in entries {
                    addEntry(entry, to: &result, columnID: feed.id, monthDate: monthDate)
                }
            } catch {
                errorMessage = "Konnte Feed \(feed.name) nicht laden."
            }
        }

        eventsTextByColumnAndDay = result
    }

    private func normalizedRemoteFeedURL(from raw: String) -> URL? {
        guard !raw.isEmpty else { return nil }
        guard var components = URLComponents(string: raw) else { return nil }

        // iCloud public calendars are commonly shared as webcal:// links.
        if components.scheme?.lowercased() == "webcal" {
            components.scheme = "https"
        }

        return components.url
    }

    private func addEntry(
        _ entry: CalendarEntry,
        to store: inout [String: [Int: [String]]],
        columnID: String,
        monthDate: Date
    ) {
        let cal = Calendar.current
        let monthStart = cal.startOfMonth(for: monthDate)
        guard let monthEnd = cal.date(byAdding: DateComponents(month: 1, second: -1), to: monthStart) else {
            return
        }

        let start = max(entry.start, monthStart)
        let end = min(entry.end, monthEnd)
        guard start <= end else { return }

        var cursor = cal.startOfDay(for: start)
        let lastDay = cal.startOfDay(for: end)
        while cursor <= lastDay {
            let day = cal.component(.day, from: cursor)
            let timePrefix: String
            if cal.isDate(cursor, inSameDayAs: entry.start),
               !cal.isDate(entry.start, equalTo: entry.end, toGranularity: .day) {
                timePrefix = entry.start.formatted(date: .omitted, time: .shortened) + " "
            } else {
                timePrefix = ""
            }
            store[columnID, default: [:]][day, default: []].append(timePrefix + entry.title)
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
    }
}

private enum ICSParser {
    static func parse(data: Data) -> [CalendarEntry] {
        guard let string = String(data: data, encoding: .utf8) else { return [] }
        let lines = unfoldICSLines(string)
        var inEvent = false
        var props: [String: String] = [:]
        var entries: [CalendarEntry] = []

        for line in lines {
            if line == "BEGIN:VEVENT" {
                inEvent = true
                props = [:]
                continue
            }
            if line == "END:VEVENT" {
                inEvent = false
                if let entry = buildEntry(from: props) {
                    entries.append(entry)
                }
                continue
            }
            if !inEvent { continue }

            let split = line.split(separator: ":", maxSplits: 1).map(String.init)
            guard split.count == 2 else { continue }
            props[split[0]] = split[1]
        }
        return entries
    }

    private static func buildEntry(from props: [String: String]) -> CalendarEntry? {
        let dtStart = propValue(named: "DTSTART", in: props)
        let dtEnd = propValue(named: "DTEND", in: props) ?? dtStart
        let summary = props["SUMMARY"] ?? "(Ohne Titel)"

        guard
            let startRaw = dtStart?.value,
            let start = parseDate(startRaw, tzid: dtStart?.tzid),
            let endRaw = dtEnd?.value,
            let end = parseDate(endRaw, tzid: dtEnd?.tzid)
        else {
            return nil
        }

        return CalendarEntry(start: start, end: max(start, end), title: summary)
    }

    private static func propValue(named key: String, in props: [String: String]) -> (value: String, tzid: String?)? {
        if let direct = props[key] {
            return (direct, nil)
        }
        for (k, value) in props where k.hasPrefix(key + ";") {
            let params = k.split(separator: ";").dropFirst()
            for param in params {
                let kv = param.split(separator: "=", maxSplits: 1).map(String.init)
                if kv.count == 2, kv[0] == "TZID" {
                    return (value, kv[1])
                }
            }
            return (value, nil)
        }
        return nil
    }

    private static func parseDate(_ raw: String, tzid: String?) -> Date? {
        let candidates = [
            "yyyyMMdd'T'HHmmss'Z'",
            "yyyyMMdd'T'HHmmss",
            "yyyyMMdd'T'HHmm",
            "yyyyMMdd"
        ]
        for format in candidates {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if format.hasSuffix("'Z'") {
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
            } else if let tzid, let tz = TimeZone(identifier: tzid) {
                formatter.timeZone = tz
            }
            if let date = formatter.date(from: raw) {
                return date
            }
        }
        return nil
    }

    private static func unfoldICSLines(_ source: String) -> [String] {
        var result: [String] = []
        let lines = source.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix(" ") || line.hasPrefix("\t"), !result.isEmpty {
                result[result.count - 1] += line.trimmingCharacters(in: .whitespaces)
            } else {
                result.append(line)
            }
        }
        return result
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }

    func monthDateRange(for date: Date) -> (start: Date, end: Date) {
        let start = startOfMonth(for: date)
        let end = self.date(byAdding: .month, value: 1, to: start) ?? start
        return (start, end)
    }
}
