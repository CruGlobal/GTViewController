//
//  GTFollowupModalView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/7/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowupModalView.h"
#import "GTFollowupThankYouView.h"
#import "GTPageInterpreter.h"
#import "GTLabel.h"
#import "UISnuffleButton.h"
#import "UIMultiButtonResponseView.h"

NSString * const kName_FollowUp_Title       = @"followup-title";
NSString * const kName_FollowUp_Body        = @"followup-body";
NSString * const kName_Input_Field          = @"input-field";
NSString * const kName_Input_Label          = @"input-label";
NSString * const kName_Input_Placeholder    = @"input-placeholder";
NSString * const kName_Thank_You            = @"thank-you";

@interface GTFollowupModalView()

@end

@implementation GTFollowupModalView

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView interpreterDelegate:(id<GTInterpreterDelegate>)interpreterDelegate {
    
    self = [super initWithFrame:presentingView.frame];
    
    [self setBackgroundColor:style.backgroundColor];
    
    TBXMLElement *fallbackElement = element->firstChild;
    
    if (!fallbackElement) {
        
    } else {
        TBXMLElement *modalComponentElement = fallbackElement->firstChild;
        
        int defaultVerticalSpacingToTop = 20;
        int currentY = defaultVerticalSpacingToTop;
        
        modalComponentElement = fallbackElement->firstChild;
        
        // first pass - building/rendering
        while(modalComponentElement != nil) {
            NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
            
            if ([modalComponentElementName isEqual:kName_FollowUp_Title]) {
                UILabel *titleLabel = [[GTLabel alloc]initFromElement:modalComponentElement
                                                  parentTextAlignment:UITextAlignmentCenter
                                                                 xPos:-1
                                                                 yPos:currentY
                                                            container:presentingView
                                                                style:style];
                
                currentY = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10;
                
                [self addSubview:titleLabel];
            } else if ([modalComponentElementName isEqual:kName_FollowUp_Body]) {
                UILabel *bodyLabel = [[GTLabel alloc]initFromElement:modalComponentElement
                                                 parentTextAlignment:UITextAlignmentLeft
                                                                xPos:-1
                                                                yPos:currentY
                                                           container:presentingView
                                                               style:style];
                currentY = bodyLabel.frame.origin.y + bodyLabel.frame.size.height + 10;
                
                [self addSubview:bodyLabel];
            } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
                UIView *inputFieldView = [self createInputFieldFromElement:modalComponentElement
                                                                     withY:currentY
                                                                 withStyle:style
                                                            presentingView:presentingView];
                
                currentY = inputFieldView.frame.origin.y + inputFieldView.frame.size.height + 10;
                
                [self addSubview:inputFieldView];
            } else if ([modalComponentElementName isEqual:kName_Button_Pair]) {
                TBXMLElement *firstButtonElement = modalComponentElement->firstChild;
                TBXMLElement *secondButtonElement = firstButtonElement->nextSibling;
                
                UIMultiButtonResponseView *buttonPairView = [[UIMultiButtonResponseView alloc] initWithFirstElement:firstButtonElement
                                                                                                      secondElement:secondButtonElement
                                                                                                      parentElement:modalComponentElement
                                                                                                          yPosition:currentY
                                                                                                      containerView:self
                                                                                                          withStyle:style];
                
                
                [self addSubview:buttonPairView];

                currentY += buttonPairView.frame.size.height + 10;
                
            } else if ([modalComponentElementName isEqual:kName_Thank_You]) {
                
                self.thankYouView = [[GTFollowupThankYouView alloc]initFromElement:modalComponentElement
                                                                         withFrame:self.frame
                                                                     withPageStyle:style];
                
                NSArray *listeners = [[TBXML valueOfAttributeNamed:kAttr_listeners forElement:modalComponentElement] componentsSeparatedByString:@","];
                
                for (id listener in listeners) {
                    NSString *listenerName = listener;
                    
                    if ([interpreterDelegate respondsToSelector:@selector(registerListenerWithEventName:target:selector:parameter:)]) {
                        [interpreterDelegate registerListenerWithEventName:listenerName
                                                                    target:interpreterDelegate
                                                                  selector:@selector(transitionFollowupToThankYou)
                                                                 parameter:nil];
                        
                    }
                }
            }
            
            modalComponentElement = modalComponentElement->nextSibling;
        }
    }
    
    return self;
}


- (void)setWatermark:(UIImageView *) watermarkImageView {

    [self addSubview:[self copyWatermark:watermarkImageView]];
    [self.thankYouView addSubview:[self copyWatermark:watermarkImageView]];
}


/* see: http://stackoverflow.com/questions/25439234/how-to-clone-a-uiimageview */
- (UIImageView *)copyWatermark:(UIImageView *)watermarkImageView {
    UIImageView *watermarkCopy = [[UIImageView alloc]initWithImage:watermarkImageView.image];
    
    watermarkCopy.frame = CGRectMake(0, 0, watermarkImageView.frame.size.width, watermarkImageView.frame.size.height);
    watermarkCopy.alpha = watermarkImageView.alpha;//same view opacity
    watermarkCopy.layer.opacity = watermarkImageView.layer.opacity;//same layer opacity
    watermarkCopy.clipsToBounds = watermarkImageView.clipsToBounds;//same clipping settings
    watermarkCopy.backgroundColor = watermarkImageView.backgroundColor;//same BG color

    return watermarkCopy;
}


- (UIView*)createInputFieldFromElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    
    UIView *inputFieldView = [[UIView alloc]init];
    GTLabel *inputFieldLabel = nil;
    UITextField *inputTextField = [[UITextField alloc]init];

    // format & configure view
    [inputFieldView setBackgroundColor:[UIColor clearColor]];
    if ([TBXML valueOfAttributeNamed:kAttr_yoff forElement:element]) {
        CGFloat yoffset = round([[TBXML valueOfAttributeNamed:kAttr_yoff forElement:element] floatValue]);
        [inputFieldView setFrame:CGRectMake(0, yPos + yoffset, presentingView.frame.size.width, 70)];
    } else {
        [inputFieldView setFrame:CGRectMake(0, yPos, presentingView.frame.size.width, 70)];
    }
    
    TBXMLElement *inputFieldChildElement = element->firstChild;
    
    while (inputFieldChildElement) {
        NSString *childElementName = [TBXML elementName:inputFieldChildElement];
        
        if ([childElementName isEqual:kName_Input_Label]) {
            inputFieldLabel = [[GTLabel alloc]initFromElement:inputFieldChildElement
                                         parentTextAlignment:UITextAlignmentLeft
                                                        xPos:0
                                                        yPos:0
                                                   container:inputFieldView
                                                       style:style];
            
        } else if ([childElementName isEqual:kName_Input_Placeholder]) {
            inputTextField.placeholder = [TBXML textForElement:inputFieldChildElement];
        }
        
        inputFieldChildElement = inputFieldChildElement->nextSibling;
    }

    [inputTextField setFrame:CGRectMake(10, 20, inputFieldView.frame.size.width - 40, 25)];
    [inputTextField setTextColor:[UIColor darkTextColor]];
    [inputTextField setBackgroundColor:[UIColor whiteColor]];
    [inputTextField setReturnKeyType:UIReturnKeyDone];
    inputTextField.delegate = self;
    
    if ([[TBXML valueOfAttributeNamed:@"type" forElement:element] isEqual:@"email"]) {
        inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
        inputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    } else if([[TBXML valueOfAttributeNamed:@"type" forElement:element] isEqual:@"text"]) {
        inputTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    
    [inputFieldView addSubview:inputFieldLabel];
    [inputFieldView addSubview:inputTextField];
    
    return inputFieldView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end