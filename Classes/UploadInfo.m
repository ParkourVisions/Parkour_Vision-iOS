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
 * UploadInfo.m
 * author: emancebo
 * 4/6/11
 */

#import "UploadInfo.h"


@implementation UploadInfo

@synthesize image, title, desc, tags, coord;

- (NSString *)description {
	return [NSString stringWithFormat:@"image:%@ title:%@ desc:%@ tags:%@ coord:(%f, %f)",
			[image description], title, desc, [tags description], coord.latitude, coord.longitude];
}

- (NSString*) getTagString {
	NSMutableString *str = [[NSMutableString alloc] init];
	for (NSString *tag in tags) {
		if ([str length] > 0) {
			[str appendFormat:@"%@", @" "];
		}
		[str appendFormat:@"%@", tag];
	}
	
	return [str autorelease];
}

@end
