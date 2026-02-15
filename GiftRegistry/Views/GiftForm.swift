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
class GiftFormModel {
    var gift: Gift.Draft
    var name:String
    var price: Double?
    var isPurchased: Bool
    
    init(gift: Gift.Draft) {
        self.gift = gift
        name = gift.name
        price = gift.price
        isPurchased = gift.isPurchased
    }
    
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    func saveGiftButtonTapped() {
        withErrorReporting {
            gift.name = name
            gift.price = price
            gift.isPurchased = isPurchased
            try database.write { db in
                try Gift
                    .upsert { gift }
                    .execute(db)
            }
        }
    }
}

struct GiftForm: View {
    @State private var model: GiftFormModel
    
    init(gift: Gift.Draft) {
        self._model = State(initialValue: GiftFormModel(gift: gift))
    }
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("Gift Details") {
                    TextField("Gift Name", text: $model.name)
                    LabeledContent("Price") {
                        TextField("Price", value: $model.price,
                                  format: .currency(
                                    code: Locale.current.currency?.identifier ?? "USD"
                                  )
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                    Toggle("Purchased", isOn: $model.isPurchased)
                }
            }
            .navigationTitle("Gift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        model.saveGiftButtonTapped()
                        dismiss()
                    }
                    .disabled(model.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}


#Preview("Existing Gift") {
    let gift = prepareDependencies {
         do {
             try $0.bootstrapDatabase()
             try $0.seedDatabaseForPreviews()
             return try $0.defaultDatabase.read { db in
                 try Gift.find(UUID(0))
                     .fetchOne(db)!
             }
         } catch {
             fatalError("Failed to bootstrap database for previews: \(error)")
         }
     }
    GiftForm(gift: Gift.Draft(gift))
}

struct GiftFormPreview: PreviewProvider {
    static var previews: some View {
        let gift = Gift.Draft(personID: UUID(0))
        GiftForm(gift: gift)
            .previewDisplayName("New Gift")
    }
}
