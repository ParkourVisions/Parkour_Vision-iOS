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
 * EditLocationViewController.m
 * author: emancebo
 * 4/5/11
 */

#import "EditLocationViewController.h"
#import "PKAnnotation.h"

@implementation EditLocationViewController

@synthesize mapView;

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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//mapView.showsUserLocation = YES;
	
	/*
	
	PKAnnotation *ann = [[PKAnnotation alloc] init];
	CLLocationCoordinate2D coord = {47, -122};
	ann.coordinate = coord;
	
	[mapView addAnnotation:ann];
	[ann release];
	
	MKCoordinateRegion region;
	region.span.latitudeDelta = 5.0;
	region.span.longitudeDelta = 5.0;
	region.center.latitude = 47;
	region.center.longitude = -122;
	[mapView setRegion:region animated:NO];
	*/
	
	// should check if photo has geo exif before doing this
	mapView.showsUserLocation = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NULL];
	annView.animatesDrop = YES;
	annView.canShowCallout = NO;
	annView.draggable = YES;
	
	return annView;
}

- (void)mapView:(MKMapView *)mv didFailToLocateUserWithError:(NSError *)error {
	NSLog(@"Error finding user location: %@", [error localizedDescription]);
	
	// Cannot find user location, drop pin in the middle of map
	PKAnnotation *ann = [[PKAnnotation alloc] init];
	CLLocationCoordinate2D coord = {0, 0};
	ann.coordinate = coord;
	
	[mapView addAnnotation:ann];
	[ann release];
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {	
	// zoom in to user location
	MKCoordinateRegion region;
	region.center = mapView.userLocation.location.coordinate;
	region.span.latitudeDelta = 0.025;
	region.span.longitudeDelta = 0.025;
	[mapView setRegion:region animated:NO];
}

- (CLLocationCoordinate2D) getCoord {
	
	CLLocationCoordinate2D coord;
	PKAnnotation *ann = [mapView.annotations objectAtIndex:0];
	if (ann != nil) {
		coord = ann.coordinate;
	}
	
	return coord;
}

- (void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated {
	double dy = mapView.region.span.latitudeDelta;
	double dx = mapView.region.span.longitudeDelta;
	
	NSLog(@"Span =  x:%f y%f", dx, dy);
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
    [super dealloc];
}


@end
