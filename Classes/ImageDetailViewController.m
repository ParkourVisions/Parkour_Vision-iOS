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
 * ImageDetailViewController.m
 * author: emancebo
 * 4/10/11
 */

#import "ImageDetailViewController.h"
#import "PKUIImageView.h"

@implementation ImageDetailViewController

@synthesize scrollView, pkImageViews;

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

- (void)layoutScrollView {
	float width = scrollView.bounds.size.width;
	float height = scrollView.bounds.size.height;
	
	NSLog(@"scroll view width %f height %f", width, height);
	
	CGSize contentSize = {[pkImageViews count] * width, height};
	scrollView.contentSize = contentSize;
	
	for (int i=0; i < [pkImageViews count]; ++i) {
		CGRect frame = CGRectMake(i*width, 0, width, height);
		[[pkImageViews objectAtIndex:i] setFrame:frame];
	}
	
	[scrollView setContentOffset:CGPointMake(width*curIdx, 0) animated:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self layoutScrollView];
}


/*
- (void) didRotate:(NSNotification *)notification
{	
	[self layoutScrollView];
}
 */

/*
- (void) loadView {
	
	
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	// hack
	// swap width and height if in landscape mode
	// for some reason the bounds of the main screen does not change when in landscape
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIInterfaceOrientationLandscapeLeft ||
		orientation == UIInterfaceOrientationLandscapeRight) {	 
		int tmp = screenRect.size.height;
		screenRect.size.height = screenRect.size.width;
		screenRect.size.width = tmp;
	}
	
	NSLog(@"screen rect x:%f y:%f width:%f height:%f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
	
	UIScrollView *sv = [[UIScrollView alloc] initWithFrame:screenRect];
	
	float width = sv.frame.size.width;
	float height = sv.frame.size.height;
	
	NSLog(@"scroll view width %f height %f after init", width, height);
	
	sv.backgroundColor = [UIColor blackColor];
	sv.pagingEnabled = YES;
	
	self.scrollView = sv;
	[sv release];
	[self setView:scrollView];
}
*/
 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 
	for (PKUIImageView *imageView in pkImageViews) {	
		[scrollView addSubview:imageView];
	}
	
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self layoutScrollView];
	[self scrollViewDidEndDecelerating:nil]; // loads current image
	
	/*
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];	
	*/
	UITapGestureRecognizer *gestureRecognizer =
		[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavBar:)];
	[scrollView addGestureRecognizer:gestureRecognizer];
	[gestureRecognizer release];
}

- (void) toggleNavBar:(UIGestureRecognizer*)gestureRecognizer {
	BOOL isHidden = self.navigationController.navigationBar.hidden;
	//[[UIApplication sharedApplication] setStatusBarHidden:!isHidden];
	self.navigationController.navigationBar.hidden = !isHidden;
}

- (id) initWithImageList:(LinkedList*)imageList initialImage:(PKImage*)initialImage {
	curIdx = 0;
	pkImageViews = [[NSMutableArray alloc] init];
	if (self = [super init]) {
		// populate array from list
		LinkedListNode *node = [imageList getHead];
		int i=0;
		while (node != nil) {
			PKUIImageView *imageView = [[PKUIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
			imageView.image = [node.data getThumbImage];
			imageView.pkImage = node.data;
			imageView.userInteractionEnabled = NO;
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			
			[pkImageViews addObject:imageView];
			[imageView release];
			
			if (initialImage == node.data) {
				curIdx = i;
			}	
			++i;
			node = node.next;
		}
		
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
	int width = scrollView.frame.size.width;
	int idx = scrollView.contentOffset.x / width;
	curIdx = idx;
	//NSLog(@"Finished decelerating on image %d", idx);
	[self performSelectorInBackground:@selector(loadFullImageForIndex:) withObject:[NSNumber numberWithInt:idx]];
}

- (void) loadFullImageForIndex:(NSNumber*)idx {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PKImage *image = [[pkImageViews objectAtIndex:[idx intValue]] pkImage];
	[image getMedImage]; // eager load
	[self performSelectorOnMainThread:@selector(setFullImage:) withObject:image waitUntilDone:NO];
	
	[pool release];
}

- (void) setFullImage:(PKImage*)pkImage {
	for (PKUIImageView *pkImageView in pkImageViews) {
		if (pkImage == pkImageView.pkImage) {
			pkImageView.image = [pkImage getMedImage];
			break;
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	NSLog(@" calling ImageDetailViewController should autorotate");
	return YES;
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

	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.scrollView = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	//imageView.image = [pkImage getMedImage];
	self.navigationController.navigationBar.translucent = YES;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[self layoutScrollView];
}

- (void)dealloc {
	[pkImageViews release];
	[scrollView release];
    [super dealloc];
}


@end
