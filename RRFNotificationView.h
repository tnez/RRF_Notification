////////////////////////////////////////////////////////////////////////////////
//  RRFNotificationView.h
//  RRFNotification
//  ----------------------------------------------------------------------------
//  Author: Travis Nesland
//  Created: 4/19/11
//  Copyright 2011, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

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
