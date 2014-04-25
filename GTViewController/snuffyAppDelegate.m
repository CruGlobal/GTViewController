//
//  snuffyAppDelegate.m
//  Snuffy
//
//  Created by Michael Harrison on 24/06/10.
//  Copyright CCCA 2010. All rights reserved.
//

#import "snuffyAppDelegate.h"
#import "snuffyViewController.h"
#import "GTTracker.h"

@implementation snuffyAppDelegate

@synthesize window			= _window;
@synthesize viewController	= _viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	//start tracking error, performance and analytics
	[[GTTracker sharedTracker] startTracking];
	
	snuffyViewController *tempViewController	= [snuffyViewController alloc];
	
	//calc frame for ViewController
	CGRect frame	= CGRectMake(self.window.frame.origin.x, self.window.frame.origin.y + [[UIApplication sharedApplication] statusBarFrame].size.height, self.window.frame.size.width, self.window.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height);
	[[tempViewController view] setFrame:frame];
	
    // Override point for customization after application launch.
    // Add the view controller's view to the window and display.
	self.viewController	= [tempViewController initWithNibName:[tempViewController nibNameForInit] bundle:nil];
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
	
	[tempViewController release];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	
	[self.viewController resetViews];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    self.viewController	= nil;
    self.window			= nil;
    [super dealloc];
}


@end
