////////////////////////////////////////////////////////////////////////////////
//  RRFNotificationController.m
//  RRFNotification
//  ----------------------------------------------------------------------------
//  Author: Travis Nesland
//  Created: 4/19/11
//  Copyright 2011, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////
#import "RRFNotificationController.h"
#import "RRFNotificationView.h"

#define RRFLogToTemp(fmt, ...) [delegate logStringToDefaultTempFile:[NSString stringWithFormat:fmt,##__VA_ARGS__]]
#define RRFLogToFile(filename,fmt, ...) [delegate logString:[NSString stringWithFormat:fmt,##__VA_ARGS__] toDirectory:[delegate tempDirectory] toFile:filename]
#define RRFPathToTempFile(filename) [[delegate tempDirectory] stringByAppendingPathComponent:filename]


#pragma mark FORWARD DECLARATION OF PRIVATE METHODS
@interface RRFNotificationController ()
- (NSUInteger)getModifierFlags;
- (NSInteger)numberOfFormatTokens: (NSString *)aString;
- (NSString *)resolveString;
@end

@implementation RRFNotificationController

@synthesize delegate;
@synthesize definition;
@synthesize errorLog;
@synthesize view;
@synthesize allowClickToProceed;
@synthesize argv;
@synthesize baseString;
@synthesize formattedString;
@synthesize secretKeyCombo;
@synthesize secretMods;

#pragma mark HOUSEKEEPING METHODS
/**
 Give back any memory that may have been allocated by this bundle
 */
- (void)dealloc {
  [errorLog release];errorLog=nil;
  // any additional release calls go here
  // ...
  [argv release];argv=nil;
  [baseString release];baseString=nil;
  [formattedString release];formattedString=nil;
  [secretKeyCombo release];secretKeyCombo=nil;
  [super dealloc];
}

#pragma mark REQUIRED PROTOCOL METHODS
/**
 Start the component - will receive this message from the component controller
 */
- (void)begin {
  // some debug loggin
  DLog(@"My secret key is: %@",secretKeyCombo);
  DLog(@"My secret modifier mask is: %x",secretMods);
}
/**
 Return a string representation of the data directory
 */
- (NSString *)dataDirectory {
  NSString *temp = nil;
  if(temp = [definition valueForKey:RRFNotificationDataDirectoryKey]) {
    return [temp stringByStandardizingPath];    // return standardized path if
                                                // we have one
  } else {
    return nil;                                 // otherwise, return nil
  }
}
/**
 Return a string object representing all current errors in log form
 */
- (NSString *)errorLog {
  return errorLog;
}
/**
 Perform any and all error checking required by the component - return YES if 
 passed
 */
- (BOOL)isClearedToBegin {
  return YES; // this is the default; change as needed
}
/**
 Returns the file name containing the raw data that will be appended to the data
 file
 */
- (NSString *)rawDataFile {
  return [delegate defaultTempFile]; // this is the default implementation
}
/**
 Perform actions required to recover from crash using the given raw data passed
 as string
 */
- (void)recover {
  // if no recovery is needed, nothing need be done here
  // but you may want to consider removing the old data file
  // [[NSFileManager defaultManager] removeItemAtPath:RRFPathToTempFile([delegate defaultTempFile]) error:nil];
  // -- 
}
/**
 Accept assignment for the component definition
 */
- (void)setDefinition: (NSDictionary *)aDictionary {
  definition = aDictionary;
}
/**
 Accept assignment for the component delegate - The component controller will 
 assign itself as the delegate
 Note: The new delegate must adopt the TKComponentBundleDelegate protocol
 */
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate {
  delegate = aDelegate;
}
/**
 Perform any and all initialization required by component - load any nib files 
 and perform all required initialization
 */
- (void)setup {
  [self setErrorLog:@""]; // clear the error log
  // WHAT NEEDS TO BE INITIALIZED BEFORE THIS COMPONENT CAN OPERATE?
  // ...
  allowClickToProceed = [[definition valueForKey:RRFNotificationShouldAllowSubjectClickKey] boolValue];
  [self setArgv:[[definition valueForKey:RRFNotificationArgumentListKey] componentsSeparatedByString:@","]];
  [self setBaseString:[definition valueForKey:RRFNotificationBaseStringKey]];
  [self setSecretKeyCombo:[[definition valueForKey:RRFNotificationSecretKeyComboKey] lowercaseString]];
  secretMods = [self getModifierFlags];
  [self setFormattedString:[self resolveString]];
  // LOAD NIB
  // ...
  if([NSBundle loadNibNamed:RRFNotificationMainNibNameKey owner:self]) {
    // SETUP THE INTERFACE VALUES
    // ...
    [view setMyChar:secretKeyCombo];
    [view setMyMods:secretMods];
    [[view window] makeFirstResponder:view];
  } else {
    // nib did not load, so throw error
    [self registerError:@"Could not load Nib file"];
  }
}
/**
 Return YES if component should perform recovery actions
 */
- (BOOL)shouldRecover {
  return NO;  // this is the default; change if needed
  /* Might consider to recover if a temporary data file exists
     (un-comment to use)
  return [[NSFileManager defaultManager] fileExistsAtPath:RRFPathToTempFile([delegate defaultTempFile]);
   */
}
/**
 Perform any and all finalization required by component
 */
- (void)tearDown {
  // any finalization should be done here:
  // ...
  // remove any temporary data files (uncomment below to use default)
  NSError *tFileMoveError = nil;
  [[NSFileManager defaultManager] removeItemAtPath:RRFPathToTempFile([delegate defaultTempFile]) error:&tFileMoveError];
  if(tFileMoveError) {
    ELog(@"%@",[tFileMoveError localizedDescription]);
    [tFileMoveError release]; tFileMoveError=nil;
  }
  // de-register any possible notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 Return the name of the current task
 */
- (NSString *)taskName {
  return [definition valueForKey:RRFNotificationTaskNameKey];
}
/**
 Return the main view that should be presented to the subject
 */
- (NSView *)mainView {
  return view;
}

#pragma mark OPTIONAL PROTOCOL METHODS
/** Uncomment and implement the following methods if desired */
/**
 Run header if something other than default is required
 */
//- (NSString *)runHeader {
//
//}
/**
 Session header if something other than default is required
 */
//- (NSString *)sessionHeader {
//
//}
/**
 Summary data if desired
 */
//- (NSString *)summary {
//
//}
/**
 Summary offset must be provided if a custom summary will be used.
 See comments below for use.
 */
//- (NSUInteger)summaryOffset {
  // for an overwritting summary, un-comment the following line
  // return [[[delegate registryForTaskWithOffset:0] valueForKey:TKComponentSummaryStartKey] unsignedIntegerValue];
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // for an appending summary, un-comment the following line
  // return [[[delegate registryForTaskWithOffset:0] valueForKey:TKComponentSummaryEndKey] unsignedIntegerValue];
// }

#pragma mark ADDITIONAL METHODS
/** Add additional methods required for operation */
- (void)registerError: (NSString *)theError {
  // append the new error to the error log
  [self setErrorLog:[[errorLog stringByAppendingString:theError] 
                     stringByAppendingString:@"\n"]];
}

/** Exit */
- (IBAction)exit: (id)sender {
  RRFLogToTemp(formattedString);
  [delegate componentDidFinish:self];
}

/**
   Get the mask for the modifier keys as specified in prefs.
   @return NSUInteger An unsigned integer representing a bit mask for the specified modifier keys
*/
- (NSUInteger)getModifierFlags {
  // start with the device indenpendent modifier flags mask
  NSUInteger myFlags = 0;
  // for each of the allowed modifier types,
  // if specified yes in prefs, bitwise OR with our flags
  if([[definition valueForKey:RRFNotificationShouldRequireAltKey] boolValue]) 
    myFlags |= NSAlternateKeyMask;
  if([[definition valueForKey:RRFNotificationShouldRequireCommandKey] boolValue])
    myFlags |= NSCommandKeyMask;
  if([[definition valueForKey:RRFNotificationShouldRequireControlKey] boolValue])
    myFlags |= NSControlKeyMask;
  if([[definition valueForKey:RRFNotificationShouldRequireShiftKey] boolValue])
    myFlags |= NSShiftKeyMask;
  // return the result
  return myFlags;
}

/**
   Return the umber of format tokens in the given string.

   We can use this valid to avoid segmentation faults. If we have 2
   format tokens, but only 1 object in our argument stack, a
   segmentation fault will occur. To avoid this, we must assert that
   the number of format tokens and the number of arguments are equal
   before attemptiting format expansion with a given string. To this
   end I write this method.
*/
- (NSInteger)numberOfFormatTokens: (NSString *)aString {
  NSInteger count = 0; // counter
  // loop through and check every character
  for( NSInteger i=0;            // start at beginning
       i < [aString length] - 1; // stop at second to last, since 
                                 // a substitution requires a spec
                                 // trailing the %
       i++ ) { 
    // if the char is a '%'...
    if([aString characterAtIndex:i] == '%' &&
       [aString characterAtIndex:i+1] != '%') {
      // ...we have a match
      count++;
    }
  } // end of for loop
  return count;
}

/**
   Given the base string and argument list full of registry key paths,
return the correctly formatted prompt string.
 
 In order to feed an array of arguments generated at run-time into a
 va_list I had to borrow ideas from the web. For further explanation see:
 http://cocoawithlove.com/2009/05/variable-argument-lists-in-cocoa.html
*/
- (NSString *)resolveString { 

  // if we don't have a base string, we can't do anything... return
  // nil
  if(!baseString) {
    ELog(@"Base String cannot be nil!");
    return nil;
  }

  // initialize an empty return value
  NSString *retVal = nil;

  // if we have arguments to substitute...
  if([argv count] > 0) {

    // create an empty arg queue
    NSMutableArray *argStack = [[NSMutableArray alloc] init];

    // for each argv create a valid argument and add to queue
    for(NSString *argString in argv) {
      DLog(@"Trying to add for key path: %@, the corresponding object is %@",argString,[delegate valueForRegistryKeyPath:argString]);
      id theObj = nil;

      // if a value is found at key path - add value to stack
      if( theObj = [delegate valueForRegistryKeyPath:argString] ) {
        [argStack addObject:theObj];
      }

      // else, elog no value found
      else {
        ELog(@"Did not find key-path: %@",argString);
      }
    } // end of for loop

    // if the number of extracted arguments is equal to the number of
    // format tokens... proceed to turn array into va_list
    if( [self numberOfFormatTokens:baseString] == [argStack count] ) {

      // turn our array into simple bytes
      char *argList = (char *)malloc(sizeof(NSString *) * [argStack count]);
      [argStack getObjects:(id *)argList];
      retVal = [[NSString alloc] initWithFormat:baseString arguments:argList];
      free(argList);
    } 

    // else, mismatch between number of arguments and format tokens
    else {
      retVal = @"There was a problem expanding the base string -- see log for description";
      ELog(@"Mismatch between arguments: %d and format tokens: %d",[argStack count],[self numberOfFormatTokens:baseString]);
    }

  } // end of arg substitution

  // we have no arguments to substitute
  else {
    // make sure we don't have any format tokens in there
    if( [self numberOfFormatTokens:baseString] > 0 ) {
      retVal = @"There was a problem expanding the base string -- see log for description";
      ELog(@"%d format tokens were found in base string, but no arguments were given for substitution",[self numberOfFormatTokens:baseString]);
    }
    // if no tokens, then we can substitute the base string as is...
    retVal = [baseString copy];
  }

  // return whatever value we derived
  return [retVal autorelease];
}

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFNotificationNameOfPreferenceKey = @"RRFNotificationNameOfPreference"
NSString * const RRFNotificationArgumentListKey = @"RRFNotificationArgumentList";
NSString * const RRFNotificationBaseStringKey = @"RRFNotificationBaseString";
NSString * const RRFNotificationDataDirectoryKey = @"RRFNotificationDataDirectory";
NSString * const RRFNotificationSecretKeyComboKey = @"RRFNotificationSecretKeyCombo";
NSString * const RRFNotificationShouldAllowSubjectClickKey = @"RRFNotificationShouldAllowSubjectClick";
NSString * const RRFNotificationShouldRequireAltKey = @"RRFNotificationShouldRequireAlt";
NSString * const RRFNotificationShouldRequireCommandKey = @"RRFNotificationShouldRequireCommand";
NSString * const RRFNotificationShouldRequireControlKey = @"RRFNotificationShouldRequireControl";
NSString * const RRFNotificationShouldRequireShiftKey = @"RRFNotificationShouldRequireShift";
NSString * const RRFNotificationTaskNameKey = @"RRFNotificationTaskName";

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS //
///////////////////////////////////////////////
NSString * const RRFNotificationMainNibNameKey = @"RRFNotificationMainNib";
        
@end
