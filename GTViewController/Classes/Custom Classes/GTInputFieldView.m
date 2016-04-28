//
//  GTTextField.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/13/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBXML.h"

#import "GTPageInterpreter.h"
#import "GTInputFieldView.h"
#import "GTLabel.h"

NSString const *emailRegEx =
@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

@interface GTInputFieldView ()

@property (strong, nonatomic) UILabel               *inputFieldLabel;
@property (strong, nonatomic) NSString              *inputFieldType;
@property (strong, nonatomic) NSRegularExpression   *validationRegex;

@end

@implementation GTInputFieldView


- (instancetype)inputFieldWithElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    
    self.inputTextField = [[UITextField alloc]init];
    
    // format & configure view
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGFloat x                   = round([[TBXML valueOfAttributeNamed:kAttr_x forElement:element] floatValue]);;
    CGFloat y                   = round([[TBXML valueOfAttributeNamed:kAttr_y forElement:element] floatValue]);;
    CGFloat h                   = round([[TBXML valueOfAttributeNamed:kAttr_height forElement:element] floatValue]);
    CGFloat w                   = round([[TBXML valueOfAttributeNamed:kAttr_width forElement:element] floatValue]);;
    CGFloat xoffset             = round([[TBXML valueOfAttributeNamed:kAttr_xoff forElement:element] floatValue]);;
    CGFloat yoffset             = round([[TBXML valueOfAttributeNamed:kAttr_yoff forElement:element] floatValue]);
    CGFloat xTrailingOffset     = round([[TBXML valueOfAttributeNamed:kAttr_xTrailingOff forElement:element] floatValue]);;
    
    if (!x) {
        x = 0;
    }
    
    x += xoffset;
    
    if (!y) {
        y = yPos;
    }
    
    y += yoffset;
    
    if (!h) {
        h = DEFAULT_HEIGHT_INPUTFIELD;
    }
    
    if (xoffset && xTrailingOffset) {
        w = presentingView.frame.size.width - xoffset - xTrailingOffset;
    } else if (!w) {
        w = presentingView.frame.size.width;
    }
    
    GTInputFieldView *inputFieldView = [self initWithFrame:CGRectMake(x, y, w, h)];
    
    TBXMLElement *inputFieldChildElement = element->firstChild;
    
    while (inputFieldChildElement) {
        NSString *childElementName = [TBXML elementName:inputFieldChildElement];
        
        if ([childElementName isEqual:kName_Input_Label]) {
            self.inputFieldLabel = [[GTLabel alloc]initWithElement:inputFieldChildElement
                                          parentTextAlignment:UITextAlignmentLeft
                                                         xPos:0
                                                         yPos:0
                                                    container:self
                                                        style:style];
            
            [self.inputFieldLabel setFrame:CGRectMake(0,0,w,DEFAULT_HEIGHT_INPUTFIELDLABEL)];
        } else if ([childElementName isEqual:kName_Input_Placeholder]) {
            self.inputTextField.placeholder = [TBXML textForElement:inputFieldChildElement];
        }
        
        inputFieldChildElement = inputFieldChildElement->nextSibling;
    }
    
    if ([[TBXML valueOfAttributeNamed:kAttr_type forElement:element] isEqual:@"email"]) {
        self.inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.inputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.inputFieldType = @"email";
    } else if([[TBXML valueOfAttributeNamed:kAttr_type forElement:element] isEqual:@"text"]) {
        self.inputTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.inputFieldType = @"name";
    }

    if ([TBXML valueOfAttributeNamed:@"valid-format" forElement:element]) {
       self.validationRegex = [[NSRegularExpression alloc] initWithPattern:[TBXML valueOfAttributeNamed:@"valid-format" forElement:element]
                                                                   options:NSRegularExpressionCaseInsensitive
                                                                     error:nil];
    }
    
    [self.inputTextField setFrame:CGRectMake(0, self.inputFieldLabel.frame.size.height, w, h)];
    [self.inputTextField setTextColor:[UIColor darkTextColor]];
    [self.inputTextField setBackgroundColor:[UIColor whiteColor]];
    [self.inputTextField setReturnKeyType:UIReturnKeyNext];
    
    [inputFieldView setFrame:CGRectMake(x, y, w, self.inputTextField.frame.size.height + self.inputFieldLabel.frame.size.height)];
    
    [inputFieldView addSubview:self.inputFieldLabel];
    [inputFieldView addSubview:self.inputTextField];
    
    return self;
}


- (NSString *)inputFieldValue {
    return self.inputTextField.text;
}


- (BOOL)isValid {
    if ([[self inputFieldType] isEqualToString:@"email"]) {
        return [self isValidEmail];
    }
    
    if (!self.validationRegex) {
        return true;
    }
    
    return [self.validationRegex numberOfMatchesInString:[self inputFieldValue]
                                                 options:0
                                                   range:NSMakeRange(0, [[self inputFieldValue] length])];
}

- (BOOL)isValidEmail {
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:self.inputFieldValue];
}

- (NSString *) validationMessage {
    if (![[self inputFieldValue] length]) {
        return [NSString stringWithFormat:@"%@ was empty.", self.inputFieldLabel.text];
    } else {
        return [NSString stringWithFormat:@"%@ was not properly formatted.", self.inputFieldLabel.text];
    }
}
@end