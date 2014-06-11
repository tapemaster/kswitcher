import Cocoa
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    @IBOutlet var parentView: NSView
    @IBOutlet var menu: NSMenu
    var statusItem: NSStatusItem?
    let keyHandler = KeyHandler()

    init() {

    }

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        WM2Helper.requestAccessibility()
        WM2Helper.registerHotkeys(keyHandler)
        WM2Helper.setupWindow(window)
        KeyHandler.setWindow(window)
        KeyHandler.setupView(parentView)
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
        statusItem!.menu = menu
        statusItem!.image = NSBundle.mainBundle().imageForResource("icon")
        statusItem!.highlightMode = true
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

}


