//
//  GTViewController.h
//  GTViewController
//
//  Created by Michael Harrison on 4/25/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UserInfo Keys for all GTViewControllerNotification's these keys let you know what config file was loaded when the action occured
 */
extern NSString *const GTViewControllerNotificationUserInfoConfigFilenameKey;

/**
 *  Notification name for Opening a resource. Called on viewDidAppear
 *  (Note: will not be called if viewDidAppear happens after dismissing a child view controller.)
 */
extern NSString *const GTViewControllerNotificationResourceDidOpen;




@class GTFileLoader, GTShareViewController, GTPageMenuViewController, GTAboutViewController;
@protocol GTViewControllerMenuDelegate;




@interface GTViewController : UIViewController

/**
 *  Initaliser of GTViewController. Once initialised this class loads and provides navigation for a God Tools package.
 *
 *  Note: Don't use initWithNibName:bundle:
 *
 *  @param filename               filename of the configureation file of the resource you would like to display.
 *  @param fileLoader             object that can be asked for paths given a filename. It also caches images.
 *  @param shareViewController    A view controller that give the user options for sharing the current resource.
 *  @param pageMenuViewController A view controller that lets the user switch between pages.
 *  @param aboutViewController    A view controller that displays the about info for the current resource.
 *  @param delegate               usually the naviagation controller that pushed this object. The delegate should get it's menus (navigation/toolbars out of view when asked by this class.
 *
 *  @return the initialized self
 */
- (instancetype)initWithConfigFile:(NSString *)filename fileLoader:(GTFileLoader *)fileLoader shareViewController:(GTShareViewController *)shareViewController pageMenuViewController:(GTPageMenuViewController *)pageMenuViewController aboutViewController:(GTAboutViewController *)aboutViewController delegate:(id<GTViewControllerMenuDelegate>)delegate;

/**
 *  loads and parses the assets for a resource defined by the config file passed to this method.
 *
 *  @param filename filename of the configureation file of the resource you would like to display.
 */
- (void)loadResourceWithConfigFilename:(NSString *)filename;

/**
 *  loads and parses the assets for a resource defined by the config file passed to this method.
 *
 *  @param filename filename of the configuration file of the resource you would like to display.
 *  @param parallelConfigFileName filename of the configuration file of the resource from the parallel language. Must be nil if there are no parallel language
 *  @param isDraft boolean that determines if the resource is a draft
 */
- (void)loadResourceWithConfigFilename:(NSString *)filename parallelConfigFileName:(NSString *)parallelConfigFileName isDraft:(BOOL)isDraft;

/**
 *  Each God Tools resource has multiple pages. This lets you switch the current page to the page you would like.
 *  Just provide the page's index.
 *
 *  @param pageIndex if there are n pages in the resource pageIndex will be 0 to n-1. The page for the index you give will be shown.
 */
- (void)switchToPageWithIndex:(NSUInteger)pageIndex;

- (void)refreshView;

- (void)setCodes:(NSString *)packageCode :(NSString *)languageCode;

@end

@protocol GTViewControllerMenuDelegate <NSObject>
@optional
- (void)showToolbar;
- (void)hideToolbar;

@end