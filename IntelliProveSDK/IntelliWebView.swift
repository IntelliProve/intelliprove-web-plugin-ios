//
//  IntelliWebView.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 03/01/2024.
//

import SwiftUI

public struct IntelliWebView: UIViewControllerRepresentable {
    private let url: String
    private weak var delegate: IntelliWebViewDelegate?

    public init(url: String, delegate: IntelliWebViewDelegate? = nil) {
        self.url = url
        self.delegate = delegate
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        let webViewController = IntelliWebViewController(url: url)
        webViewController.delegate = delegate
        return webViewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    IntelliWebView(url: "https://plugin-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJOZWJ1bGFlIHRlc3RpbmciLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjoxMDAwfSwibWV0YSI6e30sImV4cCI6MTcxNTA3NDIyMn0.kQvGQD_8wFzmLjgFMuft_i3nWjAxSKWx5oI_FBFEYXI")
}
