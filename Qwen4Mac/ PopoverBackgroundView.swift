//
//   PopoverBackgroundView.swift
//  Qwen4Mac
//
//  Created by andrea turchet on 12/02/25.
//

import AppKit

final class PopoverBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let backgroundColor = NSColor(srgbRed: 106.0/255.0, green: 89.0/255.0, blue: 227.0/255.0, alpha: 1.0) // #6a59e3
        backgroundColor.set()
        dirtyRect.fill(using: .copy)
    }
}
