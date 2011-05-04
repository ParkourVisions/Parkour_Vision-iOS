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
 * EditTagsViewController.h
 * author: emancebo
 * 4/5/11
 */

#import <UIKit/UIKit.h>


@interface EditTagsViewController : UIViewController {
	UIToolbar *keyboardToolbar;
	UITextField *tag1;
	UITextField *tag2;
	UITextField *tag3;
	UITextField *tag4;
	UITextField *tag5;
	UITextField *tag6;
	NSMutableArray *allTags;
}

- (NSArray*) getTags;

@property (nonatomic, retain) IBOutlet UIView *keyboardToolbar;
@property (nonatomic, retain) IBOutlet UITextField *tag1;
@property (nonatomic, retain) IBOutlet UITextField *tag2;
@property (nonatomic, retain) IBOutlet UITextField *tag3;
@property (nonatomic, retain) IBOutlet UITextField *tag4;
@property (nonatomic, retain) IBOutlet UITextField *tag5;
@property (nonatomic, retain) IBOutlet UITextField *tag6;

- (IBAction)hideKeyboard:(id)sender;

@end
