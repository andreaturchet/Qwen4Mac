//
//  Qwen4Mac
//
//  Created by Andrea Turchet on 29/01/2025
//
import SwiftUI
import AppKit

class MainNSViewController: NSViewController {
    override func loadView() {
        let rootView = PopoverContentView()
        let hostingController = NSHostingController(rootView: MainUI())

        rootView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: rootView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
        ])

        self.view = rootView
        self.view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 600)) 
    }

    override func mouseDragged(with event: NSEvent) {
        guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate,
              let popover = appDelegate.popover else { return }
        
        var size = popover.contentSize
        size.width += event.deltaX
        size.height += event.deltaY
        
        size.width = max(size.width, 300)
        size.height = max(size.height, 400)
        
        popover.contentSize = size
    }
}
