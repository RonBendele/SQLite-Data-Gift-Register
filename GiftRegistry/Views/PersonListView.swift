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

struct PersonListView: View {
    @FetchAll(Person.order(by: \.name)) private var people
    @Dependency(\.defaultDatabase) var database
    @State private var person: Person.Draft?
    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView("No People", systemImage: "person.2")
                } else {
                    List(people) { person in
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
                        .swipeActions(edge: .leading) {
                            Button {
                                self.person = Person.Draft(person)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withErrorReporting {
                                    try database.write { db in
                                        try Person
                                            .delete(person)
                                            .execute(db)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        person = Person.Draft()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $person) { person in
                PersonForm(person: person)
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
