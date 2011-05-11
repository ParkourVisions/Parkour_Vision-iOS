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
 * UploadStatusController.m
 * author: emancebo
 * 5/6/11
 */

#import "UploadStatusController.h"
#import "UploadInfo.h"
#import "UploadTask.h"
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageDestination.h>

@implementation UploadStatusController

@synthesize editLocationVC, editInfoVC, editTagsVC, uploadNavController, tabBarController, uploadInfo, tableView, tvCell;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *newUploadButton = 
			[[UIBarButtonItem alloc] initWithTitle:@"New Upload" style:UIBarButtonItemStyleDone target:self action:@selector(onNewUpload:)];
        self.navigationItem.rightBarButtonItem = newUploadButton;
		[newUploadButton release];
		
		uploadQueue = [[NSMutableArray alloc] init];
		uploadTaskToProgressView = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) onNewUpload:(id)sender {	
	
	// if camera is not available, don't bother giving the using a choice
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[self alertView:nil clickedButtonAtIndex:2];
		return;
	}
	
	UIAlertView *alertView = 
		[[UIAlertView alloc] initWithTitle:@"Choose source" message:@"How would you like to upload a photo?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Library", nil];
	[alertView show];
	[alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if (buttonIndex == 0) // cancel button
		return;
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
	if (buttonIndex == 1) { // camera type
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	[self configureUploadController];
	tabBarController.selectedViewController = [tabBarController.viewControllers objectAtIndex:0];
	
	self.uploadInfo = [[[UploadInfo alloc] init] autorelease];
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
	uploadInfo.imageData = imageData;
	uploadInfo.image = img;
	
	NSDictionary *metaData = [info objectForKey:UIImagePickerControllerMediaMetadata];
	if (metaData != nil) {
		NSDictionary *exifData = [metaData objectForKey:(NSString*)kCGImagePropertyExifDictionary];
		if (exifData != nil) {
			uploadInfo.exifData = exifData;
			NSLog(@"exifData: %@", [exifData description]);
			
			CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, nil);
			
			CFStringRef UTI = CGImageSourceGetType(source);
			
			NSMutableData *dataOut = [NSMutableData data];
			
			CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dataOut,UTI,1,NULL);
			
			if (destination) {
				CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metaData);
				if (CGImageDestinationFinalize(destination)) {
					NSLog(@"Using image with exif data added");
					uploadInfo.imageData = dataOut;
					uploadInfo.image = [UIImage imageWithData:dataOut];
					CFRelease(destination);
				}
				else {
					NSLog(@"Could not finalize destination image with exifData");
				}
			}
			else {
				NSLog(@"Could not create CGImageDestinationRef");
			}
			
			CFRelease(source);
		}
	}
	
	[self dismissModalViewControllerAnimated:NO];
	[self presentModalViewController:uploadNavController animated:NO];
}

- (void) configureUploadController {
	editLocationVC = [[EditLocationViewController alloc] init];
	editInfoVC = [[EditInfoViewController alloc] init];
	editTagsVC = [[EditTagsViewController alloc] init];
	
	// create tab bar items
	UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"Set Location" image:nil tag:0];
	editLocationVC.tabBarItem = tabItem;
	[tabItem release];
	
	tabItem = [[UITabBarItem alloc] initWithTitle:@"Set Title" image:nil tag:1];
	editInfoVC.tabBarItem = tabItem;
	[tabItem release];
	
	tabItem = [[UITabBarItem alloc] initWithTitle:@"Set Tags" image:nil tag:2];
	editTagsVC.tabBarItem = tabItem;
	[tabItem release];
	
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	[controllers addObject:editLocationVC];
	[controllers addObject:editInfoVC];
	[controllers addObject:editTagsVC];
	[tabBarController setViewControllers:controllers];
	[controllers release];
	
	[editLocationVC release];
	[editInfoVC release];
	[editTagsVC release];
}

- (IBAction) submitUpload:(id)sender {
	NSLog(@"Upload submitted");
	[self populateUploadInfo];
	
	UploadTask *task = [[UploadTask alloc] initWithUploadInfo:uploadInfo];
	task.delegate = self;
	self.uploadInfo = nil;
	[uploadQueue addObject:task];
	[task startInBackground];
	[task release];
	
	[tableView reloadData];
	
	[self dismissModalViewControllerAnimated:YES];
	
}

- (IBAction) cancelUploadPhoto:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// place most recent uploads at the head of the table
	int idx = [uploadQueue count] - indexPath.row - 1;
	
	UploadTask *task = [uploadQueue objectAtIndex:idx];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TVCellDefaultID"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"UploadTableViewCell" owner:self options:nil];
        cell = tvCell;
        self.tvCell = nil;
    }
	
	UIImageView *imageView;
	imageView = (UIImageView*)[cell viewWithTag:1];
	imageView.image = task.uploadInfo.image;
	
	UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
	
	if ([task isDone]) {
		NSString *error = [task getError];
		if (error == nil) {
			label.text = @"Upload complete";
		}
		else {
			label.text = error;
		}
	}
	else {
		label.text = @"Upload in progress...";
	}
	
	// update mapping of task to progress view
	UIProgressView *progressView;
	progressView = (UIProgressView*)[cell viewWithTag:3];
	[uploadTaskToProgressView setObject:progressView forKey:[task taskIdNumber]];
		
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [uploadQueue count];
}

- (void) populateUploadInfo {
	uploadInfo.title = [editInfoVC getTitle];
	uploadInfo.desc = [editInfoVC getDesc];
	uploadInfo.tags = [editTagsVC getTags];
	uploadInfo.coord = [editLocationVC getCoord];
}

- (void) uploadFinished:(UploadTask*)task {
	NSLog(@"Got upload finished message");
	[tableView reloadData];
}

- (void) progressUpdated:(UploadTask*)task {
	UIProgressView *progressView = [uploadTaskToProgressView objectForKey:[task taskIdNumber]];
	if (progressView != nil) {
		progressView.progress = [task getProgress];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tableView.rowHeight = 66.0;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {	
	[editLocationVC release];
	[editInfoVC release];
	[editTagsVC release];
	[uploadInfo release];
	[uploadQueue release];
	[uploadTaskToProgressView release];
    [super dealloc];
}


@end
