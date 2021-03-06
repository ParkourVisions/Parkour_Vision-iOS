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
 * MainNavController.h
 * author: emancebo
 * 4/5/11
 */

#import <UIKit/UIKit.h>

@class AccountViewController;
@class MapViewController;
@class UploadStatusController;
@class AboutViewController;

@interface MainNavController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
	UIView *mainView;
	
	AccountViewController *accountVC;
	AboutViewController *aboutVC;
	UIButton *uploadsButton;
	MapViewController *mapViewController;
	UploadStatusController *uploadStatusController;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet UIButton *uploadsButton;
@property (nonatomic, retain) AccountViewController *accountVC;

@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) UploadStatusController *uploadStatusController;
@property (nonatomic, retain) AboutViewController *aboutVC;

- (IBAction) viewUploads:(id)sender;
- (IBAction) browse:(id)sender;
- (IBAction) account:(id)sender;
- (IBAction) about:(id)sender;
- (IBAction) showDisclaimer:(id)sender;

@end