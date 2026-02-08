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

struct PersonForm: View {
    @State private var person: Person.Draft
    @State private var name:String
    @State private var birthDate: Date?
    @State private var notes: String
    init(person: Person.Draft) {
        self._person = State(initialValue: person)
        self._name = State(initialValue: person.name)
        self._birthDate = State(initialValue: person.birthDate)
        self._notes = State(initialValue: person.notes)
    }
    private var dateBinding: Binding<Date> {
        Binding {
            birthDate ?? Date.now
        } set: { setDate in
            birthDate = setDate
        }
    }
    @Environment(\.dismiss) var dismiss
    @Dependency(\.defaultDatabase) var database
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                if birthDate != nil {
                    HStack { 
                        DatePicker("Birthdate", selection: dateBinding, displayedComponents: .date)
                        Button {
                            birthDate = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                } else {
                    HStack {
                        Text("Birthdate")
                        Spacer()
                        Button("Add Birthdate") {
                            birthDate = Date.now
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm) {
                        person.name = name
                        person.birthDate = birthDate
                        person.notes = notes
                        withErrorReporting {
                            try database.write { db in
                                try Person
                                    .upsert { person }
                                    .execute(db)
                            }
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PersonFormPreview: PreviewProvider {
    static var previews: some View {
        PersonForm(person: Person.Draft())
    }
}
