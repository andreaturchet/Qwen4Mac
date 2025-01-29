//
//  Qwen4Mac
//
//  Created by Andrea Turchet on 29/01/2025
//
import SwiftUI
import AppKit

class MainNSViewController: NSViewController {
    override func loadView() {
        // Create a hosting controller with your SwiftUI view
        let hostingController = NSHostingController(rootView: MainUI())
        self.view = hostingController.view
        self.view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 600))
    }

    override func mouseDragged(with event: NSEvent) {
        guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate,
              let popover = appDelegate.popover else { return }
        
        var size = popover.contentSize
        size.width += event.deltaX
        size.height += event.deltaY
        
        // Ensure the size does not go below a minimum threshold
        size.width = max(size.width, 300)
        size.height = max(size.height, 400)
        
        // Update popover size
        popover.contentSize = size
    }
}
