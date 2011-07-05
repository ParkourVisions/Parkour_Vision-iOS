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
 * NavLauncher.m
 * author: emancebo
 * 5/11/11
 */

#import "NavLauncher.h"


@implementation NavLauncher

@synthesize navigationController;

- (id) initWithNavigationController:(UINavigationController*)navController {
	if (self = [super init]) {
		accountViewController = [AccountViewController getInstance];
		uploadStatusController = [[UploadStatusController alloc] init];
		self.navigationController = navController;
	}
	return self;
}

- (void) onUploadButton:(id)sender {
	[navigationController pushViewController:uploadStatusController animated:YES];
}

- (void) onAccountButton:(id)sender {
	[navigationController pushViewController:accountViewController animated:YES];
}

- (void) dealloc {
	[accountViewController release];
	[uploadStatusController release];
	[super dealloc];
}

@end
