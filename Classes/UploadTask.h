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
 * UploadTask.h
 * author: emancebo
 * 5/9/11
 */

#import <Foundation/Foundation.h>

#import "UploadInfo.h"
#import "PostResult.h"
@class UploadTask;

@protocol UploadTaskDelegate<NSObject>
@required
- (void) uploadFinished:(UploadTask*)task;
- (void) progressUpdated:(UploadTask*)task;
@end

@interface UploadTask : NSObject {

	UploadInfo *uploadInfo;
	id<UploadTaskDelegate> delegate;
	
	BOOL mDone;
	float mProgress;
	NSString *mErrorMessage;
	
	int taskId;
}

@property (nonatomic, readonly) int taskId;
@property (nonatomic, retain) UploadInfo *uploadInfo;
@property (nonatomic, retain) id<UploadTaskDelegate> delegate;

- (NSNumber*) taskIdNumber;

- (id) initWithUploadInfo:(UploadInfo*)info;
- (void) startInBackground;

- (float) getProgress; // returns number between 0 and 1.0
- (BOOL) isDone;
- (NSString*) getError; // returns nil if no error

- (void) notifyDelegateDone:(PostResult*)result;
- (void) notifyDelegateProgress;

@end


