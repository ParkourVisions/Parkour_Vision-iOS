/*
 * Copyright (c) 2011 Parkour Visions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * PKAnnotation.m
 * author: emancebo
 * 3/24/11
 */

#import "PKAnnotation.h"


@implementation PKAnnotation

@synthesize coordinate, image;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	coordinate = newCoordinate;
}

- (NSString*) title {
	if (image.title == nil || [image.title isEqualToString:@""])
		return @"untitled";
	
	return image.title;
}

- (NSString*) subtitle {
	return image.username;
}

/*
- (id)autorelease {
	NSLog(@"autorelease %p", self);
	NSLog(@"%@",[NSThread callStackSymbols]);
	return [super autorelease];
}

- (id) retain {
	NSLog(@"retain %p", self);
	NSLog(@"%@",[NSThread callStackSymbols]);
	return [super retain];
}

- (oneway void) release {
	NSLog(@"release %p", self);
	NSLog(@"%@",[NSThread callStackSymbols]);
	[super release];
}
 */

- (void) dealloc {
	[image release];
	[super dealloc];
}

@end
