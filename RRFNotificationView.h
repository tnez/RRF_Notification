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
  IBOutlet NSString *myKeyCombo;
}
@property (assign) IBOutlet RRFNotificationController *myDelegate;
@property (copy) IBOutlet NSString *myKeyCombo;
@end
