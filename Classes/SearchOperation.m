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
 * SearchOperation.h
 * author: emancebo
 * 4/12/11
 */

#import "SearchOperation.h"

#import "SearchWorker.h"
#include <libkern/OSAtomic.h>

@implementation SearchOperation

@synthesize request;

/*
- (id) retain {
	NSLog(@"Retaining SearchOperation %p", self);
	//NSLog(@"%@",[NSThread callStackSymbols]);
	return [super retain];
}

- (oneway void) release {
	NSLog(@"Releasing SearchOperation %p", self);
	[super release];
}
 */

- (id) initWithRequest:(SearchRequest*)searchRequest {
	self = [super init];
	if (self) {
		self.request = searchRequest;
	}
	return self;
}

- (void) main {
	
	static volatile int ccount = 0;
	OSAtomicIncrement32(&ccount);
	NSLog(@"ccount = %d", ccount);
	SearchWorker *worker = [[SearchWorker alloc] init];
	[worker search:request curImages:request.curImageIds];
	[worker release];
	OSAtomicDecrement32(&ccount);
	NSLog(@"ccount = %d", ccount);
}

- (void) dealloc {
	//NSLog(@"Dealloc SearchOperation %p for request %x", self, request);
	[request release];
	[super dealloc];
}

@end
