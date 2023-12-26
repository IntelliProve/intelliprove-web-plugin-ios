//
//  ContentView.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 22/12/2023.
//

import SwiftUI
import WebKit

struct ContentView: View {
    let url = "https://plugin-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJOZWJ1bGFlIHRlc3RpbmciLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjoxMDAwfSwibWV0YSI6e30sImV4cCI6MTcxNTA3NDIyMn0.kQvGQD_8wFzmLjgFMuft_i3nWjAxSKWx5oI_FBFEYXI"

    var body: some View {
        WebView(url: url).edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> WKWebView {
        // Ensure inline camera access
        // Important to set this configuration *before* starting the WKWebView
        // Otherwise the camera is opened fullscreen anyway, instead of under the custom UI
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.contentMode = .scaleToFill

        // Needed to inspect the Web Session from within Safari Dev Tools
        webView.isInspectable = true

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
            uiView.contentMode = .scaleToFill
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Implement WKNavigationDelegate and WKUIDelegate methods if needed
    }
}

#Preview {
    ContentView()
}
