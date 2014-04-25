//
//  snuffyAppDelegate.h
//  Snuffy
//
//  Created by Michael Harrison on 24/06/10.
//  Copyright CCCA 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@class snuffyViewController;

@interface snuffyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*_window;
    snuffyViewController *_viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) snuffyViewController *viewController;

@end

