import Foundation
import Cocoa

class ClearView : NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clearColor().set()
        NSRectFill(dirtyRect)
    }
}
