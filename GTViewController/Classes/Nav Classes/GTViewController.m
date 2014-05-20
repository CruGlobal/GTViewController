//
//  GTViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 4/25/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "GTPage.h"
#import "GTAboutViewController.h"
#import "GTPageMenuViewController.h"
#import "HorizontalGestureRecognizer.h"
#import "TBXML.h"
#import "GTFileLoader.h"
#import "SNInstructions.h"
#import "GTPage.h"


NSString *const GTViewControllerNotificationUserInfoLanguageKey			= @"org.cru.godtools.gtviewcontroller.notifications.all.key.language";
NSString *const GTViewControllerNotificationUserInfoPackageKey			= @"org.cru.godtools.gtviewcontroller.notifications.all.key.package";
NSString *const GTViewControllerNotificationUserInfoVersionKey			= @"org.cru.godtools.gtviewcontroller.notifications.all.key.version";

NSString *const GTViewControllerNotificationResourceDidOpen				= @"org.cru.godtools.gtviewcontroller.notifications.resourcedidopen";
NSString *const GTViewControllerNotificationUserDidShareResource		= @"org.cru.godtools.gtviewcontroller.notifications.userdidshareresource";

/**
 *  Touch Notification Key Names
 */
NSString *const snuffyViewControllerTouchNotificationTouchesKey       = @"org.cru.godtools.snuffyViewController.touchnotifications.key.touches";
NSString *const snuffyViewControllerTouchNotificationTouchKey		  = @"org.cru.godtools.snuffyViewController.touchnotifications.key.touch";
NSString *const snuffyViewControllerTouchNotificationEventKey         = @"org.cru.godtools.snuffyViewController.touchnotifications.key.event";

/**
 *  Touch Notification names
 */
NSString *const snuffyViewControllerTouchNotificationTouchesBegan     = @"org.cru.godtools.snuffyViewController.touchnotifications.name.touchesbegan";
NSString *const snuffyViewControllerTouchNotificationTouchesMoved     = @"org.cru.godtools.snuffyViewController.touchnotifications.name.touchesmoved";
NSString *const snuffyViewControllerTouchNotificationTouchesEnded     = @"org.cru.godtools.snuffyViewController.touchnotifications.name.touchesended";
NSString *const snuffyViewControllerTouchNotificationTouchesCancelled = @"org.cru.godtools.snuffyViewController.touchnotifications.name.touchescancelled";
NSString *const snuffyViewControllerTouchNotificationTap              = @"org.cru.godtools.snuffyViewController.touchnotifications.name.tap";

#define SLOW_TRANSITION_ANIMATION_DURATION 2.5
#define NORMAL_TRANSITION_ANIMATION_DURATION 0.25
#define FAST_TRANSITION_ANIMATION_DURATION 0.05
#define RESISTED_DRAG_MULTIPLIER 0.5
#define GAP_BETWEEN_VIEWS 50
#define TOOLBAR_PEEK 5



//////////TableView Mode constants//////////


NSInteger  const kTBMode_Package	= 0;
NSInteger  const kTBMode_Language	= 1;
NSInteger  const kTBMode_Page		= 2;


//////////Page Array constants//////////


NSInteger  const kPageArray_File	= 0;
NSInteger  const kPageArray_Thumb	= 1;
NSInteger  const kPageArray_Desc	= 2;


//////////Config constants///////////////


//element string constants
NSString * const kName_Doc			= @"document";
NSString * const kName_Package		= @"packagename";
NSString * const kName_Page			= @"page";
NSString * const kName_About		= @"about";

//attribute string constants
NSString * const kAttr_language		= @"lang";
NSString * const kAttr_thumb		= @"thumb";
NSString * const kAttr_filename		= @"filename";


////////////Page constants////////////////

// Constants for the XML tag names
extern NSString * const kName_Button;
extern NSString * const kName_Image;
extern NSString * const kName_Panel;
extern NSString * const kName_PanelImage;

// Constants for the XML attribute names
extern NSString * const kAttr_backgroundImage;
extern NSString * const kAttr_watermark;

@interface GTViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, GTAboutViewControllerDelegate, SNInstructionsDelegate, HorizontalGestureRecognizerDelegate, GTPageDelegate>

@property (nonatomic, weak)		id<GTViewControllerMenuDelegate> menuDelegate;
@property (nonatomic, strong)	GTFileLoader *fileLoader;

@property (nonatomic, strong)	NSString *package;
@property (nonatomic, strong)	NSString *language;
@property (nonatomic, strong)	NSNumber *version;
@property (nonatomic, assign)	NSInteger activeView;

@property (nonatomic, strong)	NSString *aboutFilename;
@property (nonatomic, strong)	NSString *packageName;

@property (nonatomic, strong)	NSArray *packageArray;
@property (nonatomic, strong)	NSMutableArray *languageArray;
@property (nonatomic, strong)	NSMutableArray *pageArray;

@property (nonatomic, weak)		IBOutlet UIButton	*navToolbarButton;
@property (nonatomic, weak)		IBOutlet UIToolbar *navToolbar;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *aboutButton;
@property (nonatomic, strong)	UIBarButtonItem *switchButton;
@property (nonatomic, assign)	BOOL navToolbarIsShown;

@property (nonatomic, strong)	SNInstructions	*instructionPlayer;
@property (nonatomic, strong)	NSArray			*arrayFromPlist;

@property (nonatomic, strong)	AVAudioPlayer *AVPlayer;

@property (nonatomic, strong)	GTPage *leftLeftPage;
@property (nonatomic, strong)	GTPage *leftPage;
@property (nonatomic, strong)	GTPage *centerPage;
@property (nonatomic, strong)	GTPage *rightPage;
@property (nonatomic, strong)	GTPage *rightRightPage;
@property (nonatomic, strong)	GTPage *oldCenterPage;

@property (nonatomic, assign)	double transitionAnimationDuration;
@property (nonatomic, assign)	double resistedDragMultiplier;
@property (nonatomic, assign)	NSUInteger gapBetweenViews;

@property (nonatomic, assign)	CGPoint inViewInCenterCenter;
@property (nonatomic, assign)	CGPoint outOfViewOnRightCenter;
@property (nonatomic, assign)	CGPoint outOfViewOnLeftCenter;

@property (nonatomic, assign)	NSInteger animating;
@property (nonatomic, strong)	CABasicAnimation *animateCurrentViewOut;
@property (nonatomic, strong)	CABasicAnimation *animateCurrentViewBackToCenter;
@property (nonatomic, strong)	CABasicAnimation *animateNextViewIn;
@property (nonatomic, strong)	CABasicAnimation *animateNextViewOut;

@property (nonatomic, strong)	HorizontalGestureRecognizer *gestureRecognizer;

@property (nonatomic, assign)	BOOL firstLeftSwipeRegistered;
@property (nonatomic, assign)	BOOL secondLeftSwipeRegistered;
@property (nonatomic, assign)	BOOL firstRightSwipeRegistered;
@property (nonatomic, assign)	BOOL secondRightSwipeRegistered;

@property (nonatomic, assign)	BOOL viewWillTransitionExecuted;

@property (nonatomic, assign)	BOOL activeViewMasked;
@property (nonatomic, assign)	BOOL isRotated;
@property (nonatomic, assign)	BOOL instructionsAreRunning;
@property (nonatomic, assign)	BOOL aboutViewControllerWasShown;

@property (nonatomic, strong)	GTPageMenuViewController	*pageMenu;
@property (nonatomic, assign)	BOOL							isFirstRunSinceCreation;
@property (nonatomic, strong)	NSArray							*allURLsButtonArray;

- (void)registerNotificationHandlers;
- (void)removeNotificationHandlers;

- (NSString *)produceShareLink;
- (NSString *)produceLinkForCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium;

- (void)skipToIndex:(NSInteger)index animated:(BOOL)animated;

- (void)emailLink:(NSString *)website;
- (void)copyLink:(NSString *)website;
- (void)openInSafari:(NSString *)website;
- (void)emailAllLinks;
- (void)copyAllLinks;

//naviagation methods
-(IBAction)toggleToolbar:(id)sender;
-(void)showNavToolbar;
-(void)showNavToolbarDidStop;
-(void)hideNavToolbar;
-(void)hideNavToolbarDidStop;
-(void)fiftyTap;

-(void)showInstructions;
-(void)runInstructionsIfNecessary;

-(IBAction)navEmptySelector:(id)sender;
-(IBAction)navToolbarShareSelector:(id)sender;
-(IBAction)navToolbarAboutSelector:(id)sender;
-(IBAction)navToolbarRewindSelector:(id)sender;
-(IBAction)navToolbarMenuSelector:(id)sender;
-(IBAction)navToolbarFastForwardSelector:(id)sender;

- (void)skipTo:(NSInteger)index;
- (void)skipToTransitionDidStop;

//animation methods
- (void)animateCenterViewBackToCenterFromLeft;
- (void)animateCenterViewBackToCenterFromRight;
- (void)animateCenterViewOutToRight;
- (void)animateCenterViewOutToLeft;

//animation callbacks
- (void)animateCenterViewBackToCenterFromLeftDidStop;
- (void)animateCenterViewBackToCenterFromRightDidStop;
- (void)animateRightViewOutFromCurrentPosDidStop;
- (void)animateLeftViewOutFromCurrentPosDidStop;
- (void)animateCenterViewOutToTheRightDidStop;
- (void)animateLeftViewInFromTheLeftDidStop;
- (void)animateCenterViewOutToTheLeftDidStop;
- (void)animateRightViewInFromTheRightDidStop;
- (void)animationCleanUp;

//caching methods
- (void)centerViewHasTransitionedOutToLeft;
- (void)centerViewHasTransitionedOutToRight;
- (void)cacheImagesForPage:(GTPage *)pageToCache;
- (void)cacheImagesForButtonWithElement:(TBXMLElement *)button_el;
- (void)cacheImagesForPanelWithElement:(TBXMLElement *)panel_el;

//config functions
- (void)switchTo:(NSString *)packageID language:(NSString *)language;
- (void)changeLanguageTo:(NSString *)languageCode;
- (void)changePackageTo:(NSString *)packageID;
- (NSMutableArray *)pageArrayFromDocumentElement:(TBXMLElement *)element;

@end

@implementation GTViewController

- (instancetype)initWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode versionNumber:(NSNumber *)versionNumber delegate:(id<GTViewControllerMenuDelegate>)delegate {
	
	if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) {
		
		[self registerNotificationHandlers];
		
		self.transitionAnimationDuration	= NORMAL_TRANSITION_ANIMATION_DURATION;
		self.resistedDragMultiplier			= RESISTED_DRAG_MULTIPLIER;
		self.gapBetweenViews				= GAP_BETWEEN_VIEWS;
		self.viewWillTransitionExecuted		= NO;
		self.isRotated						= NO;
		self.instructionsAreRunning			= NO;
		self.isFirstRunSinceCreation		= YES;
		
		//add instruction button and make instructions for button to play
		self.instructionPlayer					= [[SNInstructions alloc] init];
		
		UIBarButtonItem	*helpButton				= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Package_PopUpToolBar_Icon_Help"] style:UIBarButtonItemStyleBordered target:self action:@selector(showInstructions)];
		self.navigationItem.rightBarButtonItem	= helpButton;
		
		//init active package, language and pages
		self.package	= ( packageCode ? packageCode : @"fourlaws" );
		self.language	= ( languageCode ? languageCode : @"en" );
		self.version	= ( versionNumber ? versionNumber : @1 );
		self.activeView	= 0;
		
		self.fileLoader = [GTFileLoader fileLoaderWithPackage:self.package language:self.language];
		[self.fileLoader performSelectorInBackground:@selector(cacheSharedImages) withObject:nil];
		
		//parse xml
		TBXML *tempXml = [[TBXML alloc] initWithXMLPath:self.fileLoader.pathOfConfigFile];
		//fill page array
		self.pageArray =  [self pageArrayFromDocumentElement:tempXml.rootXMLElement];
		
		//add gesture recognizer
		self.gestureRecognizer	= [[HorizontalGestureRecognizer alloc] initWithDelegate:self target:self.view];
		
	}
	
	return self;
	
}

- (void)loadResourceWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode versionNumber:(NSNumber *)versionNumber {
	
	self.version	= ( versionNumber ? versionNumber : @1 );
	
	[self switchTo:packageCode language:languageCode];
	
}

- (void)switchToPageWithIndex:(NSUInteger)pageIndex {
	
	[self skipTo:pageIndex];
	
}

- (GTPageMenuViewController *)pageMenu {
	
	if (_pageMenu == nil) {
		
		[self willChangeValueForKey:@"pageMenu"];
		_pageMenu = [[GTPageMenuViewController alloc] initWithNibName:@"GTPageMenuViewController" bundle:nil];
		[self didChangeValueForKey:@"pageMenu"];
		
		__weak GTViewController *weakSelf = self;
		[[NSNotificationCenter defaultCenter] addObserverForName:GTTPageMenuViewControllerSwitchPage object:_pageMenu queue:nil usingBlock:^(NSNotification *note) {
			
			NSNumber *pageNumber = note.userInfo[GTTPageMenuViewControllerPageNumber];
			[weakSelf skipTo:[pageNumber integerValue]];
			
		}];
		
	}
	
	return _pageMenu;
	
}

- (void)registerNotificationHandlers {
	
	__weak GTViewController *weakSelf = self;
	
	[[NSNotificationCenter defaultCenter] addObserverForName:snuffyViewControllerTouchNotificationTouchesBegan object:nil queue:nil usingBlock:^(NSNotification *note) {
		
		NSSet *touches	= note.userInfo[snuffyViewControllerTouchNotificationTouchesKey];
		UIEvent *event	= note.userInfo[snuffyViewControllerTouchNotificationEventKey];
		[weakSelf touchesBegan:touches withEvent:event];
		
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:snuffyViewControllerTouchNotificationTouchesMoved object:nil queue:nil usingBlock:^(NSNotification *note) {
		
		NSSet *touches	= note.userInfo[snuffyViewControllerTouchNotificationTouchesKey];
		UIEvent *event	= note.userInfo[snuffyViewControllerTouchNotificationEventKey];
		[weakSelf touchesMoved:touches withEvent:event];
		
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:snuffyViewControllerTouchNotificationTouchesEnded object:nil queue:nil usingBlock:^(NSNotification *note) {
		
		NSSet *touches	= note.userInfo[snuffyViewControllerTouchNotificationTouchesKey];
		UIEvent *event	= note.userInfo[snuffyViewControllerTouchNotificationEventKey];
		[weakSelf touchesEnded:touches withEvent:event];
		
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:snuffyViewControllerTouchNotificationTouchesCancelled object:nil queue:nil usingBlock:^(NSNotification *note) {
		
		NSSet *touches	= note.userInfo[snuffyViewControllerTouchNotificationTouchesKey];
		UIEvent *event	= note.userInfo[snuffyViewControllerTouchNotificationEventKey];
		[weakSelf touchesCancelled:touches withEvent:event];
		
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:snuffyViewControllerTouchNotificationTap object:nil queue:nil usingBlock:^(NSNotification *note) {
		
		UITouch *touch	= note.userInfo[snuffyViewControllerTouchNotificationTouchKey];
		UIEvent *event	= note.userInfo[snuffyViewControllerTouchNotificationEventKey];
		[weakSelf processTap:touch withEvent:event];
		
	}];
	
}

- (void)removeNotificationHandlers {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:snuffyViewControllerTouchNotificationTouchesBegan object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:snuffyViewControllerTouchNotificationTouchesMoved object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:snuffyViewControllerTouchNotificationTouchesEnded object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:snuffyViewControllerTouchNotificationTouchesCancelled object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:snuffyViewControllerTouchNotificationTap object:nil];
	
}

#pragma mark -
#pragma mark Skip Methods

- (IBAction)navEmptySelector:(id)sender {
	//this is a work around to avoid button press issues on a hidden toolbar
}

- (NSString *)produceShareLink {
	
	return [NSString stringWithFormat:@"http://www.godtoolsapp.com"];
}

- (NSString *)produceLinkForCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium {
	
	NSString *appVersionNumber	= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	return [self.produceShareLink stringByAppendingFormat:@"?package=%@&language=%@&utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@", self.package, self.language, source, medium, appVersionNumber, campaign];
}

-(IBAction)navToolbarShareSelector:(id)sender {
	
	[self hideNavToolbar];
	
	if ([MFMailComposeViewController canSendMail]) {
		
		NSString *campaignLink				= [self produceLinkForCampaign:	snuffyViewControllerCampaignLinkCampaignName
														  source:			snuffyViewControllerCampaignLinkCampaignSource
														  medium:			snuffyViewControllerCampaignLinkCampaignMedium];
		
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate			= self;
        NSString *emailBody					= [NSString stringWithFormat:@"Hey!<br /><br />Here is the link for the app we were talking about<a href=\"%@\">%@</a>", campaignLink, self.produceShareLink];
		
        [mailer setSubject:self.packageName];
        [mailer setMessageBody:emailBody isHTML:YES];
		
        [self presentViewController:mailer animated:YES completion:nil];
		
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GTViewControllerNotificationUserDidShareResource
																object:self
															  userInfo:@{GTViewControllerNotificationUserInfoLanguageKey:	self.language,
																		 GTViewControllerNotificationUserInfoPackageKey:	self.package,
																		 GTViewControllerNotificationUserInfoVersionKey:	self.version}];
			
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
	
	// Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)navToolbarAboutSelector:(id)sender {
	
	GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithFilename:self.aboutFilename delegate:self fileLoader:self.fileLoader];

    [self presentViewController:aboutViewController animated:YES completion:nil];
    
    aboutViewController.navigationTitle.title = self.packageName;
	self.aboutViewControllerWasShown = YES;
    
}

-(IBAction)navToolbarRewindSelector:(id)sender {
	[self hideNavToolbar];
	[self skipTo:0];
}

-(void)navToolbarAddRemoveSwitchButtonForPackage:(NSString *)package andLanguage:(NSString *)language {
	
	if ( [package isEqualToString:@"kgp"] && ( [language isEqualToString:@"en_heartbeat"] || [language isEqualToString:@"et_heartbeat"] ) ) {
		
		//if button not already there then add button
		if (self.switchButton == nil) {
			
			UIBarButtonItem *switchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Package_PopUpToolBar_Icon_Switch"]
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(navToolbarHeartbeatSwitch)];
			
			self.switchButton = switchButton;
			
			[self.navToolbar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.shareButton, self.menuButton, self.switchButton, self.aboutButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil] animated:YES];
			
		}
		
		
	} else {
		
		//if button already there then remove button
		if (self.switchButton != nil) {
			
			[self.navToolbar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.shareButton, self.menuButton, self.aboutButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil] animated:YES];
			
			self.switchButton	= nil;
			
		}
		
		
	}
	
}

-(void)navToolbarHeartbeatSwitch {
	
	if ([[self language] isEqualToString:@"en_heartbeat"]) {
		
		[self changeLanguageTo:@"et_heartbeat"];
		
	} else if ([[self language] isEqualToString:@"et_heartbeat"]) {
	
		[self changeLanguageTo:@"en_heartbeat"];
		
	} else {
		
		[self changeLanguageTo:@"en_heartbeat"];
		
	}
	
}

-(IBAction)navToolbarMenuSelector:(id)sender {
	
	[self hideNavToolbar];
	
	self.pageMenu.language	= self.language;
	self.pageMenu.package	= self.package;
	self.pageMenu.pageArray = self.pageArray;
	[self presentViewController:self.pageMenu animated:YES completion:nil];
	
}

-(IBAction)navToolbarFastForwardSelector:(id)sender {
	[self hideNavToolbar];
	[self skipTo:([[self.pageArray objectAtIndex:kPageArray_File] count] - 1)];
}

-(IBAction)toggleToolbar:(id)sender {
	if (self.navToolbarIsShown) {
		[self hideNavToolbar];
	} else {
		[self showNavToolbar];
	}
}

- (void)skipTo:(NSInteger)index {
	
	[self skipToIndex:index animated:YES];
	
}

- (void)skipToIndex:(NSInteger)index animated:(BOOL)animated {
	//NSLog(@"snuffyViewController: skipTo");
	GTPage *newLeftLeftPage, *newLeftPage, *newCenterPage, *newRightPage, *newRightRightPage;
	
	//make sure the views aren't animating
	//if (self.animating == 0) {
		//if they are in a position to switch and there is a valid index
		if (index >= 0 && index < [[[self pageArray] objectAtIndex:kPageArray_File] count]) {
			//make the active view the current index
			self.activeView = index;
			
			//create the new view controllers
			if (index > 1) {
				newLeftLeftPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView - 2]
															 frame:self.view.frame
														  delegate:self
														fileLoader:self.fileLoader];
            } else {
                newLeftLeftPage = nil;
            }
			
			if (index > 0) {
				newLeftPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView - 1]
														 frame:self.view.frame
													  delegate:self
													fileLoader:self.fileLoader];
			} else {
				newLeftPage = nil;
			}
			
				newCenterPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView]
													   frame:self.view.frame
													delegate:self
												  fileLoader:self.fileLoader];
			
			if (index < [[[self pageArray] objectAtIndex:kPageArray_File] count] - 1) {
				newRightPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView + 1]
														  frame:self.view.frame
													   delegate:self
													 fileLoader:self.fileLoader];
			} else {
				newRightPage = nil;
			}
			
			if (index < [[[self pageArray] objectAtIndex:kPageArray_File] count] - 2) {
				newRightRightPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView + 2]
															   frame:self.view.frame
															delegate:self
														  fileLoader:self.fileLoader];
			} else {
				newRightRightPage = nil;
			}

			
			//remove the left view
			if (self.leftPage.superview) {
				[self.leftPage removeFromSuperview];
			}
			self.leftPage = nil;
			
			//remove the right view
			if (self.rightPage.superview != nil) {
				[self.rightPage removeFromSuperview];
			}
			self.rightPage = nil;
			
			//add the new center view to the root view
			newCenterPage.hidden	= YES;
			newCenterPage.center	= self.inViewInCenterCenter;
			[self.view insertSubview:newCenterPage belowSubview:self.centerPage];
			
			//let the center view's view controller know that it is about to transition
			[self.centerPage viewWillTransitionOut];
			
			if (animated) {
				
				//transition between the old center view and the new one
				CATransition *transition = [CATransition animation];
				transition.duration = 0.75;
				transition.removedOnCompletion = YES;
				transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				transition.type = kCATransitionFade;
				transition.delegate = self;
				[transition setValue:@"skipToTransition" forKey:@"name"];
				
				//let other code know that it is animating
				self.animating = 1;
				
				//set the animaiton to go
				[self.view.layer addAnimation:transition forKey:nil];
				
			}
			
			// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
			self.centerPage.hidden	= YES;
			newCenterPage.hidden	= NO;
			
			//save a reference to the old center view controller so that it can be cleaned up after the animation is over
			self.oldCenterPage = self.centerPage;
			
			//let the view controllers know that they are about to be released
			[self.leftLeftPage viewControllerWillBeReleased];
			[self.leftPage viewControllerWillBeReleased];
			[self.centerPage viewControllerWillBeReleased];
			[self.rightPage viewControllerWillBeReleased];
			[self.rightRightPage viewControllerWillBeReleased];
			
			//set the left center and right view controllers to the newly created ones
			self.leftLeftPage = newLeftLeftPage;
			self.leftPage = newLeftPage;
			self.centerPage = newCenterPage;
			self.rightPage = newRightPage;
			self.rightRightPage = newRightRightPage;
			
			//let the page's view controllers know what has happened to their views
			[self.oldCenterPage viewHasTransitionedOut];
			[self.centerPage viewHasTransitionedIn];

		}
	//}
}

- (void)skipToTransitionDidStop {
	//NSLog(@"snuffyViewController: skipToTransitionDidStop");
	//let everyone know that animation as stopped
	self.animating = 0;
	
	//let the page's view controllers know what has happened to their views
	//[self.oldCenterViewController viewHasTransitionedOut];
	//[self.centerViewController viewHasTransitionedIn];
	
	[self.oldCenterPage removeFromSuperview];
	self.oldCenterPage.hidden	= NO;
	self.oldCenterPage			= nil;
}

- (void)fiftyTap {
	//NSLog(@"snuffyViewController: fiftyTap");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView	setAnimationDuration:1];
	
	CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	fullRotation.fromValue = [NSNumber numberWithFloat:0];
	fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
	fullRotation.duration = 0.5;
	fullRotation.repeatCount = 10;
	[self.centerPage.layer addAnimation:fullRotation forKey:@"360"];
	
	CABasicAnimation *zoomFull = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	zoomFull.fromValue = [NSNumber numberWithFloat:0.0];
	zoomFull.toValue = [NSNumber numberWithFloat:1.0];
	zoomFull.duration = 2.5;
	zoomFull.repeatCount = 1;
	[self.centerPage.layer addAnimation:zoomFull forKey:@"zoom"];
	
	[UIView commitAnimations];
	/*
	 NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	 resourcePath = [resourcePath stringByAppendingString:@"/Resources/fiftytap.mp3"];
	 //NSLog(@"Path to play: %@", resourcePath);
	 NSError* err;
	 
	 player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:err];
	 
	 if (err) {
	 //NSLog(@"Failed with reson: %@", [err localizedDescription]);
	 }
	 else {
	 player.delegate = self;
	 [player play];
	 }
	 */
	
	//NSError *error = nil;
	NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"fiftytap" ofType:@"mp3"];
	NSURL		*soundURL	= [[NSURL alloc] initFileURLWithPath:soundPath];
	self.AVPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:NULL];
	
	if (!self.AVPlayer.playing) {
		[self.AVPlayer play];
	}
	
	
}

-(void)runInstructionsIfNecessary {
	
	if (self.arrayFromPlist == nil) {
	
		NSString	*documentsFolder	= [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString	*plistPath			= [documentsFolder stringByAppendingPathComponent:@"instructions.plist"];
		NSArray		*arrayFromPlist		= [NSArray arrayWithContentsOfFile:plistPath];
		
		self.arrayFromPlist = arrayFromPlist;
		
		if ( [arrayFromPlist count] == 0 ) {
			
			[self performSelector:@selector(showInstructions) withObject:nil afterDelay:0.5];
			
			NSArray	*arrayForPlist	= [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"InstructionsHaveBeenShown", nil], nil];
			
			self.arrayFromPlist = arrayForPlist;
			
			[arrayForPlist writeToFile:plistPath atomically:NO];
			
		}
		
	}
	
}

-(void)showInstructions {
	
	if (!self.instructionsAreRunning) {
		
		[self.instructionPlayer showIntructionsInView:self.view forDirection:SNTextDirectionModeLeftToRight withDelegate:self];
		self.instructionsAreRunning = YES;
		
	}
	
}

-(void)instructionAnimationsComplete {
	
	self.instructionsAreRunning = NO;
	
}

#pragma mark - GTPageDelegate & AboutViewControllerDelegate

- (UIView *)viewOfPageViewController {
	
	return self.view;
}

- (void)showNavToolbar {
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	if ([self.menuDelegate respondsToSelector:@selector(showNavToolbar)]) {
		[self.menuDelegate performSelector:@selector(showNavToolbar)];
	}
	
	self.navToolbarIsShown = YES;
	
	//bring toolbars to front again now that more views have been added
	[self.view bringSubviewToFront:self.navToolbar];
	[self.view bringSubviewToFront:self.navToolbarButton];
	
	CGRect toolbarFrame			= self.navToolbar.frame;
	toolbarFrame.origin.y		= self.view.frame.size.height - self.navToolbar.frame.size.height;// + TOOLBAR_PEEK;
	CGRect toolbarButtonFrame	= self.navToolbarButton.frame;
	toolbarButtonFrame.origin.y	= toolbarFrame.origin.y - self.navToolbarButton.frame.size.height;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showNavToolbarDidStop)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
	
	self.navToolbar.frame		= toolbarFrame;
	self.navToolbarButton.frame	= toolbarButtonFrame;
	
	[UIView commitAnimations];
}

- (void)showNavToolbarDidStop {
	
	
}

- (void)hideNavToolbar {
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	if ([self.menuDelegate respondsToSelector:@selector(hideNavToolbar)]) {
		
		[self.menuDelegate performSelector:@selector(hideNavToolbar)];
		
	}
	
	CGRect toolbarFrame			= self.navToolbar.frame;
	toolbarFrame.origin.y		= self.view.frame.size.height - TOOLBAR_PEEK;
	CGRect toolbarButtonFrame	= self.navToolbarButton.frame;
	toolbarButtonFrame.origin.y	= toolbarFrame.origin.y - self.navToolbarButton.frame.size.height;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideNavToolbarDidStop)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
	
	self.navToolbar.frame		= toolbarFrame;
	self.navToolbarButton.frame	= toolbarButtonFrame;
	
	[UIView commitAnimations];
	
}

- (void)hideNavToolbarDidStop {
	
	self.navToolbarIsShown		= NO;
	
}

#pragma mark - GTPageDelegate

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


#pragma mark - User Interaction methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: TouchesBegan %d", self.animating);
	//if (self.animating == 0) {
	//run gesture recognition code
	[self.gestureRecognizer processTouchesBegan:touches withEvent:event];
	
	//}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: touchesMoved %d", self.animating);
	//if (self.animating == 0) {
	[self.gestureRecognizer processTouchesMoved:touches withEvent:event];
	//}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: touchesEnded %d", self.animating);
	//if (self.animating == 0) {
	[self.gestureRecognizer processTouchesEnded:touches withEvent:event];
	//}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: touchesCancelled %d", self.animating);
	[self.gestureRecognizer processTouchesCancelled:touches withEvent:event];
}


#pragma mark -
#pragma mark Gesture Processing methods

- (void)processRightSwipe:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: processRightSwipe");
	if (self.animating == 0) {
		if (self.navToolbarIsShown) {
			[self hideNavToolbar];
		}
		
		//check if a swipe is currently being process/animated
		if (self.firstRightSwipeRegistered) {
			self.secondRightSwipeRegistered = YES;
		} else {
			self.firstRightSwipeRegistered = YES;
		}
		
		//tell the view controller that its view is being moved
		[self.leftPage setViewBeingMoved:YES];
		[self.centerPage setViewBeingMoved:YES];
		[self.rightPage setViewBeingMoved:YES];
		
		//add the view to be swiped in
		if (self.leftPage != nil && self.leftPage.superview == nil) {
			self.leftPage.center	= CGPointMake(self.centerPage.center.x - self.centerPage.frame.size.width - self.gapBetweenViews,
												  self.centerPage.center.y);
			[self.view addSubview:self.leftPage];
			//bring toolbars to front again now that more views have been added
			[self.view bringSubviewToFront:self.navToolbar];
			[self.view bringSubviewToFront:self.navToolbarButton];
		}
		
		//let the visable view reset before the transition happens
		if (!self.viewWillTransitionExecuted) {
			self.viewWillTransitionExecuted = [self.centerPage viewWillTransitionWithSwipe:YES];
		}
		
		//transition to the next view as long as we aren't at the boundary
		if (self.activeView == 0) {
			[self animateCenterViewBackToCenterFromRight];
		} else {
			[self animateCenterViewOutToRight];
		}
	}
}

- (void)processLeftSwipe:(UITouch *)touch withEvent:(UIEvent *)event{
	//NSLog(@"snuffyViewController: processLeftSwipe");
	if (self.animating == 0) {
		
		if (self.navToolbarIsShown) {
			[self hideNavToolbar];
		}
		
		//check if a swipe is currently being process/animated
		if (self.firstLeftSwipeRegistered) {
			self.secondLeftSwipeRegistered = YES;
		} else {
			self.firstLeftSwipeRegistered = YES;
		}
		
		//tell the view controller that its view is being moved
		[self.leftPage setViewBeingMoved:YES];
		[self.centerPage setViewBeingMoved:YES];
		[self.rightPage setViewBeingMoved:YES];
		
		//add the view to be swiped in
		if (self.rightPage != nil && self.rightPage.superview == nil) {
			self.rightPage.center	= CGPointMake(self.centerPage.center.x + self.centerPage.frame.size.width + self.gapBetweenViews,
												  self.centerPage.center.y);
			[self.view addSubview:self.rightPage];
			//bring toolbars to front again now that more views have been added
			[self.view bringSubviewToFront:self.navToolbar];
			[self.view bringSubviewToFront:self.navToolbarButton];
		}
		
		//let the visable view reset before the transition happens
		if (!self.viewWillTransitionExecuted) {
			self.viewWillTransitionExecuted = [self.centerPage viewWillTransitionWithSwipe:YES];
		}
		
		//transition to the next view as long as we aren't at the boundary
		if (self.activeView == ([[self.pageArray objectAtIndex:kPageArray_File] count] - 1)) {
			[self animateCenterViewBackToCenterFromLeft];
		} else {
			[self animateCenterViewOutToLeft];
		}
	}
}

- (void)processRightDrag:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: processRightDrag");
	if (self.animating == 0) {
		
		if (self.navToolbarIsShown) {
			[self hideNavToolbar];
		}
		
		//let the visable view reset before the transition happens
		if (!self.viewWillTransitionExecuted) {
			self.viewWillTransitionExecuted = [self.centerPage viewWillTransitionWithSwipe:NO];
		}
		
		//tell the view controller that its view is being moved
		[self.leftPage setViewBeingMoved:YES];
		[self.centerPage setViewBeingMoved:YES];
		[self.rightPage setViewBeingMoved:YES];
		
		CGPoint currentTouchPosition = [touch locationInView:self.view];
		CGPoint lastTouchPosition = [touch previousLocationInView:self.view];
		double changeInX = currentTouchPosition.x - lastTouchPosition.x;
		
		//add view to be dragged
		//only add it if there is one to add, it hasn't already been added and it is going to be needed (ie it is about to come onto screen)
		if (self.leftPage != nil && self.leftPage.superview == nil && self.centerPage.center.x >= (self.inViewInCenterCenter.x + (0.5 * self.gapBetweenViews))) {
			
			self.leftPage.center	= CGPointMake(self.centerPage.center.x - self.centerPage.frame.size.width - self.gapBetweenViews,
												  self.centerPage.center.y);
			[self.view addSubview:self.leftPage];
			//bring toolbars to front again now that more views have been added
			[self.view bringSubviewToFront:self.navToolbar];
			[self.view bringSubviewToFront:self.navToolbarButton];
			
		}
		
		CGPoint currentLeftViewPosition		= self.leftPage.center;
		CGPoint currentCenterViewPosition	= self.centerPage.center;
		CGPoint currentRightViewPosition	= self.rightPage.center;
		
		//introduce resisted drag (finger slips on content) if on first page and the page is being dragged off screen
		if ((self.activeView == 0 && self.centerPage.center.x > (self.centerPage.frame.size.width / 2))) {
			changeInX = round(changeInX * self.resistedDragMultiplier);
		}
		
		currentLeftViewPosition.x += changeInX;
		currentCenterViewPosition.x += changeInX;
		currentRightViewPosition.x += changeInX;
		
		self.leftPage.center	= currentLeftViewPosition;
		self.centerPage.center	= currentCenterViewPosition;
		self.rightPage.center	= currentRightViewPosition;
	}
}

- (void)processLeftDrag:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: processLeftDrag");
	if (self.animating == 0) {
		
		if (self.navToolbarIsShown) {
			[self hideNavToolbar];
		}
		
		//let the visable view reset before the transition happens
		if (!self.viewWillTransitionExecuted) {
			self.viewWillTransitionExecuted = [self.centerPage viewWillTransitionWithSwipe:NO];
		}
		
		//tell the view controller that its view is being moved
		[self.leftPage setViewBeingMoved:YES];
		[self.centerPage setViewBeingMoved:YES];
		[self.rightPage setViewBeingMoved:YES];
		
		CGPoint currentTouchPosition = [touch locationInView:self.view];
		CGPoint lastTouchPosition = [touch previousLocationInView:self.view];
		double changeInX = currentTouchPosition.x - lastTouchPosition.x;
		
		//add view to be dragged
		//only add it if there is one to add, it hasn't already been added and it is going to be needed (ie it is about to come onto screen)
		if (self.rightPage != nil && self.rightPage.superview == nil && self.centerPage.center.x <= (self.inViewInCenterCenter.x - (0.5 * self.gapBetweenViews))) {
			
			self.rightPage.center	= CGPointMake(self.centerPage.center.x + self.centerPage.frame.size.width + self.gapBetweenViews,
												  self.centerPage.center.y);
			[self.view addSubview:self.rightPage];
			//bring toolbars to front again now that more views have been added
			[self.view bringSubviewToFront:self.navToolbar];
			[self.view bringSubviewToFront:self.navToolbarButton];
		}
		
		CGPoint currentLeftViewPosition		= self.leftPage.center;
		CGPoint currentCenterViewPosition	= self.centerPage.center;
		CGPoint currentRightViewPosition	= self.rightPage.center;
		
		//introduce resisted drag (finger slips on content) if on first page and the page is being dragged off screen
		if (self.activeView == (((NSArray *)(self.pageArray[kPageArray_File])).count - 1) && self.centerPage.center.x < (self.centerPage.frame.size.width / 2)) {
			changeInX = round(changeInX * self.resistedDragMultiplier);
		}
		
		currentLeftViewPosition.x	+= changeInX;
		currentCenterViewPosition.x	+= changeInX;
		currentRightViewPosition.x	+= changeInX;
		
		self.leftPage.center		= currentLeftViewPosition;
		self.centerPage.center		= currentCenterViewPosition;
		self.rightPage.center		= currentRightViewPosition;
	}
}

- (void)processRightDragEnd:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: processRightDragEnd");
	if (self.animating == 0) {
		//if the view has been moved past half way then animate out
		if (self.centerPage.frame.origin.x >= self.view.center.x) {
			
			//transition to the next view as long as we aren't at the boundary
			if (self.activeView == 0) {
				[self animateCenterViewBackToCenterFromRight];
			} else {
				[self animateCenterViewOutToRight];
			}
		} else {
			[self animateCenterViewBackToCenterFromRight];
		}
	}
}

- (void)processLeftDragEnd:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"snuffyViewController: processLeftDragEnd");
	if (self.animating == 0) {
		//if the view has been moved past half way then animate out
		if (self.centerPage.center.x <= self.view.frame.origin.x) {
			
			//transition to the next view as long as we aren't at the boundary
			if (self.activeView == ([[self.pageArray objectAtIndex:kPageArray_File] count] - 1)) {
				[self animateCenterViewBackToCenterFromLeft];
			} else {
				[self animateCenterViewOutToLeft];
			}
		} else {
			[self animateCenterViewBackToCenterFromLeft];
		}
	}
}

- (void)processTap:(UITouch *)touch withEvent:(UIEvent *)event {
	//NSLog(@"Tap Count: %d", touch.tapCount);
	//retract any panels that are open
	
	if (touch.tapCount == 20) {
		[self fiftyTap];
	}
	
	if (touch.tapCount == 1) {
		[self.centerPage tapAnywhere];
		
		if (self.navToolbarIsShown) {
			[self hideNavToolbar];
		} else {
			if (!self.activeViewMasked) {
				[self showNavToolbar];
			}
		}
		
	}
	
}

- (void)resetViews {
	//NSLog(@"snuffyViewController: resetViews");
	//remove animations
	[self.leftPage.layer removeAllAnimations];
	[self.centerPage.layer removeAllAnimations];
	[self.rightPage.layer removeAllAnimations];
	
	//remove the side views and put current view back in center
	[self.leftPage removeFromSuperview];
	[self.rightPage removeFromSuperview];
	self.centerPage.center	= self.inViewInCenterCenter;
	
	//tell the view controller that its view isnt being moved
	[self.leftPage setViewBeingMoved:NO];
	[self.centerPage setViewBeingMoved:NO];
	[self.rightPage setViewBeingMoved:NO];
	
	//reset animation instance variables
	self.animating = 0;
	self.animateNextViewIn = nil;
	self.animateCurrentViewOut = nil;
	self.animateCurrentViewBackToCenter = nil;
	
	[self.gestureRecognizer reset];
}


#pragma mark -
#pragma mark Animation methods

- (void)animateCenterViewBackToCenterFromLeft {
	//make sure no animation is going on
	if (self.animating == 0) {
		
		UIView *currentView	= self.centerPage;
		UIView *nextView	= self.rightPage;
		
		//lets the view know what is about to happen to it
		[self.centerPage viewWillReturnToCenter];
		
		if (self.leftPage.superview != nil) {
			[self.leftPage removeFromSuperview];
		}
		
		//set animation direction
		self.animating = -1;
		
		self.animateCurrentViewBackToCenter=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateCurrentViewBackToCenter.delegate = self;
		self.animateCurrentViewBackToCenter.removedOnCompletion = YES;
		self.animateCurrentViewBackToCenter.duration=self.transitionAnimationDuration;
		self.animateCurrentViewBackToCenter.autoreverses=NO;
		self.animateCurrentViewBackToCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateCurrentViewBackToCenter.fromValue=[NSValue valueWithCGPoint:currentView.center];
		self.animateCurrentViewBackToCenter.toValue=[NSValue valueWithCGPoint:self.inViewInCenterCenter];
		[self.animateCurrentViewBackToCenter setValue:@"animateCenterViewBackToCenterFromLeft" forKey:@"name"];
		[currentView.layer addAnimation:self.animateCurrentViewBackToCenter forKey:@"animateCenterViewBackToCenterFromLeft"];
		[currentView setCenter:self.inViewInCenterCenter];
		
		if (self.rightPage != nil) {
			self.animateNextViewOut=[CABasicAnimation animationWithKeyPath:@"position"];
			self.animateNextViewOut.delegate = self;
			self.animateNextViewOut.removedOnCompletion = YES;
			self.animateNextViewOut.duration=self.transitionAnimationDuration;
			self.animateNextViewOut.autoreverses=NO;
			self.animateNextViewOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			self.animateNextViewOut.fromValue=[NSValue valueWithCGPoint:nextView.center];
			self.animateNextViewOut.toValue=[NSValue valueWithCGPoint:self.outOfViewOnRightCenter];
			[self.animateNextViewOut setValue:@"animateRightViewOutFromCurrentPos" forKey:@"name"];
			[nextView.layer addAnimation:self.animateNextViewOut forKey:@"animateRightViewOutFromCurrentPos"];
			[nextView setCenter:self.outOfViewOnRightCenter];
		} else {
			self.animateNextViewOut = nil;
		}
		
	}
}

- (void)animateCenterViewBackToCenterFromRight {
	//NSLog(@"snuffyViewController: animateCenterViewBackToCenterFromRight");
	//make sure no animation is going on
	if (self.animating == 0) {
		UIView *currentView	= self.centerPage;
		UIView *nextView	= self.leftPage;
		
		//lets the view know what is about to happen to it
		[self.centerPage viewWillReturnToCenter];
		
		if (self.rightPage.superview != nil) {
			[self.rightPage removeFromSuperview];
		}
		
		//set animation direction
		self.animating = 1;
		
		self.animateCurrentViewBackToCenter=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateCurrentViewBackToCenter.delegate = self;
		self.animateCurrentViewBackToCenter.removedOnCompletion = YES;
		self.animateCurrentViewBackToCenter.duration=self.transitionAnimationDuration;
		self.animateCurrentViewBackToCenter.autoreverses=NO;
		self.animateCurrentViewBackToCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateCurrentViewBackToCenter.fromValue=[NSValue valueWithCGPoint:currentView.center];
		self.animateCurrentViewBackToCenter.toValue=[NSValue valueWithCGPoint:self.inViewInCenterCenter];
		[self.animateCurrentViewBackToCenter setValue:@"animateCenterViewBackToCenterFromRight" forKey:@"name"];
		[currentView.layer addAnimation:self.animateCurrentViewBackToCenter forKey:@"animateCenterViewBackToCenterFromRight"];
		[currentView setCenter:self.inViewInCenterCenter];
		
		if (nextView != nil) {
			self.animateNextViewOut=[CABasicAnimation animationWithKeyPath:@"position"];
			self.animateNextViewOut.delegate = self;
			self.animateNextViewOut.removedOnCompletion = YES;
			self.animateNextViewOut.duration=self.transitionAnimationDuration;
			self.animateNextViewOut.autoreverses=NO;
			self.animateNextViewOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			self.animateNextViewOut.fromValue=[NSValue valueWithCGPoint:nextView.center];
			self.animateNextViewOut.toValue=[NSValue valueWithCGPoint:self.outOfViewOnLeftCenter];
			[self.animateNextViewOut setValue:@"animateLeftViewOutFromCurrentPos" forKey:@"name"];
			[nextView.layer addAnimation:self.animateNextViewOut forKey:@"animateLeftViewOutFromCurrentPos"];
			[nextView setCenter:self.outOfViewOnLeftCenter];
		} else {
			self.animateNextViewOut = nil;
		}
		
	}
}

- (void)animateCenterViewOutToRight {
	//make sure no animation is going on
	if (self.animating == 0) {
		
		UIView *nextView	= self.leftPage;
		UIView *currentView = self.centerPage;
		
		//lets the view know what is about to happen to it
		[self.centerPage viewWillTransitionOut];
		
		if (self.rightPage.superview != nil) {
			[self.rightPage removeFromSuperview];
		}
		
		//set animation direction
		self.animating = -1;
		
		//Do the animation
		self.animateCurrentViewOut=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateCurrentViewOut.delegate = self;
		self.animateCurrentViewOut.removedOnCompletion = YES;
		self.animateCurrentViewOut.duration=self.transitionAnimationDuration;
		self.animateCurrentViewOut.autoreverses=NO;
		self.animateCurrentViewOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateCurrentViewOut.fromValue=[NSValue valueWithCGPoint:currentView.center];
		self.animateCurrentViewOut.toValue=[NSValue valueWithCGPoint:self.outOfViewOnRightCenter];
		[self.animateCurrentViewOut setValue:@"animateCenterViewOutToTheRight" forKey:@"name"];
		[currentView.layer addAnimation:self.animateCurrentViewOut forKey:@"animateCenterViewOutToTheRight"];
		[currentView setCenter:self.outOfViewOnRightCenter];
		
		self.animateNextViewIn=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateNextViewIn.delegate = self;
		self.animateNextViewIn.removedOnCompletion = YES;
		self.animateNextViewIn.duration=self.transitionAnimationDuration;
		self.animateNextViewIn.autoreverses=NO;
		self.animateNextViewIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateNextViewIn.fromValue=[NSValue valueWithCGPoint:nextView.center];
		self.animateNextViewIn.toValue=[NSValue valueWithCGPoint:self.inViewInCenterCenter];
		[self.animateNextViewIn setValue:@"animateLeftViewInFromTheLeft" forKey:@"name"];
		[nextView.layer addAnimation:self.animateNextViewIn forKey:@"animateLeftViewInFromTheLeft"];
		[nextView setCenter:self.inViewInCenterCenter];
	}
}

- (void)animateCenterViewOutToLeft {
	//make sure no animation is going on
	if (self.animating == 0) {
		UIView *nextView	= self.rightPage;
		UIView *currentView = self.centerPage;
		
		//lets the view know what is about to happen to it
		[self.centerPage viewWillTransitionOut];
		
		if (self.leftPage.superview != nil) {
			[self.leftPage removeFromSuperview];
		}
		
		//set animation direction
		self.animating = 1;
		
		//Do the animation
		self.animateCurrentViewOut=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateCurrentViewOut.delegate = self;
		self.animateCurrentViewOut.removedOnCompletion = YES;
		self.animateCurrentViewOut.duration=self.transitionAnimationDuration;
		self.animateCurrentViewOut.autoreverses=NO;
		self.animateCurrentViewOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateCurrentViewOut.fromValue= [NSValue valueWithCGPoint:currentView.center];
		self.animateCurrentViewOut.toValue=[NSValue valueWithCGPoint:self.outOfViewOnLeftCenter];
		[self.animateCurrentViewOut setValue:@"animateCenterViewOutToTheLeft" forKey:@"name"];
		[currentView.layer addAnimation:self.animateCurrentViewOut forKey:@"animateCenterViewOutToTheLeft"];
		[currentView setCenter:self.outOfViewOnLeftCenter];
		
		self.animateNextViewIn=[CABasicAnimation animationWithKeyPath:@"position"];
		self.animateNextViewIn.delegate = self;
		self.animateNextViewIn.removedOnCompletion = YES;
		self.animateNextViewIn.duration=self.transitionAnimationDuration;
		self.animateNextViewIn.autoreverses=NO;
		self.animateNextViewIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.animateNextViewIn.fromValue=[NSValue valueWithCGPoint:nextView.center];
		self.animateNextViewIn.toValue=[NSValue valueWithCGPoint:self.inViewInCenterCenter];
		[self.animateNextViewIn setValue:@"animateRightViewInFromTheRight" forKey:@"name"];
		[nextView.layer addAnimation:self.animateNextViewIn forKey:@"animateRightViewInFromTheRight"];
		[nextView setCenter:self.inViewInCenterCenter];
	}
}


#pragma mark -
#pragma mark Animation Callbacks

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	
	if ([[animation valueForKey:@"name"] isEqual:@"animateCenterViewBackToCenterFromLeft"]) {
		[self animateCenterViewBackToCenterFromLeftDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateCenterViewBackToCenterFromRight"]) {
		[self animateCenterViewBackToCenterFromRightDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateRightViewOutFromCurrentPos"]) {
		[self animateRightViewOutFromCurrentPosDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateLeftViewOutFromCurrentPos"]) {
		[self animateLeftViewOutFromCurrentPosDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateCenterViewOutToTheRight"]) {
		[self animateCenterViewOutToTheRightDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateLeftViewInFromTheLeft"]) {
		[self animateLeftViewInFromTheLeftDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateCenterViewOutToTheLeft"]) {
		[self animateCenterViewOutToTheLeftDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"animateRightViewInFromTheRight"]) {
		[self animateRightViewInFromTheRightDidStop];
	} else if ([[animation valueForKey:@"name"] isEqual:@"skipToTransition"]) {
		[self skipToTransitionDidStop];
	} else {
		
	}
	
}

- (void)animateCenterViewBackToCenterFromLeftDidStop {
	
	if (self.animateNextViewOut == nil) {
		self.centerPage.center	= self.inViewInCenterCenter;
		
		//lets the view know that the animation has finished
		[self.centerPage viewHasReturnedToCenter];
		
		if (self.rightPage.superview != nil) {
			[self.rightPage removeFromSuperview];
		}
		
		[self animationCleanUp];
	} else {
		self.animateCurrentViewBackToCenter = nil;
	}
}

- (void)animateRightViewOutFromCurrentPosDidStop {
	
	if (self.animateCurrentViewBackToCenter == nil) {
		self.centerPage.center	= self.inViewInCenterCenter;
		
		//lets the view know that the animation has finished
		[self.centerPage viewHasReturnedToCenter];
		
		if (self.rightPage.superview != nil) {
			[self.rightPage removeFromSuperview];
		}
		
		[self animationCleanUp];
	} else {
		self.animateNextViewOut = nil;
	}
}

- (void)animateCenterViewBackToCenterFromRightDidStop {
	
	if (self.animateNextViewOut == nil) {
		self.centerPage.center	= self.inViewInCenterCenter;
		
		//lets the view know that the animation has finished
		[self.centerPage viewHasReturnedToCenter];
		
		if (self.leftPage.superview != nil) {
			[self.leftPage removeFromSuperview];
		}
		
		[self animationCleanUp];
	} else {
		self.animateCurrentViewBackToCenter = nil;
	}
}

- (void)animateLeftViewOutFromCurrentPosDidStop {
	
	if (self.animateCurrentViewBackToCenter == nil) {
		self.centerPage.center	= self.inViewInCenterCenter;
		
		//lets the view know that the animation has finished
		[self.centerPage viewHasReturnedToCenter];
		
		if (self.leftPage.superview != nil) {
			[self.leftPage removeFromSuperview];
		}
		
		[self animationCleanUp];
	} else {
		self.animateNextViewOut = nil;
	}
}

- (void)animateCenterViewOutToTheRightDidStop {
	
	if (self.animateNextViewIn == nil) {
		
		//lets the view know that the animations have finished
		[self centerViewHasTransitionedOutToRight];
		//[self.leftViewController viewHasTransitionedIn];
		//[self.centerViewController viewHasTransitionedOut];
		
		if (self.activeView == 1) {
			//manage pointers so they represent what is on screen
			self.activeView--;
			[self.centerPage removeFromSuperview];
			[self.rightPage viewControllerWillBeReleased];
			self.rightPage = self.centerPage;
			self.centerPage = self.leftPage;
			self.leftPage = nil;
		} else {
			//manage pointers so they represent what is on screen
			self.activeView--;
			[self.centerPage removeFromSuperview];
			[self.rightPage viewControllerWillBeReleased];
			self.rightPage = self.centerPage;
			self.centerPage = self.leftPage;
			self.leftPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView - 1]
													   frame:self.view.frame
													delegate:self
												  fileLoader:self.fileLoader];
		}
		
		[self animationCleanUp];
	} else {
		self.animateCurrentViewOut = nil;
	}
	
}

- (void)animateLeftViewInFromTheLeftDidStop {
	
	if (self.animateCurrentViewOut == nil) {
		
		//lets the view know that the animations have finished
		[self centerViewHasTransitionedOutToRight];
		//[self.leftViewController viewHasTransitionedIn];
		//[self.centerViewController viewHasTransitionedOut];
		
		if (self.activeView == 1) {
			//manage pointers so they represent what is on screen
			self.activeView--;
			[self.centerPage removeFromSuperview];
			[self.rightPage viewControllerWillBeReleased];
			self.rightPage = self.centerPage;
			self.centerPage = self.leftPage;
			self.leftPage = nil;
		} else {
			//manage pointers so they represent what is on screen
			self.activeView--;
			[self.centerPage removeFromSuperview];
			[self.rightPage viewControllerWillBeReleased];
			self.rightPage = self.centerPage;
			self.centerPage = self.leftPage;
			self.leftPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView - 1]
													   frame:self.view.frame
													delegate:self
												  fileLoader:self.fileLoader];
			
		}
		
		[self animationCleanUp];
	} else {
		self.animateNextViewIn = nil;
	}
}

- (void)animateCenterViewOutToTheLeftDidStop {
	
	if (self.animateNextViewIn == nil) {
		
		//lets the view know that the animations have finished
		[self centerViewHasTransitionedOutToLeft];
		//[self.rightViewController viewHasTransitionedIn];
		//[self.centerViewController viewHasTransitionedOut];
		
		if (self.activeView == ([[self.pageArray objectAtIndex:kPageArray_File] count] - 2)) {
			//manage pointers so they represent what is on screen
			self.activeView++;
			[self.centerPage removeFromSuperview];
			[self.leftPage viewControllerWillBeReleased];
			self.leftPage = self.centerPage;
			self.centerPage = self.rightPage;
			self.rightPage = nil;
		} else {
			//manage pointers so they represent what is on screen
			self.activeView++;
			[self.centerPage removeFromSuperview];
			[self.leftPage viewControllerWillBeReleased];
			self.leftPage = self.centerPage;
			self.centerPage = self.rightPage;
			self.rightPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView + 1]
														frame:self.view.frame
													 delegate:self
												   fileLoader:self.fileLoader];
			
		}
		
		[self animationCleanUp];
	} else {
		self.animateCurrentViewOut = nil;
	}
}

- (void)animateRightViewInFromTheRightDidStop {
	
	if (self.animateCurrentViewOut == nil) {
		
		//lets the view know that the animations have finished
		[self centerViewHasTransitionedOutToLeft];
		//[self.rightViewController viewHasTransitionedIn];
		//[self.centerViewController viewHasTransitionedOut];
		
		if (self.activeView == ([[self.pageArray objectAtIndex:kPageArray_File] count] - 2)) {
			//manage pointers so they represent what is on screen
			self.activeView++;
			[self.centerPage removeFromSuperview];
			[self.leftPage viewControllerWillBeReleased];
			self.leftPage = self.centerPage;
			self.centerPage = self.rightPage;
			self.rightPage = nil;
		} else {
			//manage pointers so they represent what is on screen
			self.activeView++;
			[self.centerPage removeFromSuperview];
			[self.leftPage viewControllerWillBeReleased];
			self.leftPage = self.centerPage;
			self.centerPage = self.rightPage;
			self.rightPage = [[GTPage alloc] initWithFilename:self.pageArray[kPageArray_File][self.activeView + 1]
														frame:self.view.frame
													 delegate:self
												   fileLoader:self.fileLoader];
			
		}
		
		[self animationCleanUp];
	} else {
		self.animateNextViewIn = nil;
	}
}

- (void)animationCleanUp {
	
	if (self.secondLeftSwipeRegistered == NO) {
		self.firstLeftSwipeRegistered = NO;
		self.transitionAnimationDuration = NORMAL_TRANSITION_ANIMATION_DURATION;
	}
	self.secondLeftSwipeRegistered = NO;
	if (self.secondRightSwipeRegistered == NO) {
		self.firstRightSwipeRegistered = NO;
		self.transitionAnimationDuration = NORMAL_TRANSITION_ANIMATION_DURATION;
	}
	self.secondRightSwipeRegistered = NO;
	
	self.viewWillTransitionExecuted = NO;
	
	//tell the view controller that its view is being moved
	[self.leftPage setViewBeingMoved:NO];
	[self.centerPage setViewBeingMoved:NO];
	[self.rightPage setViewBeingMoved:NO];
	
	self.animating = 0;
	self.animateCurrentViewOut = nil;
	self.animateCurrentViewBackToCenter = nil;
	self.animateNextViewIn = nil;
	self.animateNextViewOut = nil;
}

#pragma mark -
#pragma mark Caching methods

- (void)centerViewHasTransitionedOutToLeft {
	
	[self.rightPage viewHasTransitionedIn];
	[self.centerPage viewHasTransitionedOut];
	
}

- (void)centerViewHasTransitionedOutToRight {
	
	[self.leftPage viewHasTransitionedIn];
	[self.centerPage viewHasTransitionedOut];
	
}
 
- (void)cacheImagesForPage:(GTPage *)pageToCache {
	
	[pageToCache cacheImages];
	
}

- (void)cacheImagesForButtonWithElement:(TBXMLElement *)button_el {
	
}

- (void)cacheImagesForPanelWithElement:(TBXMLElement *)panel_el {
	
}

-(void)switchTo:(NSString *)packageID language:(NSString *)language {
	
	if (language == nil) {
		language = self.language;
	}
	
	//change package
	self.package			= packageID;
	self.fileLoader.package = self.package;
	
	//set the active view to the start of the package
	self.activeView = 0;
	
	//change the language to the best match found in this package
    @try {
		
        [self changeLanguageTo:language];
		
    }
    @catch (NSException *exception) {
        
        //notify the user of the deletion
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something was wrong with the resource"
														message:@"Sorry - there was an error loading the current package."
													   delegate:nil
                                              cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		
    }
	
}


#pragma mark -
#pragma mark Mem Management Callbacks


-(NSMutableArray *)pageArrayFromDocumentElement:(TBXMLElement *)element {
	
	//NSLog(@"snuffyViewController - pageArrayFromDocumentElement: %@", [TBXML elementName:element]);
	TBXMLElement	*page_el	= [TBXML childElementNamed:kName_Page parentElement:element];
	TBXMLElement	*about_el	= [TBXML childElementNamed:kName_About parentElement:element];
	TBXMLElement	*package_el	= [TBXML childElementNamed:kName_Package parentElement:element];
	NSMutableArray	*pageArr	= [[NSMutableArray alloc] init];
	NSMutableArray	*fileArr	= [[NSMutableArray alloc] init];
	NSMutableArray	*thumbArr	= [[NSMutableArray alloc] init];
	NSMutableArray	*descArr	= [[NSMutableArray alloc] init];
	
	if (package_el != nil) {
		self.packageName = [TBXML textForElement:package_el];	//set the packagename
	}
	else {
		//NSLog(@"Warning: No packagename in %@.xml", [self language]);
		self.packageName = @"";	//default packagename if not in xml
	}

	
	while (page_el != nil) {
		
		[fileArr addObject:[TBXML valueOfAttributeNamed:kAttr_filename	//add filename
											 forElement:page_el]];
		[thumbArr addObject:[TBXML valueOfAttributeNamed:kAttr_thumb	//add thumb
											  forElement:page_el]];
		[descArr addObject:[TBXML textForElement:page_el]];				//add description
		
		//move to next page element
		page_el = [TBXML nextSiblingNamed:kName_Page searchFromElement:page_el];
	}
	
	[pageArr addObject:fileArr];
	[pageArr addObject:thumbArr];
	[pageArr addObject:descArr];
	
	//grab file name of about page
	
	self.aboutFilename = [TBXML valueOfAttributeNamed:kAttr_filename forElement:about_el];
	
	return pageArr;
}

- (void)changeLanguageTo:(NSString *)languageCode {
	
	//change language
	self.language = languageCode;
	self.fileLoader.language = self.language;
	
	//grab active index
	NSInteger currentIndex = self.activeView;
	
	//clear cache
	[self.fileLoader clearCache];
	[self.fileLoader cacheSharedImages];
	
	//init the xml
	TBXML *tempXml = [[TBXML alloc] initWithXMLPath:self.fileLoader.pathOfConfigFile];
	if (!tempXml.rootXMLElement) {
		[NSException raise:@"Could not read resource!" format:@"The resource XML document is empty.\nsnuffyViewController:\n   package=%@\n   language=%@\n   version=%@", self.package, self.language, self.version];
	}
	//load the new page array
	self.pageArray =  [self pageArrayFromDocumentElement:tempXml.rootXMLElement];
	
	//restore active index
	self.activeView = (NSInteger)fmin((double)[[[self pageArray] objectAtIndex:kPageArray_File] count] - 1, (double)currentIndex);
	
	[self navToolbarAddRemoveSwitchButtonForPackage:[self package] andLanguage:[self language]];
	
	//skip to active page
	[self skipTo:self.activeView];
	
}
 
- (void)changePackageTo:(NSString *)packageID {
	@try {
        [self switchTo:packageID language:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	//[self setUpViewController];
	
	//calculate the positions the views will have during animation
	self.inViewInCenterCenter = CGPointMake(self.view.frame.size.width / 2, self.view.center.y);
	self.outOfViewOnRightCenter = CGPointMake((3 * self.inViewInCenterCenter.x) + self.gapBetweenViews, self.inViewInCenterCenter.y);
	self.outOfViewOnLeftCenter = CGPointMake(-(self.inViewInCenterCenter.x) - self.gapBetweenViews, self.inViewInCenterCenter.y);
	
	self.centerPage.center	= self.inViewInCenterCenter;
	[self.view addSubview:self.centerPage];
	[self.centerPage viewHasTransitionedIn];
	
	//bring toolbars to front again now that more views have been added
	[self.view bringSubviewToFront:self.navToolbar];
	[self.view bringSubviewToFront:self.navToolbarButton];
	
	[self showNavToolbar];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	if (self.isFirstRunSinceCreation) {
	
		[self skipToIndex:self.activeView animated:YES];
		self.isFirstRunSinceCreation	= NO;
		
	}
	
	if (!self.aboutViewControllerWasShown) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GTViewControllerNotificationResourceDidOpen
															object:self
														  userInfo:@{GTViewControllerNotificationUserInfoLanguageKey:	self.language,
																	 GTViewControllerNotificationUserInfoPackageKey:	self.package,
																	 GTViewControllerNotificationUserInfoVersionKey:	self.version}];
		
	} else {
		
		self.aboutViewControllerWasShown = NO;
		
	}
	
	[self runInstructionsIfNecessary];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[self.fileLoader clearCache];
	[self.fileLoader cacheSharedImages];
	[self skipTo:self.activeView];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
	
	self.animateCurrentViewOut = nil;
	self.animateCurrentViewBackToCenter = nil;
	self.animateNextViewIn = nil;
	self.animateNextViewOut = nil;
}


- (void)dealloc {
	
	[self.fileLoader clearCache];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GTTPageMenuViewControllerSwitchPage object:_pageMenu];
	[self removeNotificationHandlers];
	
}

@end
