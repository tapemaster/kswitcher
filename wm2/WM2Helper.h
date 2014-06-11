#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>
@class KeyHandler;

@interface WM2Helper : NSObject
+ (void) requestAccessibility;
+ (void) registerHotkeys: (KeyHandler*) keyHandler;
+ (void) setupWindow: (NSWindow*) window;
@end
