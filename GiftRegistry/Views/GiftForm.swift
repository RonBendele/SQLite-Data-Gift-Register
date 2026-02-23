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
import PhotosUI

@MainActor
@Observable
class GiftFormModel {
    var gift: Gift.Draft
    var name:String
    var price: Double?
    var isPurchased: Bool
    var photosPickerItem: PhotosPickerItem?
    var isPhotoPickerPresented = false
    var giftImageData: Data?
    var selectedOccasions: [Occasion]
    var editOccasions = false
    
    init(gift: Gift.Draft, selectedOccasions:[Occasion]) {
        self.gift = gift
        name = gift.name
        price = gift.price
        isPurchased = gift.isPurchased
        self.selectedOccasions = selectedOccasions
    }
    
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    func saveGiftButtonTapped() {
        withErrorReporting {
            gift.name = name
            gift.price = price
            gift.isPurchased = isPurchased
            try database.write { db in
                let giftID = try Gift
                    .upsert { gift }
                    .returning(\.id)
                    .fetchOne(db)
                guard let giftID else { return }
                if let giftImageData {
                    try GiftAsset
                        .upsert {
                            GiftAsset(giftID: giftID, giftImageData: giftImageData)
                        }
                        .execute(db)
                } else {
                    try GiftAsset
                        .find(giftID)
                        .delete()
                        .execute(db)
                }
                let currentOccasionGiftIDs = try OccasionGift
                    .where { $0.giftID.eq(giftID)}
                    .select(\.occasionID)
                    .fetchAll(db)
                let selectedOccasionIDs = Set(selectedOccasions.map { $0.id })
                let occasionIDsToDelete = Set(currentOccasionGiftIDs).subtracting(selectedOccasionIDs)
                let occasionIDsToInsert = selectedOccasionIDs.subtracting(currentOccasionGiftIDs)
                // Delete
                try OccasionGift
                    .where { $0.giftID.is(gift.id)
                        && $0.occasionID.in(occasionIDsToDelete)
                    }
                    .delete()
                    .execute(db)
                
                // insert
                try OccasionGift
                    .insert {
                        occasionIDsToInsert.map {
                            OccasionGift.Draft(occasionID: $0, giftID: giftID)
                        }
                    }
                    .execute(db)
            }
        }
    }
    
    func fetchGiftImage() async {
        if let giftID = gift.id {
            await withErrorReporting {
              giftImageData =  try await database.read { db in
                    try GiftAsset
                      .where { $0.giftID.eq(giftID) }
                      .select( \.giftImageData)
                      .fetchOne(db)
                }
            }
        }
    }
    
    func updatePhotos() async {
        if let photosPickerItem {
            await withErrorReporting {
                giftImageData = try await photosPickerItem.loadTransferable(type: Data.self)
                    .flatMap({ data in
                        resizedAndOptimizedImageData(from: data)
                    })
                self.photosPickerItem = nil
            }
        }
    }
    
    func resizedAndOptimizedImageData(from data: Data, maxWidth: CGFloat = 1000) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let originalSize = image.size
        let scaleFactor = min(1, maxWidth / originalSize.width)
        let newSize = CGSize(
            width: originalSize.width * scaleFactor,
            height: originalSize.height * scaleFactor
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage?.jpegData(compressionQuality: 0.8)
    }
    
    func deleteOccasionButtonTapped(_ occasion: Occasion) {
        if let index = selectedOccasions.firstIndex(where: {$0.id == occasion.id}) {
            selectedOccasions.remove(at: index)
        }
    }
}

struct GiftForm: View {
    @State private var model: GiftFormModel
    
    init(gift: Gift.Draft, selectedOccasions: [Occasion]) {
        self._model = State(initialValue: GiftFormModel(gift: gift, selectedOccasions: selectedOccasions))
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
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(model.selectedOccasions) { occasion in
                                    Text(occasion.name)
                                        .font(.caption2)
                                        .padding(.vertical, 3)
                                        .padding(.horizontal, 8)
                                        .background(occasion.color, in: .capsule)
                                        .foregroundStyle(occasion.color.adaptedTextColor)
                                        .overlay(alignment: .topTrailing) {
                                            Button {
                                                withAnimation {
                                                    model.deleteOccasionButtonTapped(occasion)
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                            }
                                            .offset(x: 6, y: -6)
                                        }
                                }
                            }
                            .padding(.top, 8)
                            .padding(.trailing, 12)
                        }
                    } header: {
                        HStack {
                            Text("Occasions")
                            Spacer()
                            Button {
                                model.editOccasions = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                            }
                        }
                        .sheet(isPresented: $model.editOccasions) {
                            OccasionsList(selectedOccasions: $model.selectedOccasions)
                        }
                    }
                }
                Group {
                    if let imageData = model.giftImageData,
                       let giftImage = UIImage(data: imageData){
                        Image(uiImage: giftImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .padding()
                HStack {
                    Spacer()
                    Button("Update Photo", systemImage: "photo") {
                        model.isPhotoPickerPresented = true
                    }
                    .buttonStyle(.glass)
                    if model.giftImageData != nil {
                        Spacer()
                        Button("Remove", systemImage: "xmark.circle.fill") {
                            model.giftImageData = nil
                        }
                        .buttonStyle(.glass)
                    }
                    Spacer()
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
            .photosPicker(isPresented: $model.isPhotoPickerPresented, selection: $model.photosPickerItem)
            .onChange(of: model.photosPickerItem) {
                Task {
                    await model.updatePhotos()
                }
            }
            .task {
                await model.fetchGiftImage()
            }
        }
    }
}


#Preview("Existing Gift") {
    let (gift, occasions) = prepareDependencies {
         do {
             try $0.bootstrapDatabase()
             try $0.seedDatabaseForPreviews()
             return try $0.defaultDatabase.read { db in
                 let gift = try Gift.find(UUID(3))
                     .fetchOne(db)!
                 let occasionGiftRecords = try OccasionGift
                     .fetchAll(db)
                     .filter { $0.giftID == gift.id }
                 let occasionIDs = occasionGiftRecords.map(\.occasionID)
                 let occasions = try Occasion
                     .fetchAll(db)
                     .filter { occasionIDs.contains($0.id)}
                 return(gift,occasions)
             }
         } catch {
             fatalError("Failed to bootstrap database for previews: \(error)")
         }
     }
    GiftForm(gift: Gift.Draft(gift), selectedOccasions: occasions)
}

struct GiftFormPreview: PreviewProvider {
    static var previews: some View {
        let gift = Gift.Draft(personID: UUID(0))
        GiftForm(gift: gift, selectedOccasions: [])
            .previewDisplayName("New Gift")
    }
}
