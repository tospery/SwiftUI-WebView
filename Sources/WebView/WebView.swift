import SwiftUI
import Combine
import WebKit

@dynamicMemberLookup
public class WebViewStore: ObservableObject {
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }
    
    public init(webView: WKWebView = WKWebView()) {
        self.webView = webView
        setupObservers()
    }
    
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }
    
    private var observers: [NSKeyValueObservation] = []
    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T { webView[keyPath: keyPath] }
}

public struct WebView: View, UIViewRepresentable {
    private var navigationDelegateHandler: NavigationDelegateHandler?
    public let webView: WKWebView
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        if let handler = navigationDelegateHandler {
            uiView.navigationDelegate = handler
        }
    }
    
    public func navigationDelegate(
        didStartProvisionalNavigation: ((WKWebView, WKNavigation) -> Void)? = nil,
        didFinish: ((WKWebView, WKNavigation) -> Void)? = nil,
        didFail: ((WKWebView, WKNavigation, Error) -> Void)? = nil,
        decidePolicyFor: ((WKWebView, WKNavigationAction, @escaping (WKNavigationActionPolicy) -> Void) -> Void)? = nil,
        webContentProcessDidTerminate: ((WKWebView) -> Void)? = nil
    ) -> WebView {
        var copy = self
        copy.navigationDelegateHandler = .init(
            didStartProvisionalNavigation: didStartProvisionalNavigation,
            didFinish: didFinish,
            didFail: didFail,
            decidePolicyFor: decidePolicyFor,
            webContentProcessDidTerminate: webContentProcessDidTerminate
        )
        return copy
    }
    
    private class NavigationDelegateHandler: NSObject, WKNavigationDelegate {
        private let didStartProvisionalNavigation: ((WKWebView, WKNavigation) -> Void)?
        private let didFinish: ((WKWebView, WKNavigation) -> Void)?
        private let didFail: ((WKWebView, WKNavigation, Error) -> Void)?
        private let decidePolicyFor: ((WKWebView, WKNavigationAction, @escaping ((WKNavigationActionPolicy) -> Void)) -> Void)?
        private let webContentProcessDidTerminate: ((WKWebView) -> Void)?
        
        
        init(
            didStartProvisionalNavigation: ((WKWebView, WKNavigation) -> Void)?,
            didFinish: ((WKWebView, WKNavigation) -> Void)?,
            didFail: ((WKWebView, WKNavigation, Error) -> Void)?,
            decidePolicyFor: ((WKWebView, WKNavigationAction, @escaping (WKNavigationActionPolicy) -> Void) -> Void)?,
            webContentProcessDidTerminate: ((WKWebView) -> Void)?
        ) {
            self.didStartProvisionalNavigation = didStartProvisionalNavigation
            self.didFinish = didFinish
            self.didFail = didFail
            self.decidePolicyFor = decidePolicyFor
            self.webContentProcessDidTerminate = webContentProcessDidTerminate
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            didStartProvisionalNavigation?(webView, navigation)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            didFinish?(webView, navigation)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("页面加载失败-didFail: \(error)")
            didFail?(webView, navigation, error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            print("页面加载失败-didFailProvisionalNavigation: \(error)")
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
        ) {
            decidePolicyFor?(webView, navigationAction, decisionHandler)
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            print("页面进程崩溃-webViewWebContentProcessDidTerminate")
            webContentProcessDidTerminate?(webView)
        }
        
    }
}
