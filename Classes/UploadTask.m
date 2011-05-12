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
 * UploadTask.m
 * author: emancebo
 * 5/9/11
 */

#import "UploadTask.h"
#import "PostResult.h"
#import "FlickrAPI.h"

#include <libkern/OSAtomic.h>

@implementation UploadTask

@synthesize uploadInfo, delegate, taskId;

- (id) initWithUploadInfo:(UploadInfo*)info {
	if (self = [super init]) {
		self.uploadInfo = info;
		mDone = NO;
		mProgress = 0.1;
		
		static volatile int rid = 0;
		taskId = OSAtomicIncrement32(&rid);
	}
	return self;
}

- (NSNumber*) taskIdNumber {
	return [NSNumber numberWithInt:taskId];
}

- (void) startInBackground {
	NSLog(@"Uploading: %@", [uploadInfo description]);
	
	// ID of the global parkour group in flickr
	static NSString *PK_GROUP_ID = @"1613155@N25";
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		// upload photo
		PostResult *result = [FlickrAPI uploadPhoto:uploadInfo];
		NSLog(@"upload photo result: %@", [result description]);
		mProgress = 0.7;
		[self performSelectorOnMainThread:@selector(notifyDelegateProgress) withObject:result waitUntilDone:NO];
		
		if (result.isOK) {
			NSString *photoId = result.photoId;
			[photoId retain];
			
			result = [FlickrAPI setPhotoLocation:photoId coord:uploadInfo.coord];
			NSLog(@"set location result: %@", [result description]);
			mProgress = 0.85;
			[self performSelectorOnMainThread:@selector(notifyDelegateProgress) withObject:result waitUntilDone:NO];
			
			if (result.isOK) {
				result = [FlickrAPI addPhoto:photoId toGroup:PK_GROUP_ID];
				NSLog(@"add to group result: %@", [result description]);
			}
			
			[photoId release];
		}
		mProgress = 1.0;
		[self performSelectorOnMainThread:@selector(notifyDelegateProgress) withObject:result waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(notifyDelegateDone:) withObject:result waitUntilDone:NO];
	});	
}

- (void) notifyDelegateDone:(PostResult*)result {
	mDone = YES;
	
	if (!result.isOK) {
		mErrorMessage = result.errorMessage;
		if (mErrorMessage == nil) {
			mErrorMessage = [NSString stringWithFormat:@"Error %d", result.statusCode];
		}
	}
	
	[delegate uploadFinished:self];
}

- (void) notifyDelegateProgress {
	[delegate progressUpdated:self];
}

- (float) getProgress {
	return mProgress;
}

- (BOOL) isDone {
	return mDone;
}

- (NSString*) getError {
	return mErrorMessage;
}

- (void) dealloc {
	[uploadInfo release];
	[delegate release];
	[super dealloc];
}

@end
