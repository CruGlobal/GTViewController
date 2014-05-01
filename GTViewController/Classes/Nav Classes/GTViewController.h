//
//  GTViewController.h
//  GTViewController
//
//  Created by Michael Harrison on 4/25/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTFileLoader;
@protocol snuffyViewControllerMenuDelegate;

@interface GTViewController : UIViewController

@property (nonatomic, weak) id<snuffyViewControllerMenuDelegate> menuDelegate;

- (instancetype)initWithFileLoader:(GTFileLoader *)fileLoader delegate:(id<snuffyViewControllerMenuDelegate>)delegate;
- (void)loadResourceWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (void)switchToPageWithIndex:(NSUInteger)pageIndex;

@end

@protocol snuffyViewControllerMenuDelegate <NSObject>
@optional
- (void)showToolbar;
- (void)hideToolbar;

@end