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
    IntelliWebView(url: "https://plugin-streaming-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJERU1PLUNVU1RPTUVSLTEiLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjotMX0sIm1ldGEiOnt9LCJleHAiOjE3MTQ5MDcyMDV9.7GRRK8zIs4Q_LJ_pDSBVljd6O4K2shfMBxZCmn4UOlM")
}
