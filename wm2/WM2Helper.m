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
