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
 * PostResult.m
 * author: emancebo
 * 4/8/11
 */

#import "PostResult.h"


@implementation PostResult

@synthesize isOK, errorMessage, rawResponse, photoId, statusCode;

- (id) init {
	self = [super init];
	if (self) {
		inPhotoID = NO;
	}
	return self;
}

- (void) populateFromXmlResponse:(NSString*)response {
	NSData* xmlData = [response dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	parser.delegate = self;
	[parser parse];
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"rsp"]) {
		NSString *status = [attributeDict objectForKey:@"stat"];
		self.isOK = [status isEqualToString:@"ok"];
	}
	else if ([elementName isEqualToString:@"err"]) {
		self.errorMessage = [attributeDict objectForKey:@"msg"];
	}
	else if ([elementName isEqualToString:@"photoid"]) {
		inPhotoID = YES;
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (inPhotoID) {
		self.photoId = string;
		inPhotoID = NO;
	}
}

- (NSString*) description {
	return [NSString stringWithFormat:@"stat:%d err:%@ photoId:%@", isOK, errorMessage, photoId];
}


@end
