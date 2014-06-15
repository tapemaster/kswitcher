#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>
@class KeyHandler;
@class WindowData;

@interface WM2Helper : NSObject
+ (void) requestAccessibility;
+ (void) registerHotkeyHandler: (KeyHandler*) keyHandler;
+ (void) addHotKey: (UInt) keyCode;
+ (void) setupWindow: (NSWindow*) window;
+ (void) bringToFront: (KeyHandler*) keyHandler appName:(NSString*) appName;
+ (void) restoreWindow: (WindowData*) data;
@end
