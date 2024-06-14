//
//  IntelliProve_POCApp.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 22/12/2023.
//

import SwiftUI

@main
struct IntelliProve_POCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
        }
    }
}
