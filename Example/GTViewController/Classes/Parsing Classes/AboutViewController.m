//
//  AboutViewController.m
//  Snuffy
//
//  Created by Michael Harrison on 4/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "AboutViewController.h"
#import	"GTPage.h"

@interface AboutViewController () <UIActionSheetDelegate, GTPageDelegate>

@property (nonatomic, strong) id<AboutViewControllerDelegate>	aboutDelegate;
@property (nonatomic, strong) GTFileLoader				*fileLoader;
@property (nonatomic, strong) NSString					*filename;
@property (nonatomic, weak  ) IBOutlet UILabel          *share;
@property (nonatomic, weak  ) IBOutlet UINavigationBar  *navigationBar;
@property (nonatomic, weak  ) IBOutlet UIScrollView     *scrollView;

@property (nonatomic, strong) NSArray *allURLsButtonArray;

- (IBAction)dismissAbout:(id)sender;

- (void)emailLink:(NSString *)website;
- (void)copyLink:(NSString *)website;
- (void)openInSafari:(NSString *)website;
- (void)emailAllLinks;
- (void)copyAllLinks;

@end

@implementation AboutViewController

-(instancetype)initWithFilename:(NSString *)file delegate:(id<AboutViewControllerDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader {
	
	self = [super init];
	
	if (self) {
		
		self.filename		= file;
		self.aboutDelegate	= delegate;
		self.fileLoader		= fileLoader;
		
	}
	
    return self;
}

-(IBAction)dismissAbout:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
    
	if ([self.aboutDelegate respondsToSelector:@selector(hideNavToolbar)]) {
		
		[self.aboutDelegate hideNavToolbar];
		
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	GTPage *aboutPage = [[GTPage alloc] initWithFilename:self.filename frame:self.view.frame delegate:self fileLoader:self.fileLoader];
	self.scrollView.backgroundColor = aboutPage.backgroundColor;
	self.navigationBar.tintColor = aboutPage.backgroundColor;
	[self.scrollView addSubview:aboutPage];
	[aboutPage viewHasTransitionedIn];
	
	//dynamically grab scroll hieght
	CGFloat maxheight = 0;
	for (UIView *subview in aboutPage.subviews) {
		maxheight = fmax(maxheight, CGRectGetMaxY(subview.frame));
	}
	aboutPage.frame = CGRectMake(0, 0, self.view.frame.size.width, maxheight + 10);
	[self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, maxheight + 10)];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - GTPageDelegate

- (UIView *)viewOfPageViewController {
	
	return self.aboutDelegate.viewOfPageViewController;
}

- (void)page:(GTPage *)page didReceiveTapOnURL:(NSURL *)url {
	
	//	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:website]]
	//																			 applicationActivities:nil];
	//
	//	controller.excludedActivityTypes	= @[UIActivityTypePostToWeibo,
	//											UIActivityTypePrint,
	//											UIActivityTypeAssignToContact,
	//											UIActivityTypeSaveToCameraRoll,
	//											UIActivityTypePostToFlickr,
	//											UIActivityTypePostToVimeo,
	//											UIActivityTypePostToTencentWeibo,
	//											UIActivityTypeAirDrop];
	//
	//	[self.navigationController presentViewController:controller animated:YES completion:nil];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url.absoluteString
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Open", @"Email", @"Copy", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet showInView:self.view];
	
}

- (void)page:(GTPage *)page didReceiveTapOnPhoneNumber:(NSString *)phoneNumber {
	
	NSString *phoneNumberString = [@"tel:" stringByAppendingString:phoneNumber];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberString]];
	
}

- (void)page:(GTPage *)page didReceiveTapOnEmailAddress:(NSString *)emailAddress {
	
	NSString *emailString = [@"mailto:" stringByAppendingString:emailAddress];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
	
}

- (void)page:(GTPage *)page didReceiveTapOnAllUrls:(NSArray *)urlArray {
	
	self.allURLsButtonArray	= urlArray;
	
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"All Websites"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Email", @"Copy", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet showInView:self.view];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ([[actionSheet title] isEqual:@"All Websites"]) {
		switch (buttonIndex) {
			case 0://email
				[self emailAllLinks];
				break;
			case 1://copy
				   //[self copyAllLinks];
				break;
			default:
				break;
		}
	} else {
		switch (buttonIndex) {
			case 0://open
				[self openInSafari:[actionSheet title]];
				break;
			case 1://email
				[self emailLink:[actionSheet title]];
				break;
			case 2://copy
				[self copyLink:[actionSheet title]];
				break;
			default:
				break;
		}
	}
	
}

-(void)emailLink:(NSString *)website {
	NSString *emailString = [[NSString alloc] initWithFormat:@"mailto:?subject=A website to assist you&body=http://%@",website];
	NSString *escaped = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
}

-(void)copyLink:(NSString *)website {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = website;
}

-(void)openInSafari:(NSString *)website {
	NSString *urlString = website	= ( [website hasPrefix:@"http"] ?
									   website :
									   [@"http://" stringByAppendingString:website] );
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)emailAllLinks {
    NSArray	*array					  = self.allURLsButtonArray;
    NSMutableString	*websiteString    = [NSMutableString string];
    NSUInteger i, count               = [array count];
	
	for (i = 0; i < count; i++) {
		NSObject * dictObj = [array objectAtIndex:i];
		[websiteString appendFormat:@"%@ - http://%@,\n", [dictObj valueForKey:@"title"],[dictObj valueForKey:@"url"]];
	}
	
	NSString *emailString = [[NSString alloc] initWithFormat:@"mailto:?subject=Websites to assist you&body=%@",[websiteString substringFromIndex:0]];
	NSString *escaped = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
}

-(void)copyAllLinks {
	
    UIPasteboard *pasteboard          = [UIPasteboard generalPasteboard];
    NSArray	*array					  = self.allURLsButtonArray;
    NSMutableString	*websiteString    = [NSMutableString string];
    NSUInteger i, count               = [array count];
	
	for (i = 0; i < count; i++) {
		NSObject * dictObj = [array objectAtIndex:i];
		[websiteString appendFormat:@"http://%@\n", [dictObj valueForKey:@"url"]];
	}
	
	pasteboard.string = websiteString;
}

@end
