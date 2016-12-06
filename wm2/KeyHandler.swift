import Foundation
import Cocoa

var window: NSWindow?

var cells = Array<Array<CellView?>>()

@objc class KeyHandler : NSObject {
    
    enum HotKeys: CUnsignedInt {
        case left = 123
        case right = 124
        case down = 125
        case up = 126
        
        static let allValues = [left, right, down, up]
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
    

    var stored = Array<WindowData>()
    
    override init() {
        super.init()
        WM2Helper.registerHotkeyHandler(self);

        for i in HotKeys.allValues {
            WM2Helper.addHotKey(i.rawValue)
        }
    }
    
    func clip(_ x: NSInteger, from: NSInteger, to: NSInteger) -> NSInteger {
        return max(from, min(x, to))
    }
    
    func stateUpdated() {
        restoreAllWindows()
        if (posX == 2 && posY == -1) {
            lockScreenImmediate()
            resetPos()
            window?.orderOut(nil)
            restoreAllWindows()
            return
        }
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
    
    func lockScreenImmediate() {
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) (Void) -> Void
        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()
    }
    
    func windowToRestore(_ data: WindowData) {
        stored.append(data)
    }
    
    func restoreAllWindows() {
        for data in stored {
            WM2Helper.restoreWindow(data)
        }
        stored.removeAll(keepingCapacity: false)
    }
    
    func disableInactiveCells() {
        for i in 0 ..< cells.count {
            for j in 0 ..< cells[i].count {
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
    
    func onKeyPressed(_ id: CUnsignedInt, delta: NSInteger) {
        if let hotkey = HotKeys(rawValue: id) {
            switch hotkey {
            case .left:
                posX -= delta
            case HotKeys.right:
                posX += delta
            case HotKeys.down:
                posY += delta
            case HotKeys.up:
                posY -= delta
            }
            stateUpdated();
        }
    }
    
    func onCtrlReleased() {
        let appName = data[posY][posX];
        NSWorkspace.shared().launchApplication(appName)
        resetPos()
        window?.orderOut(nil)
        restoreAllWindows()
    }
    
    func setWindow(_ w: NSWindow) {
        resetPos()
        window = w
        updateWindowPosition()
    }
    
    func updateWindowPosition() {
        let screenRect = NSScreen.main()!.frame
        var height = CGFloat(screenRect.height) / CGFloat(2)
        let minSize = CGFloat(200)
        if height < minSize {
            if screenRect.height < minSize {
                height = screenRect.height
            } else {
                height = minSize
            }
        }
        
        var width = CGFloat(screenRect.width) / CGFloat(2)
        
        if width < minSize {
            if screenRect.width < minSize {
                width = screenRect.width
            } else {
                width = minSize
            }
        }
        let frameRect = NSRect(x:screenRect.midX - width / CGFloat(2), y: screenRect.midY - height / CGFloat(2), width: width, height: height)
        window?.setFrame(frameRect, display: true)
    }
    
    func setupView(_ parentView: NSView) {
        let columns = data[0].count
        let rows = data.count

        let r = parentView.frame
        let stepX = r.width / CGFloat(columns)
        let stepY = r.height / CGFloat(rows)
        
        for i in 0 ..< columns {
            cells.append(Array<CellView>())
            for j in 0 ..< rows {
                var button : CellView? = nil
                let path = NSWorkspace.shared().fullPath(forApplication: data[j][i])
                if path != nil && !path!.isEmpty {
                    let bRect = NSRect(x:r.minX + stepX * CGFloat(i), y:r.maxY - stepY - stepY * CGFloat(j), width: stepX, height: stepY)

                    button = CellView(icon: NSWorkspace.shared().icon(forFile: path!), rect: bRect)
                    
                    parentView.addSubview(button!)
                }
                
                cells[i].append(button)
            }
        }
    }
}
