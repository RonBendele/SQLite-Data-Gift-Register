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

struct OccasionsList: View {
    enum Action: String {
        case new = "New Occasion"
        case edit = "Edit Occasion"
        case none = "Occasions"
    }
    @State private var action = Action.none
    @State private var newOccasion = false
    @State private var name = ""
    @State private var hexColor = Color.blue
    @Environment(\.dismiss) var dismiss
    @Binding var selectedOccasions: [Occasion]
    @FetchAll(Occasion.order(by: \.name)) var allOccasions
    @State private var occasion: Occasion.Draft?
    @Dependency(\.defaultDatabase) var database
    
    var body: some View {
        NavigationStack {
            VStack {
                if action != .none {
                    HStack {
                        TextField("Occasion Name", text: $name)
                            .textFieldStyle(.roundedBorder)
                        ColorPicker("Color", selection: $hexColor, supportsOpacity: false)
                            .labelsHidden()
                        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button {
                                if action == .new {
                                    occasion = Occasion.Draft(name: name, hexColor: hexColor.toHexString)
                                } else {
                                    occasion?.name = name
                                    occasion?.hexColor = hexColor.toHexString
                                }
                                if let occasion {
                                    withErrorReporting {
                                        try database.write { db in
                                            try Occasion
                                                .upsert { occasion }
                                                .execute(db)
                                        }
                                    }
                                    if let index = selectedOccasions.firstIndex(where:  { $0.id == occasion.id}) {
                                        selectedOccasions[index].name = name
                                        selectedOccasions[index].hexColor = hexColor.toHexString
                                    }
                                }
                                withAnimation {
                                    action = .none
                                    name = ""
                                    hexColor = .blue
                                    occasion = nil
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                }
                if allOccasions.isEmpty {
                    ContentUnavailableView("Create your first occasion", systemImage: "pencil.and.scribble")
                }
                List {
                    ForEach(allOccasions) { occasion in
                        HStack {
                            if action != .new {
                                if selectedOccasions.contains(where: {$0.id == occasion.id}) {
                                    Button {
                                        if let index = selectedOccasions.firstIndex(where: {$0.id == occasion.id}) {
                                            selectedOccasions.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundStyle(.red)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button {
                                        selectedOccasions.append(occasion)
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .foregroundStyle(.green)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            Image(systemName: "circle.fill")
                                .foregroundStyle(occasion.color)
                            Text(occasion.name)
                            Spacer()
                            if action != .new {
                                Button {
                                    withAnimation {
                                        action = .edit
                                        self.occasion = Occasion.Draft(occasion)
                                        name = occasion.name
                                        hexColor = occasion.color
                                    }
                                }label: {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = selectedOccasions.firstIndex(where: {$0.id == occasion.id}) {
                                    selectedOccasions.remove(at: index)
                                    withErrorReporting {
                                        try database.write { db in
                                            try Occasion
                                                .delete(occasion)
                                                .execute(db)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle(action.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        action = .new
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

}

#Preview {
    @Previewable
    @State var sampleOccasions = prepareDependencies {
         do {
             try $0.bootstrapDatabase()
             try $0.seedDatabaseForPreviews()
             let sampleOccasion =  try $0.defaultDatabase.read { db in
                 try Occasion.find(UUID(0))
                     .fetchOne(db)!
             }
             return [sampleOccasion]
         } catch {
             fatalError("Failed to bootstrap database for previews: \(error)")
         }
     }
    OccasionsList(selectedOccasions: $sampleOccasions)
}
