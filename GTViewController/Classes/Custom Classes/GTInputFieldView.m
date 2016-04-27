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

@interface GTInputFieldView ()

@property (strong, nonatomic) NSString              *inputFieldType;
@end

@implementation GTInputFieldView


- (instancetype)inputFieldWithElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    
    GTLabel *inputFieldLabel = nil;
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
            inputFieldLabel = [[GTLabel alloc]initWithElement:inputFieldChildElement
                                          parentTextAlignment:UITextAlignmentLeft
                                                         xPos:0
                                                         yPos:0
                                                    container:self
                                                        style:style];
            
            [inputFieldLabel setFrame:CGRectMake(0,0,w,DEFAULT_HEIGHT_INPUTFIELDLABEL)];
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

    [self.inputTextField setFrame:CGRectMake(0, inputFieldLabel.frame.size.height, w, h)];
    [self.inputTextField setTextColor:[UIColor darkTextColor]];
    [self.inputTextField setBackgroundColor:[UIColor whiteColor]];
    [self.inputTextField setReturnKeyType:UIReturnKeyNext];
    
    [inputFieldView setFrame:CGRectMake(x, y, w, self.inputTextField.frame.size.height + inputFieldLabel.frame.size.height)];
    
    [inputFieldView addSubview:inputFieldLabel];
    [inputFieldView addSubview:self.inputTextField];
    
    return self;
}


- (NSString *)inputFieldValue {
    return self.inputTextField.text;
}

@end