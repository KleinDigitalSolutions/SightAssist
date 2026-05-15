//
//  SightAssistApp.swift
//  SightAssist
//
//  Created by Özgür Azap on 15.05.26.
//

import SwiftUI
import UIKit

@main
struct SightAssistApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                UIApplication.shared.isIdleTimerDisabled = true
            case .background, .inactive:
                UIApplication.shared.isIdleTimerDisabled = false
            @unknown default: break
            }
        }
    }
}
