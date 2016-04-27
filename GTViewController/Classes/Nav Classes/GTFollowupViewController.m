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

@property (weak, nonatomic)         UITextField *activeField;
@property (assign, nonatomic)       CGFloat originalHeight;

@end

@implementation GTFollowupViewController


- (id)initWithFollowupView:(GTFollowupModalView *)followupModalView {
    if (self) {
        self = [super init];
        self.followupModalView = followupModalView;
        self.followupThankYouView = followupModalView.thankYouView;
        [self.view insertSubview:self.followupModalView atIndex:0];
        [self.view insertSubview:self.followupThankYouView belowSubview:self.followupModalView];
        self.originalHeight = followupModalView.frame.size.height;
        
        [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GTInputFieldView *inputFieldView = obj;
            inputFieldView.inputTextField.delegate = self;
        }];
        
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
        self.originalHeight = followupModalView.frame.size.height;
        
        [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GTInputFieldView *inputFieldView = obj;
            inputFieldView.inputTextField.delegate = self;
        }];
        
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

-(void)keyboardWillShow:(NSNotification *) notification {
    if (self.view.frame.origin.y < 0) {
        return;
    }
    
    [self moveView:notification];
}

-(void)keyboardWillHide:(NSNotification *) notification {
    
    if (self.view.frame.origin.y >= 0) {
        return;
    }
    
    [self resetViewPosition:notification];
}


//method to move the view up when the keyboard would cover the "active" textField
-(void)moveView:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    CGRect inputFieldViewFrame = self.activeField.superview.frame;
    
    CGRect unobscuredByKeyboardFrame = self.view.frame;
    unobscuredByKeyboardFrame.size.height -= keyboardFrame.size.height;
    
    // offset the height of the inputFieldView, b/c it is a label stacked on an input
    // if just the frame is considered, then the label could show while the input is hidden
    unobscuredByKeyboardFrame.size.height -= inputFieldViewFrame.size.height;
    
    if (CGRectContainsPoint(unobscuredByKeyboardFrame, inputFieldViewFrame.origin) ) {
        return;
    }

    CGFloat viewVerticalDelta = (inputFieldViewFrame.origin.y + inputFieldViewFrame.size.height) - unobscuredByKeyboardFrame.size.height;
    UIViewAnimationCurve animationCurve;
    NSTimeInterval animationDuration;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    [self animateViewWithVerticalDelta:viewVerticalDelta
                     animationDuration:animationDuration
                        animationCurve:animationCurve];
}


- (void) animateViewWithVerticalDelta:(CGFloat)verticalDelta animationDuration:(NSTimeInterval) animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
    // Get animation info from userInfo
    CGRect newViewFrame = self.view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    newViewFrame.origin.y -= verticalDelta;
    newViewFrame.size.height += verticalDelta;
    self.view.frame = newViewFrame;
    
    [UIView commitAnimations];
}


- (void) resetViewPosition:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect myFrame = self.view.frame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    myFrame.origin.y = 0;
    myFrame.size.height = self.originalHeight;
    
    self.view.frame = myFrame;
    
    [UIView commitAnimations];
}

- (CGFloat)calculateVerticalDeltaFromCurrentField:(UIView *)currentField toNextField:(UIView *)nextField {
    return nextField.frame.origin.y - currentField.frame.origin.y;
    
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder *nextResponder = [textField.superview.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        UITextField *nextActiveField = (UITextField*)nextResponder;
        
        CGFloat verticalDelta = [self calculateVerticalDeltaFromCurrentField:self.activeField.superview
                                                                 toNextField:nextActiveField.superview];
        
        self.activeField = nextActiveField;
        
        [self animateViewWithVerticalDelta:verticalDelta animationDuration:0.3 animationCurve:UIViewAnimationCurveEaseOut];
        
        if (![nextActiveField.superview.superview viewWithTag:++nextTag]) {
            [nextActiveField setReturnKeyType:UIReturnKeyDone];
        }
        
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

@end