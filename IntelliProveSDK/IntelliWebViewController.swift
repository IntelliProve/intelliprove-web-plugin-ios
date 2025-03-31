//
//  IntelliWebViewController.swift
//  IntelliProveSDK
//
//  Created by Dries Vanmeert on 01/02/2024.
//

import Foundation
import WebKit
import AVKit

@objc public class IntelliWebViewFactory: NSObject {
    @objc public static func newWebView(
        urlString: String,
        delegate: IntelliWebViewDelegate
    ) -> UIViewController {
        let webViewController = IntelliWebViewController(url: urlString)
        webViewController.delegate = delegate
        webViewController.doDismiss = { [weak webViewController] in
            webViewController?.dismiss(animated: true)
        }
        return webViewController
    }
}

@objc public protocol IntelliWebViewDelegate: AnyObject {
    /// This method gets triggered when a postMessage was received from the WebView.
    /// - Parameters:
    ///   - postMessage: The body of the postMessage as a JSON String
    func didReceive(postMessage: String)
}

private enum Constants {
    static let postMessageHandlerName = "IntelliProvePostMessageHandler"
}

class IntelliWebViewController: UIViewController {
    private let url: String

    weak var delegate: IntelliWebViewDelegate?

    var doDismiss: (() -> Void)?

    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var postMessageHandler = PostMessageHandler(intelliWebViewController: self)

    private lazy var configuration: WKWebViewConfiguration = {
        // Ensure inline camera access
        // Important to set this configuration *before* starting the WKWebView
        // Otherwise the camera is opened fullscreen anyway, instead of under the custom UI
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true

        // Disable zoom
        let disableZoomJS = """
var meta = document.createElement('meta');
meta.name = 'viewport';
meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
var head = document.getElementsByTagName('head')[0];
head.appendChild(meta);
"""
        let disableZoomScript = WKUserScript(
            source: disableZoomJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(disableZoomScript)

        // Patch PostMessage API
        configuration.userContentController.add(postMessageHandler, name: Constants.postMessageHandlerName)

        let postMessageJS = """
window.postMessage = function(data) {
    var jsonString = JSON.stringify(data)
    window.webkit.messageHandlers.\(Constants.postMessageHandlerName).postMessage(jsonString);
};
"""
        let postMessageScript = WKUserScript(
            source: postMessageJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(postMessageScript)

        return configuration
    }()

    private lazy var webView: WKWebView = {
        // WKWebView init
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.contentMode = .scaleToFill

        // Disable overscroll and indicators
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Needed to inspect the Web Session from within Safari Dev Tools
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        // Extend webView under safeAreaInsets
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            [.portrait, .portraitUpsideDown]
        } else {
            .portrait
        }
    }
}

extension IntelliWebViewController: WKNavigationDelegate, WKUIDelegate {
    // This WKUIDelegate function is called from the WKWebView whenever camera or microphone access is needed.
    // In this function, we test whether access was already given.
    // If the user was not yet prompted before, we prompt the user through the `AVCaptureDevice.requestAccess()`.
    // If the user *was* already prompted before, we return a `.grant` or `.deny` based on the permission status.
    // NOTE: iOS only allows prompting the user *once* for the same permission.
    // So if the user *denies* permission, they can only grant it by manually going to the iOS Settings.
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            let isAuthorized: Bool = await {
                switch type {
                case .camera:
                    return await self.isVideoAuthorized
                case .microphone:
                    return await self.isAudioAuthorized
                case .cameraAndMicrophone:
                    let isVideoAuthorized = await self.isVideoAuthorized
                    let isAudioAuthorized = await self.isAudioAuthorized
                    return isVideoAuthorized && isAudioAuthorized
                @unknown default:
                    return false
                }
            }()

            decisionHandler(isAuthorized ? .grant : .deny)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.targetFrame == nil {
            // The link tries to open in a new tab, handle it manually
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url) // Opens in Safari
                decisionHandler(.cancel) // Prevents WebView from handling it
                return
            }
        }
        
        decisionHandler(.allow) // Default navigation behavior
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        
        // Handle `window.open()` by opening the link in Safari
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        
        return nil // Prevents WebView from trying to open a new window itself
    }

    private var isVideoAuthorized: Bool {
        get async {
            let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)

            // Determine if the user previously authorized camera access.
            var isVideoAuthorized = videoStatus == .authorized

            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if videoStatus == .notDetermined {
                isVideoAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }

            return isVideoAuthorized
        }
    }

    private var isAudioAuthorized: Bool {
        get async {
            let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)

            // Determine if the user previously authorized microphone access.
            var isAudioAuthorized = audioStatus == .authorized

            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if audioStatus == .notDetermined {
                isAudioAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }

            return isAudioAuthorized
        }
    }
}

private class PostMessageHandler: NSObject, WKScriptMessageHandler {
    init(intelliWebViewController: IntelliWebViewController) {
        self.intelliWebViewController = intelliWebViewController
    }

    private weak var intelliWebViewController: IntelliWebViewController?

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == Constants.postMessageHandlerName,
              let messageBody = message.body as? String else { return }

        print("Received postMessage: \(messageBody)")

        let stage = stage(from: messageBody)

        if stage == "dismiss" {
            intelliWebViewController?.doDismiss?()
        } else {
            intelliWebViewController?.delegate?.didReceive(postMessage: messageBody)
        }
    }

    private func stage(from jsonString: String) -> String? {
        do {
            guard let jsonData = jsonString.data(using: .utf8) else { return nil }
            return try JSONDecoder().decode(PostMessage.self, from: jsonData).stage
        } catch {
            return nil
        }
    }
}

private struct PostMessage: Codable {
    let stage: String
}
