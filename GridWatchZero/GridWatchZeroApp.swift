//
//  GridWatchZeroApp.swift
//  Grid Watch Zero
//
//  Created by War Signal on 1/19/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct GridWatchZeroApp: App {

    init() {
        // Migrate save data from old "ProjectPlague" brand to new "GridWatchZero" brand
        // This preserves player progress when updating from pre-rename versions
        BrandMigrationManager.migrateIfNeeded()

        #if canImport(UIKit)
        // Simulator automation and profiling runs should skip UIKit transitions.
        UIView.setAnimationsEnabled(!RenderPerformanceProfile.reducedEffects)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
    }
}
