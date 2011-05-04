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
 * AccountViewController.m
 * author: emancebo
 * 4/6/11
 */

#import "AccountViewController.h"


@implementation AccountViewController

@synthesize username;

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSString *ustr = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	if (ustr == nil) {
		ustr = @"None";
	}

	NSLog(@"Username is: %@", ustr);
	self.username.text = ustr;
}

- (IBAction) setUserPressed:(id)sender {
	UIAlertView *confirmAuth = [[UIAlertView alloc] initWithTitle:@"Confirm" 
		message:@"A browser window will be presented for you to login to your Flickr account and authorize this app" 
														 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
	[confirmAuth show];
	[confirmAuth release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSString *API_KEY = @"2099cafa3dc4df6fec7bb0e5d7aec256";
        
        NSString *urlString = 
		[NSString stringWithFormat:@"http://flickr.com/services/auth/fresh?api_key=%@&perms=write&api_sig=%@",
		 API_KEY, @"7575cf78a09e9ae84b5966eda7388ec9"];
        
        NSURL *loginURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:loginURL];
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
