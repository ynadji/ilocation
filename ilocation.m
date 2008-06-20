//
//  ilocation.m
//  iLocation
//
//  Created by Yacin Nadji on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ilocation.h"


@implementation ilocation

- (void)awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	NSSize size;
	size.width = NSSquareStatusItemLength;
	size.height = NSSquareStatusItemLength;
	
    statusImage = [[NSImage alloc] initWithContentsOfFile:@"../iLocation/network.png"];
	[statusImage setSize:size];
	
	NSMutableArray *args = [NSMutableArray array];
	NSTask *command = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/scselect" arguments:args];
	[command waitUntilExit];
	
	if ([command terminationStatus] == 0) {
		NSLog(@"Success!");
	}
	else {
		NSLog(@"Failure!");
	}

	
	[myMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector (terminate:) keyEquivalent:@"q"]];
	
	[statusItem setImage: statusImage];
	[statusItem setMenu: myMenu];
	[statusItem setToolTip: @"A tooltip"];
	[statusItem setHighlightMode: YES];
}

- (void) dealloc {
	[statusImage release];
	[super dealloc];
}

@end
