import Foundation
import Cocoa

var posX = 0
var posY = 0
var window: NSWindow?
let data = [
    ["",         "",             "Firefox",  "",           ""         ],
    ["",         "Finder",        "Mail",    "",           ""         ],
    ["Terminal", "Android Studio",  "",  "SourceTree", "Google Chrome"],
    ["",         "",              "Adium",    "",           ""        ],
    ["",         "",              "",         "",           ""        ]
]

var cells = Array<Array<CellView?>>()

@objc class KeyHandler {
    
    init() {
    }
    
    class func onLeftPressed() {
        --posX
        if (posX < 0) {
            posX = 0
        }
        stateUpdated()
    }
    
    class func onRightPressed() {
        ++posX
        if (posX >= data[0].count) {
            posX = data[0].count - 1
        }
        stateUpdated()
    }
    
    class func onDownPressed() {
        ++posY
        if (posY >= data.count) {
            posY = data.count - 1
        }
        stateUpdated()
    }
    
    class func onUpPressed() {
        --posY
        if (posY < 0) {
            posY = 0
        }
        stateUpdated()
    }
    
    class func stateUpdated() {
        window?.orderBack(nil)
        let appName = data[posY][posX];
        NSWorkspace.sharedWorkspace().launchApplication(appName)
        disableInactiveCells()
        if let cell = cells[posX][posY] {
            cell.selected = true
            cell.needsDisplay = true
        }
    }
    
    class func disableInactiveCells() {
        for var i = 0; i < cells.count; ++i {
            for var j = 0; j < cells[i].count; ++j {
                if let cell = cells[i][j] {
                    if (cell.selected) {
                        cell.selected = false
                        cell.needsDisplay = true
                    }
                }
            }
        }
    }
    
    class func resetPos() {
        posX = 2;
        posY = 2;
        disableInactiveCells()
    }
    
    class func onCtrlReleased() {
        resetPos()
        window?.orderOut(nil)
    }
    
    class func setWindow(w: NSWindow) {
        resetPos()
        window = w
        let screenRect = NSScreen.mainScreen()!.frame
        var height = screenRect.height / Double(2)
        let minSize = Double(200)
        if height < minSize {
            if screenRect.height < minSize {
                height = screenRect.height
            } else {
                height = minSize
            }
        }
        
        var width = screenRect.width / Double(2)
        
        if width < minSize {
            if screenRect.width < minSize {
                width = screenRect.width
            } else {
                width = minSize
            }
        }
        let frameRect = NSRect(x:screenRect.midX - width / Double(2), y: screenRect.midY - height / Double(2), width: width, height: height)
        window?.setFrame(frameRect, display: true)
    }
    
    class func setupView(parentView: NSView) {
        let columns = data[0].count
        let rows = data.count

        let r = parentView.frame
        let stepX = r.width / Double(columns)
        let stepY = r.height / Double(rows)
        
        for var i = 0; i < columns; ++i {
            cells.append(Array<CellView>())
            for var j = 0; j < rows; ++j {
                var button : CellView? = nil
                let path = NSWorkspace.sharedWorkspace().fullPathForApplication(data[j][i])
                if path != nil && !path.isEmpty {
                    let bRect = NSRect(x:r.minX + stepX * Double(i), y:r.maxY - stepY - stepY * Double(j), width: stepX, height: stepY)

                    button = CellView(icon: NSWorkspace.sharedWorkspace().iconForFile(path), rect: bRect)
                    
                    parentView.addSubview(button)
                }
                
                cells[i].append(button)
            }
        }
    }
}
