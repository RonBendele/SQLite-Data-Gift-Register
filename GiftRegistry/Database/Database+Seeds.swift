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


import Foundation
import SQLiteData

extension DependencyValues {
    func seedDatabaseForPreviews() throws {
        try defaultDatabase.write { db in
            let formatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-DD"
                return f
            }()
            try db.seed {
                Person(id: UUID(0), name: "Mom", notes: "Likes gardening and cooking")
                Person(id: UUID(1), name: "Dad", birthDate: formatter.date(from: "1968-11-03"), notes: "Enjoys golf and reading")
                Person(id: UUID(2), name: "Sarah", notes: "Sister - loves art supplies")
                Person(id: UUID(3), name: "Grandma", birthDate: formatter.date(from: "1942-02-21"), notes: "Knitting and classic movies")
                Person(id: UUID(4), name: "Grandpa", notes: "Fishing trips on weekends")
                Person(id: UUID(5), name: "Uncle Joe", birthDate: formatter.date(from: "1975-07-08"), notes: "BBQ master")
                Person(id: UUID(6), name: "Aunt Lisa", notes: "Yoga and photography")
                Person(id: UUID(7), name: "Cousin Mike", birthDate: formatter.date(from: "2001-09-14"), notes: "Video games and sneakers")
                Person(id: UUID(8), name: "Emma", birthDate: formatter.date(from: "1992-03-30"), notes: "Co-worker - coffee enthusiast")
                Person(id: UUID(9), name: "Oliver", notes: "Gym buddy")
                Person(id: UUID(10), name: "Ava", birthDate: formatter.date(from: "1995-12-19"), notes: "Neighbor - loves baking")
                Person(id: UUID(11), name: "Liam", notes: "Soccer teammate")
                Person(id: UUID(12), name: "Mia", birthDate: formatter.date(from: "1989-08-05"), notes: "Book club friend")
                Person(id: UUID(13), name: "Noah", notes: "College roommate")
                Person(id: UUID(14), name: "Sophia", birthDate: formatter.date(from: "1998-01-22"), notes: "Choir partner")
                Person(id: UUID(15), name: "James", notes: "Cycling group")
                Person(id: UUID(16), name: "Isabella", birthDate: formatter.date(from: "1993-06-17"), notes: "Art class friend")
                Person(id: UUID(17), name: "Benjamin", notes: "Chess club")
                Person(id: UUID(18), name: "Charlotte", birthDate: formatter.date(from: "1990-04-11"), notes: "Hiking and photography")
                Person(id: UUID(19), name: "Ethan", notes: "Cooking classes on weekends")
                
                // Gifts for Mom (3 gifts)
                Gift(id: UUID(0), name: "Gardening Tool Set", price: 49.99, personID: UUID(0))
                Gift(id: UUID(1), name: "Cookbook Collection", price: 35.00, isPurchased: true, personID: UUID(0))
                Gift(id: UUID(2), name: "Herb Garden Kit", price: 24.99, personID: UUID(0))

                // Gifts for Dad (2 gifts)
                Gift(id: UUID(3), name: "Golf Club Set", price: 299.99, personID: UUID(1))
                Gift(id: UUID(4), name: "Mystery Novel Bundle", price: 45.00, isPurchased: true, personID: UUID(1))

                // Gifts for Sarah (4 gifts)
                Gift(id: UUID(5), name: "Watercolor Paint Set", price: 68.50, personID: UUID(2))
                Gift(id: UUID(6), name: "Premium Sketchbook", price: 22.99, personID: UUID(2))
                Gift(id: UUID(7), name: "Artist Easel", price: 125.00, personID: UUID(2))
                Gift(id: UUID(8), name: "Colored Pencil Set", price: 42.00, isPurchased: true, personID: UUID(2))

                // Gifts for Grandma (1 gift)
                Gift(id: UUID(9), name: "Yarn Collection", price: 55.00, personID: UUID(3))

                // No gifts for Grandpa

                // Gifts for Uncle Joe (2 gifts)
                Gift(id: UUID(10), name: "BBQ Smoker", price: 399.99, personID: UUID(5))
                Gift(id: UUID(11), name: "Spice Rub Set", price: 28.50, isPurchased: true, personID: UUID(5))

                // No gifts for Aunt Lisa

                // Gifts for Cousin Mike (3 gifts)
                Gift(id: UUID(12), name: "PlayStation 5 Game", price: 69.99, personID: UUID(7))
                Gift(id: UUID(13), name: "Limited Edition Sneakers", price: 180.00, personID: UUID(7))
                Gift(id: UUID(14), name: "Gaming Headset", price: 89.99, isPurchased: true, personID: UUID(7))

                // Gifts for Emma (1 gift)
                Gift(id: UUID(15), name: "Espresso Machine", price: 249.99, personID: UUID(8))

                // No gifts for Oliver, Ava, Liam

                // Gifts for Mia (2 gifts)
                Gift(id: UUID(16), name: "Bestseller Book Set", price: 55.00, personID: UUID(12))
                Gift(id: UUID(17), name: "Reading Light", price: 32.99, isPurchased: true, personID: UUID(12))

                // No gifts for Noah, Sophia, James, Isabella, Benjamin

                // Gifts for Charlotte (1 gift)
                Gift(id: UUID(18), name: "Hiking Backpack", price: 129.99, personID: UUID(18))

                // No gifts for Ethan
                
                // Occasions
                Occasion(id: UUID(0), name: "Christmas", hexColor: "C0392B")
                Occasion(id: UUID(1), name: "Birthday", hexColor: "8E44AD")
                Occasion(id: UUID(2), name: "Valentines Day", hexColor: "E91E8C")
                Occasion(id: UUID(3), name: "Wedding", hexColor: "D4AF37")

                // OccasionGifts (Many-to-Many join records)
                OccasionGift(id: UUID(0), occasionID: UUID(0), giftID: UUID(0))
                OccasionGift(id: UUID(1), occasionID: UUID(0), giftID: UUID(1))
                OccasionGift(id: UUID(2), occasionID: UUID(1), giftID: UUID(1))
                OccasionGift(id: UUID(3), occasionID: UUID(2), giftID: UUID(2))
                OccasionGift(id: UUID(4), occasionID: UUID(1), giftID: UUID(3))
                OccasionGift(id: UUID(5), occasionID: UUID(0), giftID: UUID(3))
                OccasionGift(id: UUID(6), occasionID: UUID(3), giftID: UUID(3))
                OccasionGift(id: UUID(7), occasionID: UUID(1), giftID: UUID(4))
                OccasionGift(id: UUID(8), occasionID: UUID(0), giftID: UUID(5))
                OccasionGift(id: UUID(9), occasionID: UUID(1), giftID: UUID(5))
                OccasionGift(id: UUID(10), occasionID: UUID(3), giftID: UUID(7))
                OccasionGift(id: UUID(11), occasionID: UUID(0), giftID: UUID(8))
                OccasionGift(id: UUID(12), occasionID: UUID(1), giftID: UUID(9))
                OccasionGift(id: UUID(13), occasionID: UUID(0), giftID: UUID(9))
                OccasionGift(id: UUID(14), occasionID: UUID(1), giftID: UUID(11))
                OccasionGift(id: UUID(15), occasionID: UUID(2), giftID: UUID(11))
                OccasionGift(id: UUID(16), occasionID: UUID(0), giftID: UUID(12))
                OccasionGift(id: UUID(17), occasionID: UUID(1), giftID: UUID(12))
                OccasionGift(id: UUID(18), occasionID: UUID(3), giftID: UUID(12))
                OccasionGift(id: UUID(19), occasionID: UUID(1), giftID: UUID(14))
                OccasionGift(id: UUID(20), occasionID: UUID(2), giftID: UUID(15))
                OccasionGift(id: UUID(21), occasionID: UUID(3), giftID: UUID(15))
                OccasionGift(id: UUID(22), occasionID: UUID(0), giftID: UUID(16))
                OccasionGift(id: UUID(23), occasionID: UUID(1), giftID: UUID(18))
                OccasionGift(id: UUID(24), occasionID: UUID(0), giftID: UUID(18))
            }
        }
    }
}
