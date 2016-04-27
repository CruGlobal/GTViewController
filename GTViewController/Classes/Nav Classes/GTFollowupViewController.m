//
//  GTFollowUpViewController.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowUpViewController.h"

#import "GTInputFieldView.h"
#import "GTFollowupModalView.h"
#import "GTFollowupThankYouView.h"

NSString *const GTFollowupViewControllerFieldSubscriptionNotificationName       = @"org.cru.godtools.GTFollowupModalView.followupSubscriptionNotificationName";
NSString *const GTFollowupViewControllerFieldSubscriptionEventName              = @"followup:subscribe";
NSString *const GTFollowupViewControllerFieldKeyEmail                           = @"org.cru.godtools.GTFollowupModalView.fieldKeyEmail";
NSString *const GTFollowupViewControllerFieldKeyName                            = @"org.cru.godtools.GTFollowupModalView.fieldKeyName";
NSString *const GTFollowupViewControllerFieldKeyFollowupId                      = @"org.cru.godtools.GTFollowupModalView.fieldKeyFollowupId";

@interface GTFollowupViewController ()

@property (strong, nonatomic) NSNumber *keyboardIsShowing;

@end

@implementation GTFollowupViewController


- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView {
    if (self) {
        self = [super init];
        self.followupModalView = followupModalView;
        self.followupThankYouView = followupModalView.thankYouView;
        [self.view insertSubview:self.followupModalView atIndex:0];
        [self.view insertSubview:self.followupThankYouView belowSubview:self.followupModalView];
        return self;
    }
    
    return nil;
}


- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView thankYouView:(GTFollowupThankYouView *)thankYouView {
    if (self) {
        self = [super init];
        self.followupModalView = followupModalView;
        self.followupThankYouView = thankYouView;
        self.view = followupModalView;
        
        return self;
    }
    
    return nil;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.keyboardIsShowing = @NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendFollowupSubscribeListener:)
                                                 name:UISnuffleButtonNotificationButtonTapEvent
                                               object:nil];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UISnuffleButtonNotificationButtonTapEvent
                                                  object:nil];
}


- (void) sendFollowupSubscribeListener:(NSNotification *)notification {
    if (![notification.userInfo[UISnuffleButtonNotificationButtonTapEventKeyEventName] isEqualToString:GTFollowupViewControllerFieldSubscriptionEventName]) {
        return;
    }
    
    __block NSMutableDictionary *followupDetailsDictionary = [[NSMutableDictionary alloc]init];
    [followupDetailsDictionary setValue:self.followupModalView.followupId forKey:GTFollowupViewControllerFieldKeyFollowupId];
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        
        if ([[inputFieldView inputFieldType] isEqualToString:@"name"] && inputFieldView.inputFieldValue) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyName];
        } else if ([[inputFieldView inputFieldType] isEqualToString:@"email"]) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyEmail];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTFollowupViewControllerFieldSubscriptionNotificationName
                                                        object:nil
                                                      userInfo:followupDetailsDictionary];
}


- (void)transitionToThankYou {
    [self.view addSubview:self.followupThankYouView];
    
    [UIView animateWithDuration:2.0 animations:^{
        [self.view bringSubviewToFront:self.followupThankYouView];
    }];
}


#pragma mark Animation methods to prevent text field from being hidden
// logic adapted from from: http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present
-(void)keyboardWillShow:(NSNotification *) notification {
    if ([self.keyboardIsShowing boolValue] || self.view.frame.origin.y < 0) {
        return;
    }
    
    [self setViewMovedUp:YES notification:notification];
    self.keyboardIsShowing = @YES;
}

-(void)keyboardWillHide:(NSNotification *) notification {
    if (![self.keyboardIsShowing boolValue] || self.view.frame.origin.y >= 0) {
        return;
    }
    
    [self setViewMovedUp:NO notification:notification];
    self.keyboardIsShowing = @NO;
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp notification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardEndFrame;

    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newViewFrame = self.view.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newViewFrame.origin.y -= keyboardFrame.size.height * (movedUp ? 1 : -1);
    newViewFrame.size.height += keyboardFrame.size.height * (movedUp ? 1 : -1);
    self.view.frame = newViewFrame;
    
    [UIView commitAnimations];
}


@end