 //
//  UIMultiButtonResponseView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/6/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIMultiButtonResponseView.h"
#import "GTFileLoader.h"
#import "GTPageInterpreter.h"

@implementation UIMultiButtonResponseView


- (instancetype) initWithFirstElement:(TBXMLElement *)firstElement secondElement:(TBXMLElement *)secondElement yPosition:(CGFloat)y containerView:(UIView *)container withStyle:(GTPageStyle *) pageStyle{
    TBXMLElement *positiveElement                  = nil;
    TBXMLElement *negativeElement                  = nil;
    
    if ([[TBXML elementName:firstElement] isEqual:kName_Positive_Button]) {
        positiveElement = firstElement;
        negativeElement = secondElement;
    } else {
        positiveElement = secondElement;
        negativeElement = firstElement;
    }
    
    UIMultiButtonResponseView *responseView = [super initWithFrame:CGRectMake(0, y, container.frame.size.width, 70)];
    
    float buttonWidth = responseView.frame.size.width / 2.5 ;
    
    UISnuffleButton *negativeButton = [[UISnuffleButton alloc] createButtonFromElement:negativeElement
                                                                                addTag:0
                                                                                  yPos:0
                                                                             container:responseView
                                                                             withStyle:pageStyle
                                                                     buttonTapDelegate:nil];
    
    // override frame to get "inline buttons"
    [negativeButton setFrame:CGRectMake(10,
                                        0,
                                        buttonWidth,
                                        50)];
    
    UISnuffleButton *positiveButton = [[UISnuffleButton alloc] createButtonFromElement:positiveElement
                                                                                addTag:0
                                                                                  yPos:0
                                                                             container:responseView
                                                                             withStyle:pageStyle
                                                                     buttonTapDelegate:nil];
    
    // override frame to get "inline buttons"
    [positiveButton setFrame:CGRectMake(responseView.frame.size.width - 10 - buttonWidth,
                                        0,
                                        buttonWidth,
                                        50)];
    
    [responseView addSubview:negativeButton];
    [responseView addSubview:positiveButton];
    
    return responseView;
}

@end