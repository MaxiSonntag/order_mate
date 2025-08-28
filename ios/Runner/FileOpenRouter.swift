import Flutter
import Foundation
import UIKit

final class FileOpenRouter {
    static let shared = FileOpenRouter()

    private let channelName = "com.msonntag.ordermate/files"
    private var channel: FlutterMethodChannel?
    private var pendingPaths: [String] = []

    private init() {}

    // Call this once when you have a FlutterViewController (from App/Scene)
    func attach(to controller: FlutterViewController) {
        guard channel == nil else { return }
        let ch = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )
        channel = ch

        ch.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "getInitialFiles":
                let out = self.pendingPaths
                self.pendingPaths.removeAll()
                result(out)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Flush anything that arrived before the channel was ready
        if !pendingPaths.isEmpty {
            ch.invokeMethod("onFileOpened", arguments: pendingPaths)
            pendingPaths.removeAll()
        }
    }

    // Entry point for any incoming URL (AppDelegate or SceneDelegate)
    func handle(url: URL) {
        let ext = url.pathExtension.lowercased()
        guard ext == "ordermate" || ext == "json" else {
            print("Ignoring unsupported file: \(url.lastPathComponent)")
            return
        }
        if let local = secureCopyToAppInbox(from: url) { emitOrQueue(local) }
    }

    // Helper if you get a launchOptions[.url]
    func handle(launchURL: URL?) {
        guard let u = launchURL else { return }
        handle(url: u)
    }

    // MARK: - Internals

    private func emitOrQueue(_ path: String) {
        if let ch = channel {
            ch.invokeMethod("onFileOpened", arguments: [path])
            print("FileOpenRouter: emitted -> \(path)")
        } else {
            pendingPaths.append(path)
            print("FileOpenRouter: queued -> \(path)")
        }
    }

    /// Copies potentially external/iCloud file into Application Support/Inbox.
    /// Returns a local sandboxed path you can safely use in Flutter.
    private func secureCopyToAppInbox(from externalURL: URL) -> String? {
        let fm = FileManager.default

        // Destination: <App>/Library/Application Support/Inbox
        guard
            var destDir = fm.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else { return nil }
        destDir.appendPathComponent("Inbox", isDirectory: true)
        try? fm.createDirectory(at: destDir, withIntermediateDirectories: true)

        var resultPath: String?

        // Security scope for Files/iCloud URLs
        let needsScope = externalURL.startAccessingSecurityScopedResource()
        defer {
            if needsScope { externalURL.stopAccessingSecurityScopedResource() }
        }

        // 🔁 iCloud availability check (compatible across SDKs)
        // If the item lives in iCloud and isn't current on-device, ask iOS to download it.
        if let vals = try? externalURL.resourceValues(forKeys: [
            .isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey,
        ]),
            vals.isUbiquitousItem == true
        {
            // Status values can be "current", "downloaded", or "notDownloaded"
            if vals.ubiquitousItemDownloadingStatus
                != URLUbiquitousItemDownloadingStatus.current
            {
                try? fm.startDownloadingUbiquitousItem(at: externalURL)
                // You could optionally wait/poll here, but NSFileCoordinator below
                // usually handles the wait while coordinating the read.
            }
        }

        // Coordinate a read and copy into our sandbox
        let coordinator = NSFileCoordinator()
        var coordError: NSError?
        coordinator.coordinate(
            readingItemAt: externalURL,
            options: [],
            error: &coordError
        ) { readableURL in
            let uniqueName =
                UUID().uuidString + "_" + readableURL.lastPathComponent
            let destURL = destDir.appendingPathComponent(
                uniqueName,
                isDirectory: false
            )
            do {
                try? fm.removeItem(at: destURL)
                try fm.copyItem(at: readableURL, to: destURL)
                resultPath = destURL.path
            } catch {
                print("FileOpenRouter: copy failed -> \(error)")
            }
        }
        if let e = coordError {
            print("FileOpenRouter: coordination error -> \(e)")
        }

        return resultPath
    }
}
