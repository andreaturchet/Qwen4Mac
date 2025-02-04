//
//  Qwen4Mac
//
//  Created by Andrea Turchet on 29/01/2025
//
import Cocoa
import SwiftUI
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSPopoverDelegate {

    private var statusItem: NSStatusItem!
    internal var popover: NSPopover! // Changed to internal
    private var menu: NSMenu!

    private var hotKey = HotKey(key: .c, modifiers: [.shift, .command])
    private var additionalHotKeys: [HotKey] = []
    private let alwaysOnTopKey = "alwaysOnTopPreference" // UserDefaults key
    @AppStorage("isAlwaysOnTop") var isAlwaysOnTop: Bool = false


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        constructPopover()
        constructMenu()
        setupGlobalHotKey()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.togglePopover()
        }
    }


    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let icon = NSImage(named: "menu_bar_icon")
            icon?.isTemplate = true
            button.image = icon
            button.action = #selector(handleMenuIconAction(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func handleMenuIconAction(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            removeMenu()
            togglePopover()
        }
    }

    func menuDidClose(_ menu: NSMenu) {
        removeMenu()
    }

    private func constructMenu() {
        menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Clean Cookies", action: #selector(didTapCleanCookies), keyEquivalent: "1"))

        let alwaysOnTopMenuItem = NSMenuItem(title: "Always on Top", action: #selector(toggleAlwaysOnTop), keyEquivalent: "t")
        alwaysOnTopMenuItem.state = isAlwaysOnTop ? .on : .off
        menu.addItem(alwaysOnTopMenuItem)


        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        menu.delegate = self
    }

    private func constructPopover() {
        popover = NSPopover()
        popover.contentViewController = MainNSViewController()
        popover.delegate = self
        popover.behavior = .transient
    }

    private func showMenu() {
        statusItem.menu = menu
    }

    private func removeMenu() {
        statusItem.menu = nil
    }

    private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
            deinitKeys()
        } else {
            guard let button = statusItem.button else { return }
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.level = isAlwaysOnTop ? .floating : .normal // Set level based on preference
            popover.contentViewController?.view.window?.makeKey()
            constructKeys()
        }
    }

    private func deinitKeys() {
        additionalHotKeys.forEach { $0.keyDownHandler = nil }
        additionalHotKeys.forEach { $0.keyUpHandler = nil }
        additionalHotKeys.removeAll()
    }

    private func constructKeys() {
        additionalHotKeys = [
            HotKey(key: .c, modifiers: [.command], keyDownHandler: { NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) }),
            HotKey(key: .v, modifiers: [.command], keyDownHandler: { NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) }),
            HotKey(key: .x, modifiers: [.command], keyDownHandler: { NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) }),
            HotKey(key: .z, modifiers: [.command], keyDownHandler: { NSApp.sendAction(Selector("undo:"), to: nil, from: self) }),
            HotKey(key: .a, modifiers: [.command], keyDownHandler: { NSApp.sendAction(#selector(NSStandardKeyBindingResponding.selectAll(_:)), to: nil, from: self) })
        ]
    }

    private func setupGlobalHotKey() {
        hotKey.keyUpHandler = { [weak self] in
            self?.togglePopover()
        }
    }

    @objc private func didTapCleanCookies() {
        WebViewHelper.clean()
    }

    @objc private func toggleAlwaysOnTop() {
        isAlwaysOnTop.toggle()
        constructMenu() // Reconstruct menu to update the state of "Always on Top" item
        if popover.isShown { // Re-apply level if popover is already shown
            popover.contentViewController?.view.window?.level = isAlwaysOnTop ? .floating : .normal
        }
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func popoverWillClose(_ notification: Notification) {
        deinitKeys()
    }
}
