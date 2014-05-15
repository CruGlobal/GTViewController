//
//  UISnuffleButton.h
//  Snuffy
//
//  Created by Michael Harrison on 23/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISnuffleButtonTapDelegate;

@interface UISnuffleButton : UIButton

@property (nonatomic, weak  ) id<UISnuffleButtonTapDelegate> tapDelegate;
@property (nonatomic, strong) NSString			*mode;
@property (nonatomic, strong) NSString			*urlTarget;

-(instancetype)initWithFrame:(CGRect)frame tapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate;
-(void)reset;

@end

@protocol UISnuffleButtonTapDelegate <NSObject>

- (CGRect)pageFrame;
- (UIView *)viewOfPageViewController;

@optional
- (void)didReceiveTapOnURLButton:(UISnuffleButton *)urlButton;
- (void)didReceiveTapOnPhoneButton:(UISnuffleButton *)phoneButton;
- (void)didReceiveTapOnEmailButton:(UISnuffleButton *)emailButton;
- (void)didReceiveTapOnAllURLButton:(UISnuffleButton *)allURLButton;
- (void)didReceiveTapOnButton:(UISnuffleButton *)button;

@end