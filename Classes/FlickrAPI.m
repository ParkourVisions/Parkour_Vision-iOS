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
 * FlickrAPI.m
 * author: emancebo
 * 3/24/11
 */

#import "FlickrAPI.h"
#import "JSON.h"
#import "PKImage.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#include <libkern/OSAtomic.h>
#import "ImageInfo.h"

#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>

// configurable constants
static int RESULTS_PER_PAGE = 7;
static NSString *PK_GROUP_ID = @"819314@N20";
static NSString *API_KEY = @"2099cafa3dc4df6fec7bb0e5d7aec256";
static NSString *SECRET = @"d7b13bf4ebfceac2";

static int numApiCalls = 0;

static NSCache *infoCache;

@implementation FlickrAPI

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        infoCache = [[NSCache alloc] init];
		[infoCache setCountLimit:256];
    }
}

+ (void) incrementApiCount {
	int x = OSAtomicIncrement32(&numApiCalls);

	if (x % 10 == 0) {
		NSLog(@"Api calls = %d", x);
	}
}

+ (NSMutableArray*) searchRegionMin:(CLLocationCoordinate2D)minCoord max:(CLLocationCoordinate2D)maxCoord error:(NSError**)error {
	
	NSMutableArray *imageList = [[NSMutableArray alloc] init];
	
	NSString *requestString = 
		[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&group_id=%@&bbox=%f,%f,%f,%f&per_page=%d&format=json&nojsoncallback=1", 
		 API_KEY, PK_GROUP_ID, minCoord.longitude, minCoord.latitude, maxCoord.longitude, maxCoord.latitude, RESULTS_PER_PAGE];
	
	NSDictionary *result = [self callFlickrWithRequestString:requestString error:error];
	
	if (result != nil) {
		// extract image IDs
		NSArray *photos = [[result objectForKey:@"photos"] objectForKey:@"photo"];
		for (NSDictionary *photo in photos)
		{		
			NSString *imageId = [photo objectForKey:@"id"];
			//NSLog(@"Found image ID: %@", imageId);
			PKImage *image = [[PKImage alloc] initWithImageId:imageId];
			image.farm = [photo objectForKey:@"farm"];
			image.server = [photo objectForKey:@"server"];
			image.secret = [photo objectForKey:@"secret"];
		
			[imageList addObject:image];
			[image release];
		}
	}

	return [imageList autorelease];
}

// returns results as an NSDictionary parsed from the JSON response
+ (NSDictionary*) callFlickrWithRequestString:(NSString*)requestString error:(NSError**)error {
	
	//NSLog(@"request string: %@", requestString);
	
	NSMutableDictionary *dict = nil;
	
	NSURL *url = [NSURL URLWithString:requestString];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLResponse *response = nil;
	NSError *myError = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&myError];
	
	if (myError) {
		NSLog(@"Got error: %@", [myError description]);
		*error = myError;
	}
	else {
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		dict = [jsonString JSONValue];
		[jsonString release];
	}
	
	[FlickrAPI incrementApiCount];
	[request release];
	return dict;
}

+ (UIImage*) getImage:(PKImage*)pkImage size:(NSString*)size {
	
	NSString *sizeStr = @"";
	if (size != nil) {
		sizeStr = [NSString stringWithFormat:@"_%@", size];
	}
	
	NSString *photoURLString = 
		[NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@%@.jpg", 
			pkImage.farm, pkImage.server, pkImage.imageId, pkImage.secret, sizeStr];
	
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]];
	UIImage *uiImage = [UIImage imageWithData:imgData];
	
	return uiImage;
}

+ (void) setInfo:(PKImage*)pkImage {

	// first check cache
	ImageInfo *imageInfo = [infoCache objectForKey:pkImage.imageId];
	if (imageInfo == nil) {
		imageInfo = [[ImageInfo alloc] init];
		
		NSString *requestString = 
			[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", API_KEY, pkImage.imageId];

		NSDictionary *result = [self callFlickrWithRequestString:requestString error:nil];

		if (result != nil) {
			CLLocationCoordinate2D point;
			point.latitude = [[[[result objectForKey:@"photo"] objectForKey:@"location"] objectForKey:@"latitude"] doubleValue];
			point.longitude = [[[[result objectForKey:@"photo"] objectForKey:@"location"] objectForKey:@"longitude"] doubleValue];
			imageInfo.location = point;
		}
	
		imageInfo.title = [[[result objectForKey:@"photo"] objectForKey:@"title"] objectForKey:@"_content"];
		imageInfo.username = [[[result objectForKey:@"photo"] objectForKey:@"owner"] objectForKey:@"username"];
		
		[infoCache setObject:imageInfo forKey:pkImage.imageId];
		[imageInfo release];
	}
	else {
		static int cacheHits = 0;
		int x = OSAtomicIncrement32(&cacheHits);
		NSLog(@"cache hits = %d", x);
	}
	
	pkImage.title = imageInfo.title;
	pkImage.username = imageInfo.username;
	pkImage.coord = imageInfo.location;
}

+ (PostResult*) uploadPhoto:(UploadInfo*)uploadInfo {
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	[postData setObject:@"1" forKey:@"is_public"];
	[postData setObject:uploadInfo.title forKey:@"title"];
	[postData setObject:uploadInfo.desc forKey:@"description"];
	[postData setObject:[uploadInfo getTagString] forKey:@"tags"];
	
	PostResult *result = 
		[FlickrAPI postToUrl:@"http://api.flickr.com/services/upload" postData:postData image:uploadInfo.imageData];
	
	[postData release];
	return result;
}

+ (PostResult*) addPhoto:(NSString*)photoId toGroup:(NSString*)groupId {
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	[postData setObject:@"flickr.groups.pools.add" forKey:@"method"];
	[postData setObject:photoId forKey:@"photo_id"];
	[postData setObject:groupId forKey:@"group_id"];
	
	PostResult *result = 
		[FlickrAPI postToUrl:@"http://api.flickr.com/services/rest" postData:postData image:nil];
	
	[postData release];
	return result;
}

+ (PostResult*) setPhotoLocation:(NSString*)photoId coord:(CLLocationCoordinate2D)coord {
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	[postData setObject:@"flickr.photos.geo.setLocation" forKey:@"method"];
	[postData setObject:photoId forKey:@"photo_id"];
	[postData setObject:[NSString stringWithFormat:@"%f", coord.latitude] forKey:@"lat"];
	[postData setObject:[NSString stringWithFormat:@"%f", coord.longitude] forKey:@"lon"];
	
	PostResult *result = 
		[FlickrAPI postToUrl:@"http://api.flickr.com/services/rest" postData:postData image:nil];
	
	[postData release];
	return result;
}

+ (PostResult*) postToUrl:(NSString*)urlString postData:(NSDictionary*)postData image:(NSData*)imageData {
	
	NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
	[myDict addEntriesFromDictionary:postData];
	
	// add in common args
	NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"auth_token"];
	[myDict setObject:API_KEY forKey:@"api_key"];
	[myDict setObject:authToken forKey:@"auth_token"];
	
	// upload API does not seem to support json, so just do everything in xml for posts
	//[myDict setObject:@"json" forKey:@"format"];
	//[myDict setObject:@"1" forKey:@"nojsoncallback"];
	
	NSString *sig = [FlickrAPI apiSigFromArgs:myDict];
	
	ASIFormDataRequest *request = 
		[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request addPostValue:sig forKey:@"api_sig"];
	for (NSString *key in myDict) {
		NSString *val = [myDict objectForKey:key];
		if ([val length] > 0)
			[request addPostValue:val forKey:key];
	}
	[myDict release];
	
	if (imageData != nil) {
		int len = [imageData length];
		NSLog(@"Setting imageData with %d bytes", len);
		[request addData:imageData forKey:@"photo"];
	}
	
	[request startSynchronous];
	
	PostResult *result = [[PostResult alloc] init];
	result.statusCode = request.responseStatusCode;
	if (request.responseStatusCode == 200) {
		result.rawResponse = [request responseString];
		[result populateFromXmlResponse:result.rawResponse];
		NSLog(@"response string: %@", result.rawResponse);
	}
	else {
		result.isOK = NO;
		result.errorMessage = [request responseStatusMessage];
		if (result.errorMessage == nil) {
			result.errorMessage = [NSString stringWithFormat:@"%d", request.responseStatusCode];
		}
	}
	
	[FlickrAPI incrementApiCount];
	[request release];
	return [result autorelease];
}

+ (AuthResult*) authenticate:(NSString*)frob {

	NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
	[args setObject:@"flickr.auth.getToken" forKey:@"method"];
	[args setObject:API_KEY forKey:@"api_key"];
	[args setObject:frob forKey:@"frob"];
	[args setObject:@"json" forKey:@"format"];
	[args setObject:@"1" forKey:@"nojsoncallback"];
	//[args setObject:@"write" forKey:@"perms"];
	
	NSString *queryString = [FlickrAPI signedQueryStringFromArgs:args];
	NSString *requestString = [NSString stringWithFormat:@"http://flickr.com/services/rest/?%@", queryString];
	[args release];
	
	NSDictionary *result = [self callFlickrWithRequestString:requestString error:nil];
	// {"auth":{"token":{"_content":"72157626272487149-76e9ce8578ab3b92"}, "perms":{"_content":"write"}, "user":{"nsid":"60225151@N03", "username":"pkphotomap", "fullname":""}}, "stat":"ok"}
	
	AuthResult *authResult = [[AuthResult alloc] init];
	authResult.token = [[[result objectForKey:@"auth"] objectForKey:@"token"] objectForKey:@"_content"];
	authResult.userId = [[[result objectForKey:@"auth"] objectForKey:@"user"] objectForKey:@"nsid"];
	authResult.username = [[[result objectForKey:@"auth"] objectForKey:@"user"] objectForKey:@"username"];
	authResult.fullname = [[[result objectForKey:@"auth"] objectForKey:@"user"] objectForKey:@"fullname"];
	
	return [authResult autorelease];
}

+ (NSString*) signedQueryStringFromArgs:(NSDictionary*)args {
	NSMutableString *queryString = [NSMutableString stringWithCapacity:10];
	
	for (NSString *arg in [args allKeys]) {
		NSString *val = [args objectForKey:arg];		
		if ([val length] > 0) {
			if ([queryString length] > 0) {
				[queryString appendFormat:@"%@", @"&"];
			}
			[queryString appendFormat:@"%@=%@", arg, val];
		}
	}
	
	[queryString appendFormat:@"&api_sig=%@", [FlickrAPI apiSigFromArgs:args]];
	
	return queryString;
}	

+ (NSString*) apiSigFromArgs:(NSDictionary*)args {
	NSArray *sortedKeys = [[args allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	NSMutableString *sigString = [NSMutableString stringWithString:SECRET];	
	for (NSString *arg in sortedKeys) {
		NSString *val = [args objectForKey:arg];
		if ([val length] > 0)
			[sigString appendFormat:@"%@%@", arg, val];
	}
	
	NSString *apiSig = [FlickrAPI calculateMd5:sigString];

	return apiSig;
}

+ (NSString*) calculateMd5:(NSString*)str {
	const char *data = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(data, strlen(data), result);
	
	NSMutableString *md5hex = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++) {
        [md5hex appendFormat:@"%02x", result[i]];
    }
	return md5hex;
}

@end
