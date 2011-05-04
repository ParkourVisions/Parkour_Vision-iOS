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
 * SearchRequest.m
 * author: emancebo
 * 3/23/11
 */

#import "SearchRequest.h"


@implementation SearchRequest

@synthesize rid, minCoord, maxCoord, curImageIds;

/*
- (id) retain {
	NSLog(@"Retaining %p", self);
	//NSLog(@"%@",[NSThread callStackSymbols]);
	return [super retain];
}

- (oneway void) release {
	NSLog(@"Releasing %p", self);
	[super release];
}
 */

- (void) dealloc {
	//NSLog(@"SearchRequest.dealloc release curImageIds %p", curImageIds);
	[curImageIds release];
	[super dealloc];
}

@end
