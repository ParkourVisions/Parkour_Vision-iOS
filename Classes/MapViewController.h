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
 * MapViewController.h
 * author: emancebo
 * 4/10/11
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class LinkedList;
#import "NavLauncher.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {
	UIView *parentView;
	MKMapView *mapView;
	UIScrollView *scrollView;
	
	// model objects
	LinkedList *visibleImages;
	NSMutableDictionary *annotations;
	
	BOOL isCurrentLocationSet;
	//MKCoordinateRegion lastUserLocation;
	
	NavLauncher *navLauncher;
}

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIScrollView *scrollView;

+ (MapViewController*) getInstance;

- (void) setNavLauncher:(NavLauncher *)launcher;

- (NSDictionary*) getImageIdSet;
- (void) addVisibleImages:(NSArray*)pkImages;
- (void) removeImagesOutsideMinCoord:(CLLocationCoordinate2D)minCoord maxCoord:(CLLocationCoordinate2D)maxCoord;

- (void) onThumbTap:(UIGestureRecognizer*)gestureRecognizer;
- (void) showDetailViewForImage:(id)sender;

- (double) distBetween:(CLLocationCoordinate2D)coordA coordB:(CLLocationCoordinate2D) coordB;
- (void) nearestNeighborSort;

- (void) setSearchError:(NSError*)error;

@end
