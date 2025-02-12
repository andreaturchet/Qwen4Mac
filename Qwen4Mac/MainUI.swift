//
//  Qwen4Mac
//
//  Created by Andrea Turchet on 29/01/2025
//
import SwiftUI
import WebKit

// Extension to initialize Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(red: Double((int & 0xFF0000) >> 16) / 255, green: Double((int & 0x00FF00) >> 8) / 255, blue: Double(int & 0x0000FF) / 255)
    }
}

struct MainUI: View {
    @State private var webViewAction = WebViewAction.idle
    @State private var webViewState = WebViewState.empty
    private let webAddress = "https://chat.qwenlm.ai"

    private var webConfig: WebViewConfig {
        WebViewConfig(customUserAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15")
    }

    // Define the desired background color
    private var headerBackgroundColor: Color {
        Color(hex: "#6a59e3")
    }


    var body: some View {
        VStack(spacing: 0) {
            navigationToolbar
            errorView
            WebView(config: webConfig,
                    action: $webViewAction,
                    state: $webViewState,
                    restrictedPages: nil)
            Divider()
        }
        .onAppear {
            loadAddress()
        }
        .background(headerBackgroundColor) // Apply header color to the entire popover background
    }

    private var navigationToolbar: some View {
        HStack(spacing: 10) {
            ToolbarButton(systemName: "square.and.pencil") {
                loadNewChat()
            }
            Spacer()
            if webViewState.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ToolbarButton(systemName: "arrow.counterclockwise") {
                    webViewAction = .reload
                }
            }
        }
        .padding(15)
        .background(headerBackgroundColor) // Header bar still uses the same color
    }

    @ViewBuilder
    private var errorView: some View {
        if let error = webViewState.error {
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }

    private func loadNewChat() {
        guard let baseURL = URL(string: webAddress),
              let newChatURL = URL(string: "/", relativeTo: baseURL)
        else { return }
        webViewAction = .load(URLRequest(url: newChatURL))
    }

    private func loadAddress() {
        guard let url = URL(string: webAddress) else { return }
        webViewAction = .load(URLRequest(url: url))
    }
}

struct ToolbarButton: View {
    let systemName: String
    let disabled: Bool
    let action: () -> Void

    init(systemName: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.systemName = systemName
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .imageScale(.large)
                .foregroundColor(disabled ? .gray : .primary)
        }
        .disabled(disabled)
    }
}

struct WebViewHelper {
    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    print("[WebCacheCleaner] Record \(record) deleted")
                }
            }
        }
    }
}

struct MainUI_Previews: PreviewProvider {
    static var previews: some View {
        MainUI()
    }
}
