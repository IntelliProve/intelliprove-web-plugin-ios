//
//  IntelliWebView.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 03/01/2024.
//

import SwiftUI

public struct IntelliWebViewLink<Label: View>: View {
    private let url: String
    private let delegate: IntelliWebViewDelegate?

    @ViewBuilder
    private let label: () -> Label

    @State private var isPresented = false

    /// Creates a navigation link that presents the IntelliWebView as a full screen modal.
    /// - Parameters:
    ///   - urlString: The url of the IntelliProve plugin to be shown
    ///   - delegate: A delegate object to receive callbacks from the IntelliProve plugin
    ///   - label: A view builder to produce a label describing the `destination`
    ///    to present.
    public init(
        urlString: String,
        delegate: IntelliWebViewDelegate? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.url = urlString
        self.delegate = delegate
        self.label = label
    }

    public var body: some View {
        Button(
            action: {
                isPresented.toggle()
            },
            label: {
                HStack(spacing: 0) {
                    label()
                    NavigationLink.empty.layoutPriority(-1)
                }
            }
        )
        .fullScreenCover(isPresented: $isPresented) {
            IntelliWebView(
                url: url,
                delegate: delegate,
                doDismiss: { isPresented = false }
            )
        }
    }
}

private extension NavigationLink where Label == EmptyView, Destination == EmptyView {
    static var empty: NavigationLink {
        NavigationLink(destination: EmptyView(), label: { EmptyView() })
    }
}

private struct IntelliWebView: UIViewControllerRepresentable {
    private let url: String
    private weak var delegate: IntelliWebViewDelegate?
    private let doDismiss: (() -> Void)?

    init(
        url: String,
        delegate: IntelliWebViewDelegate? = nil,
        doDismiss: (() -> Void)? = nil
    ) {
        self.url = url
        self.delegate = delegate
        self.doDismiss = doDismiss
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let webViewController = IntelliWebViewController(url: url)
        webViewController.delegate = delegate
        webViewController.doDismiss = doDismiss
        return webViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    IntelliWebView(url: "https://plugin-rc.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJ0ZXN0aW5nLWFwaS1rZXkiLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjotMSwiYXV0aDBfdXNlcl9pZCI6bnVsbH0sIm1ldGEiOnt9LCJleHAiOjE3MzU2ODk2MDB9.zKWdq4lE6SXOnhvSgHCVvPKTsiwH66likFDNPIe4ozk&patient=DriesVanmeert")
}
