//
//  WebView.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import SwiftUI
import WebKit

struct WebView {
    var request: URLRequest
    var configuration: WKWebViewConfiguration = { config in
        config.allowsAirPlayForMediaPlayback = false
        config.limitsNavigationsToAppBoundDomains = true
#if os(iOS)
        config.allowsInlineMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
#endif
        return config
    }(WKWebViewConfiguration())

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let host = navigationAction.request.url?.host, host == "buildkite.com" || host == "www.buildkite.com" else {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}

#if canImport(UIKit)
extension WebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}
#else
extension WebView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(request)
    }
}
#endif

struct WebView_Previews: PreviewProvider {
    static var url = URLRequest(url: URL(string: "https://google.com")!)

    static var previews: some View {
        WebView(request: url)
    }
}
