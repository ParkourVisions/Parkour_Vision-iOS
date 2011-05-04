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
 * PKImage.m
 * author: emancebo
 * 3/23/11
 */

#import "PKImage.h"
#import "FlickrAPI.h"

@implementation PKImage

@synthesize imageId, farm, server, secret, title, username, coord;

- (id) initWithImageId:(NSString*)imgid {
	if (self = [super init]) {
		[imgid retain];
		imageId = imgid;
		isInfoLoaded = NO;
	}
	return self;
}

- (void)loadInfo {
	if (!isInfoLoaded) {
		[FlickrAPI setInfo:self];
		isInfoLoaded = YES;
	}
}

- (UIImage*) getThumbImage {
	
	if (thumbImage == nil) {
		thumbImage = [FlickrAPI getImage:self size:@"t"];
		[thumbImage retain];
	}
	
	return thumbImage;
	
}

- (UIImage*) getMedImage {
	
	if (medImage == nil) {
		medImage = [FlickrAPI getImage:self size:nil];
		[medImage retain];
	}
	
	return medImage;
}

- (void) dealloc {
	[imageId release];
	[thumbImage release];
	[medImage release];
	[farm release];
	[server release];
	[secret release];
	
	[super dealloc];
}

@end
