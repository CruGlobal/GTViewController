//
//  GTInputField.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/13/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#include <UIKit/UIKit.h>

@interface GTInputFieldView : UIView<UITextFieldDelegate>

- (instancetype)createInputFieldFromElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView;

@end
