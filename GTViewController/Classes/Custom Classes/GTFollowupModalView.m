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
        
        while(modalComponentElement != nil) {
            NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
            
            if ([modalComponentElementName isEqual:kName_FollowUp_Title]) {
                UILabel *titleLabel = [self createTitleLabelFromElement:modalComponentElement
                                                              withStyle:style
                                                         presentingView:presentingView];
                
                [self addSubview:titleLabel];
            } else if ([modalComponentElementName isEqual:kName_FollowUp_Body]) {
                UILabel *bodyLabel = [self createBodyLabelFromElement:modalComponentElement
                                                            withStyle:style
                                                       presentingView:presentingView];
                
                [self addSubview:bodyLabel];
            } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
                UIView *inputFieldView = [self createInputFieldFromElement:modalComponentElement
                                                                 withStyle:style
                                                            presentingView:presentingView];
                
                [self addSubview:inputFieldView];
            } else if ([modalComponentElementName isEqual:kName_Thank_You]) {
                self.thankYouPage = nil;
            }
            
            modalComponentElement = modalComponentElement->nextSibling;
        }
    }
    
    return self;
}


- (UILabel*)createTitleLabelFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    UILabel *titleLabel = [[UILabel alloc]init];
    
    [titleLabel setFrame:CGRectMake(20, 20, self.frame.size.width - 20, 40)];
    [titleLabel setText:[TBXML textForElement:element]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[style defaultTextColor]];
    [titleLabel setNumberOfLines:0];
    
    return titleLabel;
}


- (UILabel*)createBodyLabelFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    UILabel *bodyLabel = [[UILabel alloc]init];
    
    [bodyLabel setFrame:CGRectMake(20, 120, self.frame.size.width - 20, 40)];
    [bodyLabel setText:[TBXML textForElement:element]];
    [bodyLabel setTextAlignment:NSTextAlignmentCenter];
    [bodyLabel setTextColor:[style defaultTextColor]];
    [bodyLabel setNumberOfLines:0];
    
    return bodyLabel;
}


- (UIView*)createInputFieldFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView {
    
    UIView *inputFieldView = [[UIView alloc]init];
    UILabel *inputFieldLabel = [[UILabel alloc]init];
    UITextField *inputTextField = [[UITextField alloc]init];

    // format & configure view
    [inputFieldView setBackgroundColor:[UIColor clearColor]];
    [inputFieldView setFrame:CGRectMake(20, 220, self.frame.size.width - 20, 60)];

    
    TBXMLElement *inputFieldChildElement = element->firstChild;
    
    while (inputFieldChildElement) {
        NSString *childElementName = [TBXML elementName:inputFieldChildElement];
        
        if ([childElementName isEqual:kName_Input_Label]) {
            [inputFieldLabel setFrame:CGRectMake(20, 0, self.frame.size.width - 20, 15)];
            [inputFieldLabel setTextColor: style.defaultTextColor];
            [inputFieldLabel setText:[TBXML textForElement:inputFieldChildElement]];
        } else if ([childElementName isEqual:kName_Input_Placeholder]) {
            //TODO fill in placeholder
        }
        
        inputFieldChildElement = inputFieldChildElement->nextSibling;
    }

    [inputTextField setFrame:CGRectMake(20, 50, self.frame.size.width - 20, 40)];
    [inputTextField setTextColor:[UIColor darkTextColor]];

    [inputFieldView addSubview:inputFieldLabel];
    [inputFieldView addSubview:inputTextField];
    
    return inputFieldView;
}


@end