//
//  SceneDelegate.swift
//  IntelliProve UIKit POC
//
//  Created by Dries Vanmeert on 10/04/2024.
//

import SwiftUI
import IntelliProveSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let urlString = "https://plugin-streaming-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJERU1PLUNVU1RPTUVSLTEiLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjotMX0sIm1ldGEiOnt9LCJleHAiOjE3MTQ5MDcyMDV9.7GRRK8zIs4Q_LJ_pDSBVljd6O4K2shfMBxZCmn4UOlM"

    var window: UIWindow?

    private lazy var navigationController = UINavigationController(
        rootViewController: UIHostingController(rootView: RootView(onButtonTap: { [weak self] in
            self?.showWebView()
        }))
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        self.window = window

        window.rootViewController = navigationController

        window.makeKeyAndVisible()
    }

    private func showWebView() {
        let webViewController = IntelliWebViewFactory.newWebView(urlString: urlString, delegate: self)
        webViewController.modalPresentationStyle = .fullScreen
        navigationController.present(webViewController, animated: true)
    }
}

extension SceneDelegate: IntelliWebViewDelegate {
    func didReceive(postMessage: String) {
        print("POC: \(postMessage)")
    }
}

struct RootView: View {
    let onButtonTap: () -> Void

    var body: some View {
        VStack {
            Text("WebView POC")

            Button {
                onButtonTap()
            } label: {
                Text("Open WebView")
            }
        }
    }
}

