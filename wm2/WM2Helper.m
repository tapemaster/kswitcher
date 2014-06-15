#import <Foundation/Foundation.h>
#import "WM2Helper.h"
#import <Cocoa/cocoa.h>
#import <Carbon/Carbon.h>
#import <AppKit/NSEvent.h>
#import "wm2-Swift.h"

extern Boolean AXIsProcessTrustedWithOptions(CFDictionaryRef options) __attribute__((weak_import));

EventHandlerUPP hotKeyFunction;
FourCharCode ccmdCode = 'CCMD';
FourCharCode ctrlCode = 'CTRL';

pascal OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    EventHotKeyID hkCom;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
    
    KeyHandler* kh = (__bridge KeyHandler*) userData;
    
    int delta = (hkCom.signature == ccmdCode) ? 2 : 1;
    [kh onKeyPressed: hkCom.id delta: delta];
    
    return noErr;
}

@implementation WM2Helper : NSObject

+ (void) requestAccessibility {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    if(!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
        
    }
}

+ (void)setupWindow:(NSWindow *)window {
    [window setLevel:NSFloatingWindowLevel];
    [window setOpaque:NO];
}

+ (void) bringToFront: (KeyHandler*) keyHandler appName:(NSString*) appName {
    pid_t currentProcess = [[NSProcessInfo processInfo] processIdentifier];
    CGSize screenSize = [[NSScreen mainScreen] frame].size;
    
    NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in runningApplications) {
        pid_t pid = [app processIdentifier];
        
        if (pid != currentProcess && pid != ((pid_t) - 1) && ![app.localizedName isEqualToString: appName]) {
            AXUIElementRef _app = AXUIElementCreateApplication(pid);
            CFArrayRef _windows;
            
            AXUIElementCopyAttributeValue((AXUIElementRef)_app,
                                          (CFStringRef)NSAccessibilityWindowsAttribute,
                                          (CFTypeRef*)&_windows);
            
            NSArray *data = [(__bridge NSArray *) _windows copy];
            
            for (int i = 0; i < [data count]; i++) {
                CFTypeRef _window = (__bridge CFTypeRef)data[i];
                CFTypeRef _pos;
                
                AXUIElementCopyAttributeValue((AXUIElementRef)_window,
                                              (CFStringRef)NSAccessibilityPositionAttribute,
                                              (CFTypeRef*)&_pos);
                NSPoint oldPos;
                AXValueGetValue(_pos, kAXValueCGPointType, &oldPos);
                
                WindowData* wd = [[WindowData alloc] init];
                wd.posX = oldPos.x;
                wd.posY = oldPos.y;
                wd.wRef = (__bridge id) _window;
                [keyHandler windowToRestore: wd];
                
                NSPoint pos;
                pos.x = screenSize.width;
                pos.y = screenSize.height;
                _pos = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&pos));
                
                AXUIElementSetAttributeValue((AXUIElementRef)_window,
                                             (CFStringRef)NSAccessibilityPositionAttribute,
                                             (CFTypeRef*)_pos);
            }
        }
    }
}

+ (void) restoreWindow: (WindowData*) data {
    NSPoint pos;
    pos.x = data.posX;
    pos.y = data.posY;
    
    CFTypeRef _pos = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&pos));
    CFTypeRef _window = (__bridge CFTypeRef)data.wRef;
    
    AXUIElementSetAttributeValue((AXUIElementRef)_window,
                                 (CFStringRef)NSAccessibilityPositionAttribute,
                                 (CFTypeRef*)_pos);
}

+ (void)registerHotkeyHandler: (KeyHandler*) keyHandler {
    hotKeyFunction = NewEventHandlerUPP(hotKeyHandler);
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(hotKeyFunction, 1, &eventType, (__bridge void*) keyHandler, NULL);

    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent *event) {
        NSEventType tp = [event type];
        if (tp == NSFlagsChanged) {
            NSUInteger mod = [event modifierFlags];
            if(!(mod & NSControlKeyMask)) {
                [keyHandler onCtrlReleased];
            }
        }
    }];
}

+ (void) addHotKey: (UInt) keyCode {
    EventHotKeyRef theRef = NULL;
    EventHotKeyID keyID;
    keyID.signature = ctrlCode;
    keyID.id = keyCode;
    RegisterEventHotKey(keyCode, controlKey, keyID, GetApplicationEventTarget(), 0, &theRef);
    
    EventHotKeyID keyIDCmd;
    keyIDCmd.signature = ccmdCode;
    keyIDCmd.id = keyCode;
    RegisterEventHotKey(keyCode, controlKey | cmdKey, keyIDCmd, GetApplicationEventTarget(), 0, &theRef);
}

@end
