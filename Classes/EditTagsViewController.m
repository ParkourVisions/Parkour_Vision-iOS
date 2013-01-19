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
 * EditTagsViewController.m
 * author: emancebo
 * 4/5/11
 */

#import "EditTagsViewController.h"
#import "Tag.h"

static char *CHECKED_DEFAULTS[] = {"pktrainingspot", "parkour", '\0'};
static char *UNCHECKED_DEFAULTS[] = 
	{
		"accessramp", 
		"benches", 
		"bollards", 
		"college", 
		"curbs", 
		"ledges", 
		"park", 
		"parkinggarage", 
		"playground", 
		"railings", 
		"rocks", 
		"scaffolding", 
		"stairs", 
		"trees", 
		"walls",
		'\0'
	};

static int CURRENT_TAG_IDX = 0;
static int SUGGESTED_TAG_IDX = 1;
static int NUM_SECTIONS = 2;

@implementation EditTagsViewController

@synthesize keyboardToolbar, textField, tableView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	allTags = [[NSMutableArray alloc] init];
	for (int i=0; i < NUM_SECTIONS; ++i) {
		[allTags addObject:[[[NSMutableArray alloc] init] autorelease]];
	}
	
	[self setupDefaults:CHECKED_DEFAULTS selected:YES];
	[self setupDefaults:UNCHECKED_DEFAULTS selected:NO];
}

- (NSArray*) getTags {
	NSMutableArray *tagStrings = [[NSMutableArray alloc] init];
	
	for (int i=0; i < NUM_SECTIONS; ++i) {
		for (Tag *tag in [allTags objectAtIndex:i]) {
			if (tag.isSelected) {
				[tagStrings addObject:tag.text];
			}
		}
	}
	
	return [tagStrings autorelease];
}

- (void) setupDefaults:(char **)tagArray selected:(BOOL)selected {
	
	int idx = SUGGESTED_TAG_IDX;
	if (selected) {
		idx = CURRENT_TAG_IDX;
	}
	
	int i=0;
	char *tagString = tagArray[i];
	while (tagString != NULL) {
		NSString *str = [NSString stringWithUTF8String:tagString];
		NSMutableArray *arr = [allTags objectAtIndex:idx];
		[arr addObject:[[[Tag alloc] initWithText:str selected:selected] autorelease]];
		tagString = tagArray[++i];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditTagsTableCell"];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EditTagsTableCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
	}
	
	Tag *tag = [[allTags objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.textLabel.text = tag.text;
	
	if (tag.isSelected == YES) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[allTags objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NUM_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == CURRENT_TAG_IDX) {
		return @"Current Tags";
	}
	else {
		return @"Suggested Tags";
	}
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
	
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
	
	Tag *tag = [[allTags objectAtIndex:newIndexPath.section] objectAtIndex:newIndexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
		tag.isSelected = YES;
    } 
	else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
		tag.isSelected = NO;
    }	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)hideKeyboard:(id)sender {
	self.textField.text = @"";
	[self.textField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = self.keyboardToolbar.frame;
    frame.origin.y = self.view.frame.size.height - 211.0;
    self.keyboardToolbar.frame = frame;
	
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = self.keyboardToolbar.frame;
    frame.origin.y = self.view.frame.size.height;
    self.keyboardToolbar.frame = frame;
	
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
	
	NSString *text = tf.text;
	
	if (text.length > 0) {
		[[allTags objectAtIndex:CURRENT_TAG_IDX] addObject:[[[Tag alloc] initWithText:text selected:YES] autorelease]];
		tf.text = @"";
	}
	[tf resignFirstResponder];
	[tableView reloadData];
	
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[allTags release];
	allTags = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
