#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>

@interface WM2Helper : NSObject
+ (void) requestAccessibility;
+ (void) registerHotkeys;
+ (void) setupWindow: (NSWindow*) window;
@end
