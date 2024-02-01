//
//  ContentView.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 22/12/2023.
//

import SwiftUI
import WebKit
import AVKit
import IntelliProveSDK

struct ContentView: View {
    let url = "https://plugin-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJOZWJ1bGFlIHRlc3RpbmciLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjoxMDAwfSwibWV0YSI6e30sImV4cCI6MTcxNTA3NDIyMn0.kQvGQD_8wFzmLjgFMuft_i3nWjAxSKWx5oI_FBFEYXI"

    var body: some View {
        IntelliWebView(url: url)
            //.edgesIgnoringSafeArea(.all) // Comment this line to pin to safeAreaInsets (content does not grow under camera bezel)
    }
}

#Preview {
    ContentView()
}
