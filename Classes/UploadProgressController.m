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
 * UploadProgressController.m
 * author: emancebo
 * 4/6/11
 */

#import "UploadProgressController.h"
#import "UploadInfo.h"
#import "FlickrAPI.h"
#import "PostResult.h"

@implementation UploadProgressController

@synthesize imageTitle, imageView, status, activityView, errorView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (id) initWithUploadInfo:(UploadInfo*)uinfo {
	self = [super init];
	if (self) {
		uploadInfo = uinfo;
		[uploadInfo retain];
	}
	return self;
}

- (void) uploadAsync {
	NSLog(@"Uploading: %@", [uploadInfo description]);
		
	static NSString *PK_GROUP_ID = @"1613155@N25";
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		// upload photo
		PostResult *result = [FlickrAPI uploadPhoto:uploadInfo];
		NSLog(@"upload photo result: %@", [result description]);
		
		if (result.isOK) {
			NSString *photoId = result.photoId;
			[photoId retain];
			
			result = [FlickrAPI setPhotoLocation:photoId coord:uploadInfo.coord];
			NSLog(@"set location result: %@", [result description]);
				
			if (result.isOK) {
				result = [FlickrAPI addPhoto:photoId toGroup:PK_GROUP_ID];
				NSLog(@"add to group result: %@", [result description]);
			}
			
			[photoId release];
		}
		[self performSelectorOnMainThread:@selector(setResult:) withObject:result waitUntilDone:NO];
	});
	
	//[FlickrAPI uploadPhoto:info];
	
	//NSString *photoId = @"5594215837";
	//NSString *groupId = @"1613155@N25";
	//[FlickrAPI addPhoto:photoId toGroup:groupId];
}

- (void) setResult:(PostResult*)result {
	if (result.isOK) {
		status.text = @"Upload Successful";
	}
	else {
		status.text = @"Upload Failed";
		errorView.text = result.errorMessage;
	}
	[activityView stopAnimating];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
	imageView.image = uploadInfo.image;
	//imageView.contentMode = UIViewContentModeScaleAspectFit;	
	imageTitle.text = uploadInfo.title;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[uploadInfo release];
	[super dealloc];
}


@end
