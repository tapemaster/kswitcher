import Foundation
import Cocoa

class ClearView : NSView {
    override func drawRect(dirtyRect: NSRect) {
        NSColor.clearColor().set()
        NSRectFill(dirtyRect)
    }
}
