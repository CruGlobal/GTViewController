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

NSString *const GTFollowupViewControllerFieldSubscriptionNotificationName       = @"org.cru.godtools.GTFollowupModalView.followupSubscriptionNotificationName";
NSString *const GTFollowupViewControllerFieldSubscriptionEventName              = @"followup:subscribe";
NSString *const GTFollowupViewControllerFieldKeyEmail                           = @"org.cru.godtools.GTFollowupModalView.fieldKeyEmail";
NSString *const GTFollowupViewControllerFieldKeyName                            = @"org.cru.godtools.GTFollowupModalView.fieldKeyName";
NSString *const GTFollowupViewControllerFieldKeyFollowupId                      = @"org.cru.godtools.GTFollowupModalView.fieldKeyFollowupId";

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendFollowupSubscribeListener:)
                                                 name:UISnuffleButtonNotificationButtonTapEvent
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
@end