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

@class EditLocationViewController;
@class EditInfoViewController;
@class EditTagsViewController;
@class AccountViewController;
@class UploadInfo;
@class MapViewController;

@interface MainNavController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
	UIView *mainView;
	
	EditLocationViewController *editLocationVC;
	EditInfoViewController *editInfoVC;
	EditTagsViewController *editTagsVC;
	AccountViewController *accountVC;
	UITabBarController *tabBarController;
	UINavigationController *uploadNavController;
	UIButton *uploadFromCameraButton;
	UIButton *uploadFromLibraryButton;
	MapViewController *mapViewController;
	
	UIImage *selectedImage;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet UIButton *uploadFromCameraButton;
@property (nonatomic, retain) IBOutlet UIButton *uploadFromLibraryButton;
@property (nonatomic, retain) IBOutlet AccountViewController *accountVC;
@property (nonatomic, retain) EditLocationViewController *editLocationVC;
@property (nonatomic, retain) EditInfoViewController *editInfoVC;
@property (nonatomic, retain) EditTagsViewController *editTagsVC;
@property (nonatomic, retain) IBOutlet UINavigationController *uploadNavController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) MapViewController *mapViewController;

@property (nonatomic, retain) UIImage *selectedImage;

- (IBAction) uploadFromCamera:(id)sender;
- (IBAction) uploadFromLibrary:(id)sender;

- (IBAction) browse:(id)sender;
- (IBAction) account:(id)sender;

- (IBAction) cancelUploadPhoto:(id)sender;
- (IBAction) submitUpload:(id)sender;

- (void) configureUploadController;
- (UploadInfo*) createUploadInfo;

@end