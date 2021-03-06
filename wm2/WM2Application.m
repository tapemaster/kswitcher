#import <Foundation/Foundation.h>
#import "WM2Application.h"
#import "wm2-Swift.h"

@implementation WM2Application


- (void)sendEvent:(NSEvent *)anEvent
{
    NSEventType tp = [anEvent type];
    if (tp == NSFlagsChanged) {
        NSUInteger mod = [anEvent modifierFlags];
        if(!(mod & NSControlKeyMask)) {
            [[(AppDelegate*)[[NSApplication sharedApplication] delegate] keyHandler] onCtrlReleased];
        }
    }
    [super sendEvent: anEvent];
}

@end
