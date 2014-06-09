#import <Foundation/Foundation.h>
#import "WM2Helper.h"
#import <Cocoa/cocoa.h>
#import <Carbon/Carbon.h>
#import <AppKit/NSEvent.h>
#import "wm2-Swift.h"

extern Boolean AXIsProcessTrustedWithOptions(CFDictionaryRef options) __attribute__((weak_import));

EventHandlerUPP hotKeyFunction;

pascal OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    EventHotKeyID hkCom;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
    
    switch (hkCom.id) {
        case 1:
            [KeyHandler onLeftPressed];
            break;
        case 2:
            [KeyHandler onRightPressed];
            break;
        case 3:
            [KeyHandler onDownPressed];
            break;
        case 4:
            [KeyHandler onUpPressed];
            break;
    }
    
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

+ (void)registerHotkeys {
    //handler
    hotKeyFunction = NewEventHandlerUPP(hotKeyHandler);
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(hotKeyFunction, 1, &eventType, (__bridge void*)self, NULL);
    //hotkey 1
    UInt32 keyCode1 = 123; //left arrow
    EventHotKeyRef theRef = NULL;
    EventHotKeyID keyID1;
    keyID1.signature = 'FOO '; //arbitrary string
    keyID1.id = 1;
    RegisterEventHotKey(keyCode1, controlKey, keyID1, GetApplicationEventTarget(), 0, &theRef);
    //hotkey 2
    UInt32 keyCode2 = 124; //right arrow
    EventHotKeyID keyID2;
    keyID2.signature = 'FOO '; //arbitrary string
    keyID2.id = 2;
    RegisterEventHotKey(keyCode2, controlKey, keyID2, GetApplicationEventTarget(), 0, &theRef);
    //hotkey 3
    UInt32 keyCode3 = 125; //down arrow
    EventHotKeyID keyID3;
    keyID3.signature = 'FOO '; //arbitrary string
    keyID3.id = 3;
    RegisterEventHotKey(keyCode3, controlKey, keyID3, GetApplicationEventTarget(), 0, &theRef);
    //hotkey 4
    UInt32 keyCode4 = 126; //up arrow
    EventHotKeyID keyID4;
    keyID4.signature = 'FOO '; //arbitrary string
    keyID4.id = 4;
    RegisterEventHotKey(keyCode4, controlKey, keyID4, GetApplicationEventTarget(), 0, &theRef);
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent *event) {
        NSEventType tp = [event type];
        if (tp == NSFlagsChanged) {
            NSUInteger mod = [event modifierFlags];
            if(!(mod & NSControlKeyMask)) {
                [KeyHandler onCtrlReleased];
            }
        }
    }];
    
}

@end
