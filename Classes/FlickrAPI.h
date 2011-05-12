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
 * FlickrAPI.h
 * author: emancebo
 * 3/24/11
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PKImage.h"
#import "AuthResult.h"
#import "UploadInfo.h"
#import "PostResult.h"

@interface FlickrAPI : NSObject {

}

// searches for images within specified region
// returns list of image IDs
+ (NSMutableArray*) searchRegionMin:(CLLocationCoordinate2D)minCoord max:(CLLocationCoordinate2D)maxCoord error:(NSError**)error;

// valid sizes one of {s, t, m, z, b}
// See: http://www.flickr.com/services/api/misc.urls.html
+ (UIImage*) getImage:(PKImage*)pkImage size:(NSString*)size;

// sets coordinates and other info properties
+ (void) setInfo:(PKImage*)pkImage;

+ (AuthResult*) authenticate:(NSString*)frob;

+ (PostResult*) addPhoto:(NSString*)photoId toGroup:(NSString*)groupId;
+ (PostResult*) uploadPhoto:(UploadInfo*)uploadInfo;
+ (PostResult*) setPhotoLocation:(NSString*)photoId coord:(CLLocationCoordinate2D)coord;

// private
+ (NSDictionary*) callFlickrWithRequestString:(NSString*)requestString error:(NSError**)error;
+ (NSString*) signedQueryStringFromArgs:(NSDictionary*)args;
+ (NSString*) apiSigFromArgs:(NSDictionary*)args;
+ (NSString*) calculateMd5:(NSString*)str;
+ (PostResult*) postToUrl:(NSString*)urlString postData:(NSDictionary*)postData image:(NSData*)imageData;
+ (void) incrementApiCount;

@end
