//
//----------------------------------------------
// Original project: GiftRegistry
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SQLiteData
import SwiftUI

@MainActor
@Observable
class PersonListModel {
    enum SortField {
        case name, birthdate
    }
    @ObservationIgnored
    @FetchAll(Person.none) var people
    
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    var person: Person.Draft?
    var sortAscending = true {
        didSet {
            Task {
                await reloadData()
            }
        }
    }
    
    var sortField: SortField = .name {
        didSet {
            Task {
                await reloadData()
            }
        }
    }
    
    var searchText = "" {
        didSet {
            Task {
                await reloadData()
            }
        }
    }
    
    init() {
        Task {
            await reloadData()
        }
    }
    
    func deleteButtonTapped(_ person: Person) {
        withErrorReporting {
            try database.write { db in
                try Person
                    .delete(person)
                    .execute(db)
            }
        }
    }
    var searchTask: Task<Void, Never>?
    
    func reloadData() async {
        searchTask?.cancel()
        searchTask = Task {
            await withErrorReporting {
                _ = try await $people.load(
                    Person.all
                        .order {
                            switch sortField {
                            case .name:
                                if sortAscending {
                                    $0.name
                                } else {
                                    $0.name.desc()
                                }
                            case .birthdate:
                                if sortAscending {
                                    $0.birthDate
                                } else {
                                    $0.birthDate.desc()
                                }
                            }
                        }
                        .where {
//                            $0.name.like("%\(searchText)%")
                            $0.name.contains(searchText) ||
                            $0.notes.contains(searchText)
                        },
                    animation: .default
                )
            }
        }
    }
}

struct PersonListView: View {
    @State private var model = PersonListModel()
    var body: some View {
        NavigationStack {
            Group {
                if model.people.isEmpty {
                    ContentUnavailableView("No People", systemImage: "person.2")
                } else {
                    List(model.people) { person in
                        NavigationLink {
                            PersonForm(person: Person.Draft(person))
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(person.name)
                                        .font(.headline)
                                    Spacer()
                                    if let birthDate = person.birthDate {
                                        Text(birthDate, format: .dateTime.month(.abbreviated).day().year())
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Text(person.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                       
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                model.deleteButtonTapped(person)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $model.searchText, prompt: "Filter by name or note")
            .navigationTitle("People")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        model.person = Person.Draft()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    Menu {
                        Section("Sort By") {
                            Button {
                                model.sortField = .name
                            } label: {
                                Label("Name", systemImage: model.sortField == .name ? "checkmark" : "")
                            }
                            Button {
                                model.sortField = .birthdate
                            } label: {
                                Label("Birthdate", systemImage: model.sortField == .birthdate ? "checkmark" : "")
                            }
                        }
                        Section("Order") {
                            Button {
                                model.sortAscending = true
                            } label: {
                                Label("Ascending", systemImage: model.sortAscending ? "checkmark" : "arrow.up")
                            }
                            Button {
                                model.sortAscending = false
                            } label: {
                                Label("Descending", systemImage: !model.sortAscending ? "checkmark" : "arrow.down")
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(item: $model.person) { person in
                NavigationStack {
                    PersonForm(person: person)
                }
            }
        }
    }
}

#Preview {
   let _ = prepareDependencies {
        do {
            try $0.bootstrapDatabase()
            try $0.seedDatabaseForPreviews()
        } catch {
            fatalError("Failed to bootstrap database for previews: \(error)")
        }
    }
    PersonListView()
}
