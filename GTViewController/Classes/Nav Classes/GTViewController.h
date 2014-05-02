//
//  GTViewController.h
//  GTViewController
//
//  Created by Michael Harrison on 4/25/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UserInfo Keys for all GTViewControllerNotification's these keys let you know what language, package, version combo
 *  were loaded when the action occured
 */
extern NSString *const GTViewControllerNotificationUserInfoLanguageKey;
extern NSString *const GTViewControllerNotificationUserInfoPackageKey;
extern NSString *const GTViewControllerNotificationUserInfoVersionKey;

/**
 *  Notification name for Opening a resource. Called on viewDidAppear
 */
extern NSString *const GTViewControllerNotificationResourceDidOpen;

/**
 *  Notification name for Sharing a resource. Called after a successful share.
 */
extern NSString *const GTViewControllerNotificationUserDidShareResource;




@class GTFileLoader;
@protocol GTViewControllerMenuDelegate;




@interface GTViewController : UIViewController

/**
 *  Initaliser of GTViewController. Once initialised this class loads and provides navigation for a God Tools package.
 *  
 *  Note: Don't use initWithNibName:bundle:
 *
 *  @param packageCode   unique string that identifies the package you would like
 *  @param languageCode  unique string that identifies the langue you would like the package in
 *  @param versionNumber NSNumber that represents the version of the package langauge combo
 *  @param delegate      usually the naviagation controller that pushed this object. The delegate should get it's menus (navigation/toolbars out of view when asked by this class.
 *
 *  @return the initialized self
 */
- (instancetype)initWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode versionNumber:(NSNumber *)versionNumber delegate:(id<GTViewControllerMenuDelegate>)delegate;

/**
 *  loads and parses the assets for a resource with the package code, language code and version number provided.
 *
 *  @param packageCode   unique string that identifies the package you would like
 *  @param languageCode  unique string that identifies the langue you would like the package in
 *  @param versionNumber NSNumber that represents the version of the package langauge combo
 */
- (void)loadResourceWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode versionNumber:(NSNumber *)versionNumber;

/**
 *  Each God Tools resource has multiple pages. This lets you switch the current page to the page you would like.
 *  Just provide the page's index.
 *
 *  @param pageIndex if there are n pages in the resource pageIndex will be 0 to n-1. The page for the index you give will be shown.
 */
- (void)switchToPageWithIndex:(NSUInteger)pageIndex;

@end

@protocol GTViewControllerMenuDelegate <NSObject>
@optional
- (void)showToolbar;
- (void)hideToolbar;

@end