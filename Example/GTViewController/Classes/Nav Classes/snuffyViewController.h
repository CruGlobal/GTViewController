//
//  snuffyViewController.h
//  Snuffy
//
//  Created by Michael Harrison on 24/06/10.
//  Copyright CCCA 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "HorizontalGestureRecognizer.h"
#import "TBXML.h"
#import "GTFileLoader.h"
#import "SnuffyRepo.h"
#import "Downloader.h"
#import "SNInstructions.h"
#import "GTPage.h"

@protocol snuffyViewControllerMenuDelegate;

@interface snuffyViewController : UIViewController <HorizontalGestureRecognizerDelegate, GTPageDelegate>

@property (nonatomic, weak)		IBOutlet UIButton	*navToolbarButton;
@property (nonatomic, weak)		IBOutlet UIToolbar *navToolbar;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *langButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem *aboutButton;
@property (nonatomic, strong)	UIBarButtonItem *switchButton;
@property (nonatomic, weak)		IBOutlet UIView *navView;
@property (nonatomic, weak)		IBOutlet UINavigationItem *navTitle;
@property (nonatomic, assign)	BOOL navToolbarIsShown;

@property (nonatomic, strong)	SNInstructions	*instructionPlayer;
@property (nonatomic, strong)	NSArray			*arrayFromPlist;

@property (nonatomic, assign)   BOOL setUpRun;

@property (nonatomic, strong)	GTFileLoader *fileLoader;
@property (nonatomic, strong)	AVAudioPlayer *AVPlayer;
@property (nonatomic, strong)	NSString *packageName;

@property (nonatomic, strong)	GTPage *leftLeftPage;
@property (nonatomic, strong)	GTPage *leftPage;
@property (nonatomic, strong)	GTPage *centerPage;
@property (nonatomic, strong)	GTPage *rightPage;
@property (nonatomic, strong)	GTPage *rightRightPage;
@property (nonatomic, strong)	NSArray *packageArray;
@property (nonatomic, strong)	NSMutableArray *languageArray;
@property (nonatomic, strong)	NSMutableArray *pageArray;
@property (nonatomic, strong)	NSArray *viewControllerArray;
@property (nonatomic, strong)	NSArray *viewControllerDisplayNameArray;
@property (nonatomic, strong)	NSArray *viewControllerThumbnailArray;
@property (nonatomic, strong)	NSString *activePackage;
@property (nonatomic, strong)	NSString *activeLanguage;
@property (nonatomic)			NSInteger activeView;
@property (nonatomic, strong)	NSString *aboutFilename;

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

@property (nonatomic, weak)		id<snuffyViewControllerMenuDelegate> menuDelegate;

@property (nonatomic, strong)   SnuffyRepo *snuffyRepo;
@property (nonatomic, strong)   SnuffyRepo *remoteRepo;
@property (nonatomic, strong)   SnuffyRepo *localRepo;

//returns the name of the nib file to be loaded by this view controller
- (NSString *)nibNameForInit;
//- (void)setUpViewController;

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
//- (void)cacheImagesFromBundle;
- (void)cacheImagesForPage:(GTPage *)pageToCache;
- (void)cacheImagesForButtonWithElement:(TBXMLElement *)button_el;
- (void)cacheImagesForPanelWithElement:(TBXMLElement *)panel_el;

//config functions
-(void)switchTo:(NSString *)packageID language:(NSString *)language;
- (NSString *)language;
- (NSString *)findLanguageAt:(NSInteger)index;
- (void)changeLanguageTo:(NSString *)languageCode;
- (NSString *)findBestLanguageForPackage:(NSString *)packageID;
- (NSString *)getLocationCode;
- (NSString *)package;
- (NSString *)findPackageAt:(NSInteger)index;
- (void)changePackageTo:(NSString *)packageID;
-(void)updateWithLocalRepo:(SnuffyRepo *)localRepo remoteRepo:(SnuffyRepo *)remoteRepo;
- (void)populateRepositories;
- (NSString *)pathOfPackageConfig;
- (NSMutableArray *)pageArrayFromDocumentElement:(TBXMLElement *)element;

@end

@protocol snuffyViewControllerMenuDelegate <NSObject>
@optional
- (void)showNavToolbar;
- (void)hideNavToolbar;

@end