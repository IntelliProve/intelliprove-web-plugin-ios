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
    let url = "https://plugin-streaming-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJERU1PLUNVU1RPTUVSLTEiLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjotMX0sIm1ldGEiOnt9LCJleHAiOjE3MTQ5MDcyMDV9.7GRRK8zIs4Q_LJ_pDSBVljd6O4K2shfMBxZCmn4UOlM"

    var body: some View {
        IntelliWebView(url: url)
            //.edgesIgnoringSafeArea(.all) // Comment this line to pin to safeAreaInsets (content does not grow under camera bezel)
    }
}

#Preview {
    ContentView()
}
