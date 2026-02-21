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

import SwiftUI

extension Color {

    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor: uiColor)
    }

    
    var toHexString: String {
        UIColor(self).toHexString(includeAlpha: false) ?? "0000FF"
    }
    
    var toHexSttringWithAlpha: String {
        UIColor(self).toHexString(includeAlpha: true) ?? "0000FF"
    }
    
    var luminance: Double {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)
        // Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        // Compute luminance.
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
    
    var adaptedTextColor: Color {
        luminance > 0.5 ? Color.black : Color.white
    }


}


