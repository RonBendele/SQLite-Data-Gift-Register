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
    mutating func bootstrapDatabase() throws {
        let database = try SQLiteData.defaultDatabase()
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("Create the 'people' table") { db in
            try #sql(
                """
                CREATE TABLE "people" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "name" TEXT NOT NULL DEFAULT '',
                    "birthDate" TEXT,
                    "notes" TEXT NOT NULL DEFAULT ''
                ) STRICT
                """
            )
            .execute(db)
        }
        migrator.registerMigration("Create table and index for 'gifts'") { db in
            try #sql(
                """
                CREATE TABLE "gifts" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "name" TEXT NOT NULL DEFAULT '',
                    "price" REAL,
                    "isPurchased" INTEGER NOT NULL DEFAULT 0,
                    "personID" TEXT NOT NULL REFERENCES "people"("id") ON DELETE CASCADE
                ) STRICT
                """
            )
            .execute(db)
            try #sql(
                """
                CREATE INDEX "index_gifts_on_personID" ON "gifts"("personID")
                """
            )
            .execute(db)
        }
        migrator.registerMigration("Create 'giftAssets' table") { db in
            try #sql(
                """
                CREATE TABLE "giftAssets" (
                    "giftID" TEXT NOT NULL PRIMARY KEY REFERENCES "gifts"("id") ON DELETE CASCADE,
                    "giftImageData" BLOB NOT NULL
                ) STRICT
                """
            )
            .execute(db)
        }
        try migrator.migrate(database)
        defaultDatabase = database
    }
}
