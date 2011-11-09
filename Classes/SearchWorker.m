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
 * SearchWorker.m
 * author: emancebo
 * 3/23/11
 */

#import "SearchWorker.h"
#import "RequestIdGenerator.h"
#import "FlickrAPI.h"
#import "PKImage.h"
#import "MapViewController.h"
#import "SearchResult.h"

#include <libkern/OSAtomic.h>

@implementation SearchWorker

- (void) search:(SearchRequest*)request curImages:(NSDictionary*)curImageIds {
	
	static volatile int executed = 0;
	static volatile int cancelled = 0;
	
	@try {
		
		// cancel this unit of work if rid is stale
		int curRid = [RequestIdGenerator getCurrentId];
		if (curRid > request.rid) {
			OSAtomicIncrement32(&cancelled);
			NSLog(@"cancelled = %d", cancelled);
			return;
		}
		
		// add delay to get more cancels of unecessary operations
		[NSThread sleepForTimeInterval:1.0]; // 2.0 simulation
		curRid = [RequestIdGenerator getCurrentId];
		if (curRid > request.rid) {
			OSAtomicIncrement32(&cancelled);
			NSLog(@"cancelled = %d", cancelled);
			return;
		}
		
		OSAtomicIncrement32(&executed);
		NSLog(@"executed = %d", executed);
		
		// get relevant image IDs for this geographical area by calling
		// flickr search api
		NSError *error = nil;
		NSMutableArray *imageList = [FlickrAPI searchRegionMin:request.minCoord max:request.maxCoord error:&error];
		
		if (error) {
			SearchError *searchError = [[SearchError alloc] init];
			searchError.requestId = request.rid;
			searchError.error = error;
			[self performSelectorOnMainThread:@selector(setError:) withObject:searchError waitUntilDone:NO];
			NSLog(@"Got error in call to searchRegionMin for rid: %d", searchError.requestId);
			return;
		}
		
		for (PKImage *image in imageList) {
			// break out if another request comes in
			curRid = [RequestIdGenerator getCurrentId];
			if (curRid > request.rid)
				break;
			
			// only fetch data for imageIds that are not already in the model
			if ([curImageIds objectForKey:image.imageId] == nil) {
				// eager load coordinates and thumbnail
				[image loadInfo];
				[image getThumbImage];
				
				NSMutableArray *pkImages = [[NSMutableArray alloc] init];
				[pkImages addObject:image];
				SearchResult *result = [[SearchResult alloc] initWithRid:request.rid images:pkImages];
				[pkImages release];	
				
				// check rid again and update model on main thread
				[self performSelectorOnMainThread:@selector(updateModel:) withObject:result waitUntilDone:YES];
				[result release];
			}
		}
	}
	@finally {
		[self performSelectorOnMainThread:@selector(finishRequest:) withObject:request waitUntilDone:YES];
	}
	
	//[request release]; // allocated by search engine
}

- (void) finishRequest:(SearchRequest*)request {
	MapViewController *mapViewController = [MapViewController getInstance];
	[mapViewController clearActivityIndicator:request];
}

- (void) updateModel:(SearchResult*)result {
	int curRid = [RequestIdGenerator getCurrentId];
	if (curRid > result.rid)
		return;
	
	MapViewController *mapViewController = [MapViewController getInstance];
	[mapViewController addVisibleImages:result.pkImages];
}

- (void) setError:(SearchError *)error {
	
	// de-dupe errors coming in from multiple threads
	// we check for request ID > 1 because two requests are made when the app first loads up
	// (in order to pan to the user's location)
	static int lastErrorRid = 0;
	if (error.requestId > lastErrorRid && error.requestId > 1) {
		MapViewController *mapViewController = [MapViewController getInstance];
		[mapViewController setSearchError:error.error];
		lastErrorRid = error.requestId;
	}
}

@end
