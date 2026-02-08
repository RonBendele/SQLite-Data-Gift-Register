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
            }
        }
    }
}
