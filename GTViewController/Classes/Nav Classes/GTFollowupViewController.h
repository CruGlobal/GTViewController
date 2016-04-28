//
//  GTFollowUpController.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const GTFollowupViewControllerFieldSubscriptionNotificationName;
extern NSString *const GTFollowupViewControllerFieldSubscriptionEventName;
extern NSString *const GTFollowupViewControllerFieldKeyEmail;
extern NSString *const GTFollowupViewControllerFieldKeyName;
extern NSString *const GTFollowupViewControllerFieldKeyFollowupId;

@class GTFollowupModalView, GTFollowupThankYouView;

@interface GTFollowupViewController : UIViewController<UITextFieldDelegate>

@property (strong,nonatomic) GTFollowupModalView *followupModalView;
@property (strong,nonatomic) GTFollowupThankYouView *followupThankYouView;

- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView;
- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView thankYouView:(GTFollowupThankYouView *)thankYouView;
- (void)transitionToThankYou;
@end
