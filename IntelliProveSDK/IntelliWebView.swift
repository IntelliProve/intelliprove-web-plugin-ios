//
//  IntelliWebView.swift
//  IntelliProve POC
//
//  Created by Dries Vanmeert on 03/01/2024.
//

import SwiftUI
import WebKit
import AVKit

@objc public class IntelliWebViewFactory: NSObject {
    @objc public static func newWebView(urlString: String) -> UIViewController {
        return IntelliWebViewController(url: urlString)
    }
}

public struct IntelliWebView: UIViewControllerRepresentable {
    private let url: String

    public init(url: String) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        IntelliWebViewController(url: url)
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class IntelliWebViewController: UIViewController {
    private let url: String

    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var configuration: WKWebViewConfiguration = {
        // Ensure inline camera access
        // Important to set this configuration *before* starting the WKWebView
        // Otherwise the camera is opened fullscreen anyway, instead of under the custom UI
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true

        // Disable zoom - TODO: Dries - perhaps this should be put in the actual WebApp's code instead?
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
        //webView.scrollView.contentInsetAdjustmentBehavior = .never

        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

#Preview {
    IntelliWebView(url: "https://plugin-dev.intelliprove.com/?action_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImVtYWlsIjoiIiwiY3VzdG9tZXIiOiJOZWJ1bGFlIHRlc3RpbmciLCJncm91cCI6ImFkbWluIiwibWF4X21lYXN1cmVtZW50X2NvdW50IjoxMDAwfSwibWV0YSI6e30sImV4cCI6MTcxNTA3NDIyMn0.kQvGQD_8wFzmLjgFMuft_i3nWjAxSKWx5oI_FBFEYXI")
}
