
#import "windowcontroller.h"




@implementation CWindowController



- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];

	if (self)
	{
    }

	return self;
}


- (void) keyDown:(NSEvent *)event
{
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];

	switch (c)
	{
		case 27:  // esc
			break;
        case '#':
            break_debug();
            break;
	}

	[super keyDown:event];
}

@end
