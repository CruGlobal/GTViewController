//
//  GTPageMenuViewController.h
//  GTViewController
//
//  Created by Michael Harrison on 3/11/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const GTTPageMenuViewControllerSwitchPage;
extern NSString * const GTTPageMenuViewControllerPageNumber;

@interface GTPageMenuViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *pageArray;
@property (nonatomic, strong) NSString *package;
@property (nonatomic, strong) NSString *language;

@end
