//
//  GTFollowUpViewController.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowUpViewController.h"

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

- (void)transitionToThankYou {
    [self.view addSubview:self.followupThankYouView];
    
    [UIView animateWithDuration:2.0 animations:^{
        [self.view bringSubviewToFront:self.followupThankYouView];
    }];
}
@end