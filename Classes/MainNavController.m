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
 * MainNavController.m
 * author: emancebo
 * 4/5/11
 */

#import "MainNavController.h"
#import "EditLocationViewController.h"
#import "EditInfoViewController.h"
#import "EditTagsViewController.h"
#import "UploadProgressController.h"
#import "AccountViewController.h"
#import "UploadInfo.h"
#import "MapViewController.h"
//#import "PostResult.h"

@implementation MainNavController

@synthesize mainView, editLocationVC, editInfoVC, editTagsVC, tabBarController, uploadNavController, accountVC, selectedImage, uploadFromCameraButton, mapViewController, uploadFromLibraryButton;


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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mapViewController = [MapViewController getInstance];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


- (IBAction) browse:(id)sender {
	[self.navigationController pushViewController:mapViewController animated:YES];
}

- (IBAction) account:(id)sender {
	[self.navigationController pushViewController:accountVC animated:YES];
}

- (IBAction) uploadFromCamera:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (IBAction) uploadFromLibrary:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	//imagePicker.allowsEditing = YES;
	//imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	[self configureUploadController];
	tabBarController.selectedViewController = [tabBarController.viewControllers objectAtIndex:0];
	
	//UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
	//if (img == nil) {
	//	img = [info objectForKey:UIImagePickerControllerOriginalImage];
	//}
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	self.selectedImage = img;
	
	[self dismissModalViewControllerAnimated:NO];
	//UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
	//[self.navigationController pushViewController:navController animated:NO];
	[self presentModalViewController:uploadNavController animated:NO];
	//[navController release];
}

- (IBAction) cancelUploadPhoto:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) submitUpload:(id)sender {

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm upload" message:@"Upload this photo to Flickr?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload",nil];
	[alertView show];
	[alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self dismissModalViewControllerAnimated:NO];
		
		UploadInfo *uploadInfo = [self createUploadInfo];
		UploadProgressController *progressController = [[UploadProgressController alloc] initWithUploadInfo:uploadInfo];
		
		[self.navigationController pushViewController:progressController animated:NO];
		[progressController uploadAsync];
		[progressController release];
	}
}

- (UploadInfo*) createUploadInfo {
	UploadInfo *info = [[UploadInfo alloc] init];
	info.image = selectedImage;
	info.title = [editInfoVC getTitle];
	info.desc = [editInfoVC getDesc];
	info.tags = [editTagsVC getTags];
	info.coord = [editLocationVC getCoord];
	
	return [info autorelease];
}

- (void) viewWillAppear:(BOOL)animated {
	
	// disable both upload buttons if user is not logged in
	NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"auth_token"];
	if (authToken == nil) {
		uploadFromCameraButton.enabled = NO;
		uploadFromLibraryButton.enabled = NO;
	}
	else {
		uploadFromCameraButton.enabled = YES;
		uploadFromLibraryButton.enabled = YES;
	}
	
	// disable upload from camera button if device has no camera
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		uploadFromCameraButton.enabled = NO;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.tabBarController = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
