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

struct SyncProgressViewModifier: ViewModifier {
    @Dependency(\.defaultSyncEngine) var syncEngine
    var personCount: Int
    func body(content: Content) -> some View {
        if syncEngine.isSynchronizing {
            ZStack {
                content
                VStack {
                    if personCount == 0 {
                        ContentUnavailableView("Synchronizing", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle", description: Text("Synchronizing your gift registry with CloudKit"))
                    }
                    ProgressView()
                }
            }
        } else {
            content
        }
    }
}

extension View {
    func syncProgress(personCount: Int) -> some View {
        modifier(SyncProgressViewModifier(personCount: personCount))
    }
}
