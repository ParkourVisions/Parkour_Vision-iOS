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
 * MapViewController.m
 * author: emancebo
 * 4/10/11
 */

#import "MapViewController.h"
#import "SearchEngine.h"
#import "SearchResult.h"
#import "SearchRequest.h"
#import "RequestIdGenerator.h"
#import "LinkedList.h"
#import "LinkedListNode.h"
#import "PKImage.h"
#import "PKAnnotation.h"
#import "PKUIImageView.h"
#import "ImageDetailViewController.h"
#import "FlickrAPI.h"
#import "Disclaimer.h"
#import <math.h>

#define THUMB_SIZE 64
#define THUMB_BORDER 4

static int calloutButtonTagId = 0;

@implementation MapViewController

@synthesize parentView, mapView, scrollView, activityView, mapTypeSwitch;

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


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

static MapViewController *singleton;

// called by system
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        singleton = [[MapViewController alloc] init];
    }
}

+ (MapViewController*) getInstance {
	return singleton;
}

- (id) init {
	
	self = [super init];
	if (self) {
		visibleImages = [[LinkedList alloc] init];
		annotations = [[NSMutableDictionary alloc]  init];
		isCurrentLocationSet = NO;
		subRequestsCompleted = 0;
		
		parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 416)];
		
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 64, 416)];
		scrollView.backgroundColor = [UIColor blackColor];
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[parentView addSubview:scrollView];
		[scrollView release];
		
		mapView = [[MKMapView alloc] initWithFrame:CGRectMake(64, 0, 256, 416)];
		mapView.delegate = self;
		mapView.showsUserLocation = YES;
		mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		//mapView.mapType = MKMapTypeSatellite;
		[parentView addSubview:mapView];
		[mapView release];
		
		mapTypeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 384, 92, 24)];
		mapTypeSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[mapTypeSwitch addTarget: self action: @selector(toggleMapType:) forControlEvents:UIControlEventValueChanged];
		[parentView addSubview:mapTypeSwitch];
		[mapTypeSwitch release];
		
		UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(148, 384, 72, 24)];
		switchLabel.text = @"Satellite:";
		switchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		switchLabel.backgroundColor = [UIColor clearColor];
		[parentView addSubview:switchLabel];
		[switchLabel release];
		
		activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(320-48, 0, 48, 48)];
		activityView.hidesWhenStopped = YES;
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		activityView.userInteractionEnabled = NO;
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		//[activityView startAnimating];
		[parentView addSubview:activityView];
		[activityView release];
		
		/*
		// setup buttons for upload and account views
		UIBarButtonItem *uploadButton = 
			[[UIBarButtonItem alloc] initWithTitle:@"Uploads" style:UIBarButtonItemStyleDone target:navLauncher action:@selector(onUploadButton:)];
        self.navigationItem.rightBarButtonItem = uploadButton;
		[uploadButton release];
		
		UIBarButtonItem *accountButton = 
			[[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleDone target:navLauncher action:@selector(onAccountButton:)];
		self.navigationItem.leftBarButtonItem = accountButton;
		[accountButton release];

		self.navigationItem.title = @"Browse";
		 */
		
		[self setView:parentView];

	}
	return self;
}

- (void) setNavLauncher:(NavLauncher *)launcher {
	navLauncher = launcher;
	[navLauncher retain];
	
	UIBarButtonItem *uploadButton = 
	[[UIBarButtonItem alloc] initWithTitle:@"Uploads" style:UIBarButtonItemStylePlain target:navLauncher action:@selector(onUploadButton:)];
	self.navigationItem.rightBarButtonItem = uploadButton;
	[uploadButton release];
	
	//UIBarButtonItem *accountButton = 
	//[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:navLauncher action:@selector(onAccountButton:)];
	//self.navigationItem.leftBarButtonItem = accountButton;
	//[accountButton release];
	
	self.navigationItem.title = @"Browse";
}


- (void)mapView:(MKMapView *)mview regionDidChangeAnimated:(BOOL)animated {
	NSTimeInterval t =[[NSDate date] timeIntervalSince1970];
	NSLog(@"called mapView:regionDidChangeAnimated: at time %f", t);
	
	SearchRequest *request = [[SearchRequest alloc] init];
	//NSLog(@"Allocated request %p", request);
	request.rid = [RequestIdGenerator getNextId];
	
	CLLocationCoordinate2D center = mview.region.center;
	MKCoordinateSpan span = mview.region.span;
	double dy = span.latitudeDelta / 2.0;
	double dx = span.longitudeDelta / 2.0;
	
	// shift origin
	//double reservedDelta = 0.15 * span.longitudeDelta;
	//center.longitude = center.longitude - reservedDelta;
	
	CLLocationCoordinate2D minCoord;
	CLLocationCoordinate2D maxCoord;
	minCoord.latitude = center.latitude - dy;
	minCoord.longitude = center.longitude - dx;
	maxCoord.latitude = center.latitude + dy;
	maxCoord.longitude = center.longitude + dx;
	request.minCoord = minCoord;
	request.maxCoord = maxCoord;
	
	[activityView startAnimating];	
	subRequestsCompleted = 0;
	
	SearchEngine *engine = [[SearchEngine alloc] init];
	[engine partitionAndSubmitSearch:request];
		
	//NSLog(@"Going to release request %p", request);
	
	[request release];
	[engine release];
	//NSLog(@"Exiting regionDidChangeAnimated");
}

- (void) clearActivityIndicator:(SearchRequest*)partitionedRequest {
	if (partitionedRequest.rid == [RequestIdGenerator getCurrentId]) {
		++subRequestsCompleted;
	}
	
	if (subRequestsCompleted == [SearchEngine getNumPartitions]) {
		[activityView stopAnimating];
		subRequestsCompleted = 0;
	}
}

- (NSDictionary*) getImageIdSet {
	NSMutableDictionary *imageIdSet = [[NSMutableDictionary alloc] init];
	// NSLog(@"init imageIdSet %p", imageIdSet);
	
	for (LinkedListNode *node = [visibleImages getHead]; node != NULL; node = [node next]) {
		PKImage *image = [node data];
		[imageIdSet setObject:[NSNumber numberWithBool:YES] forKey:image.imageId];
	}
	
	return [imageIdSet autorelease];
}

// sort visible images using nearest neighbor algorithm, using the map upper left origin as the
// first point
- (void) nearestNeighborSort {
	CLLocationCoordinate2D origin = mapView.region.center;
	origin.longitude -= mapView.region.span.longitudeDelta/2;
	origin.latitude += mapView.region.span.latitudeDelta/2;
	
	LinkedList *newList = [[LinkedList alloc] init];
	
	while ([visibleImages count] > 0) {
	
		LinkedListNode *tail = [newList getTail];
		CLLocationCoordinate2D pt;
		if (tail == nil) {
			pt = origin;
		}
		else {
			pt = [tail.data coord];
		}
		
		LinkedListNode *closestNode;
		double minDist = -1.0;
		LinkedListNode *node = [visibleImages getHead];
		while (node != nil) {
			double dist = [self distBetween:pt coordB:[node.data coord]];
			if (minDist < 0 || dist < minDist) {
				minDist = dist;
				closestNode = node;
			}			
			node = node.next;
		}
		
		PKImage *image = closestNode.data;
		[newList add:image];
		[visibleImages remove:closestNode];
	}
	
	[visibleImages release];
	visibleImages = newList;
}

// for each image:
// * add annotation to map
// * add thumbnail to scroll view
- (void) addVisibleImages:(NSArray*)pkImages {
	
	//NSLog(@"called addVisibleImages");
	
	int curSize = [visibleImages count];
	CGSize contentSize = {THUMB_SIZE,THUMB_SIZE*(curSize + [pkImages count])};
	scrollView.contentSize = contentSize;
	
	for (int i=0; i < [pkImages count]; ++i) {
		// add annotations
		PKImage *image = [pkImages objectAtIndex:i];
		PKAnnotation *annotation = [[PKAnnotation alloc] init];
		annotation.image = image;
		[annotation setCoordinate:image.coord];
		
		//NSLog(@"Add annotation %p", annotation);
		//NSLog(@"Adding annotation at (%f, %f) for imageId %@", annotation.coordinate.latitude, annotation.coordinate.longitude, image.imageId);
		[mapView addAnnotation:annotation];
		[annotations setObject:annotation forKey:annotation.image.imageId];
		[annotation release];
		
		[visibleImages add:image];
		
		// add subview
		CGRect frame = CGRectMake(0+THUMB_BORDER/2, THUMB_SIZE*(curSize+i)+THUMB_BORDER/2, 
								  THUMB_SIZE-THUMB_BORDER, THUMB_SIZE-THUMB_BORDER/2);
	
		PKUIImageView *imageView = [[PKUIImageView alloc] initWithFrame:frame];
		imageView.image = [image getThumbImage];
		imageView.pkImage = image;
		imageView.userInteractionEnabled = YES;
		
		UITapGestureRecognizer *gestureRecognizer =
		[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onThumbTap:)];
		[imageView addGestureRecognizer:gestureRecognizer];
		[gestureRecognizer release];
		
		[scrollView addSubview:imageView];
		[imageView release];
	}
		
	// sort by NN
	[self nearestNeighborSort];
	
	// reorder scroll view images
	/*
	LinkedListNode *node = [visibleImages getHead];
	int i=0;
	while (node != nil) {
		PKUIImageView *view = [scrollView.subviews objectAtIndex:i];
		view.pkImage = node.data;
		view.image = [view.pkImage getThumbImage];
		++i;
		node = node.next;
	}
	 */
	LinkedListNode *node = [visibleImages getHead];
	for (UIView *view in scrollView.subviews) {
		if ([view isKindOfClass:[PKUIImageView class]]) {
			PKUIImageView *pkView = (PKUIImageView*)view;
			pkView.pkImage = node.data;
			pkView.image = [pkView.pkImage getThumbImage];
			node = node.next;
		}
	}	
}

- (double) distBetween:(CLLocationCoordinate2D)coordA coordB:(CLLocationCoordinate2D) coordB {
	return sqrt(pow(coordA.latitude - coordB.latitude, 2) + pow(coordA.longitude - coordB.longitude, 2));
}

- (void) removeImagesOutsideMinCoord:(CLLocationCoordinate2D)minCoord maxCoord:(CLLocationCoordinate2D)maxCoord {
	
	NSLog(@"called removeImagesOutsideMinCoord");
	
	NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
	
	/*
	for (PKAnnotation *ian in mapView.annotations) {
		NSLog(@"Map has annotation %p", ian);
	}
	 */
	
	// First remove images that are outside the region box
	LinkedListNode *node = [visibleImages getHead];
	while (node != NULL) 
	{
		LinkedListNode *nextNode = [node next];
		PKImage *image = [node data];
		double lat = image.coord.latitude;
		double lon = image.coord.longitude;
		
		// if outside of box, then remove this node
		if (lat < minCoord.latitude || lat > maxCoord.latitude || lon < minCoord.longitude || lon > maxCoord.longitude) {
			NSLog(@"Removing annotation %p", [annotations objectForKey:image.imageId]);
			[annotationsToRemove addObject:[annotations objectForKey:image.imageId]];
			[annotations removeObjectForKey:image.imageId];
			[visibleImages remove:node];
		}
		
		node = nextNode;
	}
	
	NSLog(@"Removing %d images outside of map region", [annotationsToRemove count]);
	
	// remove associated annotations
	[mapView removeAnnotations:annotationsToRemove];
	//int numAnn = [mapView.annotations count];
	//NSLog(@"Have %d annotations remaining in map view", numAnn);
	//NSLog(@"Have %d annotations in hash table", [annotations count]);
	[annotationsToRemove release];
	
	// redraw remaining images
	node = [visibleImages getHead];
	for (UIView *view in scrollView.subviews) {
		if ([view isKindOfClass:[PKUIImageView class]]) {
		
			PKUIImageView *imageView = (PKUIImageView*)view;
			if (node != NULL) {
						
				// reuse this view for the current image
				PKImage *image = [node data];
				imageView.image = [image getThumbImage];
				imageView.pkImage = image;
				node = [node next];
			}
			else {
				[imageView removeFromSuperview];
			}
		}
	}
	
	// adjust content size
	CGSize contentSize = {THUMB_SIZE,THUMB_SIZE*[visibleImages count]};
	scrollView.contentSize = contentSize;
}

- (void) onThumbTap:(UIGestureRecognizer*)gestureRecognizer {
	PKUIImageView *imageView = (PKUIImageView*)gestureRecognizer.view;
	
	PKImage *pkImage = imageView.pkImage;
	//NSLog(@"Registered tap gesture for image %@", imageView.pkImage.imageId);
	
	// select annotation for this image
	PKAnnotation *pkann = [annotations objectForKey:pkImage.imageId];
	[mapView selectAnnotation:pkann animated:NO];
	
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (![annotation isKindOfClass:[PKAnnotation class]]) {
		return nil;
	}
	
	MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NULL];
	
	annView.animatesDrop = YES;
	annView.canShowCallout = YES;
	
	PKAnnotation *pkAnn = (PKAnnotation*)annotation;
	
	// right button
	// TODO: set target
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton addTarget:self action:@selector(showDetailViewForImage:) forControlEvents:UIControlEventTouchUpInside];
	rightButton.tag = calloutButtonTagId++;
	annView.rightCalloutAccessoryView = rightButton;
	
	// left thumbnail
	CGRect iconFrame = CGRectMake(0,0,32,32);
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
	iconView.image = [pkAnn.image getThumbImage];
	annView.leftCalloutAccessoryView = iconView;
	[iconView release];
	
	return [annView autorelease];
}


- (void) showDetailViewForImage:(id)sender {
	
	UIButton *pressedButton = (UIButton*)sender;
	
	// find PKImage for clicked button by matching up the button tag and the annotation
	// seems pretty hacky...
	for (PKAnnotation *annotation in mapView.annotations) {
		MKAnnotationView *view = [mapView viewForAnnotation:annotation];
		if (view.rightCalloutAccessoryView != nil) {
			UIButton *thisButton = (UIButton*)view.rightCalloutAccessoryView;
			if (pressedButton.tag == thisButton.tag) {
				
				PKImage *image = annotation.image;
				//NSLog(@"Registered detail button push for image %@", image.imageId);
				
				ImageDetailViewController *imageDetailViewController =
				[[ImageDetailViewController alloc] initWithImageList:visibleImages initialImage:image];
				
				//imageDetailViewController.hidesBottomBarWhenPushed = YES;
				//self.navigationController.navigationBarHidden = NO;
				[self.navigationController pushViewController:imageDetailViewController animated:YES];
				[imageDetailViewController release];
				break;
			}
		}
	}
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {	
	// zoom in to user location
	MKCoordinateRegion region;
	region.center = mapView.userLocation.location.coordinate;
	region.span.latitudeDelta = 0.025;
	region.span.longitudeDelta = 0.025;
	//lastUserLocation = region;
	
	// use flag to prevent map from moving around while user is browsing
	// we go to the current location the first time only
	if (!isCurrentLocationSet) {
		[mapView setRegion:region animated:YES];
		isCurrentLocationSet = YES;
	}
}

- (void) toggleMapType: (id)sender {
	UISwitch *mapSwitch = (UISwitch *) sender;
	if (mapSwitch.on) {
		mapView.mapType = MKMapTypeSatellite;
	}
	else {
		mapView.mapType = MKMapTypeStandard;
	}
}

- (void) setSearchError:(NSError*)error {
	UIAlertView *searchErrorAlert = 
		[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error %d", error.code] message:[error localizedDescription] 
								  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[searchErrorAlert show];
	[searchErrorAlert release];
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
}

- (void) viewWillAppear:(BOOL)animated {
	// go to current location when view appears again
	//[mapView setRegion:lastUserLocation];
	self.navigationController.navigationBar.translucent = NO;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) viewDidAppear:(BOOL)animated {
	[Disclaimer showDisclaimerIfFirstTime];
}


- (void)dealloc {
	[annotations release];
	[visibleImages release];
	[navLauncher release];
	[super dealloc];
}


@end
