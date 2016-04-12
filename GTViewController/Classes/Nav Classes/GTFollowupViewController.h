//
//  GTFollowUpController.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTFollowupModalView.h"
#import "GTFollowupThankYouView.h"

@interface GTFollowupViewController : UIViewController

@property (strong,nonatomic) GTFollowupModalView *followupModalView;
@property (strong,nonatomic) GTFollowupThankYouView *followupThankYouView;

- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView;
- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView thankYouView:(GTFollowupThankYouView *)thankYouView;
- (void)transitionToThankYou;
@end
