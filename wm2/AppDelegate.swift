import Cocoa
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow?
    @IBOutlet var parentView: NSView?
    @IBOutlet var menu: NSMenu?
    var statusItem: NSStatusItem?
    let keyHandler = KeyHandler()

    override init() {

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //WM2Helper.requestAccessibility()
        WM2Helper.setupWindow(window)
        keyHandler.setWindow(window!)
        keyHandler.setupView(parentView!)
        
        statusItem = NSStatusBar.system().statusItem(withLength: -1)
        statusItem!.menu = menu
        statusItem!.image = Bundle.main.image(forResource: "icon")
        statusItem!.highlightMode = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}


