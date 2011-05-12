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
 * SearchEngine.m
 * author: emancebo
 * 3/24/11
 */

#import "SearchEngine.h"
#import "RequestIdGenerator.h"
#import "MapViewController.h"
#import "PKImage.h"
#import "SearchWorker.h"
#import "SearchRequest.h"
#import "SearchOperation.h"

#include <libkern/OSAtomic.h>

@implementation SearchEngine

static int ROWS = 2;
static int COLS = 2;

static NSOperationQueue *queue;
+ (void)initialize
{
    if(self == [SearchEngine class])
    {
        queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:(ROWS*COLS)];
    }
}

// The search query is partitioned into geographical regions to ensure that we get results
// from all areas of the map
- (void) partitionAndSubmitSearch:(SearchRequest*)request {
	
	// hack
	// when the map view loads it kicks of a search request immediately, and then pans to the current location
	// and creates another search request
	// this allows us to ignore the first search request
	if (request.rid == 1)
		return;
	
	// remove off screen annotations and images
	MapViewController *mapViewController = [MapViewController getInstance];
	[mapViewController removeImagesOutsideMinCoord:request.minCoord maxCoord:request.maxCoord];
	
	// get IDs of images remaining in the visible region
	
	NSDictionary *curImageIdSet = [mapViewController getImageIdSet];
	
	double dy = (request.maxCoord.latitude - request.minCoord.latitude) / ROWS;
	double dx = (request.maxCoord.longitude - request.minCoord.longitude) / COLS;
	
	for (int row=0; row < ROWS; ++row) {
		for (int col=0; col < COLS; ++col) {
			
			// construct search request for this partition
			SearchRequest *psr = [[SearchRequest alloc] init];
			psr.rid = request.rid;
			CLLocationCoordinate2D minCoord;
			CLLocationCoordinate2D maxCoord;
			minCoord.latitude = request.minCoord.latitude + dy*row;
			minCoord.longitude = request.minCoord.longitude + dx*col;
			maxCoord.latitude = request.minCoord.latitude + dy*(row+1);
			maxCoord.longitude = request.minCoord.longitude + dx*(col+1);
			psr.minCoord = minCoord;
			psr.maxCoord = maxCoord;
			
			/*
			static volatile int ccount = 0;
			
			dispatch_async(dispatch_get_global_queue(0, 0), ^{
				OSAtomicIncrement32(&ccount);
				NSLog(@"ccount = %d", ccount);
				SearchWorker *worker = [[SearchWorker alloc] init];
				[worker search:psr curImages:curImageIdSet];
				[worker release];
				OSAtomicDecrement32(&ccount);
				NSLog(@"ccount = %d", ccount);
			});
			 */
			
			// ---------------------
			// new dispatch
			psr.curImageIds = curImageIdSet;
			SearchOperation *op = [[SearchOperation alloc] initWithRequest:psr];
			[queue addOperation:op];
			[op release];
			// ---------------------
			[psr release];
		}
	}	
}

@end
