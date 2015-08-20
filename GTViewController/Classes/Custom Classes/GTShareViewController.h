//
//  GTShareViewController.h
//  GTViewController
//
//  Created by Michael Harrison on 5/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTShareViewController : UIActivityViewController

- (instancetype)initWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (void)setPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;

@end
