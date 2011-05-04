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
 * SearchRequest.h
 * author: emancebo
 * 3/23/11
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SearchRequest : NSObject {

	int rid;
	CLLocationCoordinate2D minCoord;
	CLLocationCoordinate2D maxCoord;
	NSDictionary *curImageIds;
}

@property (nonatomic, assign) int rid;
@property (nonatomic, assign) CLLocationCoordinate2D minCoord;
@property (nonatomic, assign) CLLocationCoordinate2D maxCoord;
@property (nonatomic, retain) NSDictionary *curImageIds;

@end
