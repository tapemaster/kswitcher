import Foundation
import Cocoa

class CellView : NSView {
    
    let image : NSImage
    let rect : NSRect
    var selected : Bool
    
    init(icon : NSImage, rect : NSRect) {
        image = icon
        self.rect = rect
        selected = false
        super.init(frame: rect)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor(white: 0.5, alpha: 0.3).set()
        NSRectFill(dirtyRect)
        let width = min(dirtyRect.width, image.size.width)
        let height = min(dirtyRect.height, image.size.height)
        let targetRect = NSRect(x: dirtyRect.midX - width / Double(2), y: dirtyRect.midY - height / Double(2), width: width, height: height)
        image.drawInRect(targetRect)
        
        if selected {
            let selectorRect = NSRect(x: targetRect.minX - width / Double(2), y: targetRect.minY - height / Double(2), width: width * Double(2), height: height * Double(2))
            NSColor.blueColor().set()
            let path = NSBezierPath(roundedRect: selectorRect, xRadius: 5, yRadius: 5)
            path.stroke()
        }
    }
}
