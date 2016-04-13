//
//  GTFollowupModalView.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/7/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#include <UIKit/UIKit.h>
#include "TBXML.h"

#include "GTPageStyle.h"
#include "GTPageInterpreter.h"
#import "GTFollowupThankYouView.h"

@interface GTFollowupModalView : UIView<UITextFieldDelegate>

@property (strong, nonatomic) NSArray *listeners;
@property (strong, nonatomic) GTFollowupThankYouView *thankYouView;

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView interpreterDelegate:(id<GTInterpreterDelegate>)interpreterDelegate;

@end