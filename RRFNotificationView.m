////////////////////////////////////////////////////////////////////////////////
//  RRFNotificationView.m
//  RRFNotification
//  ----------------------------------------------------------------------------
//  Author: Travis Nesland
//  Created: 4/19/11
//  Copyright 2011, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

#import "RRFNotificationView.h"
#import "RRFNotificationController.h"

@implementation RRFNotificationView

@synthesize myDelegate;
@synthesize myChar;
@synthesize myMods;

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)dealloc {
  [myChar release];myChar=nil;
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

- (BOOL)performKeyEquivalent: (NSEvent *)theEvent {
  // get characters
  NSString *theChar = [[theEvent charactersIgnoringModifiers] lowercaseString];
  // get modifiers
  NSUInteger theMods = [theEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;
  // debug log
  DLog(@"Received Chars: %@ Mods: %x",theChar,theMods);
  // if this is the admin key combo...
  if([theChar isEqualToString:myChar] && theMods == myMods) {
    // ...then let's exit
    [myDelegate exit:self];
    return YES;
  }
  // else...
  return NO;
}

@end
