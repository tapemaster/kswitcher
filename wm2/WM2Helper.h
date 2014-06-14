#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>
@class KeyHandler;

@interface WM2Helper : NSObject
+ (void) requestAccessibility;
+ (void) registerHotkeyHandler: (KeyHandler*) keyHandler;
+ (void) addHotKey: (UInt) keyCode;
+ (void) setupWindow: (NSWindow*) window;
@end
