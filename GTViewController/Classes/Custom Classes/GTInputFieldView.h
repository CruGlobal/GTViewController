//
//  GTInputField.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/13/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"

@class GTPageStyle;

@interface GTInputFieldView : UIView<UITextFieldDelegate>

- (instancetype)createInputFieldFromElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView;

- (NSString *)inputFieldType;
- (NSString *)inputFieldValue;

@end
