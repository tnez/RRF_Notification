//
//  RRFNotificationView.m
//  Notification
//
//  Created by Travis Nesland on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RRFNotificationView.h"
#import "RRFNotificationController.h"

@implementation RRFNotificationView

@synthesize myDelegate;
@synthesize myKeyCombo;

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)dealloc {
  [myKeyCombo release];myKeyCombo=nil;
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

- (void)keyDown: (NSEvent *)theEvent {
  if([[theEvent charactersIgnoringModifiers] isEqualToString:myKeyCombo]) {
    [myDelegate exit:self];
  } else {
    [super keyDown:theEvent];
  }
}

@end
