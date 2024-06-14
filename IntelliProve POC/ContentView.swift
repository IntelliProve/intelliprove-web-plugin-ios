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

class ContentViewModel: ObservableObject {
    let urlString = "https://plugin-rc.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJ0ZXN0aW5nLWFwaS1rZXkiLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjotMSwiYXV0aDBfdXNlcl9pZCI6bnVsbH0sIm1ldGEiOnt9LCJleHAiOjE3MzU2ODk2MDB9.zKWdq4lE6SXOnhvSgHCVvPKTsiwH66likFDNPIe4ozk&patient=DriesVanmeert"
}

extension ContentViewModel: IntelliWebViewDelegate {
    func didReceive(postMessage: String) {
        print("POC: \(postMessage)")
    }
}

struct ContentView: View {
    @ObservedObject
    private(set) var viewModel: ContentViewModel

    var body: some View {
        VStack {
            Text("IntelliProve SwiftUI POC")
                .font(.largeTitle)

            IntelliWebViewLink(
                urlString: viewModel.urlString,
                delegate: viewModel
            ) {
                Text("Show WebView")
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}
