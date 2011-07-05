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
#import "AccountViewController.h"
#import "MapViewController.h"
#import "UploadStatusController.h"
#import "AboutViewController.h"
#import "Disclaimer.h"
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageDestination.h>
//#import "PostResult.h"

@implementation MainNavController

@synthesize mainView, accountVC, mapViewController, uploadsButton, uploadStatusController, aboutVC;


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
	uploadStatusController = [[UploadStatusController alloc] init];
	aboutVC = [[AboutViewController alloc] init];
	
	[self browse:nil];
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

- (IBAction) viewUploads:(id)sender {
	[self.navigationController pushViewController:uploadStatusController animated:YES];
}

- (IBAction) about:(id)sender {
	[self.navigationController pushViewController:aboutVC animated:YES];
}

- (IBAction) showDisclaimer:(id)sender {
	[Disclaimer showDisclaimerPopup];
}


- (void) viewWillAppear:(BOOL)animated {
	/*
	// disable both upload buttons if user is not logged in
	NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"auth_token"];
	if (authToken == nil) {
		uploadsButton.enabled = NO;
	}
	else {
		uploadsButton.enabled = YES;
	}
	 */
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
	self.uploadStatusController = nil;
	self.aboutVC = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
