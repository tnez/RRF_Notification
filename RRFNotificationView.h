//
//  RRFNotificationView.h
//  Notification
//
//  Created by Travis Nesland on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RRFNotificationController;

@interface RRFNotificationView : NSView {
  IBOutlet RRFNotificationController *myDelegate;
  NSString *myChar;
  NSUInteger myMods;
}
@property (assign) IBOutlet RRFNotificationController *myDelegate;
@property (copy) NSString *myChar;
@property (readwrite) NSUInteger myMods;
@end
