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

NSString *const GTFollowupViewControllerParameterName_Name                      = @"name";
NSString *const GTFollowupViewControllerParameterName_Email                     = @"email";
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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


- (void)setFollowupView:(GTFollowupModalView *)followupModalView {
    self.followupModalView = followupModalView;
    self.followupThankYouView = followupModalView.thankYouView;
    [self.view insertSubview:self.followupModalView atIndex:0];
    [self.view insertSubview:self.followupThankYouView belowSubview:self.followupModalView];
    self.originalHeight = followupModalView.frame.size.height;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        inputFieldView.inputTextField.delegate = self;
    }];
    
    return;
}


- (void)setFollowupView:(GTFollowupModalView *)followupModalView andThankYouView:(GTFollowupThankYouView *)thankYouView {
    self.followupModalView = followupModalView;
    self.followupThankYouView = thankYouView;
    self.view = followupModalView;
    self.originalHeight = followupModalView.frame.size.height;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        inputFieldView.inputTextField.delegate = self;
    }];
    
    return;
}


- (void)transitionToThankYou {
    [self.view addSubview:self.followupThankYouView];
    
    [UIView animateWithDuration:2.0 animations:^{
        [self.view bringSubviewToFront:self.followupThankYouView];
    }];
}


- (void) sendFollowupSubscribeListener {
    
    __block NSMutableDictionary *followupDetailsDictionary = [[NSMutableDictionary alloc]init];
    [followupDetailsDictionary setValue:self.followupModalView.followupId forKey:GTFollowupViewControllerFieldKeyFollowupId];
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        
        if ([inputFieldView.parameterName isEqualToString:GTFollowupViewControllerParameterName_Name] && inputFieldView.inputFieldValue) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyName];
        } else if ([inputFieldView.parameterName isEqualToString:GTFollowupViewControllerParameterName_Email] && inputFieldView.inputFieldValue) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyEmail];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTFollowupViewControllerFieldSubscriptionNotificationName
                                                        object:nil
                                                      userInfo:followupDetailsDictionary];
}


#pragma mark - Animation methods to prevent text field from being hidden

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
    unobscuredByKeyboardFrame.size.height -= CGRectGetHeight(keyboardFrame);
    
    // offset the height of the inputFieldView, b/c it is a label stacked on an input
    // if just the frame is considered, then the label could show while the input is hidden
    unobscuredByKeyboardFrame.size.height -= CGRectGetHeight(inputFieldViewFrame);
    
    if (CGRectContainsPoint(unobscuredByKeyboardFrame, inputFieldViewFrame.origin) ) {
        return;
    }

    CGFloat viewVerticalDelta = (CGRectGetMinY(inputFieldViewFrame) + CGRectGetHeight(inputFieldViewFrame)) - CGRectGetHeight(unobscuredByKeyboardFrame);
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


- (void) resetViewPosition:(NSNotification *)notification {
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
    return CGRectGetMinY(nextField.frame) - CGRectGetMinY(currentField.frame);
    
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    if (![textField.superview.superview viewWithTag:textField.tag + 1]) {
        [textField setReturnKeyType:UIReturnKeyDone];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


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


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


#pragma mark - UISnuffleButtonTapDelegate methods

- (void)didReceiveTapOnPositiveButton:(UISnuffleButton *)positiveButton {    
    NSArray *inputValidationErrors = [self inputValidationErrors];
    
    if ([positiveButton validation] && [inputValidationErrors count]) {
        [[[UIAlertView alloc] initWithTitle:@"Please correct these fields:"
                                    message:[inputValidationErrors componentsJoinedByString:@"\n"]
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        return;
    }
    
    [positiveButton.tapEvents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tapEvent = obj;
        tapEvent = tapEvent ? [tapEvent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
       
        if ([tapEvent isEqualToString:GTFollowupViewControllerFieldSubscriptionEventName]) {
            [self sendFollowupSubscribeListener];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:UISnuffleButtonNotificationButtonTapEvent
                                                                object:self
                                                              userInfo:@{UISnuffleButtonNotificationButtonTapEventKeyEventName: tapEvent}];
        }
    }];
}

- (CGRect)pageFrame {
    return self.followupModalView.frame;
}

- (UIView *)viewOfPageViewController {
    return self.followupModalView;
}

- (NSArray *)inputValidationErrors {
    __block NSMutableArray *validationErrors = @[].mutableCopy;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        
        if (![inputFieldView isValid]) {
            [validationErrors addObject:[inputFieldView validationMessage]];
        }
    }];
    
    return validationErrors;
}

@end