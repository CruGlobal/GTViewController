//
//  AboutViewController.h
//  Snuffy
//
//  Created by Michael Harrison on 4/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTFileLoader.h"

@protocol AboutViewControllerDelegate;

@interface AboutViewController : UIViewController

@property (nonatomic, weak  ) IBOutlet UINavigationItem *navigationTitle;

- (instancetype)initWithFilename:(NSString *)file delegate:(id<AboutViewControllerDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader;

@end


@protocol AboutViewControllerDelegate <NSObject>

- (UIView *)viewOfPageViewController;

@optional
- (void)hideNavToolbar;

@end