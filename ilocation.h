//
//  ilocation.h
//  iLocation
//
//  Created by Yacin Nadji on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ilocation : NSObject {
	IBOutlet NSMenu *myMenu;
	
	NSStatusItem *statusItem;
	
	NSImage *statusImage;
	NSImage *statusAltImage;
}

- (void) populateMenu;
- (IBAction) refreshMenu:(id)sender;
- (IBAction) changeLocation:(id)sender;
- (NSString *) fixLocation:(NSString *)location;
- (void) dealloc;

@end
