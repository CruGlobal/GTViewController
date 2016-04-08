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

@interface GTFollowupModalView : UIView

@property (strong, nonatomic) NSArray *listeners;

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView;

@end