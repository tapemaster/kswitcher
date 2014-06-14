import Foundation
import Cocoa

var window: NSWindow?

var cells = Array<Array<CellView?>>()

@objc class KeyHandler {
    
    enum HotKeys: CUnsignedInt {
        case Left = 123
        case Right = 124
        case Down = 125
        case Up = 126
        
        static let allValues = [Left, Right, Down, Up]
    }
    
    var posX = 0
    var posY = 0
    let data = [
        ["",         "",              "Firefox",        "",           ""        ],
        ["",         "Finder",     "Google Chrome",     "",           ""        ],
        ["Terminal", "Android Studio",  "",        "SourceTree",      ""        ],
        ["",         "",              "Adium",          "",           ""        ],
        ["",         "",              "Mail",           "",           ""        ]
    ]
    

    
    init() {
        WM2Helper.registerHotkeyHandler(self);

        for i in HotKeys.allValues {
            WM2Helper.addHotKey(i.toRaw());
        }
    }
    
    func onLeftPressed() {
        --posX
        stateUpdated()
    }
    
    func onRightPressed() {
        ++posX
        stateUpdated()
    }
    
    func onDownPressed() {
        ++posY
        stateUpdated()
    }
    
    func onUpPressed() {
        --posY
        stateUpdated()
    }
    
    func clip(x: NSInteger, from: NSInteger, to: NSInteger) -> NSInteger {
        return max(from, min(x, to))
    }
    
    func stateUpdated() {
        posX = clip(posX, from: 0, to: data[0].count - 1)
        posY = clip(posY, from: 0, to: data.count - 1)
        window?.orderBack(nil)
        updateWindowPosition()
        disableInactiveCells()
        if let cell = cells[posX][posY] {
            cell.selected = true
            cell.needsDisplay = true
        }
    }
    
    func disableInactiveCells() {
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
    
    func resetPos() {
        posX = 2;
        posY = 2;
        disableInactiveCells()
    }
    
    func onKeyPressed(id: CUnsignedInt) {
        if let hotkey = HotKeys.fromRaw(id) {
            switch hotkey {
            case .Left:
                onLeftPressed()
            case HotKeys.Right:
                onRightPressed()
            case HotKeys.Down:
                onDownPressed()
            case HotKeys.Up:
                onUpPressed()
            }
        }
    }
    
    func onCtrlReleased() {
        let appName = data[posY][posX];
        NSWorkspace.sharedWorkspace().launchApplication(appName)
        resetPos()
        window?.orderOut(nil)
    }
    
    func setWindow(w: NSWindow) {
        resetPos()
        window = w
        updateWindowPosition()
    }
    
    func updateWindowPosition() {
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
    
    func setupView(parentView: NSView) {
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
