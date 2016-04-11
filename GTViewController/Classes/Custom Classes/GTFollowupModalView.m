//
//  GTFollowupModalView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/7/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowupModalView.h"
#import "GTPage.h"
#import "GTPageInterpreter.h"
#import "GTLabel.h"
#import "UISnuffleButton.h"
#import "UIMultiButtonResponseView.h"

NSString * const kName_FollowUp_Title       = @"followup-title";
NSString * const kName_FollowUp_Body        = @"followup-body";
NSString * const kName_Input_Field          = @"input-field";
NSString * const kName_Input_Label          = @"input-label";
NSString * const kName_Input_Placeholder    = @"input-placheholder";
NSString * const kName_Thank_You            = @"thank-you";

@interface GTFollowupModalView()

@property (strong, nonatomic) GTPage *thankYouPage;

@end

@implementation GTFollowupModalView

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    self = [super initWithFrame:presentingView.frame];
    
    [self setBackgroundColor:style.backgroundColor];
    
    TBXMLElement *fallbackElement = element->firstChild;
    
    if (!fallbackElement) {
        
    } else {
        TBXMLElement *modalComponentElement = fallbackElement->firstChild;
        
        // first pass - vertical spacing
        int numLabels = 0;
        int numTextFields = 0;
        int numButtonPairs = 1; //assume 1 for now
        while(modalComponentElement != nil) {
            NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
            
            if ([modalComponentElementName isEqual:kName_FollowUp_Title] ||
                [modalComponentElementName isEqual:kName_FollowUp_Body]) {
                numLabels++;
            } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
                numTextFields++;
            }
            
            modalComponentElement = modalComponentElement->nextSibling;
        }
        
        int defaultVerticalSpacingToTop = 20;
        int currentY = defaultVerticalSpacingToTop;
        
        modalComponentElement = fallbackElement->firstChild;
        
        // first pass - building/rendering
        while(modalComponentElement != nil) {
            NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
            
            if ([modalComponentElementName isEqual:kName_FollowUp_Title]) {
                UILabel *titleLabel = [[GTLabel alloc]initFromElement:modalComponentElement
                                                  parentTextAlignment:UITextAlignmentCenter
                                                                 xPos:0
                                                                 yPos:currentY
                                                            container:presentingView
                                                                style:style];
                
                currentY += titleLabel.frame.size.height + 10;
                
                [self addSubview:titleLabel];
            } else if ([modalComponentElementName isEqual:kName_FollowUp_Body]) {
                UILabel *bodyLabel = [[GTLabel alloc]initFromElement:modalComponentElement
                                                 parentTextAlignment:UITextAlignmentCenter
                                                                xPos:0
                                                                yPos:currentY
                                                           container:presentingView
                                                               style:style];
                currentY += bodyLabel.frame.size.height + 10;
                
                [self addSubview:bodyLabel];
            } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
                UIView *inputFieldView = [self createInputFieldFromElement:modalComponentElement
                                                                     withY:currentY
                                                                 withStyle:style
                                                            presentingView:presentingView];
                
                currentY += inputFieldView.frame.size.height + 10;
                
                [self addSubview:inputFieldView];
            } else if ([modalComponentElementName isEqual:kName_Button_Pair]) {
                TBXMLElement *firstButtonElement = modalComponentElement->firstChild;
                TBXMLElement *secondButtonElement = firstButtonElement->nextSibling;
                
                UIMultiButtonResponseView *buttonPairView = nil;
                
                if([[TBXML elementName:firstButtonElement] isEqual:kName_Positive_Button]) {
                    
                    buttonPairView = [[UIMultiButtonResponseView alloc] initWithFirstElement:firstButtonElement
                                                                                secondElement:secondButtonElement
                                                                                    yPosition:currentY
                                                                                containerView:self];
                } else {
                    
                    buttonPairView = [[UIMultiButtonResponseView alloc] initWithFirstElement:secondButtonElement
                                                                               secondElement:firstButtonElement
                                                                                   yPosition:currentY
                                                                               containerView:self];                }
                
                [self addSubview:buttonPairView];

                currentY += buttonPairView.frame.size.height + 10;
                
            }else if ([modalComponentElementName isEqual:kName_Thank_You]) {
                self.thankYouPage = nil;
            }
            
            modalComponentElement = modalComponentElement->nextSibling;
        }
    }
    
    return self;
}


- (UIView*)createInputFieldFromElement:(TBXMLElement *)element withY:(CGFloat)yPos withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    
    UIView *inputFieldView = [[UIView alloc]init];
    UILabel *inputFieldLabel = [[UILabel alloc]init];
    UITextField *inputTextField = [[UITextField alloc]init];

    // format & configure view
    [inputFieldView setBackgroundColor:[UIColor clearColor]];
    [inputFieldView setFrame:CGRectMake(0, yPos, presentingView.frame.size.width, 70)];
    
    TBXMLElement *inputFieldChildElement = element->firstChild;
    
    while (inputFieldChildElement) {
        NSString *childElementName = [TBXML elementName:inputFieldChildElement];
        
        if ([childElementName isEqual:kName_Input_Label]) {
            [inputFieldLabel setFrame:CGRectMake(20, 0, inputFieldView.frame.size.width, 15)];
            [inputFieldLabel setTextColor: style.defaultTextColor];
            [inputFieldLabel setText:[TBXML textForElement:inputFieldChildElement]];
        } else if ([childElementName isEqual:kName_Input_Placeholder]) {
            //TODO fill in placeholder
        }
        
        inputFieldChildElement = inputFieldChildElement->nextSibling;
    }

    [inputTextField setFrame:CGRectMake(20, 20, inputFieldView.frame.size.width - 40, 25)];
    [inputTextField setTextColor:[UIColor darkTextColor]];
    [inputTextField setBackgroundColor:[UIColor whiteColor]];
    
    [inputFieldView addSubview:inputFieldLabel];
    [inputFieldView addSubview:inputTextField];
    
    return inputFieldView;
}


@end