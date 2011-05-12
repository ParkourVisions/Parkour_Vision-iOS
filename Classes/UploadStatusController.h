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
 * UploadStatusController.h
 * author: emancebo
 * 5/6/11
 */

#import <UIKit/UIKit.h>

#import "EditInfoViewController.h"
#import "EditLocationViewController.h"
#import "EditTagsViewController.h"
#import "UploadInfo.h"
#import "UploadTask.h"
#import "AuthInterceptor.h"

@interface UploadStatusController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITableViewDataSource, UploadTaskDelegate> {

	UITableView *tableView;
	EditLocationViewController *editLocationVC;
	EditInfoViewController *editInfoVC;
	EditTagsViewController *editTagsVC;
	UITabBarController *tabBarController;
	UINavigationController *uploadNavController;
	UploadInfo *uploadInfo;
	
	UITableViewCell *tvCell;
	
	NSMutableArray *uploadQueue;
	NSMutableDictionary *uploadTaskToProgressView;
	
	AuthInterceptor *authInterceptor;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) EditLocationViewController *editLocationVC;
@property (nonatomic, retain) EditInfoViewController *editInfoVC;
@property (nonatomic, retain) EditTagsViewController *editTagsVC;
@property (nonatomic, retain) IBOutlet UINavigationController *uploadNavController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UploadInfo *uploadInfo;

@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

- (void) onNewUpload:(id)sender;
- (IBAction) submitUpload:(id)sender;
- (IBAction) cancelUploadPhoto:(id)sender;
- (void) configureUploadController;
- (void) populateUploadInfo;

@end
