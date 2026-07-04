import Cocoa
import WebKit

// A borderless window pinned at desktop level: above the wallpaper image,
// below the desktop icons. Clicks pass straight through to the desktop.
final class WallpaperWindow: NSWindow {
    init(screen: NSScreen, url: URL) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        hasShadow = false
        backgroundColor = .black

        let webView = WKWebView(frame: contentView!.bounds)
        webView.autoresizingMask = [.width, .height]
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        contentView!.addSubview(webView)
    }

    // Borderless windows refuse key status by default; we never want it anyway.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let htmlURL: URL
    var wallpaperWindows: [NSWindow] = []

    init(htmlURL: URL) { self.htmlURL = htmlURL }

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildWindows()
        // Rebuild when displays are added/removed or resolutions change.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.buildWindows() }
    }

    func buildWindows() {
        wallpaperWindows.forEach { $0.close() }
        wallpaperWindows = NSScreen.screens.map { screen in
            let window = WallpaperWindow(screen: screen, url: htmlURL)
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            return window
        }
    }
}

// The HTML file lives next to the compiled binary unless a path is passed
// as the first argument.
let executableDir = URL(fileURLWithPath: CommandLine.arguments[0])
    .resolvingSymlinksInPath()
    .deletingLastPathComponent()
let htmlURL: URL
if CommandLine.arguments.count > 1 {
    htmlURL = URL(fileURLWithPath: CommandLine.arguments[1])
} else {
    htmlURL = executableDir.appendingPathComponent("starfield.html")
}

guard FileManager.default.fileExists(atPath: htmlURL.path) else {
    FileHandle.standardError.write(Data("starfield: HTML file not found at \(htmlURL.path)\n".utf8))
    exit(1)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // no Dock icon, no menu bar
let delegate = AppDelegate(htmlURL: htmlURL)
app.delegate = delegate
app.run()
