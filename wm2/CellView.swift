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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor(white: 0.5, alpha: 0.3).set()
        dirtyRect.fill()
        let w = min(dirtyRect.width, image.size.width)
        let h = min(dirtyRect.height, image.size.height)
        let targetRect = NSRect(x: dirtyRect.midX - w / CGFloat(2), y: dirtyRect.midY - h / CGFloat(2), width: w, height: h)
        image.draw(in: targetRect)
        
        if selected {
            let selectorRect = NSRect(x: targetRect.minX - w / CGFloat(2), y: targetRect.minY - h / CGFloat(2), width: w * CGFloat(2), height: h * CGFloat(2))
            NSColor.blue.set()
            let path = NSBezierPath(roundedRect: selectorRect, xRadius: 5, yRadius: 5)
            path.stroke()
        }
    }
}
