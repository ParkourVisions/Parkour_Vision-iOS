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
 * Disclaimer.m
 * author: emancebo
 * 7/4/11
 */

#import "Disclaimer.h"


@implementation Disclaimer

+ (void) showDisclaimerPopup {
	UIAlertView *disclaimer = [[UIAlertView alloc] initWithTitle:@"Disclaimer" 
														  message:@"Parkour visions (PKV) in no way verifies that the photos in this app depict safe or legal places to practice parkour.  By using this app you agree to not hold PKV or developers of this app liable for any any injury/death that may occur from training at these places." 
														delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil];
	[disclaimer show];
	[disclaimer release];
}

+ (void) showDisclaimerIfFirstTime {

	NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
	NSString *disclaimerKey = @"have_shown_disclaimer";
	
	BOOL haveShownDisclaimer = [config boolForKey:disclaimerKey];
	
	if (haveShownDisclaimer)
		return;
	
	[Disclaimer showDisclaimerPopup];
	[config setObject:[NSNumber numberWithBool:YES] forKey:disclaimerKey];
}

@end
