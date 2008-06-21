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
	
	[self populateMenu];
	
	[statusItem setImage:statusImage];
	[statusItem setMenu:myMenu];
	[statusItem setHighlightMode: YES];
}

- (IBAction) refreshMenu:(id)sender {
	[self populateMenu];
}

- (void) populateMenu {
	// if there's info there already, reset it
	if (myMenu != NULL) {
		NSLog(@"Clearing menu for reset...");
		
		int numItems = [myMenu numberOfItems];
		
		while (numItems > 0)
			[myMenu removeItemAtIndex:--numItems];
	}
	
	NSTask *pipeTask = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSData *inData = nil;
	NSString *str = nil;
	NSMutableString *totalStr = [[NSMutableString alloc] init];
	
    // write handle is closed to this process
    [pipeTask setStandardError:newPipe];
    [pipeTask setLaunchPath:@"/usr/sbin/scselect"];
    [pipeTask launch];
	
	NSLog(@"wtf is going on?!");
	
    while ((inData = [readHandle availableData]) && [inData length]) {
		str = [[NSString alloc] initWithData:inData encoding:NSASCIIStringEncoding];
		[totalStr appendString:str];
		[str release];
    }
	
	NSArray *arr = [totalStr componentsSeparatedByString:@"\n"];
	
    [pipeTask release];
	
	NSString *location = nil;
	NSMenuItem *tmpItem = nil;
	
	if ([arr count] > 0) {
		unsigned int i, count = [arr count];
		
		for (i = 1; i < count - 1; i++) {
			location = [self fixLocation:[arr objectAtIndex:i]];
			//location = [self fixLocation:location];
			tmpItem = [[NSMenuItem alloc] initWithTitle:location action:@selector (changeLocation:) keyEquivalent:[[NSNumber numberWithInt: i] stringValue]];
			[tmpItem setTarget:self];
			[tmpItem setRepresentedObject:location];
			[myMenu addItem:tmpItem];
			[tmpItem release];
			NSLog(@"Line #%d: %@\n", i, location);
		}
	}
	
	[myMenu addItem:[NSMenuItem separatorItem]];
	
	tmpItem = [[NSMenuItem alloc] initWithTitle:@"Refresh Menu" action:@selector (refreshMenu:) keyEquivalent:@"r"];
	[tmpItem setTarget:self];
	[myMenu addItem:tmpItem];
	[tmpItem release];
	
	[myMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector (terminate:) keyEquivalent:@"q"]];
}

- (NSString *) fixLocation:(NSString *)location {
	BOOL currentLoc = NO;
	int len = [location length],
		i;
	
	NSRange range;
	
	for (i = 0; i < len; i++) {
		if ([location characterAtIndex:i] == '*')
			currentLoc = YES;
		else if ([location characterAtIndex:i] == '(')
			range.location = i + 1;
		else if ([location characterAtIndex:i] == ')')
			range.length = i - range.location;
	}
	
	NSMutableString *newLoc = [[NSMutableString alloc] initWithString:[location substringWithRange:range]];
	if (currentLoc)
		[newLoc insertString:@"* " atIndex:0];
	
	return newLoc;
}

- (IBAction) changeLocation:(id)sender {
	NSLog(@"Okay, maybe this will work!");
	NSString *location = (NSString *) [sender representedObject];
	NSLog(@"Represented object: %@", location);
	
	if ([location characterAtIndex:0] == '*') {
		NSLog(@"Already at current setting, do nothing");
	} else {
		NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity:1];
		[args addObject:location];
		
		NSTask *command = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/scselect" arguments:args];
		[command waitUntilExit];
		
		// refresh it to take into account the new default
		[self populateMenu];
		[args release];
	}
}

- (void) dealloc {
	[statusImage release];
	[myMenu release];
	[super dealloc];
}

@end
